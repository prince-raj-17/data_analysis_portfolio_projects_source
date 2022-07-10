-- SQL Data Exploration (Data Analyst Portfolio Project)

-- Data Source: https://ourworldindata.org/covid-deaths (20-02-2020 to 06-07-2022)
-- Tool: Microsoft SQl Server Management Studio
-- COVID 19 Data Exploration



-- Checking Table 1
SELECT * 
FROM portfolio_project..covid_deaths


-- Checking Table 2
SELECT * 
FROM portfolio_project..covid_vaccinations


-- Overall World View
SELECT SUM(DISTINCT population) AS World_Population, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths
FROM portfolio_project..covid_deaths
WHERE continent is not null


-- Continent based deaths
SELECT continent, SUM(new_cases) AS Total_Cases, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Countries with highest death count 
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Countries with higher infection rate 
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM portfolio_project..covid_deaths
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC


-- Cases and deaths as per date and countrywise
select Location, date, total_cases, new_cases, total_deaths 
from portfolio_project..covid_deaths
where total_deaths is not null
order by 1,2


-- Total cases vs total deaths in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM portfolio_project..covid_deaths
WHERE location = 'India' and total_deaths is not null
ORDER BY 2


-- Covid 19 Overview of India (June 2022)
SELECT de.location, de.date, de.population, de.total_cases, vc.total_vaccinations ,de.total_deaths, (de.total_deaths/de.total_cases)*100 AS Death_Percentage
FROM portfolio_project..covid_deaths de
JOIN portfolio_project..covid_vaccinations vc
ON de.location = vc.location
	and de.date = vc.date
WHERE de.location = 'India' and 
de.date = '2022-06-30 00:00:00:00' and 
total_deaths is not null
ORDER BY 2


-- New cases and deaths in Global numbers
SELECT date, SUM(new_cases) AS New_Cases, SUM(CAST(new_deaths AS INT)) AS New_Deaths
FROM portfolio_project..covid_deaths
WHERE date >= '2020-01-22 00:00:00:00'
GROUP BY date
ORDER BY 1


-- Vaccinations vs New Cases Globally
SELECT de.continent, de.location, de.date, de.population, vc.new_vaccinations, de.new_cases
FROM portfolio_project..covid_deaths de
JOIN portfolio_project..covid_vaccinations vc
	ON de.location = vc.location
	and de.date = vc.date
WHERE vc.new_vaccinations is not null and de.continent is not null
ORDER BY 2,3


-- Creating view to store data for later

CREATE VIEW Percent_Population_Vaccinated 
AS
Select de.continent, de.location, de.date, de.population, vc.new_vaccinations
, SUM(CONVERT(INT,vc.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) 
as RollingPeopleVaccinated
from portfolio_project..covid_deaths de
join portfolio_project..covid_vaccinations vc
	On de.location = vc.location
	and de.date = vc.date
where de.continent is not null