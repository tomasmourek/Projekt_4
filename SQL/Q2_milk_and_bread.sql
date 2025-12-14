DROP VIEW IF EXISTS v_tomas_mourek_milk_bread_affordability CASCADE;

CREATE VIEW v_tomas_mourek_milk_bread_affordability AS
WITH yearly AS (
    SELECT DISTINCT
        year,
        overall_avg_wage,
        avg_price_milk,
        avg_price_bread,
        milk_liters,
        bread_kg
    FROM t_tomas_mourek_project_sql_primary_final
    WHERE overall_avg_wage IS NOT NULL
        AND avg_price_milk IS NOT NULL
        AND avg_price_bread IS NOT NULL
),
bounds AS (
    SELECT
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM yearly
)
SELECT
    y.*
FROM yearly AS y
JOIN bounds AS b
    ON y.year IN (b.first_year, b.last_year)
ORDER BY
    y.year;
