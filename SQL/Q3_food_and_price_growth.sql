DROP VIEW IF EXISTS v_tomas_mourek_food_price_growth CASCADE;

CREATE VIEW v_tomas_mourek_food_price_growth AS
WITH yearly_avg_prices AS (
    SELECT
        year,
        price_category_name AS category,
        AVG(avg_price_per_category) AS avg_price
    FROM t_tomas_mourek_project_sql_primary_final
    WHERE price_category_name IS NOT NULL
    GROUP BY
        year,
        price_category_name
),
price_changes AS (
    SELECT
        category,
        year,
        avg_price,
        LAG(avg_price) OVER (
            PARTITION BY category
            ORDER BY year
        ) AS prev_price
    FROM yearly_avg_prices
),
growth_rates AS (
    SELECT
        category,
        ROUND(
            100.0 * (avg_price - prev_price) / NULLIF(prev_price, 0),
            2
        ) AS growth_pct
    FROM price_changes
    WHERE prev_price IS NOT NULL
)
SELECT
    category,
    ROUND(AVG(growth_pct), 2) AS avg_yearly_growth_pct
FROM growth_rates
GROUP BY
    category
ORDER BY
    avg_yearly_growth_pct ASC
LIMIT 10;
