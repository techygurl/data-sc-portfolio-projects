select*
from project..[covid deaths] 
where continent is not null
order by 3,4 

alter table[dbo].[covid deaths]
alter column total_deaths float;


alter table[dbo].[covid deaths]
alter column total_deaths float;

--select*
--from project..[covid vaccinations]
--order by 3,4

--select data to use

select location,date,total_cases,new_cases,total_deaths,population_density
from  project..[covid deaths]
order by 1,2

--looking for total cases vs total deaths
select location,date,total_cases,total_deaths, ( total_deaths / total_cases)
from  project..[covid deaths]
order by 1,2
--shows likelyhood of dying if you have covid in your country
Select Location, date, total_cases, total_deaths,  (total_deaths /total_cases)*100 as DeathPercentage
From Project..[covid deaths]
where location like '%nigeria%'
order by 1,2

--total cases vs population
--what percentage of population got covid
Select Location, date, total_cases, population_density, (  total_cases/population_density )*100 as percentpopulationinfected
From Project..[covid deaths]
where location like '%nigeria%'
order by 1,2

--country with higest infection rate
Select Location, population_density,max(total_cases) as higheseinfectioncount, max( (total_cases/population_density ))*100 as percentpopulationinfected
From Project..[covid deaths]
Group by population_density,location
order by  percentpopulationinfected desc

--country with highest death count per population
Select Location, max(total_deaths) as totaldeathcount
From Project..[covid deaths]
where continent is not null
Group by population_density,location
order by totaldeathcount  desc

--lets check by continet
Select continent, max(total_deaths) as totaldeathcount
From Project..[covid deaths]
where continent is not null
Group by continent
order by totaldeathcount desc

--- above showing continent with highest death count


-- breaking global numbers
Select sum(new_cases)as totalcase,sum(new_deaths)as totaldeaths, sum(new_deaths)/sum
 (new_cases)*100 as DeathPercentage
From Project..[covid deaths]
--where location like '%nigeria%'
where continent is not  null
--group by date
order by 1,2

---check population vs vaccination
--use cte
with popvsvac(continent,location,date,population,new_vaccinations,rollpeoplevacc)
as
(
 select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over( partition by dea.location order by dea.location,dea.date)as rollpeoplevacc
--(rollpeoplevacc/population)*100
from project..[covid deaths]dea
join project..[covid vaccinations] vac
 on dea.location = vac.location 
 and dea.date = vac.date
where dea.continent is not  null
--order by 2,3
)
select*,(rollpeoplevacc/population)*100
from popvsvac

---temp table
drop table if exists #percentpopvacc
create table #percentpopvacc
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollpeoplevacc numeric
)
insert into #percentpopvacc
 select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over( partition by dea.location order by dea.location,dea.date)as rollpeoplevacc
--(rollpeoplevacc/population)*100
from project..[covid deaths]dea
join project..[covid vaccinations] vac
 on dea.location = vac.location 
 and dea.date = vac.date
where dea.continent is not  null
--order by 2,3
select*,(rollpeoplevacc/population)*100
from #percentpopvacc

--create view to store data for later visualizations
Create View percentpopvacc as
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over( partition by dea.location order by dea.location,dea.date)as rollpeoplevacc
--(rollpeoplevacc/population)*100
from project..[covid deaths]dea
join project..[covid vaccinations] vac
 on dea.location = vac.location 
 and dea.date = vac.date
where dea.continent is not  null
--order by 2,3

select*
from percentpopvacc