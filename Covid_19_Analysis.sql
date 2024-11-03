

-- presenting all data ordered by column 3,4 from covidDeaths
select * 
from CovidDeaths
where continent is not null
order by 3,4


--
select * 
from CovidVaccinations
order by 3,4

-- Select the columns that we are going to be using 

select 
  Location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
from Aryacovidanalysis..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases ve Total Deaths
-- show the likeihood of dying if you contract covid in your country 
select 
  Location, 
  date, 
  total_cases, 
   total_deaths,
   (total_deaths/total_cases)*100 as DeathPercentage
from Aryacovidanalysis..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population 
-- Show what percentage of population got Covid 
select 
  Location, 
  date, 
  total_cases, 
   population,
   (total_cases/ population)*100 as PercentPopulationInfected
from Aryacovidanalysis..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2
-- Looking at Countries with Highest Infection Rate compared to Population 

select 
  Location, 
  population,
  Max(total_cases) as HighestInfectionCount, 
  Max((total_cases/ population))*100 as PercentPopulationInfected
from Aryacovidanalysis..CovidDeaths
where continent is not null
--where location like '%states%' 
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
 select 
  Location, 
  Max(cast(total_deaths as int)) as TotalDeathsCount
from Aryacovidanalysis..CovidDeaths
where continent is not null
--where location like '%states%' 
Group by location
order by TotalDeathsCount desc

--let's break things down by continent
 select 
  
 continent, 
  Max(cast(total_deaths as int)) as TotalDeathsCount
from Aryacovidanalysis..CovidDeaths
--where continent is not null
--where location like '%states%' 
Group by continent
order by TotalDeathsCount desc


select 
  case 
    when continent is null then 'unknown'
	else continent
  end as modifide_continent,
 --continent, 
  Max(cast(total_deaths as int)) as TotalDeathsCount
from Aryacovidanalysis..CovidDeaths
--where continent is not null
--where location like '%states%' 
Group by continent
order by TotalDeathsCount desc


--showing the contintents with highest deathcount per population 

select 
  continent,
  sum(cast(total_deaths as int)) as total_deathcount,
  sum(population ) as total_population,
  sum(cast(total_deaths as int))/sum(population )*100 as death_per_popPerce

from Aryacovidanalysis..CovidDeaths
group by  continent


--Global numbers likeihood of death per cases
select 
  --date, 
  sum(new_cases) as total_cases,
  sum(cast(new_deaths as int)) as Total_deaths,
   sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from Aryacovidanalysis..CovidDeaths
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations


select
dea.continent,
dea.location,
dea.date,
dea.population, 
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.Date) as rollingpeoplecaccinated
--,(rollingpeoplecaccinated/population)*100
from Aryacovidanalysis..CovidDeaths dea
join Aryacovidanalysis..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE
-- CTE is metode of creating a temperrey table for further calculations from that table which comes afther CTE is created
with PopvsVac(continent,
 location,
 date,
 population,
 new_vaccinations,
 rollingpeoplecaccinated)
 as 
 (
 select
 dea.continent,
 dea.location,
 dea.date,
 dea.population, 
 vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.Date) as rollingpeoplecaccinated
 --,(rollingpeoplecaccinated/population)*100
from Aryacovidanalysis..CovidDeaths dea
join Aryacovidanalysis..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,
(rollingpeoplecaccinated/population)*100
from PopvsVac


--TEMP table
--is metode of creating a temperrey table for further calculations from that table which comes afther temp table is created
--when we creat temp table we need to have # before the name of the temp talble 
Drop table if exists #percentpopulation
Create table #percentpopulationvaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplecaccinated numeric
)
insert into #percentpopulationvaccinated
  select
 dea.continent,
 dea.location,
 dea.date,
 dea.population, 
 vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.Date) as rollingpeoplecaccinated
 --,(rollingpeoplecaccinated/population)*100
from Aryacovidanalysis..CovidDeaths dea
join Aryacovidanalysis..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select*,
(rollingpeoplecaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualizations
create view PercentPopulationVaccinated as 
 select
 dea.continent,
 dea.location,
 dea.date,
 dea.population, 
 vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.Date) as rollingpeoplecaccinated
 --,(rollingpeoplecaccinated/population)*100
from Aryacovidanalysis..CovidDeaths dea
join Aryacovidanalysis..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null



DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated AS 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingPeopleVaccinated
FROM 
    Aryacovidanalysis..CovidDeaths dea
JOIN 
    Aryacovidanalysis..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


select* 
from PercentPopulationVaccinated


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Aryacovidanalysis..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc