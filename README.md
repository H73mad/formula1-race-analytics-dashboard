# Formula 1 Race Analytics Dashboard

> A five-page Power BI report and reproducible PostgreSQL analytics layer analysing performance, strategy and race conditions at the 2024 Formula One British Grand Prix.

![Formula 1 executive dashboard](./screenshots/Executive%20Dashboard.png)

## Project purpose

This individual Business Intelligence project turns historical race, telemetry, pit-stop and weather records into an interactive decision-support report. It was built to demonstrate how raw event data can be cleaned, modelled and translated into clear performance comparisons for different audiences.

The report answers questions such as:

- Which drivers and teams were quickest and most consistent?
- How did lap time and position develop during the race?
- When were pit stops made, and how long did they take?
- How did teammates and constructors compare?
- How did track and weather conditions change across the event?

## Report pages

| Page | Analytical purpose |
| --- | --- |
| Executive Dashboard | Summarises standings, fastest lap, average lap time, pit activity and headline race insights |
| Driver Analysis | Compares driver pace, ranking, sector performance and position |
| Team Analysis | Aggregates driver performance into constructor-level comparisons |
| Race Strategy | Explores pit-stop timing, duration and lap-by-lap race progression |
| Weather Analysis | Tracks air temperature, track temperature, humidity, wind and rainfall by lap |

## Business Intelligence workflow

```text
Race and telemetry records
        ↓
Power Query cleaning and transformation
        ↓
Relationships and analytical data model
        ↓
DAX measures and calculated metrics
        ↓
Interactive report pages, slicers and KPI cards
        ↓
Performance and strategy insights
```

The project separates preparation, modelling, calculation and presentation. This matters because a useful dashboard should not only look polished; its measures should be traceable to structured records and should respond consistently to report filters.

## SQL analytics layer

The [`sql/`](./sql/) folder adds a reproducible relational version of the event analysis. It includes a normalized PostgreSQL schema, a traceable 20-driver dataset, reusable analytical views, data-quality checks and 12 documented business queries.

The SQL analysis demonstrates:

- primary keys, foreign keys, checks and indexes
- joins across race, driver, constructor, result and pit-stop records
- CTEs and conditional aggregation
- ranking, teammate benchmarks, percentiles and running totals with window functions
- an explainable strategy-efficiency metric
- a flat governed view designed for Power BI import

Start with the [SQL walkthrough](./sql/README.md), then open [`04_analysis.sql`](./sql/04_analysis.sql) to see each business question and its implementation.

## Measures and analysis represented

- Driver and team standings
- Average and fastest lap time
- Sector-level performance
- Position and lap progression
- Pit-stop count, timing and duration
- Driver-to-driver and team-to-team comparison
- Air and track temperature
- Humidity, wind speed and rainfall

## Dashboard gallery

### Driver analysis

![Driver analysis](./screenshots/Driver%20Analysis.png)

### Team analysis

![Team analysis](./screenshots/Team%20Analysis.png)

### Race strategy

![Race strategy](./screenshots/Race%20Strategy.png)

### Weather analysis

![Weather analysis](./screenshots/Weather%20Analysis.png)

## Explore the report

1. Download [`F1Dashboard.pbix`](./F1Dashboard.pbix).
2. Open it with Power BI Desktop.
3. Use the page navigation and slicers to change the analytical context.
4. Cross-filter visuals to compare drivers, teams, laps and race conditions.

## Repository contents

```text
F1Dashboard.pbix    Complete Power BI report
screenshots/        Exported previews of the five report pages
sql/                PostgreSQL model, source data, views and analysis
README.md           Project explanation and usage guide
```

## Skills demonstrated

- Power BI report development
- Power Query data cleaning and transformation
- Analytical data modelling and relationships
- DAX measures and filter context
- PostgreSQL schema design and reusable analytical views
- SQL joins, CTEs, aggregations and window functions
- Data validation, constraints and source lineage
- KPI selection and information hierarchy
- Interactive filtering and visual storytelling
- Translating detailed event data into executive and operational views

## Current boundaries

- The analysis covers one historical event: the 2024 British Grand Prix.
- The SQL folder is a curated, source-linked event extract; it is not a live feed or a full-season warehouse.
- The PBIX contains broader report analysis, while the SQL package focuses on verified classification, fastest-lap, grid and pit-summary records.
- The report is descriptive rather than predictive and does not use a live refresh pipeline.
- Full interaction requires Power BI Desktop because no public Power BI embed is included.

## Author

Muhammad Hamad
