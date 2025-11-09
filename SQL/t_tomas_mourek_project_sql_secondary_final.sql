DROP TABLE IF EXISTS t_tomas_mourek_project_SQL_secondary_final;

CREATE TABLE t_tomas_mourek_project_SQL_secondary_final AS
WITH cz_years AS (
    SELECT DISTINCT year FROM t_tomas_mourek_project_SQL_primary_final
),
eu_countries AS (
    SELECT
        c.name      AS country,
        c.region,
        c.continent
    FROM countries c
    WHERE c.continent = 'Europe' OR c.region ILIKE '%Europe%'
),
eu_economies AS (
    SELECT
        e.country,
        e.year,
        e.gdp::numeric        AS gdp,
        e.gini::numeric       AS gini,
        e.population::numeric AS population
    FROM economies e
    WHERE e.year IN (SELECT year FROM cz_years)
)
SELECT
    ec.year,
    ec.country,
    uc.region,
    uc.continent,
    ec.gdp,
    ec.gini,
    ec.population
FROM eu_economies ec
JOIN eu_countries uc USING (country)
ORDER BY ec.year, ec.country;
