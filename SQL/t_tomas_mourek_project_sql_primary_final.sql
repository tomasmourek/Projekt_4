DROP TABLE IF EXISTS t_tomas_mourek_project_sql_primary_final;

CREATE TABLE t_tomas_mourek_project_sql_primary_final AS
WITH years_intersection AS (
    SELECT y
    FROM (
        SELECT DISTINCT
            payroll_year AS y
        FROM czechia_payroll
        WHERE value_type_code = 5958
            AND calculation_code = 200
            AND value IS NOT NULL
    ) p
    INNER JOIN (
        SELECT DISTINCT
            EXTRACT(YEAR FROM date_from)::int AS y
        FROM czechia_price
        WHERE value IS NOT NULL
    ) pr
        USING (y)
),
wage_data AS (
    SELECT
        cp.payroll_year AS year,
        cpib.name AS industry_branch_name,
        ROUND(AVG(cp.value)::numeric, 2) AS avg_wage_per_industry
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958
        AND cp.calculation_code = 200
        AND cp.value IS NOT NULL
        AND cpib.name IS NOT NULL
        AND cp.payroll_year IN (SELECT y FROM years_intersection)
    GROUP BY
        cp.payroll_year,
        cpib.name
),
overall_avg_wage_data AS (
    SELECT
        cp.payroll_year AS year,
        ROUND(AVG(cp.value)::numeric, 2) AS overall_avg_wage
    FROM czechia_payroll cp
    WHERE cp.value_type_code = 5958
        AND cp.calculation_code = 200
        AND cp.value IS NOT NULL
        AND cp.industry_branch_code IS NULL
        AND cp.payroll_year IN (SELECT y FROM years_intersection)
    GROUP BY
        cp.payroll_year
),
price_data AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS year,
        cpc.name AS price_category_name,
        ROUND(AVG(cp.value)::numeric, 2) AS avg_price_per_category
    FROM czechia_price cp
    JOIN czechia_price_category cpc
        ON cp.category_code = cpc.code
    WHERE cp.value IS NOT NULL
        AND EXTRACT(YEAR FROM cp.date_from)::int IN (SELECT y FROM years_intersection)
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from)::int,
        cpc.name
),
milk_bread_prices AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS year,
        ROUND(AVG(CASE WHEN cpc.name ILIKE '%Mléko polotučné pasterované%' THEN cp.value END)::numeric, 2) AS avg_price_milk,
        ROUND(AVG(CASE WHEN cpc.name ILIKE '%Chléb konzumní kmínový%' THEN cp.value END)::numeric, 2) AS avg_price_bread
    FROM czechia_price cp
    JOIN czechia_price_category cpc
        ON cp.category_code = cpc.code
    WHERE cp.value IS NOT NULL
        AND EXTRACT(YEAR FROM cp.date_from)::int IN (SELECT y FROM years_intersection)
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from)::int
)
SELECT
    wd.year,
    wd.industry_branch_name,
    wd.avg_wage_per_industry,
    oawd.overall_avg_wage,
    pd.price_category_name,
    pd.avg_price_per_category,
    mbp.avg_price_milk,
    mbp.avg_price_bread,
    ROUND((oawd.overall_avg_wage / NULLIF(mbp.avg_price_milk, 0))::numeric, 2) AS milk_liters,
    ROUND((oawd.overall_avg_wage / NULLIF(mbp.avg_price_bread, 0))::numeric, 2) AS bread_kg
FROM wage_data wd
LEFT JOIN overall_avg_wage_data oawd
    ON wd.year = oawd.year
LEFT JOIN price_data pd
    ON wd.year = pd.year
LEFT JOIN milk_bread_prices mbp
    ON wd.year = mbp.year
WHERE oawd.overall_avg_wage IS NOT NULL
    AND mbp.avg_price_milk IS NOT NULL
    AND mbp.avg_price_bread IS NOT NULL
ORDER BY
    wd.year,
    wd.industry_branch_name,
    pd.price_category_name;