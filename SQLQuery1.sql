-- Seleccionar todos los datos de Proy1..D y ordenar por la tercera y cuarta columna
SELECT *
FROM Proy1..D
ORDER BY 3, 4;

-- Seleccionar todos los datos de Proy1..V y ordenar por la tercera y cuarta columna
SELECT *
FROM Proy1..V
ORDER BY 3, 4;

-- Seleccionar datos específicos de Proy1..D y ordenar por la primera y segunda columna
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM Proy1..D
ORDER BY 1, 2;

-- Comparación entre casos totales y muertes totales en Proy1..D
--SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases) 
--FROM Proy1..D
--ORDER BY 1, 2;

-- Filtrar datos de muertes que tienen valores no numéricos en Proy1..D
SELECT Location, Date, total_cases, total_deaths
FROM Proy1..D
WHERE ISNUMERIC(total_cases) = 0 OR ISNUMERIC(total_deaths) = 0;

-- Calcular el porcentaje de muertes respecto a los casos totales en Proy1..D con alias DeathPercentage
SELECT 
    Location, 
    Date, 
    CAST(total_cases AS numeric) AS total_cases_numeric, 
    CAST(total_deaths AS numeric) AS total_deaths_numeric, 
    (CAST(total_deaths AS numeric) * 100.0 / NULLIF(CAST(total_cases AS numeric), 0)) AS DeathPercentage
FROM 
    Proy1..D
WHERE 
    location LIKE '%Argenti%'
ORDER BY 
    Location, Date;

-- Calcular el porcentaje de casos totales respecto a la población en Proy1..D con alias DeathPercentage
SELECT 
    Location,
    Date,
    Population,
    total_cases,
    (total_cases/population)*100 AS DeathPercentage
FROM
    Proy1..D
WHERE
    location LIKE '%states%'
ORDER BY
    4

-- Total Cases vs. Population
SELECT 
    Location,
    Date,
    Population,
    total_cases,
    (total_cases/population)*100 AS PercentagePopulationInfected
FROM
    Proy1..D
WHERE
    location LIKE '%states%'
ORDER BY
    4 DESC;

--Looking at countries with the Highest Infection Rate compared to Population

SELECT
	location,
	Population,
	MAX(total_cases)as HighestInfectionCount,
	MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM
    Proy1..D
--WHERE 
--	location like '%argentin%'
GROUP BY 
	location,
	population
ORDER BY
	4 desc

-- Showing Countries with Highest Death Count per Population
Select
	location,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
From
	Proy1..D
Where continent is not null
Group by 
	Location
Order by
	TotalDeathCount desc



-- By continent
Select
	Location,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
From
	Proy1..D
Where 
	continent is  null
	AND Location NOT LIKE '%income%'
Group by 
	location
Order by
	TotalDeathCount desc

-- Showing continent with the highest death count per population
Select
	continent,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
From
	Proy1..D
Where 
	continent is  null
	AND Location NOT LIKE '%income%'
Group by 
	continent
Order by
	TotalDeathCount desc

Select
	continent,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
From
	Proy1..D
Where 
	continent is not null
	
Group by 
	continent
Order by
	TotalDeathCount desc

-- Global numbers
Select
	Date,
	SUM(new_cases) as TotalCases,
	SUM(cast(new_deaths as int)) as totalDeath,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	--total_cases
From
	Proy1..D
Where
	continent is not null
Group by
	date
--Order by
--	1, 2

-- Looking at Total population vs Vaccinations

--Select 
--	dea.continent, 
--	dea.location, 
--	dea.date,
--	dea.population,
--	vac.new_vaccinations,
--	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
--From 
--	Proy1..D dea
--Join
--	Proy1..V vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where
--	dea.continent is not null
--order by
--	2, 3

SELECT 
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(ISNULL(CAST(vac.new_vaccinations AS bigint), 0)) OVER (PARTITION BY dea.Location, dea.date) AS TotalVaccinations
FROM 
    Proy1..D dea
JOIN
    Proy1..V vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.location, dea.date;

-- Este no me funciono asi que puse el de abajo 
--SELECT 
--    dea.continent, 
--    dea.location, 
--    dea.date,
--    dea.population,
--    vac.new_vaccinations,
--    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.Location, dea.date) 
--FROM 
--    Proy1..D dea
--JOIN
--    Proy1..V vac
--    ON dea.location = vac.location
--    AND dea.date = vac.date
--WHERE
--    dea.continent IS NOT NULL
--ORDER BY
--    dea.location, dea.date;

--USE CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollinPeopleVaccinated)
as
(
SELECT 
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollinPeopleVaccinated
--, (RollinPeopleVaccinated/population)*100
FROM 
    Proy1..D dea
JOIN
    Proy1..V vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
--    dea.location, dea.date;
)
Select *, (RollinPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continet nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollinPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollinPeopleVaccinated
--, (RollinPeopleVaccinated/population)*100
FROM 
    Proy1..D dea
JOIN
    Proy1..V vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
--    dea.location, dea.date;
Select *, (RollinPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store data for Later Visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated AS
Select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
--	SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
--	SUM(CONVERT(int, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
-- estas dos de arriba me tiraba error por la cantidad de valores que los que puede manejar int
	SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated

FROM 
    Proy1..D dea
JOIN
    Proy1..V vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
--    dea.location, dea.date;

SELECT * 
FROM 
	dbo.PercentPopulationVaccinated; -- Reemplaza "dbo" con el esquema correcto si es necesario
