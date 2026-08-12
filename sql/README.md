# Formula 1 SQL analytics layer

This folder turns the 2024 British Grand Prix into a small, reproducible PostgreSQL analytics project. It complements the Power BI report by showing the relational model, source lineage, data-quality rules and SQL used to derive race insights.

## What this proves

- relational modelling with primary keys, foreign keys and checks
- SQL joins across drivers, constructors, races, results and pit summaries
- CTEs, aggregations and conditional aggregation
- window functions including `DENSE_RANK`, running totals and `PERCENT_RANK`
- reusable analytical views for a BI consumer
- transparent metric definitions and data-quality tests
- source lineage rather than unexplained hard-coded dashboard values

## Model

```text
drivers ───────┐
               ├── race_results ─── pit_stop_summaries
constructors ──┤         │
               │         │
races ─────────┘         └── analytical views ── Power BI / SQL analysis
  │
  └── race_data_sources ── data_sources
```

`race_results` is the central fact table. Driver, constructor and race tables provide descriptive dimensions. `pit_stop_summaries` has the same driver/race grain as the result fact, while the source tables document where the records came from.

## Files

| File | Purpose |
| --- | --- |
| `00_run_all.sql` | Rebuilds the database objects and loads the dataset |
| `01_schema.sql` | Creates the normalized schema, constraints and indexes |
| `02_seed_british_gp.sql` | Loads the 20-driver event dataset and source lineage |
| `03_views.sql` | Creates driver, constructor and Power BI export views |
| `04_analysis.sql` | Answers 12 business questions from basic joins to window functions |
| `05_quality_tests.sql` | Fails the build if core counts and known results are wrong |

## Run locally

Requirements: PostgreSQL 14 or later and the `psql` command-line client.

```bash
createdb f1_analytics
psql -d f1_analytics -f sql/00_run_all.sql
psql -d f1_analytics -f sql/04_analysis.sql
```

The setup script deliberately drops and rebuilds only the `f1_analytics` schema. Do not point it at a database where an existing schema with that name must be preserved.

## Business questions covered

1. What was the final classification?
2. Which drivers gained or lost the most positions?
3. Which constructor delivered the strongest combined result?
4. How did each driver compare with their teammate?
5. How far was each fastest lap from the race benchmark?
6. Who had the lowest average recorded pit-lane time per stop?
7. Who most outperformed their team's finishing baseline?
8. How were points accumulated down the finishing order?
9. How reliable was the field?
10. Who ranks highest on a transparent strategy-efficiency index?
11. Does the dataset pass the defined quality checks?
12. What governed view could be imported into Power BI?

## Important metric definitions

- **Positions gained** = grid position minus finishing position. Pit-lane starters and a DNS are excluded from movement comparisons.
- **Average stop seconds** = total official pit-lane time divided by stop count. It is not presented as stationary tyre-change time.
- **Pace percentile from front** ranks fastest laps from quickest to slowest within this event.
- **Strategy-efficiency index** is an illustrative, explainable portfolio metric: 50% finish quality, 25% grid movement and 25% pit efficiency. It is not an official Formula One measure or a causal model.

## Verified headline results

- Lewis Hamilton won from second on the grid.
- Max Verstappen gained two positions to finish second.
- Carlos Sainz finished fifth, gained two positions and set the race's fastest lap at 1:28.293.
- McLaren scored 27 points from two cars; Mercedes scored 25 after George Russell retired.
- Nineteen drivers completed at least one lap; Pierre Gasly did not start.

## Data provenance and boundaries

The classification, fastest-lap and pit-stop summary records are transcribed from the [FIA race classification](https://www.fia.com/events/fia-formula-one-world-championship/season-2024/british-grand-prix/race-classification). Grid records are checked against the [FIA official grid](https://www.fia.com/events/fia-formula-one-world-championship/season-2024/british-grand-prix/qualifying-classification) and [Formula 1 starting grid](https://www.formula1.com/en/results/2024/races/1240/britain/starting-grid). [BBC Sport's result table](https://www.bbc.co.uk/sport/formula1/2024/british-grand-prix/results) is recorded as a cross-check.

This is a curated single-event analytical dataset, not a live timing feed or a full-season data warehouse. It intentionally does not invent lap-by-lap telemetry or weather records that cannot be verified from the published repository sources.

## Interview explanation

If asked how this works, explain it in this order:

1. **Grain:** one `race_results` row represents one driver in one race.
2. **Normalization:** driver, constructor and race labels live in dimension tables instead of being repeated in every fact row.
3. **Integrity:** keys and checks prevent duplicate results, impossible positions and incomplete lap-time pairs.
4. **Transformation:** views join the normalized tables and calculate reusable measures.
5. **Analysis:** CTEs and window functions compare drivers without destroying row-level detail.
6. **Consumption:** Power BI can import the flat export view while PostgreSQL remains the governed source.

Be ready to open `04_analysis.sql`, choose one query and explain every line. That is stronger evidence than memorising terminology.
