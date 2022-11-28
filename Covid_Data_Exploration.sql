-- Select data we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
Where continent is not null
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death by contraction of Covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location = 'United States' and continent is not null
order by 1, 2

--Looking at Total Cases vs Population
Select Location, date, total_cases, Population, (total_cases/Population)*100 as percentInfected
from CovidDeaths
Where location = 'United States' and continent is not null
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionFound,  MAX((total_cases/Population))*100 as percentInfected
from CovidDeaths
Where continent is not null
Group by Location, Population
order by percentInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Looking at Continents with the highest Death Count per Population
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null
Group by Continent
order by TotalDeathCount desc

-- Looking at percentage of cases resuting in death worldwide
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
from CovidDeaths
Where continent is not null
Group By date
order by date

-- Looking at rolling percent of population that is vaccinated
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercOfPopVaccinated
From PopvsVac
Order by 3,2,1


-- Create Temp Table to look at above data
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as PercentOfPopVaxed
From #PercentPopulationVaccinated