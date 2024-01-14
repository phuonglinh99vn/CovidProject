--select * 
-- from CovidVaccinations
-- order by 3, 4

select *
from CovidDeaths
where continent is not null
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%state%'
and continent is not null
order by 1, 2

-- Looking at Total cases vs Population

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%state%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%state%'
group by Location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count Per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Let's break things down by continenent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global numbers
select date, sum(new_cases), sum(cast(new_deaths as int)) --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
-- where location like '%state%'
where continent is not null
Group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
, 
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date

where dea.continent is not null
order by 2, 3


-- USE CTE

with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date

where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date

where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date

where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated