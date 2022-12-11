select * from [dbo].[CovidDeaths]
--total cases and percentage of deaths
select location ,date ,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [dbo].[CovidDeaths]
where location = 'india'
order by 1,2
--shows percentage of populatein got covid
select location ,date ,population,total_cases,total_deaths,(total_cases/population)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where location = 'india'
order by 1,2
--countries with higher infection rate compare to populateion
select location, population, max(total_cases) as HighestInfectioncount , max((total_cases/population))*100 as percentagepopulationaffected
from [dbo].[CovidDeaths]
group by location, population
order by percentagepopulationaffected desc

--showing countries with highest death count per populations
select location, max((cast(total_deaths as int))) as total_death_count
from [dbo].[CovidDeaths]
where continent is not null
group by location
order by total_death_count desc

--breaking things by continent
select location, max((cast(total_deaths as int))) as total_death_count
from [dbo].[CovidDeaths]
where continent is  null
group by location
order by total_death_count desc

--global numbers

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [dbo].[CovidDeaths]
where continent is not null
group by date 
order by 1,2

--total global cases
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2

--looking at total populatin vs vaccination
select a.continent,a.location,a.date,a.population,b.new_vaccinations,sum(convert(int, b.new_vaccinations)) over (partition by a.location 
order by a.location,a.date) as RollingPopulationvaccinated
from [dbo].[CovidDeaths] a
join [dbo].[CovidVaccinations] b
on a.location = b.location
and a.date =b.date
where a.continent is not  null
order by 2,3

--using cte to known percentage to people got vaccinated
with result(continent,location,date,population,new_vaccinations,RollingPopulationvaccinated)  as
(

select a.continent,a.location,a.date,a.population,b.new_vaccinations,sum(convert(int, b.new_vaccinations)) over (partition by a.location 
order by a.location,a.date) as RollingPopulationvaccinated
from [dbo].[CovidDeaths] a
join [dbo].[CovidVaccinations] b
on a.location = b.location
and a.date =b.date
where a.continent is not  null
--order by 2,3
)
select *, (RollingPopulationvaccinated/population)*100
from result
 
 --createing a temp table
 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
   continent nvarchar(255),
   location nvarchar(255), 
   date datetime,
   population numeric,
   new_vaccinations numeric,
   RollingPopulationvaccinated numeric
)
 insert into #percentpopulationvaccinated
 select a.continent,a.location,a.date,a.population,b.new_vaccinations,sum(convert(int, b.new_vaccinations)) over (partition by a.location 
order by a.location,a.date) as RollingPopulationvaccinated
from [dbo].[CovidDeaths] a
join [dbo].[CovidVaccinations] b
on a.location = b.location
and a.date =b.date
--where a.continent is not  null
--order by 2,3
select *, (RollingPopulationvaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualization
 
 create view percentpopulationvaccinated as
  select a.continent,a.location,a.date,a.population,b.new_vaccinations,sum(convert(int, b.new_vaccinations)) over (partition by a.location 
order by a.location,a.date) as RollingPopulationvaccinated
from [dbo].[CovidDeaths] a
join [dbo].[CovidVaccinations] b
on a.location = b.location
and a.date =b.date
--where a.continent is not  null
--order by 2,3










