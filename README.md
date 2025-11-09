# Engeto: Project 4 - Projekt z SQL

Analyzovat vývoj mezd a cen potravin v České republice a doplnit o makroekonomické ukazatele dalších evropských zemí.

## Vstupní datové zdroje

| Tabulka | Popis |
|----------|--------|
| `czechia_payroll` | Údaje o mzdách dle odvětví a roků. |
| `czechia_payroll_industry_branch` | Číselník odvětví. |
| `czechia_price` | Ceny vybraných potravin podle let a kategorií. |
| `czechia_price_category` | Číselník kategorií potravin. |
| `countries`, `economies` | Mezinárodní makroekonomická data (HDP, GINI, populace aj.). |

## Výstupní tabulky

### `t_tomas_mourek_project_SQL_primary_final`
Zahrnuje spojená data o mzdách a cenách potravin za ČR v období 2006  2018.  

Sloupce:
- `year`
- `industry_branch`
- `avg_salary`
- `food_category`
- `avg_price`
- `quantity`
- `unit`

### `t_tomas_mourek_project_SQL_secondary_final`
Dodatečná data o evropských zemích z tabulek `countries` a `economies`  
(rok, země, HDP, GINI, populace).

## Přehled analytických views

## Analytické views

|  | Otázka | View |
|---|---|---|
| 1 | Rostou mzdy ve všech odvětvích, nebo v některých klesají? | `v_tomas_mourek_wages_trend` |
| 2 | Kolik litrů mléka a kg chleba si lze koupit v prvním a posledním srovnatelném roce? | `v_tomas_mourek_milk_bread_affordability` |
| 3 | Která kategorie potravin zdražuje nejpomaleji (nejnižší průměrný YoY nárůst)? | `v_tomas_mourek_food_price_growth` |
| 4 | Existuje rok, kdy meziroční růst cen > růst mezd o více než 10 p. b.? | `v_tomas_mourek_prices_vs_wages` |
| 5 | Má růst HDP vliv na mzdy a ceny (stejný/následující rok)? | `v_tomas_mourek_gdp_growth_effect` |

## Odpovědi (zjištění z dat)

### Q1: Mzdy v čase dle odvětví
- Dlouhodobě rostou, ale ne lineárně a ne ve všech odvětvích každý rok.  
- Poklesy (příklady): 2013 u Administrativy (-1,24 %), ICT (-1,04 %), Financí (-8,83 %), Profesních činností (-3,02 %); dále např. Stavebnictví 2013 (-2,06 %), Těžba 2009/2013/2014/2016, Výroba energií 2011/2013/2015 atd.

### Q2: Kupní síla: mléko a chléb (národní průměr)
- 2006: ~1 352,91 l mléka a 1 211,91 kg chleba.  
- 2018: ~1 616,70 l mléka a 1 321,91 kg chleba.  
- Změna 2006→2018: mléko +19,5 %, chléb +9,1 %.  
Kupní síla vzrostla, výrazněji u mléka.

### Q3: Nejpomaleji zdražující kategorie (průměrný YoY %, 2006-2018)
- 118101 Cukr krystalový -1,92 %  
- 117101 Rajská jablka červená kulatá -0,74 %  
- 116103 Banány žluté +0,81 %  
Na opačném konci: 117103 Papriky +7,29 %, 115101 Máslo +6,67 %.

### Q4: Ceny vs. mzdy: >10 p. b.?
- Ne. Největší kladný rozdíl 2013: ceny +5,55 %, mzdy -0,13 %, rozdíl +5,68 p. b.  
- Největší záporný rozdíl 2009: ceny -6,79 %, mzdy +3,37 %, rozdíl -10,16 p. b.  
Hranice +10 p. b. nikdy překročena nebyla.

### Q5: Vliv HDP na mzdy a ceny
- V řadě let spolu rostou (např. 2017: HDP +5,17 %, mzdy +6,74 %, ceny +9,63 %).  
- Výjimky potvrzují, že nejde o pevnou kauzalitu (např. 2015: HDP +5,39 %, mzdy +3,19 %, ceny -0,55 %; 2012: HDP -0,79 %, ale ceny +6,73 %).  
Závěr: pozitivní vztah ano, nikoli stabilní příčinná vazba.
