select *
from death
where continent is not null
order by 3,4

--select *
--from vactinations
--order by 3,4

--Select data that we are going to be using

select location, date,total_cases,new_cases,total_deaths,population
from death
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract in your country

select location, date,total_cases,total_deaths,((cast(total_deaths as float))/total_cases)*100 as deathpercentage
from death
where location like '%states%'
and continent is not null
order by 1,2


--loking at total cases vs population
--shows what percentage of population got covid

select location, date,population,total_cases,(total_cases/population)*100 as Percentpopulationinfected
from death
where continent is not null
--where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population


select location,population,max(total_cases) as highestinfectioncount ,max((total_cases/population))*100 
as Percentpopulationinfected
from death
where continent is not null
group by location,population
order by  Percentpopulationinfected desc



--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as totaldeathcount 
from death
where continent is not null
group by location
order by  totaldeathcount  desc



--LET'S BREAK THINGS DOWN BY CONTINENT
--showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount 
from death
where continent is not null
group by continent
order by  totaldeathcount  desc


-- global numbers
select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from death
--where location like '%states%'
where continent is not null and new_cases <>0
--group by date
order by 1,2

--loking at total population vs vactinations
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location,dea.date)
as rollingpeaoplevactinated
from death dea
join vactinations vac
 on  dea.location=vac.location
    and dea.date=vac.date
	where dea.continent is not null
order by 2,3

--USE CTE

WITH POPvsVAC (continent,location,date,population,new_vaccinations,rollingpeoplevactinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location,dea.date)
as rollingpeaoplevactinated
from death dea
join vactinations vac
 on  dea.location=vac.location
    and dea.date=vac.date
	where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevactinated/population)*100
from POPvsVAC



--TEMP TABLE
DROP TABLE if exists #percentpopulationvactinated
create table #percentpopulationvactinated
(continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevactinated numeric
 )
insert into #percentpopulationvactinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location,dea.date)
as rollingpeaoplevactinated
from death dea
join vactinations vac
 on  dea.location=vac.location
    and dea.date=vac.date
	where dea.continent is not null
--order by 2,3
select *,(rollingpeoplevactinated/population)*100
from #percentpopulationvactinated


--creating view to store data for later visualizations
Create view percentpopulationvactinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location,dea.date)
as rollingpeaoplevactinated
from death dea
join vactinations vac
 on  dea.location=vac.location
    and dea.date=vac.date
	where dea.continent is not null
--order by 2,3

select *
from percentpopulationvactinated




