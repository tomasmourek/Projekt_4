DROP VIEW IF EXISTS v_tomas_mourek_food_price_growth CASCADE;

CREATE VIEW v_tomas_mourek_food_price_growth AS
WITH avg_prices AS (
  SELECT
    cpc.code                                   AS category_code,
    cpc.name                                   AS food_category,
    EXTRACT(YEAR FROM cp.date_from)::int       AS year,
    AVG(cp.value)::numeric                     AS avg_price
  FROM czechia_price cp
  JOIN czechia_price_category cpc
    ON cp.category_code = cpc.code
  WHERE cp.value IS NOT NULL
  GROUP BY cpc.code, cpc.name, EXTRACT(YEAR FROM cp.date_from)
),
diff AS (
  SELECT
    category_code,
    food_category,
    year,
    avg_price,
    LAG(avg_price) OVER (PARTITION BY category_code ORDER BY year) AS prev_price
  FROM avg_prices
)
SELECT
  category_code,
  food_category,
  ROUND(AVG((avg_price - prev_price) / NULLIF(prev_price, 0) * 100), 2) AS avg_yoy_price_growth_pct
FROM diff
WHERE prev_price IS NOT NULL
GROUP BY category_code, food_category
ORDER BY avg_yoy_price_growth_pct ASC;
