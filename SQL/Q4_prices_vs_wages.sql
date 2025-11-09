DROP VIEW IF EXISTS v_tomas_mourek_prices_vs_wages CASCADE;

CREATE VIEW v_tomas_mourek_prices_vs_wages AS
WITH wages AS (
  SELECT
    payroll_year AS year,
    ROUND(AVG(value)::numeric, 2) AS avg_wage
  FROM czechia_payroll
  WHERE value_type_code = 5958
    AND calculation_code = 200
    AND industry_branch_code IS NULL
  GROUP BY payroll_year
),
prices AS (
  SELECT
    EXTRACT(YEAR FROM date_from)::int AS year,
    ROUND(AVG(value)::numeric, 2) AS avg_price
  FROM czechia_price
  WHERE value IS NOT NULL
  GROUP BY EXTRACT(YEAR FROM date_from)
),
wages_diff AS (
  SELECT year,
         (avg_wage - LAG(avg_wage) OVER (ORDER BY year)) / LAG(avg_wage) OVER (ORDER BY year) * 100 AS wage_yoy_pct
  FROM wages
),
price_diff AS (
  SELECT year,
         (avg_price - LAG(avg_price) OVER (ORDER BY year)) / LAG(avg_price) OVER (ORDER BY year) * 100 AS price_yoy_pct
  FROM prices
)
SELECT
  p.year,
  ROUND(p.price_yoy_pct, 2) AS price_yoy_pct,
  ROUND(w.wage_yoy_pct, 2)  AS wage_yoy_pct,
  ROUND(p.price_yoy_pct - w.wage_yoy_pct, 2) AS diff_pct,
  CASE WHEN (p.price_yoy_pct - w.wage_yoy_pct) > 10 THEN 'YES' ELSE 'NO' END AS price_higher_than_wages_10pct
FROM price_diff p
JOIN wages_diff w USING (year)
WHERE p.price_yoy_pct IS NOT NULL AND w.wage_yoy_pct IS NOT NULL
ORDER BY diff_pct DESC;
