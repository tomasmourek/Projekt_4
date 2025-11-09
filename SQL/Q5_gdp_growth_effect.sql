DROP VIEW IF EXISTS v_tomas_mourek_gdp_growth_effect CASCADE;

CREATE VIEW v_tomas_mourek_gdp_growth_effect AS
WITH years AS (
  SELECT DISTINCT year FROM t_tomas_mourek_project_SQL_primary_final
),
gdp AS (
  SELECT e.year, AVG(e.gdp)::numeric AS gdp
  FROM t_tomas_mourek_project_SQL_secondary_final e
  JOIN years y USING (year)
  WHERE e.country IN ('Czech Republic','Czechia')
  GROUP BY e.year
),
wages AS (
  SELECT cp.payroll_year AS year, AVG(cp.value)::numeric AS avg_wage
  FROM czechia_payroll cp
  JOIN years y ON y.year = cp.payroll_year
  WHERE cp.value_type_code = 5958
    AND cp.calculation_code = 200
    AND cp.industry_branch_code IS NULL
  GROUP BY cp.payroll_year
),
prices AS (
  SELECT y.year, AVG(cat_avg)::numeric AS avg_price
  FROM years y
  JOIN (
    SELECT EXTRACT(YEAR FROM cp.date_from)::int AS year,
           cpc.code,
           AVG(cp.value)::numeric AS cat_avg
    FROM czechia_price cp
    JOIN czechia_price_category cpc ON cp.category_code = cpc.code
    WHERE cp.value IS NOT NULL
    GROUP BY year, cpc.code
  ) p USING (year)
  GROUP BY y.year
),
gdp_y AS (
  SELECT year,
         100*(gdp - LAG(gdp) OVER (ORDER BY year)) / NULLIF(LAG(gdp) OVER (ORDER BY year),0) AS gdp_growth_pct
  FROM gdp
),
wage_y AS (
  SELECT year,
         100*(avg_wage - LAG(avg_wage) OVER (ORDER BY year)) / NULLIF(LAG(avg_wage) OVER (ORDER BY year),0) AS salary_growth_pct
  FROM wages
),
price_y AS (
  SELECT year,
         100*(avg_price - LAG(avg_price) OVER (ORDER BY year)) / NULLIF(LAG(avg_price) OVER (ORDER BY year),0) AS food_price_growth_pct
  FROM prices
)
SELECT
  y.year,
  ROUND(g.gdp_growth_pct, 2)       AS gdp_growth_pct,
  ROUND(w.salary_growth_pct, 2)    AS salary_growth_pct,
  ROUND(p.food_price_growth_pct,2) AS food_price_growth_pct
FROM years y
LEFT JOIN gdp_y   g USING (year)
LEFT JOIN wage_y  w USING (year)
LEFT JOIN price_y p USING (year)
ORDER BY y.year;
