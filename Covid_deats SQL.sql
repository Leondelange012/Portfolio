--Select * from covidvaccinations

Select * from CovidDeaths
where continent is not null
order by 3,4

-- Select Data to be used

Select location, date, total_cases, New_cases, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs. total deaths
-- Shows the likelyhood of dying if you contract Covid in your Country

Select location, [Date], total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at the total cases vs the Population
-- Shows what percentage of population got Covid
Select location, [Date], total_cases,population,(CONVERT(float, population) / NULLIF(CONVERT(float, total_cases), 0))*100 as PercentofPopInfected
from CovidDeaths
where continent is not null
--where location like '%South Africa%'
order by 1,2

--Looking at countries with the highest Infection rate compared to population

Select location, MAX(total_cases) as HighestInfectionCount,population, MAX(CONVERT(float, population) / NULLIF(CONVERT(float, total_cases), 0))*100 as PercentofPopInfected
from CovidDeaths
where continent is not null
--where location like '%South Africa%'
group by location, Population
Order By PercentofPopInfected desc


-- Countries with  Highest death rate/Population

Select  continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, SUM(cast(New_cases as int)) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(Convert(float,New_deaths) / NULLIF(convert(float,new_cases), 0))*100 as Deathpercentage
from CovidDeaths
where continent is not null
--where location like '%South Africa%'
group by date
Order By 1,2

Select  SUM(cast(New_cases as int)) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(CONVERT(float, New_deaths) / NULLIF(CONVERT(float, new_cases), 0))*100 as DeathPercent
from CovidDeaths
where continent is not null
--where location like '%South Africa%'
--group by date
Order By 1,2 desc


-- Total Population vs Vaccinations
--CTE

With PopvsVac (Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/nullif population)*100
from CovidDeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3
)

Select * , (RollingPeopleVaccinated / NULLIF(CONVERT(float, population), 0))*100
From PopvsVac

--TEMP Table
Drop Table if exists #PercantagePopVaccinated
Create Table #PercantagePopVaccinated
(
Continent nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercantagePopVaccinated
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/nullif population)*100
from Covid_portf..CovidDeaths dea
join Covid_portf..covidvaccinations vac   
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3

Select * , (RollingPeopleVaccinated / NULLIF(CONVERT(float, population), 0))*100
From #PercantagePopVaccinated


--Creating view to store data for Visualizations

Create View PercantagePopVaccinated as
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/nullif population)*100
from Covid_portf..CovidDeaths dea
join Covid_portf..covidvaccinations vac   
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3






