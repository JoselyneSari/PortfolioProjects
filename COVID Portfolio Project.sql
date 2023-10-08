
Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order By 3,4 

--Select *
--From PortfolioProject..CovidVaccination$
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
Order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group By Location, Population
Order by PercentPopulationInfected desc

--Showing the countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group By Location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null
Group By location
Order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group By continent
Order by TotalDeathCount desc

--GLobal Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
Order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacciantions numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualisation
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated




