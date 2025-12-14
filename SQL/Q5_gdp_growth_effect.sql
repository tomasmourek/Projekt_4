DROP VIEW IF EXISTS v_tomas_mourek_gdp_growth_effect CASCADE;

CREATE VIEW v_tomas_mourek_gdp_growth_effect AS
WITH yearly_primary AS (
    SELECT DISTINCT
        year,
        overall_avg_wage,
        avg_price_milk,
        avg_price_bread
    FROM t_tomas_mourek_project_sql_primary_final
    WHERE overall_avg_wage IS NOT NULL
        AND avg_price_milk IS NOT NULL
        AND avg_price_bread IS NOT NULL
),
cz_gdp AS (
    SELECT
        year,
        gdp_per_capita
    FROM t_tomas_mourek_project_sql_secondary_final
    WHERE country = 'Czech Republic'
        AND gdp_per_capita IS NOT NULL
),
joined AS (
    SELECT
        p.year,
        g.gdp_per_capita,
        p.overall_avg_wage,
        p.avg_price_milk,
        p.avg_price_bread
    FROM yearly_primary AS p
    JOIN cz_gdp AS g
        USING (year)
),
lagged AS (
    SELECT
        year,
        gdp_per_capita,
        LEAD(gdp_per_capita) OVER (ORDER BY year) AS next_year_gdp,
        overall_avg_wage,
        avg_price_milk,
        avg_price_bread
    FROM joined
)
SELECT
    CORR(gdp_per_capita, overall_avg_wage) AS corr_gdp_wage_same_year,
    CORR(gdp_per_capita, avg_price_milk) AS corr_gdp_milk_same_year,
    CORR(gdp_per_capita, avg_price_bread) AS corr_gdp_bread_same_year,
    CORR(next_year_gdp, overall_avg_wage) AS corr_next_gdp_wage,
    CORR(next_year_gdp, avg_price_milk) AS corr_next_gdp_milk,
    CORR(next_year_gdp, avg_price_bread) AS corr_next_gdp_bread
FROM lagged
WHERE next_year_gdp IS NOT NULL;
