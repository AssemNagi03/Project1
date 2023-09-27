Select *
From Project#1.dbo.CovidDeaths$
Where continent is not null 
order by 3,4;

-- Select Data that we are going to be starting with

SELECT continent, location,date,new_cases , total_cases, total_deaths, population
FROM Project#1.dbo.CovidDeaths$
Where continent is not null
order by 2,3;


-- Total Cases vs Total Deaths 

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases )*100 as DeathPercentage
FROM Project#1.dbo.CovidDeaths$
Where continent is not null
order by 1,2;

--show likehood of dying if you convert covid in united state

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases )*100 as DeathPercentage
FROM Project#1.dbo.CovidDeaths$
Where continent is not null and location like '%states%'
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, ( total_cases/ population )*100 as PercentPopulationInfected
FROM Project#1.dbo.CovidDeaths$
--Where continent is not null and location like '%states%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT location, Population, max (total_cases) as HighestInfectionCount , max( total_cases/ population )*100 as PercentPopulationInfected
FROM Project#1.dbo.CovidDeaths$
group by  Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

SELECT location, max (total_deaths) as TotalDeathCount , max( total_deaths/ population )*100 as PercentPopulation_deaths
FROM Project#1.dbo.CovidDeaths$
Where continent is not null 
group by  Location
order by TotalDeathCount desc;

-- Showing contintents with the highest death count per population

SELECT continent , max (total_deaths) as TotalDeathCount
FROM Project#1.dbo.CovidDeaths$
Where continent is not null 
group by  continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT sum(convert(int, new_cases)) as "Total Cases" , sum (cast (new_deaths as int)) as "Total Deaths", sum(convert(int, new_cases))  / sum (cast (new_deaths as int))*100 as DeathPercentage
FROM Project#1.dbo.CovidDeaths$
Where continent is not null 
order by 1,2;

--use Project#1
--go

select *
from CovidVaccinations$;

-- Total Population vs Vaccinations

select cv.continent, cv.location, cv.date, cv.new_vaccinations, population,
sum (cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) 
as RollingPeopleVaccinated
from CovidVaccinations$ cv join CovidDeaths$ cd
on cv.location = cd.location
and cv.date = cd.date
where cd.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVas (continent, location, date,new_vaccinations, population, RollingPeopleVaccinated )
as 
(
select cv.continent, cv.location, cv.date, cv.new_vaccinations, population,
sum (cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) 
as RollingPeopleVaccinated
from CovidVaccinations$ cv join CovidDeaths$ cd
on cv.location = cd.location
and cv.date = cd.date
where cd.continent is not null 
--order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100 as precentage
From PopvsVas;

-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(50),
Location varchar(50),
data datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select cv.continent, cv.location, cv.date, cv.new_vaccinations, population,
sum (cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) 
as RollingPeopleVaccinated
from CovidVaccinations$ cv join CovidDeaths$ cd
on cv.location = cd.location
and cv.date = cd.date
--where cd.continent is not null 
--order by 2,3;

select *
from #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations
create view percentPopulationVaccinated
as
(
select cv.continent, cv.location, cv.date, cv.new_vaccinations, population,
sum (cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) 
as RollingPeopleVaccinated
from CovidVaccinations$ cv join CovidDeaths$ cd
on cv.location = cd.location
and cv.date = cd.date
--where cd.continent is not null 
--order by 2,3;
)

select *
from percentPopulationVaccinated;
