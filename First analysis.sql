select *
from Death
order by 3,4


select *
from Vaccination
order by 3,4

-- Select the data that  we're going to use.
select location, date, total_cases, new_cases, total_deaths, population
from Death
order by 1,2

-- Looking at total cases, total deaths in a country
select location,date, total_cases, total_deaths, round(((total_deaths/total_cases) * 100),2) as death_percentaje
from Death
where location='Argentina'
order by 1,2

-- Looking the total cases vs population in a country.
select location,date, total_cases, population, round(((total_cases/population) * 100),2) as population_percentaje_with_covid
from Death
where location='Argentina'
order by 1,2

-- Looking countries with highest infection rate.
select location, max(total_cases) as HighestInfectionCount, population, max(round(((total_cases/population) * 100),2)) as Highest_percentaje_with_covid
from Death
where location='Argentina'
group by location, population
order by Highest_percentaje_with_covid desc

-- Showing countries with highest death percentaje per population
select top 10 location, max(cast(total_deaths as int)) as TotalDeathCount
from Death
where location not in('World','Europe','High income','Asia','Upper middle income',
'North America','European Union','South America','Africa','Lower middle income')
group by location, population
order by TotalDeathCount desc

-- Breaking down as continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Death
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Death
where location='World'
group by location

-- Global numbers by date

select date, sum(new_cases) as TotalCases, sum(cast(total_deaths as int)) as TotalDeathCount, max(round(((total_cases/population) * 100),2)) as Highest_percentaje_with_covid
from Death
where location is not null
group by date
order by TotalCases desc

-- Global numbers by date for Tableau

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Death
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Joining tables

select Death.location, Death.date, Death.population, vac.new_vaccinations
from Death
join Vaccination as vac
	on Death.continent = vac.continent
	and Death.date=vac.date
where Death.continent is not null
order by Death.date desc

-- New sums
select Death.location, Death.date, Death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by Death.location order by Death.location, Death.date) as total_vaccinations_location
from Death
join Vaccination as vac
	on Death.continent = vac.continent
	and Death.date=vac.date
--where Death.continent is not null
where Death.location='Argentina'
order by Death.location, Death.date

-- Use cit
select Death.location, Death.date, Death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by Death.location order by Death.location, Death.date) as total_vaccinations_location
from Death
join Vaccination as vac
	on Death.continent = vac.continent
	and Death.date=vac.date
--where Death.continent is not null
where Death.location='Argentina' and Death.date >'2020-12-25'
order by Death.location, Death.date desc

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Death.continent, Death.location, Death.date, Death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location, Death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Death
join Vaccination as vac
	on Death.continent = vac.continent
	and Death.date=vac.date
where Death.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, Death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location, Death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Death
join Vaccination as vac
	on Death.continent = vac.continent
	and Death.date=vac.date
--where Death.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedView as
Select Death.continent, Death.location, Death.date, Death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location, Death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Death
join Vaccination as vac
	on Death.continent = vac.continent
	and Death.date=vac.date
where Death.continent is not null