BEGIN;

SET search_path TO f1_analytics;

INSERT INTO constructors (constructor_id, constructor_code, constructor_name) VALUES
    (1,  'MERCEDES',     'Mercedes-AMG PETRONAS F1 Team'),
    (2,  'RED_BULL',     'Oracle Red Bull Racing'),
    (3,  'MCLAREN',      'McLaren Formula 1 Team'),
    (4,  'FERRARI',      'Scuderia Ferrari'),
    (5,  'HAAS',         'MoneyGram Haas F1 Team'),
    (6,  'ASTON_MARTIN', 'Aston Martin Aramco F1 Team'),
    (7,  'WILLIAMS',     'Williams Racing'),
    (8,  'RB',           'Visa Cash App RB F1 Team'),
    (9,  'SAUBER',       'Stake F1 Team Kick Sauber'),
    (10, 'ALPINE',       'BWT Alpine F1 Team');

INSERT INTO drivers (
    driver_id, driver_code, permanent_number, first_name, last_name, nationality
) VALUES
    (1,  'HAM', 44, 'Lewis',     'Hamilton',    'British'),
    (2,  'VER',  1, 'Max',       'Verstappen',  'Dutch'),
    (3,  'NOR',  4, 'Lando',     'Norris',      'British'),
    (4,  'PIA', 81, 'Oscar',     'Piastri',     'Australian'),
    (5,  'SAI', 55, 'Carlos',    'Sainz',       'Spanish'),
    (6,  'HUL', 27, 'Nico',      'Hulkenberg',  'German'),
    (7,  'STR', 18, 'Lance',     'Stroll',      'Canadian'),
    (8,  'ALO', 14, 'Fernando',  'Alonso',      'Spanish'),
    (9,  'ALB', 23, 'Alexander', 'Albon',       'Thai'),
    (10, 'TSU', 22, 'Yuki',      'Tsunoda',     'Japanese'),
    (11, 'SAR',  2, 'Logan',     'Sargeant',    'American'),
    (12, 'MAG', 20, 'Kevin',     'Magnussen',   'Danish'),
    (13, 'RIC',  3, 'Daniel',    'Ricciardo',   'Australian'),
    (14, 'LEC', 16, 'Charles',   'Leclerc',     'Monegasque'),
    (15, 'BOT', 77, 'Valtteri',  'Bottas',      'Finnish'),
    (16, 'OCO', 31, 'Esteban',   'Ocon',        'French'),
    (17, 'PER', 11, 'Sergio',    'Perez',       'Mexican'),
    (18, 'ZHO', 24, 'Guanyu',    'Zhou',        'Chinese'),
    (19, 'RUS', 63, 'George',    'Russell',     'British'),
    (20, 'GAS', 10, 'Pierre',    'Gasly',       'French');

INSERT INTO races (
    race_id, season, round_number, race_name, race_date,
    circuit_name, country, scheduled_laps, distance_km
) VALUES (
    202412, 2024, 12, 'British Grand Prix', DATE '2024-07-07',
    'Silverstone Circuit', 'United Kingdom', 52, 306.198
);

INSERT INTO data_sources (
    source_id, source_name, source_type, source_url, accessed_on
) VALUES
    (
        1,
        'FIA 2024 British Grand Prix race classification',
        'OFFICIAL',
        'https://www.fia.com/events/fia-formula-one-world-championship/season-2024/british-grand-prix/race-classification',
        DATE '2026-08-12'
    ),
    (
        2,
        'FIA 2024 British Grand Prix official grid',
        'OFFICIAL',
        'https://www.fia.com/events/fia-formula-one-world-championship/season-2024/british-grand-prix/qualifying-classification',
        DATE '2026-08-12'
    ),
    (
        3,
        'Formula 1 2024 British Grand Prix starting grid',
        'OFFICIAL',
        'https://www.formula1.com/en/results/2024/races/1240/britain/starting-grid',
        DATE '2026-08-12'
    ),
    (
        4,
        'BBC Sport 2024 British Grand Prix results',
        'CROSS_CHECK',
        'https://www.bbc.co.uk/sport/formula1/2024/british-grand-prix/results',
        DATE '2026-08-12'
    );

INSERT INTO race_data_sources (race_id, source_id, data_scope) VALUES
    (202412, 1, 'classification, fastest laps and pit-stop summary'),
    (202412, 2, 'official grid classification'),
    (202412, 3, 'grid penalties and pit-lane start note'),
    (202412, 4, 'grid, pit count, fastest lap and points cross-check');

-- elapsed_time_ms records the FIA classified elapsed time, not an invented
-- lap-by-lap estimate. gap_to_winner_ms is only populated for cars on the
-- lead lap because a millisecond gap is not comparable for lapped cars.
INSERT INTO race_results (
    race_id, driver_id, constructor_id, start_type, grid_position,
    finish_position, laps_completed, result_status, elapsed_time_ms,
    gap_to_winner_ms, championship_points, fastest_lap_number,
    fastest_lap_ms, fastest_lap_speed_kph
) VALUES
    (202412,  1,  1, 'GRID',      2,  1, 52, 'FINISHED',      4947059,     0, 25.0, 45, 89438, 237.120),
    (202412,  2,  2, 'GRID',      4,  2, 52, 'FINISHED',      4948524,  1465, 18.0, 48, 88952, 238.416),
    (202412,  3,  3, 'GRID',      3,  3, 52, 'FINISHED',      4954606,  7547, 15.0, 43, 89262, 237.588),
    (202412,  4,  3, 'GRID',      5,  4, 52, 'FINISHED',      4959488, 12429, 12.0, 51, 88748, 238.964),
    (202412,  5,  4, 'GRID',      7,  5, 52, 'FINISHED',      4994377, 47318, 11.0, 52, 88293, 240.195),
    (202412,  6,  5, 'GRID',      6,  6, 52, 'FINISHED',      5002781, 55722,  8.0, 43, 89836, 236.070),
    (202412,  7,  6, 'GRID',      8,  7, 52, 'FINISHED',      5003628, 56569,  6.0, 46, 89897, 235.909),
    (202412,  8,  6, 'GRID',     10,  8, 52, 'FINISHED',      5010636, 63577,  4.0, 47, 89710, 236.401),
    (202412,  9,  7, 'GRID',      9,  9, 52, 'FINISHED',      5015446, 68387,  2.0, 52, 89718, 236.380),
    (202412, 10,  8, 'GRID',     13, 10, 52, 'FINISHED',      5026362, 79303,  1.0, 43, 90229, 235.041),
    (202412, 11,  7, 'GRID',     12, 11, 52, 'FINISHED',      5036019, 88960,  0.0, 42, 89972, 235.713),
    (202412, 12,  5, 'GRID',     17, 12, 52, 'FINISHED',      5037212, 90153,  0.0, 42, 90093, 235.396),
    (202412, 13,  8, 'GRID',     15, 13, 51, 'LAPPED',        4956996,  NULL,  0.0, 47, 90735, 233.731),
    (202412, 14,  4, 'GRID',     11, 14, 51, 'LAPPED',        4987532,  NULL,  0.0, 43, 89748, 236.301),
    (202412, 15,  9, 'GRID',     16, 15, 51, 'LAPPED',        4988880,  NULL,  0.0, 44, 91277, 232.343),
    (202412, 16, 10, 'GRID',     18, 16, 50, 'LAPPED',        4957741,  NULL,  0.0, 46, 90875, 233.371),
    (202412, 17,  2, 'PIT_LANE', NULL, 17, 50, 'LAPPED',      4965064,  NULL,  0.0, 50, 89707, 236.409),
    (202412, 18,  9, 'GRID',     14, 18, 50, 'LAPPED',        5001535,  NULL,  0.0, 43, 91014, 233.014),
    (202412, 19,  1, 'GRID',      1, 19, 33, 'RETIRED',       3171677,  NULL,  0.0,  3, 91298, 232.289),
    (202412, 20, 10, 'GRID',     20, 20,  0, 'DID_NOT_START',    NULL,  NULL,  0.0, NULL,  NULL,    NULL);

INSERT INTO pit_stop_summaries (
    race_id, driver_id, stop_count, total_pit_time_ms
) VALUES
    (202412,  1, 2,  58967),
    (202412,  2, 2,  57441),
    (202412,  3, 2,  59048),
    (202412,  4, 2,  58741),
    (202412,  5, 3,  87002),
    (202412,  6, 2,  59677),
    (202412,  7, 2,  58492),
    (202412,  8, 2,  59027),
    (202412,  9, 2,  64152),
    (202412, 10, 2,  59658),
    (202412, 11, 2,  62245),
    (202412, 12, 2,  60192),
    (202412, 13, 2,  58748),
    (202412, 14, 3,  86880),
    (202412, 15, 2,  62155),
    (202412, 16, 4, 115146),
    (202412, 17, 4, 118875),
    (202412, 18, 4, 121224),
    (202412, 19, 1,  32045),
    (202412, 20, 0,   NULL);

COMMIT;
