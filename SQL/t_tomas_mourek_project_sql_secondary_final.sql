DROP TABLE IF EXISTS t_tomas_mourek_project_sql_secondary_final;

CREATE TABLE t_tomas_mourek_project_sql_secondary_final AS
WITH cz_years AS (
    SELECT DISTINCT
        year
    FROM t_tomas_mourek_project_sql_primary_final
),
eu_countries AS (
    SELECT
        c.name AS country,
        c.region,
        c.continent
    FROM countries c
    WHERE c.continent = 'Europe'
        OR c.region ILIKE '%Europe%'
),
eu_economies AS (
    SELECT
        e.country,
        e.year,
        e.gdp::numeric AS gdp_per_capita,
        e.gini::numeric AS gini,
        e.population::numeric AS population
    FROM economies e
    WHERE e.year IN (SELECT year FROM cz_years)
)
SELECT
    ee.country,
    ee.year,
    ROUND(ee.gdp_per_capita, 2) AS gdp_per_capita,
    ROUND(ee.gini, 2) AS gini_index,
    ROUND(ee.population) AS population
FROM eu_economies ee
JOIN eu_countries ec
    USING (country)
ORDER BY
    ee.country,
    ee.year;