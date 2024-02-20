-- Select Data that we are going to be using

Select Location,date, total_cases, new_cases, total_deaths, population
from ProtfolioProject..CovidDeaths
order by 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you cantract covid in your country

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from ProtfolioProject..CovidDeaths
where location like '%Nepal%'
order by 1,2

--Looking at Total Cases vs Population

Select Location, date,Population, total_cases, (cast(total_cases as float)/cast(Population as float))*100 as PercentPopulationInfected
from ProtfolioProject..CovidDeaths
where location like '%Nepal%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location,Population, Max(total_cases) as HighestInfectionCount, Max((cast(total_cases as float)/cast(Population as float))*100) 
as PercentPopulationInfected
from ProtfolioProject..CovidDeaths
--where location like '%Nepal%'
Group by Location, Population
order by PercentPopulationInfected Desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProtfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Showing Continent and World with Highest Death Count

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProtfolioProject..CovidDeaths
Where (continent is null) and (Location not in('High income', 'Upper middle income',
'Lower middle income', 'European Union', 'Low income'))
Group by Location
Order by TotalDeathCount desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


