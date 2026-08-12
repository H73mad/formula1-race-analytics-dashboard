SET search_path TO f1_analytics;

-- ================================================================
-- 1. FINAL CLASSIFICATION
-- Skills: INNER JOIN, LEFT JOIN, aliases and formatting.
-- Question: What was the final order and the core performance record?
-- ================================================================
SELECT
    finish_position,
    driver_name,
    constructor_name,
    grid_position,
    start_type,
    positions_gained,
    laps_completed,
    result_status,
    championship_points
FROM vw_driver_race_performance
ORDER BY finish_position;

-- ================================================================
-- 2. GRID-TO-FINISH MOVEMENT
-- Skills: CASE, filtering and NULL-safe modelling.
-- Question: Which drivers gained or lost the most positions?
-- Pit-lane starters and a DNS are excluded because a normal grid-to-finish
-- comparison would be misleading.
-- ================================================================
SELECT
    driver_name,
    constructor_name,
    grid_position,
    finish_position,
    positions_gained,
    CASE
        WHEN positions_gained > 0 THEN 'GAINED'
        WHEN positions_gained < 0 THEN 'LOST'
        ELSE 'HELD'
    END AS movement_direction
FROM vw_driver_race_performance
WHERE start_type = 'GRID'
  AND result_status <> 'DID_NOT_START'
ORDER BY positions_gained DESC, finish_position;

-- ================================================================
-- 3. CONSTRUCTOR SCOREBOARD
-- Skills: CTE, aggregation, conditional aggregation and DENSE_RANK.
-- Question: Which team delivered the strongest combined result?
-- ================================================================
WITH team_results AS (
    SELECT
        constructor_name,
        SUM(championship_points) AS points,
        MIN(finish_position) AS best_finish,
        SUM(laps_completed) AS laps_completed,
        COUNT(*) FILTER (WHERE finish_position <= 10) AS points_finishes
    FROM vw_driver_race_performance
    GROUP BY constructor_name
)
SELECT
    DENSE_RANK() OVER (ORDER BY points DESC, best_finish) AS team_rank,
    constructor_name,
    points,
    best_finish,
    points_finishes,
    laps_completed
FROM team_results
ORDER BY team_rank, constructor_name;

-- ================================================================
-- 4. TEAMMATE BENCHMARK
-- Skills: window AVG, MIN and MAX.
-- Question: How did each driver compare with the other car in the same team?
-- ================================================================
SELECT
    constructor_name,
    driver_name,
    finish_position,
    championship_points,
    ROUND(AVG(finish_position) OVER (
        PARTITION BY constructor_code
    ), 1) AS team_average_finish,
    MIN(finish_position) OVER (
        PARTITION BY constructor_code
    ) AS team_best_finish,
    MAX(finish_position) OVER (
        PARTITION BY constructor_code
    ) AS team_worst_finish,
    ROUND(
        AVG(finish_position) OVER (PARTITION BY constructor_code)
        - finish_position,
        1
    ) AS positions_vs_team_average
FROM vw_driver_race_performance
ORDER BY constructor_name, finish_position;

-- ================================================================
-- 5. FASTEST-LAP BENCHMARK
-- Skills: MIN window function, PERCENT_RANK and derived measures.
-- Question: How far was each driver's best lap from the race benchmark?
-- ================================================================
SELECT
    driver_name,
    constructor_name,
    fastest_lap_seconds,
    ROUND(
        fastest_lap_seconds
        - MIN(fastest_lap_seconds) OVER (),
        3
    ) AS gap_to_fastest_seconds,
    ROUND(
        (100 * PERCENT_RANK() OVER (ORDER BY fastest_lap_seconds))::NUMERIC,
        1
    ) AS pace_percentile_from_front
FROM vw_driver_race_performance
WHERE fastest_lap_seconds IS NOT NULL
ORDER BY fastest_lap_seconds;

-- ================================================================
-- 6. PIT-STOP EFFICIENCY
-- Skills: NULLIF, calculated fields and multi-column ordering.
-- Question: Which drivers spent the least time per recorded stop?
-- This compares total FIA pit-lane time per stop, not stationary tyre-change
-- time alone, so it should not be labelled as a mechanic-only metric.
-- ================================================================
SELECT
    driver_name,
    constructor_name,
    stop_count,
    total_pit_seconds,
    average_stop_seconds,
    finish_position
FROM vw_driver_race_performance
WHERE stop_count > 0
ORDER BY average_stop_seconds, finish_position;

-- ================================================================
-- 7. PERFORMANCE AGAINST TEAM BASELINE
-- Skills: nested CTEs and window functions.
-- Question: Who most outperformed their team's average finishing position?
-- Positive values mean the driver finished ahead of the team average.
-- ================================================================
WITH driver_baselines AS (
    SELECT
        driver_name,
        constructor_name,
        finish_position,
        AVG(finish_position) OVER (
            PARTITION BY constructor_code
        ) AS team_average_finish
    FROM vw_driver_race_performance
)
SELECT
    driver_name,
    constructor_name,
    finish_position,
    ROUND(team_average_finish, 1) AS team_average_finish,
    ROUND(team_average_finish - finish_position, 1) AS outperformance_positions
FROM driver_baselines
ORDER BY outperformance_positions DESC, finish_position;

-- ================================================================
-- 8. CUMULATIVE POINTS CONTRIBUTION
-- Skills: running total with an ordered window frame.
-- Question: How quickly were the race's points accumulated down the order?
-- ================================================================
SELECT
    finish_position,
    driver_name,
    championship_points,
    SUM(championship_points) OVER (
        ORDER BY finish_position
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_points,
    ROUND(
        100 * SUM(championship_points) OVER (
            ORDER BY finish_position
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(championship_points) OVER (),
        1
    ) AS cumulative_points_pct
FROM vw_driver_race_performance
ORDER BY finish_position;

-- ================================================================
-- 9. COMPLETION AND RELIABILITY SUMMARY
-- Skills: FILTER, COUNT, AVG and percentage calculations.
-- Question: How reliable was the field at this event?
-- ================================================================
SELECT
    COUNT(*) AS entrants,
    COUNT(*) FILTER (WHERE result_status = 'FINISHED') AS lead_lap_finishers,
    COUNT(*) FILTER (WHERE result_status = 'LAPPED') AS lapped_finishers,
    COUNT(*) FILTER (WHERE result_status = 'RETIRED') AS retirements,
    COUNT(*) FILTER (WHERE result_status = 'DID_NOT_START') AS did_not_start,
    ROUND(AVG(completion_pct), 1) AS average_completion_pct
FROM vw_driver_race_performance;

-- ================================================================
-- 10. EXPLAINABLE STRATEGY-EFFICIENCY INDEX
-- Skills: multi-stage CTE, normalization and weighted calculation.
-- Question: Who combined finish, grid movement and pit efficiency best?
-- This is a transparent portfolio metric, not an official F1 statistic.
-- Weights: 50% finish quality, 25% position gain, 25% pit efficiency.
-- ================================================================
WITH eligible AS (
    SELECT *
    FROM vw_driver_race_performance
    WHERE start_type = 'GRID'
      AND result_status IN ('FINISHED', 'LAPPED')
      AND average_stop_seconds IS NOT NULL
), normalized AS (
    SELECT
        *,
        100.0 * (20 - finish_position) / 19 AS finish_score,
        100.0 * (
            positions_gained - MIN(positions_gained) OVER ()
        ) / NULLIF(
            MAX(positions_gained) OVER () - MIN(positions_gained) OVER (),
            0
        ) AS movement_score,
        100.0 * (
            MAX(average_stop_seconds) OVER () - average_stop_seconds
        ) / NULLIF(
            MAX(average_stop_seconds) OVER () - MIN(average_stop_seconds) OVER (),
            0
        ) AS pit_score
    FROM eligible
)
SELECT
    driver_name,
    constructor_name,
    finish_position,
    positions_gained,
    average_stop_seconds,
    ROUND(
        0.50 * finish_score
        + 0.25 * movement_score
        + 0.25 * pit_score,
        1
    ) AS strategy_efficiency_index
FROM normalized
ORDER BY strategy_efficiency_index DESC;

-- ================================================================
-- 11. DATA-QUALITY CHECKS
-- Skills: UNION ALL, validation rules and exception reporting.
-- Question: Are required facts complete and relational keys unique?
-- Every issue_count should return zero for this seed dataset.
-- ================================================================
SELECT 'duplicate driver/race keys' AS quality_rule,
       COUNT(*) AS issue_count
FROM (
    SELECT race_id, driver_id
    FROM race_results
    GROUP BY race_id, driver_id
    HAVING COUNT(*) > 1
) AS duplicates
UNION ALL
SELECT 'missing fastest lap for starter', COUNT(*)
FROM race_results
WHERE result_status <> 'DID_NOT_START'
  AND fastest_lap_ms IS NULL
UNION ALL
SELECT 'missing pit summary', COUNT(*)
FROM race_results AS rr
LEFT JOIN pit_stop_summaries AS ps
    ON ps.race_id = rr.race_id
   AND ps.driver_id = rr.driver_id
WHERE ps.driver_id IS NULL
UNION ALL
SELECT 'invalid lead-lap gap', COUNT(*)
FROM race_results
WHERE result_status = 'FINISHED'
  AND gap_to_winner_ms IS NULL;

-- ================================================================
-- 12. BI EXPORT PREVIEW
-- Skills: governed analytical view and consumer-ready selection.
-- Question: What table would be handed to Power BI for this event?
-- ================================================================
SELECT *
FROM vw_power_bi_race_export
ORDER BY finish_position;
