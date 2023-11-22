Select *
from PortfolioProject..CovidDeaths
order by location,date

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we'll be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by location,date


--looking for total cases vs total deaths
select location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by location,date

--what percentage of person got covid.
select location,date,total_cases,population, (total_cases/population)*100 as CovidEffect_People
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by location,date

-------------------
--check if trend is increasing:
	SELECT
    date,
    location,
    total_vaccinations
FROM (
    SELECT
        date,
        location,
        total_vaccinations,
        LAG(total_vaccinations) OVER (PARTITION BY location ORDER BY date) AS prev_total_vaccinations
    FROM
        covidVaccinations
    WHERE
        location = 'india'
        AND total_vaccinations > 0
) AS subquery
WHERE
    total_vaccinations > prev_total_vaccinations
ORDER BY
    date;


	select * from CovidVaccinations
	where total_vaccinations>0 and continent='Asia'

------Lets check if the vaccionation is working?
WITH VaccinationAndRecoveryData AS (
    SELECT
        cd.date,
        cd.location,
        CAST(cd.total_deaths AS DECIMAL(18, 2)) AS total_deaths,
        CAST(cv.total_vaccinations AS DECIMAL(18, 2)) AS total_vaccinations,
        CAST(cd.total_cases AS DECIMAL(18, 2)) - CAST(LAG(cd.total_cases) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)) AS new_cases,
        CAST(cd.total_deaths AS DECIMAL(18, 2)) - CAST(LAG(cd.total_deaths) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)) AS new_deaths,
        CAST(cv.total_vaccinations AS DECIMAL(18, 2)) - CAST(LAG(cv.total_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)) AS new_vaccinations,
        CAST(cd.total_cases AS DECIMAL(18, 2)) - CAST(cd.total_deaths AS DECIMAL(18, 2)) AS active_cases,
        (CAST(cd.total_cases AS DECIMAL(18, 2)) - CAST(cd.total_deaths AS DECIMAL(18, 2))) - ((CAST(LAG(cd.total_cases) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2))) - (CAST(LAG(cd.total_deaths) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)))) AS recovered_cases
    FROM
        coviddeaths cd
    JOIN
        covidVaccinations cv
    ON
        cd.location = cv.location
        AND cd.date = cv.date
    WHERE
       -- cd.location = 'india'  -- Replace 'Your_Location' with the specific location you are interested in
        --AND 
		cd.total_deaths > 0
        AND cv.total_vaccinations > 0
)
SELECT
    date,
    location,
    total_deaths,
    total_vaccinations,
    new_cases,
    new_deaths,
    new_vaccinations,
    active_cases,
    recovered_cases
	recovered_cases_percent
FROM
    VaccinationAndRecoveryData

ORDER BY
    date;

	---------2 trying to find percentage
	WITH VaccinationAndRecoveryData AS (
    SELECT
        cd.date,
        cd.location,
        CAST(cd.total_deaths AS DECIMAL(18, 2)) AS total_deaths,
        CAST(cv.total_vaccinations AS DECIMAL(18, 2)) AS total_vaccinations,
        CAST(cd.total_cases AS DECIMAL(18, 2)) - CAST(LAG(cd.total_cases) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)) AS new_cases,
        CAST(cd.total_deaths AS DECIMAL(18, 2)) - CAST(LAG(cd.total_deaths) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)) AS new_deaths,
        CAST(cv.total_vaccinations AS DECIMAL(18, 2)) - CAST(LAG(cv.total_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)) AS new_vaccinations,
        CAST(cd.total_cases AS DECIMAL(18, 2)) - CAST(cd.total_deaths AS DECIMAL(18, 2)) AS active_cases,
        (CAST(cd.total_cases AS DECIMAL(18, 2)) - CAST(cd.total_deaths AS DECIMAL(18, 2))) - ((CAST(LAG(cd.total_cases) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2))) - (CAST(LAG(cd.total_deaths) OVER (PARTITION BY cd.location ORDER BY cd.date) AS DECIMAL(18, 2)))) AS recovered_cases,
        (CAST(cd.total_cases AS DECIMAL(18, 2)) - CAST(cd.total_deaths AS DECIMAL(18, 2))) * 100 / NULLIF(CAST(cd.total_cases AS DECIMAL(18, 2)), 0) AS recovery_percentage
    FROM
        coviddeaths cd
    JOIN
        covidVaccinations cv
    ON
        cd.location = cv.location
        AND cd.date = cv.date
    WHERE
        --cd.location = 'india'  -- Replace 'Your_Location' with the specific location you are interested in
       -- AND 
		cd.total_deaths > 0
        AND cv.total_vaccinations > 0
)
SELECT
    date,
    location,
    total_deaths,
    total_vaccinations,
    new_cases,
    new_deaths,
    new_vaccinations,
    active_cases,
    recovered_cases,
    recovery_percentage
FROM
    VaccinationAndRecoveryData
ORDER BY
    date;



--coutry with highest infection rate as compare to population

select location,population,max(total_cases) as HighestInfectedPeople, max(total_cases/population)*100 as InfectedPeoplePercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location,	population
order by InfectedPeoplePercentage desc

--counties with highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCounts  desc


--check the continent ASisa has a null value , so will rid of it.

Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by location,date

---let see and break the things by continents

select continent, max(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCounts  desc


--trying with location and totaldeathcount
select location, max(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCounts  desc

--38.5
--showing continetnts with highest death counts

select date, sum(new_cases)as New_Cases, sum(cast(new_deaths as int)) as new_deaths , sum(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by date, New_Cases

--looking at total population vs vaccinations

select * 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vacc
on dea.location=vacc.location
and dea.date=vacc.date

select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 1,2,3


--if you want to add new_vaccinations as cumulative
select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations ,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)	as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 2,3

--1:06
--Use CTE
with PopvsVac (continent, Location, Date,Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations ,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)	as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
--order by 2,3
)

Select * from PopvsVac


Drop table if exists #PercentPopulationVaccinated
--Temp table
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations ,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)	as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated


--Creating Views for later visualisations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations ,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)	as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
