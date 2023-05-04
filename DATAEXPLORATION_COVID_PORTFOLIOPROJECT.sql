SELECT *
FROM PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2 


--Looking at Total Cases vs Total Deaths 
--Shows Likelihood of dying if you contact in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%philippines%'
Order by 1,2 

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
Order by 1,2 


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
Group by location, population
Order by PercentPopulationInfected desc


--Showing the Countries where the Highest Death Count Population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
where continent is not null
Group by location
Order by TotalDeathCount desc


-- Showing continents with the highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%philippines%'
where continent is not null
--Group by date
Order by 1,2 

--Combine columns (date and location) 

Select *
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PopulationVaccinated
Create Table #PopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PopulationVaccinated 


--Creating View to store data for visualization

USE PortfolioProject 
GO
Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PopulationVaccinated