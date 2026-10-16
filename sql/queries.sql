--Query 1: Total cases and deaths by continent (JOIN, GROUP BY, aggregates, ORDER BY)
SELECT c.continent, SUM(d.new_cases) AS total_cases, SUM(d.new_deaths) AS total_deaths
FROM daily_cases d
JOIN countries c ON c.iso_code = d.iso_code
GROUP BY c.continent
ORDER BY total_cases DESC;

--Query 2: Top 10 countries by cases, with cases per million people
SELECT c.location, SUM(d.new_cases) AS total_cases,
       ROUND(SUM(d.new_cases) * 1000000.0 / c.population) AS cases_per_million
FROM daily_cases d
JOIN countries c ON c.iso_code = d.iso_code
GROUP BY c.location, c.population
ORDER BY total_cases DESC
LIMIT 10;

--Query 3: Monthly worldwide cases (trend over time)
SELECT year, month, SUM(new_cases) AS monthly_cases
FROM daily_cases
GROUP BY year, month
ORDER BY year, month;

--Query 4: Countries with over 1M cases ranked by fatality rate (HAVING)
SELECT c.location, SUM(d.new_cases) AS cases, SUM(d.new_deaths) AS deaths,
       ROUND(SUM(d.new_deaths) * 100.0 / NULLIF(SUM(d.new_cases), 0), 2) AS fatality_pct
FROM daily_cases d
JOIN countries c ON c.iso_code = d.iso_code
GROUP BY c.location
HAVING SUM(d.new_cases) > 1000000
ORDER BY fatality_pct DESC
LIMIT 10;

--Query 5: Vaccination coverage level per country (CASE + subquery)
SELECT location, pct_fully_vaccinated,
       CASE WHEN pct_fully_vaccinated >= 70 THEN 'High'
            WHEN pct_fully_vaccinated >= 40 THEN 'Medium'
            ELSE 'Low' END AS coverage_level
FROM (
    SELECT c.location,
           ROUND(MAX(v.people_fully_vaccinated) * 100.0 / c.population, 1) AS pct_fully_vaccinated
    FROM vaccinations v
    JOIN countries c ON c.iso_code = v.iso_code
    GROUP BY c.location, c.population
) t
ORDER BY pct_fully_vaccinated DESC;

--Query 6: Countries with total cases above the average country (subquery)
SELECT location, total_cases
FROM (
    SELECT c.location, SUM(d.new_cases) AS total_cases
    FROM daily_cases d
    JOIN countries c ON c.iso_code = d.iso_code
    GROUP BY c.location
) t
WHERE total_cases > (
    SELECT AVG(x) FROM (SELECT SUM(new_cases) AS x FROM daily_cases GROUP BY iso_code) a
)
ORDER BY total_cases DESC;

--Query 7: Average test positive rate and total tests by continent (WHERE, JOIN)
SELECT c.continent, ROUND(AVG(t.positive_rate) * 100, 2) AS avg_positive_pct,
       SUM(t.new_tests) AS total_tests
FROM tests t
JOIN countries c ON c.iso_code = t.iso_code
WHERE t.positive_rate IS NOT NULL
GROUP BY c.continent
ORDER BY avg_positive_pct DESC;

--Query 8: Yearly cases vs average government stringency (policy strictness)
SELECT year, SUM(new_cases) AS total_cases, ROUND(AVG(stringency_index), 1) AS avg_stringency
FROM daily_cases
GROUP BY year
ORDER BY year;