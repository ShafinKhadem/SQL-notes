--1

select STREET_ADDRESS, CITY, STATE_PROVINCE, POSTAL_CODE
from LOCATIONS
order by POSTAL_CODE asc ;


-- 2

select (substr(FIRST_NAME,1,1)||'. '||LAST_NAME) Full_Name, (SALARY*(1+nvl(COMMISSION_PCT,0))) Current_Annual_Salary, (SALARY*(1+nvl(COMMISSION_PCT,0))*1.1) New_Annual_Salary
from EMPLOYEES
where LAST_NAME like 'M%'
or LAST_NAME like 'm%';

-- 3

select ((add_months(trunc(HIRE_DATE,'MONTH'),1))-HIRE_DATE) Days
from EMPLOYEES;

-- 4

select LPAD(FIRST_NAME,20,' ') First_Name, DEPARTMENT_ID
from EMPLOYEES
where DEPARTMENT_ID=10
or DEPARTMENT_ID=30
order by length(FIRST_NAME)desc ;

-- 5

select MANAGER_ID, count(*) Employee_count, avg(nvl(SALARY,0)) Avg_Salary
from EMPLOYEES
group by MANAGER_ID
having count(*) > 4 and avg(SALARY) > 2000
order by Employee_count desc , Avg_Salary asc;
