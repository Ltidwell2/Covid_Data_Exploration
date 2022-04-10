--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`
Where location = 'United States'
Order by 1,2;


--Total Cases vs Population

Select location, date, total_cases, population,(total_cases/population)*100 as infection_percentage
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`
Where location = 'United States'
Order by 1,2;


--Countries with highest infection rate based on population

Select location, population, Max(total_cases) as total_infection_count, Max((total_cases/population))*100 as infection_percentage
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`
Group by location, population
Order by infection_percentage desc;


--Countries with highest death rate based on population

Select location, population, Max(total_deaths) as total_death_count, Max((total_deaths/population))*100 as death_percentage
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`
Group by location, population
Order by death_percentage desc;


--Death rate by Continent

Select continent, Max(total_deaths) as total_death_count, Max((total_deaths/population))*100 as death_percentage
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`
Where continent is not null
Group by continent
Order by death_percentage desc;


--Global Cases and Deaths

Select date, new_cases, Sum(new_cases) Over(Order by date) as total_cases, new_deaths, Sum(new_deaths) Over (Order by date) as total_deaths
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`
Where location = 'World'
Group by date, new_cases, new_deaths
Order by 1,2;


--Vaccination rate based on population (CTE)

With PopvsVac
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(vac.new_vaccinations)
Over (Partition by dea.location Order by dea.location, dea.date) as total_country_vaccinations
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`dea
Join  `portfolio-project-346803.Portfolio_Project.Covid_Vaccinations` vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
)

Select *, (total_country_vaccinations/population)*100
From PopvsVac;


--Vaccination rate based on population (Temp Table)

Drop Table if exists Portfolio_Project.Percent_Population_Vaccinated;
Create Table Portfolio_Project.Percent_Population_Vaccinated
    (
    Continent string,
    Location string,
    Date datetime,
    Population numeric,
    New_Vaccinations numeric,
    total_country_vaccinations numeric,
    );

Insert into `portfolio-project-346803.Portfolio_Project.Percent_Population_Vaccinated`
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(vac.new_vaccinations)
Over (Partition by dea.location Order by dea.location, dea.date) as total_country_vaccinations
From `portfolio-project-346803.Portfolio_Project.Covid_Deaths`dea
Join  `portfolio-project-346803.Portfolio_Project.Covid_Vaccinations` vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null;

Select *, (total_country_vaccinations/population)*100 as Vaccination_Percentage
From Portfolio_Project.Percent_Population_Vaccinated;
