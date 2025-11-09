DROP VIEW IF EXISTS v_tomas_mourek_milk_bread_affordability CASCADE;

CREATE VIEW v_tomas_mourek_milk_bread_affordability AS
WITH wages AS (
  SELECT
    payroll_year AS year,
    ROUND(AVG(value)::numeric, 2) AS avg_salary
  FROM czechia_payroll
  WHERE value_type_code = 5958
    AND calculation_code = 200
    AND industry_branch_code IS NULL
  GROUP BY payroll_year
),
milk AS (
  SELECT
    EXTRACT(YEAR FROM date_from)::int AS year,
    ROUND(AVG(value)::numeric, 2) AS milk_price
  FROM czechia_price cp
  JOIN czechia_price_category cpc ON cp.category_code = cpc.code
  WHERE cpc.name = 'Mléko polotučné pasterované'
  GROUP BY EXTRACT(YEAR FROM date_from)
),
bread AS (
  SELECT
    EXTRACT(YEAR FROM date_from)::int AS year,
    ROUND(AVG(value)::numeric, 2) AS bread_price
  FROM czechia_price cp
  JOIN czechia_price_category cpc ON cp.category_code = cpc.code
  WHERE cpc.name = 'Chléb konzumní kmínový'
  GROUP BY EXTRACT(YEAR FROM date_from)
)
SELECT
  w.year,
  w.avg_salary,
  m.milk_price,
  b.bread_price,
  ROUND(w.avg_salary / m.milk_price, 2) AS liters_of_milk,
  ROUND(w.avg_salary / b.bread_price, 2) AS kilos_of_bread
FROM wages w
JOIN milk m USING (year)
JOIN bread b USING (year)
WHERE w.year BETWEEN 2006 AND 2018
ORDER BY w.year;
