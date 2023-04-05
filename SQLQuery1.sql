SELECT * FROM CovidDeaths
ORDER BY location, date

--* Denotes to show all the data from CovidDeaths table

--SELECT * FROM CovidVaccinations
--ORDER BY location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths
ORDER BY location, date;

--selecting certain columns and sorting location and data

--Looking at Total Cases vs Total Deaths
--Shows likeihood of contracting covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death Percentage'  FROM CovidDeaths
WHERE location like '%states%'
ORDER BY location, date

--%states% is advance filterting for words before and after states. Also sorting location and date

--Looking at total cases vs population
--Shows what percetange of population got Covid
SELECT location, date, total_cases, (total_cases/population)*100 AS DeathPercentage FROM CovidDeaths
--WHERE location like '%states'
ORDER BY location, date

--Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--Showing countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

--breaking things down by continent

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

--Global Numbers

SELECT SUM(new_cases) AS NewCases, SUM(cast(new_deaths as int)) AS NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage FROM CovidDeaths --,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY NewCases, NewDeaths;

SELECT * FROM CovidVaccinations;

--Joining Covid Vaccinations onto Covid Deaths
--Looking total population vs vaccinations

SELECT dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

--Using partition aggregation

SELECT dea.continent, dea.location, dea.date ,dea.population,vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingADD
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY dea.location, dea.date, vac.new_vaccinations 


--USE CTE

WITH POPvsVAC (Continent, location, Date, Population, new_vaccinations, RollingADD) AS (
SELECT dea.continent, dea.location, dea.date ,dea.population,vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingADD
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY dea.location, dea.date, vac.new_vaccinations 
)

SELECT * FROM POPvsVAC