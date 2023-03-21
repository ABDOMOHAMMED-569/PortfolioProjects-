select * 
from CovidDeaths$
where continent is not null
order by 3,4 



select * 
from CovidVaccinations$
order by 1,2



--select Data we are going to be using 

select  location ,date , total_cases ,new_cases , total_deaths , population
from CovidDeaths$
where continent is not null
order by 1,2




--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in your country 

select  location ,date , total_cases , total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths$
WHERE location like '%states%'
and continent is not null
order by 1,2




--Looking at Total Cases vs Population 
--Shows what percantage of population got Covid 

select  location ,date , population ,total_cases ,(total_cases/population)*100 as cases_Percentage
from CovidDeaths$
--WHERE location like '%states%'
where continent is not null
order by 1,2




--Looking at countries with Highest Infection Rate compared to Population 

select  location , population ,Max(total_cases) as Highest_Infaction_Rate ,Max((total_cases/population))*100 as cases_percantage 
From CovidDeaths$ 
--WHERE location like '%states%'
where continent is not null
Group by Location , Population 
Order by cases_percantage desc


--Let's Break things down by CONTINENT 

select  continent , MAX(cast(total_deaths as int)) as Total_Deaths_Count 
from CovidDeaths$
--WHERE location like '%states%'
where continent is not null
Group by continent 
order by Total_Deaths_Count DESC


--Let's Break Things Down By CONTINET 

--Showing the continent with the Highest seath count per Population 


select  continent , MAX(cast(total_deaths as int)) as Total_Deaths_Count 
from CovidDeaths$
--WHERE location like '%states%'
where continent is not null
Group by continent 
order by Total_Deaths_Count DESC




--GLOBAL NUMBERS 

select SUM(new_cases) as Total_Cases ,sum(cast(new_deaths as int)) as Total_deaths , sum(cast(new_deaths as int))/sum (new_cases)*100  as Death_Percentage
from CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--Group by date
order by 1,2



--LOoking fro Total Population vs Vaccinations 

with PopvsVac (continant , location , date , population , new_vaccinations , Rolling_people_Vaccinated)
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int))OVER (Partition by dea.Location order by dea.location , dea.date) as Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated/population)*100 
from CovidDeaths$ Dea
join CovidVaccinations$ Vac  
    ON Dea.Location = Vac.Location 
	and Dea.date = Vac.date  
where dea.continent is not null
--order by 2,3
)
--USE CTE
select * , (Rolling_people_Vaccinated/population)*100
from PopvsVac


--TEMP TABLE 
drop table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
Location nvarchar(255),
Date Datetime ,
population numeric ,
new_vaccinations numeric ,
Rolling_people_Vaccinated numeric 
)



insert into #PercentPopulationVaccinated 
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int))OVER (Partition by dea.Location order by dea.location , dea.date) as Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated/population)*100 
from CovidDeaths$ Dea
join CovidVaccinations$ Vac  
    ON Dea.Location = Vac.Location 
	and Dea.date = Vac.date  
--where dea.continent is not null
--order by 2,3


select * , (Rolling_people_Vaccinated/population)*100
from #PercentPopulationVaccinated 


--createing View to store data for later visualizations 

create View PercentPopulationVaccinated as
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int))OVER (Partition by dea.Location order by dea.location , dea.date) as Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated/population)*100 
from CovidDeaths$ Dea
join CovidVaccinations$ Vac  
    ON Dea.Location = Vac.Location 
	and Dea.date = Vac.date  
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated 