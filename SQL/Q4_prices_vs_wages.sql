DROP VIEW IF EXISTS v_tomas_mourek_prices_vs_wages CASCADE;

CREATE VIEW v_tomas_mourek_prices_vs_wages AS
WITH yearly AS (
    SELECT DISTINCT
        year,
        overall_avg_wage AS wage,
        avg_price_milk AS milk,
        avg_price_bread AS bread
    FROM t_tomas_mourek_project_sql_primary_final
    WHERE overall_avg_wage IS NOT NULL
        AND avg_price_milk IS NOT NULL
        AND avg_price_bread IS NOT NULL
),
chg AS (
    SELECT
        year,
        wage,
        milk,
        bread,
        LAG(wage) OVER (ORDER BY year) AS prev_wage,
        LAG(milk) OVER (ORDER BY year) AS prev_milk,
        LAG(bread) OVER (ORDER BY year) AS prev_bread
    FROM yearly
)
SELECT
    year,
    ROUND(100.0 * (wage - prev_wage) / NULLIF(prev_wage, 0), 2) AS wage_growth_pct,
    ROUND(100.0 * (milk - prev_milk) / NULLIF(prev_milk, 0), 2) AS milk_growth_pct,
    ROUND(100.0 * (bread - prev_bread) / NULLIF(prev_bread, 0), 2) AS bread_growth_pct
FROM chg
WHERE prev_wage IS NOT NULL
    AND (
        (100.0 * (milk - prev_milk) / NULLIF(prev_milk, 0))
            > (100.0 * (wage - prev_wage) / NULLIF(prev_wage, 0)) + 10
        OR
        (100.0 * (bread - prev_bread) / NULLIF(prev_bread, 0))
            > (100.0 * (wage - prev_wage) / NULLIF(prev_wage, 0)) + 10
    )
ORDER BY
    year;
