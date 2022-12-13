--Queries that is used for  Tableau visualizataion --

--1)--global numbers for total covid cases , total deaths and the death perentage.--
	select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
	from [dbo].[CovidDeaths]
	where continent is not null
	order by 1,2

--2)--European union is part of Europe---
	select location, max((cast(total_deaths as int))) as total_death_count
	from [dbo].[CovidDeaths]
	where continent is  null
	and location not in ('World','European Union','International')
	group by location
	order by total_death_count desc

--3)--Total population infected
	select location, population, max(total_cases) as HighestInfectioncount , max((total_cases/population))*100 as percentagepopulationaffected
	from [dbo].[CovidDeaths]
	group by location, population
	order by percentagepopulationaffected desc

--4)
     select location, population,date, max(total_cases) as HighestInfectioncount , max((total_cases/population))*100 as percentagepopulationaffected
	from [dbo].[CovidDeaths]
	group by location, population,date
	order by percentagepopulationaffected desc
