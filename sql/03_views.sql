BEGIN;

SET search_path TO f1_analytics;

CREATE OR REPLACE VIEW vw_driver_race_performance AS
SELECT
    r.season,
    r.round_number,
    r.race_name,
    r.race_date,
    d.driver_code,
    CONCAT(d.first_name, ' ', d.last_name) AS driver_name,
    c.constructor_code,
    c.constructor_name,
    rr.start_type,
    rr.grid_position,
    rr.finish_position,
    CASE
        WHEN rr.start_type = 'GRID'
            THEN rr.grid_position - rr.finish_position
    END AS positions_gained,
    rr.laps_completed,
    ROUND(100.0 * rr.laps_completed / r.scheduled_laps, 1) AS completion_pct,
    rr.result_status,
    rr.championship_points,
    rr.fastest_lap_number,
    ROUND(rr.fastest_lap_ms / 1000.0, 3) AS fastest_lap_seconds,
    rr.fastest_lap_speed_kph,
    ps.stop_count,
    ROUND(ps.total_pit_time_ms / 1000.0, 3) AS total_pit_seconds,
    ROUND(ps.total_pit_time_ms / NULLIF(ps.stop_count, 0) / 1000.0, 3)
        AS average_stop_seconds
FROM race_results AS rr
JOIN races AS r
    ON r.race_id = rr.race_id
JOIN drivers AS d
    ON d.driver_id = rr.driver_id
JOIN constructors AS c
    ON c.constructor_id = rr.constructor_id
LEFT JOIN pit_stop_summaries AS ps
    ON ps.race_id = rr.race_id
   AND ps.driver_id = rr.driver_id;

CREATE OR REPLACE VIEW vw_constructor_race_summary AS
WITH constructor_totals AS (
    SELECT
        rr.race_id,
        rr.constructor_id,
        SUM(rr.championship_points) AS team_points,
        SUM(rr.laps_completed) AS team_laps,
        MIN(rr.finish_position) AS best_finish,
        COUNT(*) FILTER (WHERE rr.finish_position <= 3) AS podiums,
        COUNT(*) FILTER (WHERE rr.result_status IN ('RETIRED', 'DID_NOT_START')) AS non_finishes,
        SUM(ps.stop_count) AS total_stops,
        SUM(ps.total_pit_time_ms) AS total_pit_time_ms
    FROM race_results AS rr
    LEFT JOIN pit_stop_summaries AS ps
        ON ps.race_id = rr.race_id
       AND ps.driver_id = rr.driver_id
    GROUP BY rr.race_id, rr.constructor_id
)
SELECT
    r.season,
    r.round_number,
    r.race_name,
    c.constructor_code,
    c.constructor_name,
    ct.team_points,
    DENSE_RANK() OVER (
        PARTITION BY ct.race_id
        ORDER BY ct.team_points DESC, ct.best_finish
    ) AS points_rank,
    ct.best_finish,
    ct.podiums,
    ct.team_laps,
    ct.non_finishes,
    ct.total_stops,
    ROUND(ct.total_pit_time_ms / 1000.0, 3) AS total_pit_seconds
FROM constructor_totals AS ct
JOIN races AS r
    ON r.race_id = ct.race_id
JOIN constructors AS c
    ON c.constructor_id = ct.constructor_id;

-- A flat, BI-friendly export: one row per driver/race with readable labels
-- and pre-calculated operational fields. Power BI can import this view while
-- the normalized tables remain the governed source of truth.
CREATE OR REPLACE VIEW vw_power_bi_race_export AS
SELECT
    p.*,
    MIN(p.fastest_lap_seconds) OVER (
        PARTITION BY p.season, p.round_number
    ) AS race_fastest_lap_seconds,
    ROUND(
        p.fastest_lap_seconds
        - MIN(p.fastest_lap_seconds) OVER (
            PARTITION BY p.season, p.round_number
        ),
        3
    ) AS fastest_lap_gap_seconds,
    AVG(p.finish_position) OVER (
        PARTITION BY p.season, p.round_number, p.constructor_code
    ) AS constructor_average_finish
FROM vw_driver_race_performance AS p;

COMMIT;
