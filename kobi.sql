select*
from portfolio_project..CovidDeaths$
--where continent is not null
order by 3, 4

select*
from portfolio_project..CovidVaccinations$
where continent is not null 
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..CovidDeaths$
order by 1,2

-- total_cases vs total_deaths
select location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as deaths_percentage
from portfolio_project..CovidDeaths$
order by 1,2

-- total_cases vs population
select location, date, total_cases, population,
(total_cases/population)*100 as infected_percentage
from portfolio_project..CovidDeaths$
order by 1,2 

-- countries with the highest infection rate compared to population 
select location, population, max(total_cases) as highest_infection_count,
max((total_cases/population))*100 as infected_percentage
from portfolio_project..CovidDeaths$
group by location,  population
order by 4 desc

-- countries with the highest death count per population
select location, max(cast(total_deaths as int)) as total_deaths_count
from portfolio_project..CovidDeaths$
where continent is not null 
group by location
order by 2 desc

-- continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as total_deaths_count
from portfolio_project..CovidDeaths$
where continent is not null 
group by continent
order by 2 desc

-- Global numbers...
select sum(new_cases)as new_cases_globally, SUM(cast(new_deaths as int)) as new_deaths_globally, SUM(cast(new_deaths as int))/ sum(new_cases)*100 as death_percentage_globally  
from portfolio_project..CovidDeaths$
where continent is not null 

-- Global numbers by date
select date, sum(new_cases)as new_cases_globally, SUM(cast(new_deaths as int)) as new_deaths_globally, SUM(cast(new_deaths as int))/ sum(new_cases)*100 as death_percentage_globally  
from portfolio_project..CovidDeaths$
where continent is not null 
group by date
order by 1 desc

-- total population vs vaccinated people
with population_vs_vaccinated (continent, location, date, population, new_vaccinations, vaccinated_per_day) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations, SUM(cast (vacci.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as vaccinated_per_day
from portfolio_project..CovidDeaths$ as dea
join portfolio_project..CovidVaccinations$ as vacci
on dea.location = vacci.location
and dea.date = vacci.date
where dea.continent is not null 
)
select *, (vaccinated_per_day/population)*100 as vaccinated_percentage
from population_vs_vaccinated





