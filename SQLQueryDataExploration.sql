SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select the data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at the total cases v/s total deaths 
-- Shows the likelihood of dying if you contract COVID in INDIA

SELECT location,date,total_cases,total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2


-- Looking at the total cases v/s the population

SELECT continent,location,date,population,total_cases,((total_cases/population)*100) AS PopulationAffected
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%' AND continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT continent,location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population)*100) AS PopulationAffected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population, continent
ORDER BY PopulationAffected DESC


-- Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null --try is null 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Group By Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, SUM(CAST(new_deaths AS INT))/NULLIF(SUM(new_cases),0)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Deaths Globally as on 27.05.2023
SELECT SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, SUM(CAST(new_deaths AS INT))/NULLIF(SUM(new_cases),0)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--COVID VACCINATIONS


--Looking at Total Population vs Vaccinations
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE

WITH PopvsVac (Continent, location, date , population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View for storing data later for data visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

WHERE dea.continent IS NOT NULL

