--Select *
--From [Portfolio Project]..CovidDeaths
--order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select the data that we are going to use:
--Select location, date, total_cases, new_cases, total_deaths, population
--From [Portfolio Project]..CovidDeaths
--order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying from Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%United States'
order by 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of the population tested positive for Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%United States'
order by 1,2

-- Looking at coutries with highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by location, population
--Where location like '%United States'
order by PercentPopulationInfected DESC 

-- Looking at coutries with the Highest Death Count per Capita

Select location, MAX(CAST(total_deaths as int))as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount DESC 

--LET'S TAKE A LOOK AT EACH CONTINENT


-- Showing the Continents with the highest death count
Select location, MAX(CAST(total_deaths as int))as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is null and location not like '%income%' 
Group by location
order by TotalDeathCount DESC 

-- Shows what percentage of the population tested positive for Covid on each Continent, and the infection rate per capita

Select location, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
where continent is null and location not like '%income%' and location not like '%International%'
Group by location
order by PercentPopulationInfected DESC 

-- Shows the current Death Count per Capita for each continent

Select location, MAX(CAST(total_deaths as int) / population)*100 as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is null and location not like '%income%' and location not like '%International%'
Group by location
order by TotalDeathCount DESC 


-- Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as bigint)) as total_deaths, (SUM(CAST(new_deaths as bigint))/SUM(new_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null 
Group by date
order by 1,2


-- Join our two datasets
Select *
From [Portfolio Project]..CovidDeaths as dea
Join [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null


--use a cte

WITH PopvsVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
-- Looking at Total Population vs. Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths as dea
Join [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
-- Looking at Total Population vs. Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths as dea
Join [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
USE [Portfolio Project]
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths as dea
Join [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
