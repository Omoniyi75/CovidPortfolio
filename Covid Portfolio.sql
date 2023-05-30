Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2

--Total cases vs Population 
Select location, date,population, total_cases, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where location like '%Nigeria%'
Order by 1,2


--Looking at countries with highest infection rate compare to their total population 
Select location,population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Infected_Percentage
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
Group by location, population
Order by Infected_Percentage desc

-- Showing the total death per population
Select location,population, MAX(total_deaths) as Highest_death_Count, MAX(total_deaths/population)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by Highest_death_Count desc

-- LET'S BREAK IT DOWN BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) as Total_death_Count
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by Total_death_Count desc

--GLOBAL NUMBERS 

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group By date
Order by 1,2

--Looking at Total population vs vaccination

Select *
From PortfolioProject..CovidDeaths dth 
Join PortfolioProject..CovidVaccinations vct
on  dth.location = vct.location
and dth.date = vct.date

	Select dth.continent, dth.location, dth.date, dth.population, vct.new_vaccinations,
	SUM(CONVERT(int,vct.new_vaccinations)) OVER (Partition by dth.location Order by dth.location, dth.date) as Rolling_Poeple_vaccinated 
	From PortfolioProject..CovidDeaths dth 
	Join PortfolioProject..CovidVaccinations vct
	on  dth.location = vct.location
	and dth.date = vct.date
	Where dth.continent is not null 
	Order by 2,3

	-- USE CTE 

	With popvsVac (continent, location, date, population,new_vaccinations,Rolling_Poeple_vaccinated) 
	AS 
	(
	Select dth.continent, dth.location, dth.date, dth.population, vct.new_vaccinations,
	SUM(CONVERT(int,vct.new_vaccinations)) OVER (Partition by dth.location Order by dth.location, dth.date) as Rolling_Poeple_vaccinated 
	From PortfolioProject..CovidDeaths dth 
	Join PortfolioProject..CovidVaccinations vct
	on  dth.location = vct.location
	and dth.date = vct.date
	Where dth.continent is not null and dth.location like '%Nigeria%'
	--Order by 2,3
	)
	Select *, (Rolling_Poeple_vaccinated/population)*100 as Percentage_people
	From popvsVac



	--TEMP TABLE 
	Drop Table if exists #PercentagePeopleVaccinated
	Create Table #PercentagePeopleVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	date datetime, 
	Population numeric, 
	New_vaccinations numeric, 
	Rolling_Poeple_vaccinated numeric 
	)

	Insert into  #PercentagePeopleVaccinated
	Select dth.continent, dth.location, dth.date, dth.population, vct.new_vaccinations,
	SUM(CONVERT(int,vct.new_vaccinations)) OVER (Partition by dth.location Order by dth.location, dth.date) as Rolling_Poeple_vaccinated 
	From PortfolioProject..CovidDeaths dth 
	Join PortfolioProject..CovidVaccinations vct
	on  dth.location = vct.location
	and dth.date = vct.date
	Where dth.continent is not null and dth.location like '%Nigeria%'
	--Order by 2,3
	
	Select *, (Rolling_Poeple_vaccinated/population)*100 as Percentage_people
	From #PercentagePeopleVaccinated

	

	--Creating view to store data for later visualization

	Create View PercentPopulationVaccinated as 
	Select dth.continent, dth.location, dth.date, dth.population, vct.new_vaccinations,
	SUM(CONVERT(int,vct.new_vaccinations)) OVER (Partition by dth.location Order by dth.location, dth.date) as Rolling_Poeple_vaccinated 
	From PortfolioProject..CovidDeaths dth 
	Join PortfolioProject..CovidVaccinations vct
	on  dth.location = vct.location
	and dth.date = vct.date
	Where dth.continent is not null and dth.location like '%Nigeria%'
	--Order by 2,3

	Select * 
	From PercentPopulationVaccinated