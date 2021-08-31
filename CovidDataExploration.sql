select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood in your country 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- Shows percentage of population who got COVID

select Location, date, total_cases, total_deaths, population  , (total_cases/population)*100 as PercentageofCasesByPopulation
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population 

select Location, max(total_cases) as HighestInfectionCount, population  , max((total_cases/population))*100 as PercentageofCasesByPopulation
from PortfolioProject..CovidDeaths
group by location, population
order by PercentageofCasesByPopulation desc


-- Showing Countries with Highest Death Count 
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing Continents with Highest Death Count 
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null and location not in ('World')
group by location
order by TotalDeathCount desc

-- Showing continents with their DeathPercentage 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is null and location not in ('World')
order by 1,2

-- Shows continents with their percentage of people who got COVID 
select Location, date, total_cases, total_deaths, population  , (total_cases/population)*100 as PercentageofCasesByPopulation
from PortfolioProject..CovidDeaths
where  continent is null and location not in ('World')
order by 1,2

 --Looking at continents with Highest Infection Rate compared to Population 

select Location, max(total_cases) as HighestInfectionCount, population  , max((total_cases/population))*100 as PercentageofCasesByPopulation
from PortfolioProject..CovidDeaths
where  continent is null and location not in ('World')
group by location, population
order by PercentageofCasesByPopulation desc

--Global Numbers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Looking at Total Population vs Vaccination 



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))  over  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2, 3


-- USING CTE to perform calculation on partition By in previous query 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))  over  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
Select * , (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated 
From PopvsVac

--Using CTE again to find current %population vaccinataed and ordering my countries with highest vaccination rates 
With PopvsVac ( Location, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.location, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))  over  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
Select Max(RollingPeopleVaccinated/Population)*100 as CurrentPerofPopulationVaccinated , location
From PopvsVac
group by location
order by CurrentPerofPopulationVaccinated desc 



---Creating View 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


-- Analysing COVID Percentages by Total Cases vs Population for different ranges of  Human Development Index 
-- Range :  Very High 
Select 
dea.location, max(total_cases) as highestcasecount, vac.gdp_per_capita, vac.human_development_index, 
max(total_cases/dea.population)*100 as PercentageofCasesByPopulation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.human_development_index > 0.80
group by dea.location, vac.gdp_per_capita, vac.human_development_index
order by PercentageofCasesByPopulation desc

--Range : High  
Select 
dea.location, max(total_cases) as highestcasecount, vac.gdp_per_capita, vac.human_development_index, 
max(total_cases/dea.population)*100 as PercentageofCasesByPopulation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.human_development_index  between 0.70 and 0.79
group by dea.location, vac.gdp_per_capita, vac.human_development_index
order by PercentageofCasesByPopulation desc

--Range : Medium 
Select 
dea.location, max(total_cases) as highestcasecount, vac.gdp_per_capita, vac.human_development_index, 
max(total_cases/dea.population)*100 as PercentageofCasesByPopulation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.human_development_index  between 0.55 and 0.70
group by dea.location, vac.gdp_per_capita, vac.human_development_index
order by PercentageofCasesByPopulation desc

--Range : Low 
Select 
dea.location, max(total_cases) as highestcasecount, vac.gdp_per_capita, vac.human_development_index, 
max(total_cases/dea.population)*100 as PercentageofCasesByPopulation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent  is not null and vac.human_development_index  < 0.55
group by dea.location, vac.gdp_per_capita, vac.human_development_index
order by PercentageofCasesByPopulation desc






