/*
Queries used for Power BI visualisation
Total 5 quaries, we will save them into an excel workbook in 5 different sheeets
*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid19DataAnalysis..CovidDeaths
where continent is not null


-- 2. 

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid19DataAnalysis..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid19DataAnalysis..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid19DataAnalysis..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 5.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid19DataAnalysis..CovidDeaths
Where location like '%pakistan%'
or location like '%emirates%'
or location like '%states%'
or location like '%italy%'
or location like '%china%'
Group by Location, Population, date
order by PercentPopulationInfected desc