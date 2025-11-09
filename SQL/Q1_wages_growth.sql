DROP VIEW IF EXISTS v_tomas_mourek_wages_trend CASCADE;

CREATE VIEW v_tomas_mourek_wages_trend AS
WITH wages AS (
  SELECT
    payroll_year AS year,
    cpib.name AS industry_branch,
    ROUND(AVG(cp.value)::numeric, 2) AS avg_salary
  FROM czechia_payroll cp
  JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code
  WHERE cp.value_type_code = 5958
    AND cp.calculation_code = 200
    AND cp.value IS NOT NULL
  GROUP BY payroll_year, cpib.name
),
diff AS (
  SELECT
    industry_branch,
    year,
    avg_salary,
    LAG(avg_salary) OVER (PARTITION BY industry_branch ORDER BY year) AS prev_salary
  FROM wages
)
SELECT
  industry_branch,
  year,
  ROUND((avg_salary - prev_salary) / NULLIF(prev_salary, 0) * 100, 2) AS yoy_salary_change_pct,
  CASE WHEN avg_salary > prev_salary THEN 'UP' ELSE 'DOWN' END AS trend
FROM diff
WHERE prev_salary IS NOT NULL
ORDER BY industry_branch, year;
