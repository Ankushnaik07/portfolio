/* Exploring COVID 19 data 
   Skills used:Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
   Table names:covid deaths,covid vaccine
   Data taken from:https://ourworldindata.org/covid-deaths
*/


--showing the contents of tables: covid deaths.
SELECT * 
FROM [portfolio project]..['covid deaths']
ORDER BY 3,4;

--showing the contents of tables:covid vaccines.

SELECT * 
FROM [portfolio project]..['covid vaccines']
ORDER BY 3,4;

--Taking the required data

SELECT LOCATION,DATE,total_cases,new_cases,total_deaths,population
FROM [portfolio project]..['covid deaths']
WHERE continent is not null
order by 1,2;

--the following query shows total cases vs total deaths and death percentage
--the country I selected was India

SELECT location,date,total_cases,total_deaths,(CAST (total_deaths AS float)/CAST(total_cases AS float))*100 as DEATH_PERCENTAGE
FROM [portfolio project]..['covid deaths']
WHERE location like 'INDIA'
order by 5 desc;

--the total percentage of population effected by COVID-19 in India
SELECT location,date,total_cases,population,(cast(total_cases as float)/(population))*100 as infectedpercentage
from [portfolio project]..['covid deaths']
WHERE location like 'INDIA'
order by 5 desc;

--the total population infected all over world 
SELECT location,population,max(total_cases) as total_cases ,(max(cast(total_cases as float))/(population))*100 as infected_percentage
from [portfolio project]..['covid deaths']
group by location, population
order by infected_percentage desc;

--the total deaths_percentage occured all over world 
SELECT location,population,max(total_deaths)as total_deaths,(max(cast(total_deaths as float))/(population))*100 as death_percentage
from [portfolio project]..['covid deaths']
group by location, population
order by  death_percentage desc;

--countries with highest death count
select location,population,MAX(cast(Total_deaths as int))as deaths
from [portfolio project]..['covid deaths']
where continent is not null
group by location,population
order by deaths desc;

--grouping by continents
--Showing contintents with the highest death count per population
select continent,MAX(cast(Total_deaths as int))as deaths
from [portfolio project]..['covid deaths']
where continent is not null
group by continent
order by deaths desc;


--total cases of COVID globally
select sum(cast(new_cases as int)) as total_cases,sum(cast(new_deaths as int)) as death_toll,sum(convert(float,new_deaths))/ sum(convert(float,total_cases))*100 as death_percentage
from [portfolio project]..['covid deaths']
where continent is not null
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from [portfolio project]..['covid deaths'] d
join [portfolio project]..['covid vaccines'] v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from [portfolio project]..['covid deaths'] d
join [portfolio project]..['covid vaccines'] v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
)
Select *, (rolling_people_vaccinated/Population)*100 
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from [portfolio project]..['covid deaths'] d
join [portfolio project]..['covid vaccines'] v
	on d.location=v.location
	and d.date=v.date
	
Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from [portfolio project]..['covid deaths'] d
join [portfolio project]..['covid vaccines'] v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null