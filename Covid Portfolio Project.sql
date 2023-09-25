Select *
From PortfolioProject..CovidDeaths
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select Location, Date, Total_cases, New_cases, Total_deaths, Population
From PortfolioProject..CovidDeaths
Order By 1,2

--Total Cases vs Total Deaths

Select Location, Date, Total_cases, Total_deaths, (Cast(Total_deaths as int)/Cast(Total_cases as int))
From PortfolioProject..CovidDeaths
Order By 1,2

--Shows likelihood of dying if you contract covid in your country

Select Location, Date, total_cases, total_deaths, (CONVERT(float, total_deaths)/Nullif(Convert(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states'
Order By 1,2

--Total Cases vs Population
--Shows what percentage of population infected with Covid

Select Location, Date, Population, total_cases,(CONVERT(float, total_cases)/Nullif(Convert(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states'
Order By 1,2

--Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, (CONVERT(float, Max(total_cases))/Nullif(Convert(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states'
Group By Location, Population
Order By PercentPopulationInfected desc

--Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent is not null
Group By Location
Order By TotalDeathCount desc

--Breaking things down by Continent and Income

--Showing continents and income with the highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent is null
Group By Location
Order By TotalDeathCount desc

--Global Numbers

Select Date, Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, (Sum(new_deaths)/Nullif(Sum(new_cases),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent is not null
Group by Date
Order By 1,2

Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, (Sum(new_deaths)/Nullif(Sum(new_cases),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent is not null
--Group by Date
Order By 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order by 2,3

--Using CTE to perform calculation on partition by in previous query

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform calculation on partition by in previous query

Drop Table if exists #PercentPoulationVaccinated
Create Table #PercentPoulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPoulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date =vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPoulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPoulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by 2,3



