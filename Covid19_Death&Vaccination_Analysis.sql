/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Covid19DataAnalysis..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data (location, date, total_cases, new_cases, total_deaths & population) that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From Covid19DataAnalysis..CovidDeaths
Where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19DataAnalysis..CovidDeaths
Where continent is not null
and location like '%Emirates%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 as PopulationInfectedPercentage
From Covid19DataAnalysis..CovidDeaths
--Where continent is not null
--and location like '%Emirates%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectedCount, MAX(total_cases/population)*100 as PopulationInfectedPercentage
From Covid19DataAnalysis..CovidDeaths
Group by location, population
order by PopulationInfectedPercentage desc


-- Countries with Highest Death Count per Population
-- Cast total_deaths into 'int' because the column is in 'nvarchar'

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19DataAnalysis..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19DataAnalysis..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
-- Cast total_deaths into 'int' because the column is in 'nvarchar'

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covid19DataAnalysis..CovidDeaths
where continent is not null


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER(Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From Covid19DataAnalysis..CovidDeaths d
join Covid19DataAnalysis..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER(Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From Covid19DataAnalysis..CovidDeaths d
join Covid19DataAnalysis..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER(Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From Covid19DataAnalysis..CovidDeaths d
join Covid19DataAnalysis..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for visualizations

Create view PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER(Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From Covid19DataAnalysis..CovidDeaths d
join Covid19DataAnalysis..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From PercentPopulationVaccinated