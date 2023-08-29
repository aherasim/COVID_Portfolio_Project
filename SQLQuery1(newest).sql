SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select the data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths


ALTER TABLE CovidDeaths
ALTER COLUMN total_cases decimal

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths int

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths decimal

ALTER TABLE CovidDeaths
ALTER COLUMN population float
--Shows likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage                
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Canada%'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got COVID

SELECT Location, date, population, total_cases, (total_cases/population)*100 as CovidInfectedPercentage                
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Canada%'
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected                
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
--WHERE Location like '%Canada%'
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest Death Count per country

SELECT Location, MAX(total_deaths) as TotalDeathCount            
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Lets break things down by continent

SELECT location, MAX(total_deaths) as TotalDeathCount            
FROM PortfolioProject..CovidDeaths
WHERE Continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT continent, MAX(total_deaths) as TotalDeathCount            
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing continents with the highest death count per poppulation

--Global Numbers (Number of new cases and new deaths daily + death percentage)


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage               
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL and new_cases <> 0
GROUP BY date
ORDER BY 1,2

--whats the percentage of people who died from COVID worldwide?

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage               
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL and new_cases <> 0
ORDER BY 1,2


--Looking at Total Population vs Vaccinations (shows how many people were vaccinated in total daily as well as running overall total)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--Use CTE (shows newly vaccinated people count 

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location 
Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac




--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location 
Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--creating view to store data for later visualizations


USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location 
Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

select * from PercentPopulationVaccinated