BEGIN;

DROP SCHEMA IF EXISTS f1_analytics CASCADE;
CREATE SCHEMA f1_analytics;
SET search_path TO f1_analytics;

CREATE TABLE constructors (
    constructor_id SMALLINT PRIMARY KEY,
    constructor_code VARCHAR(20) NOT NULL UNIQUE,
    constructor_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE drivers (
    driver_id SMALLINT PRIMARY KEY,
    driver_code CHAR(3) NOT NULL UNIQUE,
    permanent_number SMALLINT NOT NULL UNIQUE CHECK (permanent_number BETWEEN 1 AND 99),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    nationality VARCHAR(50) NOT NULL
);

CREATE TABLE races (
    race_id INTEGER PRIMARY KEY,
    season SMALLINT NOT NULL CHECK (season >= 1950),
    round_number SMALLINT NOT NULL CHECK (round_number > 0),
    race_name VARCHAR(100) NOT NULL,
    race_date DATE NOT NULL,
    circuit_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    scheduled_laps SMALLINT NOT NULL CHECK (scheduled_laps > 0),
    distance_km NUMERIC(7,3) NOT NULL CHECK (distance_km > 0),
    UNIQUE (season, round_number)
);

CREATE TABLE data_sources (
    source_id SMALLINT PRIMARY KEY,
    source_name VARCHAR(120) NOT NULL,
    source_type VARCHAR(30) NOT NULL CHECK (source_type IN ('OFFICIAL', 'CROSS_CHECK')),
    source_url TEXT NOT NULL UNIQUE,
    accessed_on DATE NOT NULL
);

CREATE TABLE race_data_sources (
    race_id INTEGER NOT NULL REFERENCES races (race_id),
    source_id SMALLINT NOT NULL REFERENCES data_sources (source_id),
    data_scope VARCHAR(80) NOT NULL,
    PRIMARY KEY (race_id, source_id, data_scope)
);

CREATE TABLE race_results (
    race_id INTEGER NOT NULL REFERENCES races (race_id),
    driver_id SMALLINT NOT NULL REFERENCES drivers (driver_id),
    constructor_id SMALLINT NOT NULL REFERENCES constructors (constructor_id),
    start_type VARCHAR(20) NOT NULL CHECK (start_type IN ('GRID', 'PIT_LANE')),
    grid_position SMALLINT CHECK (grid_position BETWEEN 1 AND 20),
    finish_position SMALLINT NOT NULL CHECK (finish_position BETWEEN 1 AND 20),
    laps_completed SMALLINT NOT NULL CHECK (laps_completed BETWEEN 0 AND 100),
    result_status VARCHAR(20) NOT NULL
        CHECK (result_status IN ('FINISHED', 'LAPPED', 'RETIRED', 'DID_NOT_START')),
    elapsed_time_ms INTEGER CHECK (elapsed_time_ms >= 0),
    gap_to_winner_ms INTEGER CHECK (gap_to_winner_ms >= 0),
    championship_points NUMERIC(4,1) NOT NULL DEFAULT 0 CHECK (championship_points >= 0),
    fastest_lap_number SMALLINT CHECK (fastest_lap_number BETWEEN 1 AND 100),
    fastest_lap_ms INTEGER CHECK (fastest_lap_ms > 0),
    fastest_lap_speed_kph NUMERIC(6,3) CHECK (fastest_lap_speed_kph > 0),
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (race_id, driver_id),
    UNIQUE (race_id, finish_position),
    CHECK (
        (start_type = 'GRID' AND grid_position IS NOT NULL)
        OR (start_type = 'PIT_LANE' AND grid_position IS NULL)
    ),
    CHECK (
        (fastest_lap_ms IS NULL AND fastest_lap_number IS NULL)
        OR (fastest_lap_ms IS NOT NULL AND fastest_lap_number IS NOT NULL)
    )
);

CREATE TABLE pit_stop_summaries (
    race_id INTEGER NOT NULL,
    driver_id SMALLINT NOT NULL,
    stop_count SMALLINT NOT NULL CHECK (stop_count BETWEEN 0 AND 10),
    total_pit_time_ms INTEGER CHECK (total_pit_time_ms >= 0),
    PRIMARY KEY (race_id, driver_id),
    FOREIGN KEY (race_id, driver_id)
        REFERENCES race_results (race_id, driver_id),
    CHECK (
        (stop_count = 0 AND total_pit_time_ms IS NULL)
        OR (stop_count > 0 AND total_pit_time_ms IS NOT NULL)
    )
);

CREATE INDEX idx_race_results_constructor
    ON race_results (race_id, constructor_id);

CREATE INDEX idx_race_results_finish
    ON race_results (race_id, finish_position);

CREATE INDEX idx_race_results_fastest_lap
    ON race_results (race_id, fastest_lap_ms)
    WHERE fastest_lap_ms IS NOT NULL;

COMMIT;
