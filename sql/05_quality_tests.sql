SET search_path TO f1_analytics;

DO $$
DECLARE
    actual_count INTEGER;
    actual_text TEXT;
    actual_number NUMERIC;
BEGIN
    SELECT COUNT(*) INTO actual_count
    FROM race_results
    WHERE race_id = 202412;

    IF actual_count <> 20 THEN
        RAISE EXCEPTION 'Expected 20 race results, found %', actual_count;
    END IF;

    SELECT COUNT(DISTINCT finish_position) INTO actual_count
    FROM race_results
    WHERE race_id = 202412;

    IF actual_count <> 20 THEN
        RAISE EXCEPTION 'Finishing positions are incomplete or duplicated';
    END IF;

    SELECT d.driver_code INTO actual_text
    FROM race_results AS rr
    JOIN drivers AS d ON d.driver_id = rr.driver_id
    WHERE rr.race_id = 202412
      AND rr.finish_position = 1;

    IF actual_text <> 'HAM' THEN
        RAISE EXCEPTION 'Expected HAM as winner, found %', actual_text;
    END IF;

    SELECT d.driver_code INTO actual_text
    FROM race_results AS rr
    JOIN drivers AS d ON d.driver_id = rr.driver_id
    WHERE rr.race_id = 202412
    ORDER BY rr.fastest_lap_ms NULLS LAST
    LIMIT 1;

    IF actual_text <> 'SAI' THEN
        RAISE EXCEPTION 'Expected SAI to hold fastest lap, found %', actual_text;
    END IF;

    SELECT SUM(championship_points) INTO actual_number
    FROM race_results
    WHERE race_id = 202412;

    IF actual_number <> 102.0 THEN
        RAISE EXCEPTION 'Expected 102 total points including fastest-lap bonus, found %', actual_number;
    END IF;

    SELECT SUM(rr.championship_points) INTO actual_number
    FROM race_results AS rr
    JOIN constructors AS c ON c.constructor_id = rr.constructor_id
    WHERE rr.race_id = 202412
      AND c.constructor_code = 'MCLAREN';

    IF actual_number <> 27.0 THEN
        RAISE EXCEPTION 'Expected McLaren to score 27 points, found %', actual_number;
    END IF;

    SELECT COUNT(*) INTO actual_count
    FROM race_results AS rr
    LEFT JOIN pit_stop_summaries AS ps
        ON ps.race_id = rr.race_id
       AND ps.driver_id = rr.driver_id
    WHERE rr.race_id = 202412
      AND ps.driver_id IS NULL;

    IF actual_count <> 0 THEN
        RAISE EXCEPTION 'Found % race results without a pit-stop summary', actual_count;
    END IF;

    RAISE NOTICE 'All Formula 1 SQL quality tests passed';
END
$$;
