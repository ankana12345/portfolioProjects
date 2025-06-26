Select *
From portfolio_project..CovidDeaths
Where continent is not null
order by 3, 4

--Select *
--From portfolio_project..CovidVaccinations
--order by 3, 4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From portfolio_project..CovidDeaths
Where continent is not null
order by 1, 2


-- looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, CAST(total_deaths as FLOAT)/NULLIF(total_cases,0) * 100 as DeathPercentage
From portfolio_project..CovidDeaths
Where continent is not null
and location like 'india'
order by 1, 2

--looking at total cases vs population
--shows what % of population got covid

Select location, date, total_cases, population, CAST(total_cases as FLOAT)/NULLIF(population,0) * 100 as PercentagePopulationInfected
From portfolio_project..CovidDeaths
Where continent is not null
and location like 'india'
order by 1, 2

--looking at countries with highest infection rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_deaths as FLOAT)/NULLIF(total_cases,0)) * 100 as PercentagePopulationInfected
From portfolio_project..CovidDeaths
Where continent is not null
Group by location, population
order by PercentagePopulationInfected desc

--showing countries with ighest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio_project..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--let's break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio_project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--showing the continents with highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio_project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers

Select date, SUM(new_cases) as NewCases, SUM(new_deaths) as NewDeaths, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as float))/SUM(nullif(new_cases , 0))* 100 as DeathPercentage --total_deaths, CAST(total_deaths as FLOAT)/NULLIF(total_cases,0) * 100 as DeathPercentage 
From portfolio_project..CovidDeaths
Where continent is not null
--and location like 'india'
Group By date
order by 1, 2

--grandtotal world cases

Select SUM(new_cases) as NewCases, SUM(new_deaths) as NewDeaths, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as float))/SUM(nullif(new_cases , 0))* 100 as DeathPercentage --total_deaths, CAST(total_deaths as FLOAT)/NULLIF(total_cases,0) * 100 as DeathPercentage 
From portfolio_project..CovidDeaths
Where continent is not null
order by 1, 2

--looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From portfolio_project..CovidDeaths dea
Join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

--using cte

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From portfolio_project..CovidDeaths dea
Join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From portfolio_project..CovidDeaths dea
Join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From portfolio_project..CovidDeaths dea
Join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated