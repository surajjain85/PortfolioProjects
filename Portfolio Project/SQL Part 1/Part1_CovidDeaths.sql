Select *
from PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we'll be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2


--looking for total cases vs total deaths
select location,date,total_cases,total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--what percentage of person got covid.
select location,date,total_cases,population, (total_cases/population)*100 as CovidEffect_People
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

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
order by 3,4

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
order by 1,2

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


Select * from #PercentPopulationVaccinated


--Creating Views for later visualisations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations ,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)	as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidDeaths as vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
