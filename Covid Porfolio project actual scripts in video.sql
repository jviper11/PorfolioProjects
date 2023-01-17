--select *
--from PorfolioProject..CovidDeaths
--order by 3,4

--select *
--from PorfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

--select location, date, total_cases, new_cases, total_deaths, population
--from PorfolioProject..CovidDeaths
--order by 1,2

-- looking at total cases vs total deaths
-- SHows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PorfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population,total_cases, (total_cases/population)* 100 as DeathPercentage
from PorfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--Looking at countriesd with highest infection rate comppared to population

select location, population,max(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as PercentPopulationInfected
from PorfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--Showing countries with highest Death Count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by totaldeathcount desc

-- lets break things down by continent 

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by totaldeathcount desc


--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by totaldeathcount desc


-- global numbers

select  sum(new_cases) as totalcases,
sum(cast(new_deaths as int)) as totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from PorfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as rollingpeaoplevaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (Continent, location, date, population,new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as rollingpeoplevaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)

select *, (rollingpeoplevaccinated/population )*100
from PopvsVac


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Datre datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population )*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated