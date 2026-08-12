\set ON_ERROR_STOP on

-- Run from the repository root with:
-- psql -d f1_analytics -f sql/00_run_all.sql
\ir 01_schema.sql
\ir 02_seed_british_gp.sql
\ir 03_views.sql
\ir 05_quality_tests.sql

\echo 'F1 analytics database created successfully.'
\echo 'Quality tests passed. Run sql/04_analysis.sql to explore the business questions.'
