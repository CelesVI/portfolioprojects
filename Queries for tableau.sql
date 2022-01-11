-- Global numbers by date for Tableau
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, 
SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From Death
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Table no.2 
select location, sum(cast(new_deaths as bigint)) as TotalDeathCount
from Death
where continent is not null
and location not in('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

-- Table no. 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
round(max((total_cases/population)*100 ),2)as PercentPopulationInfected
From Death
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Table no.4
select location, population, date, max(total_cases) as HighestInfectCount,
round(max((total_cases/population)*100 ),2)as PercentPopulationInfected
from Death
where continent is not null
group by location, population, date
order by PercentPopulationInfected desc

