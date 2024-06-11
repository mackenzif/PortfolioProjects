-- Full Covid Deaths Data
Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Full Covid Vaccinations Data
Select *
From PortfolioProject..CovidVaccinations$
order by 3,4

-- Total Cases vs. Total Deaths
-- (i.e. Historic Death Percentage per Day in the United States)
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
 AND location='United States'
order by 1,2

-- Total Cases vs. The Population
-- (i.e. Daily percentage of the population that has at some point contracted COVID in the United States)
Select location, date, Population, total_cases, (total_cases/population)*100 as ContractionPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
 AND location='United States'
order by 1,2

-- Current Highest Total Cases vs. The Population by Country
-- (i.e. Percentage of the population that has at some point contracted COVID by Country)
Select Location, Population, MAX(total_cases) as HighestTotalCases, (MAX(total_cases)/population)*100 as ContractionPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, Population
order by ContractionPercentage desc

-- Countries with the Highest Death Count
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Continents with the Highest Death Count
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Cases vs. Deaths
-- (i.e. Global death percentage per day)
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null 
	AND new_cases != 0
Group by date
order by date

-- Global Death Percentage Total
-- (i.e. Sum of daily counts to show overall Death Percentage since the onset of COVID)
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null 
	AND new_cases != 0

-- Total Population vs. Vaccinations
-- (i.e. How many people have been vaccinated since the onset of COVID by day)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as
(
-- Total Population vs. Vaccinations
-- (i.e. Percentage of population vaccinated by day per country)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
)

Select *, (Rolling_People_Vaccinated/population)*100 as Percent_Population_Vaccinated
From PopvsVac
Order by 2,3

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations float,
Rolling_People_Vaccinated float,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

Select *, (Rolling_People_Vaccinated/population)*100 as Percent_Population_Vaccinated
From #PercentPopulationVaccinated
Order By 2,3


--
--
--
-- Creating Views to Store Data for Later Visualizations
--
--
--

-- Total Cases vs. Total Deaths
Create View Total_Cases_vs_Total_Deaths as
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
 AND location='United States'

Select *
From Total_Cases_vs_Total_Deaths

-- Total Cases vs. The Population
Create View Contraction_Percentage as
Select location, date, Population, total_cases, (total_cases/population)*100 as ContractionPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
 AND location='United States'

 Select *
 From Contraction_Percentage

-- Current Highest Total Cases vs. The Population by Country
Create View Highest_Contraction_Rate as
Select Location, Population, MAX(total_cases) as HighestTotalCases, (MAX(total_cases)/population)*100 as ContractionPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, Population

Select *
From Highest_Contraction_Rate

-- Countries with the Highest Death Count
Create View Countries_Death_Count as
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location

Select *
From Countries_Death_Count

-- Continents with the Highest Death Count
Create View Continents_Death_Count as
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent

Select *
From Continents_Death_Count

-- Global Cases vs. Deaths
Create View Death_Percentage as
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null 
	AND new_cases != 0
Group by date

Select *
From Death_Percentage

-- Global Death Percentage Total
Create View Death_Percentage_Sum as
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null 
	AND new_cases != 0

Select *
From Death_Percentage_Sum

-- Total Population vs. Vaccinations
Create View Rolling_Vaccination_Count as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
-- , (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From Rolling_Vaccination_Count

