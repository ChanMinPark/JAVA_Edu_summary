/*count, sum, avg, min, max, stddev, variance*/
--사원의 수를 출력하라
select count(*) from employees;
--커미션을 받는 사원의 수
select count(commission_pct) from employees;
--커니션 평균, null은 연산에서 제외된다.
select avg(commission_pct) from employees;
select sum(commission_pct), avg(commission_pct), sum(commission_pct)/count(*) from employees;

--가장 큰 급여액은?
select max(salary) from employees;
--가장 많은 그병를 받는 사원의 이름은? -> 서브쿼리로 해결해야 함. 나중에 배움

--사원들의 급여의 총합, 평균과 표준편차, 그리고 분산을 구하세요.
select sum(salary), avg(salary), stddev(salary), variance(salary) from employees;
--소수점 이하 두 번째 자리까지만 표현하세요.
select sum(salary) as 합계
      , round(avg(salary),2) as 평균
      , round(stddev(salary),2) as 표준편차
      , round(variance(salary),2) as 분산
from employees;


/*group by, having*/
--특정 열을 기준으로 그룹핑 할 때 group by
--그룹핑 한 것을 비교 조건으로 사용할 때 having

--부서별 급여 평균을 출력하라.
select department_id, avg(salary)
from employees
group by department_id;

--부서별 사원의 수를 출력하라.
select department_id, count(*)
from employees
group by department_id;

--부서별 연봉의 평균을 출력하라.
select department_id, round(avg(coalesce(salary+salary*commission_pct, salary)),2) salary_avg
from employees
group by department_id;

--having
select department_id, round(avg(salary),2) as avg_sal
from employees
group by department_id
having avg(Salary) >= 2000
;

select department_id, round(avg(salary),2) as avg_sal
from employees
having avg(Salary) >= 2000
group by department_id
;

select department_id, avg_sal
from (select department_id, round(avg(salary),2) as avg_sal
      from employees
      group by department_id) t /*'인라인 뷰'라고 합니다.*/
where avg_sal >= 2000; --서브쿼리를 이용한 것


--부서별, 업무별 급여의 평균과 사원의 수를 출력하라.
select department_id, job_id, round(avg(salary),2), count(*)
from employees
group by department_id, job_id
order by department_id, job_id;

--위의 결과에 각 부서별 평균과, 사원의 수도 출력하고 싶습니다.
--전체 평균, 전체 사원의 수를 출력하고 싶습니다.
select department_id, job_id, round(avg(salary),2), count(*)
from employees
group by rollup(department_id, job_id) /*rollup은 소계(평균)을 출력한다.*/
order by department_id, job_id;

--위의 결과에 업무별 급여평균과 사원의 수도 출력하고 싶습니다.
select department_id, job_id, round(avg(salary), 2), count(*)
from employees
group by cube(department_id, job_id) /*cube는 전체 총계(평균)을 출력한다.*/
order by department_id, job_id;

/*grouping*/
--어떤 컬럼이 그룹핑 작업에 사용되었으면 1, 그렇지 않았으면 0을 반환
select
  nvl2(department_id, department_id||'', '소계') as 부서,
  nvl(job_id, decode(grouping(job_id), 1, '소계')) as 직무, /*소계 영역임을 다시 확인...*/
  round(avg(salary),2) as 평균,
  count(*)as 사원의수
from employees
group by cube(department_id, job_id) /*cube는 전체 총계(평균)을 출력한다.*/
order by department_id, job_id;

/*grouping_id*/
--두 컬럼 다 그룹핑에 사용되면 3, A컬럼만 그룹핑에 사용되면 1,
--B컬럼만 그룹핑에 사용되면 2, 두 컬럼 모두 사용 안되면 0
select
  nvl2(department_id, department_id||'',
        decode(grouping_id(department_id, job_id), 2, '소계',
                                                  3, '합계')) as 부서번호,
  nvl(job_id, decode(grouping_id(department_id, job_id), 1, '소계',
                                                        3, '합계')) as 직무,
  grouping_id(department_id, job_id) as GID,
  round(avg(salary),2) as 평균,
  count(*)as 사원의수
from employees
group by cube(department_id, job_id) /*cube는 전체 총계(평균)을 출력한다.*/
order by department_id, job_id;

--select * from employees;

/*grouping sets*/
--두 그룹에 대한 집계를 동시에 출력하고 싶다.

--부서별, 직무별 사원의 수를 각각 출력하세요.
select department_id||'' as department_id_job_id, count(*)
from employees
group by department_id
union
select job_id, count(*)
from employees
group by job_id;

--위의 코드를 grouping sets를 이용하여 작성하세요.
select nvl(department_id, '')||nvl(job_id,'') as group_id, count(*)
from employees
group by grouping sets(department_id, job_id);


/*Equi Join*/
-- =연산자로 조인 조건을 기술하는 조인

--103번 사원의 이름과 부서의 이름을 출력하세요.
select e.first_name, d.department_name
from employees e, departments d
where e.employee_id=103 and e.department_id = d.department_id;

--ANSI join
select e.first_name, d.department_name
from employees e
join departments d on e.department_id = d.department_id
where e.employee_id=103;


/*Self join*/
--사원번호가 103인 사원의 이름과 매니저 이름을 출력하세요.
--Self join : 동일한 테이블을 조인하는 것
select e.first_name as employee_name, m.first_name as manager_name
from employees e, employees m
where e.manager_id = m.employee_id and e.employee_id=103;

--ANSI join올...
select e.first_name as employee_name, m.first_name as manager_name
from employees e
join employees m on e.manager_id = m.employee_id
where e.employee_id=103;


/*103번 사원의 매니저가 근무하는 부서이름은?*/
--employees e. employees mm, departments d가 필요
select d.department_name as department_name
from employees e, employees m, departments d
where e.manager_id = m.employee_id and m.department_id=d.department_id and e.employee_id=103;


/*103번 사원의 직무 이름은?
직무는 jobs 테이블에 있습니다.*/
select j.job_title
from employees e, jobs j
where e.job_id=j.job_id and e.employee_id =103;

/*103번 사원의 사무실 주소(street_address)는?
주소는 locations 테이블에 있습니다.*/
desc locations;
desc jobs;
desc departments;
desc employees;

select l.street_address as Office_Address
from employees e, departments d, locations l
where e.department_id = d.department_id and d.location_id = l.location_id and e.employee_id=103;


--모든 사원의 매니저 이름을 출력하세요.
select e.first_name, m.first_name
from employees e, employees m
where e.manager_id = m.employee_id(+);

--모든 사원의 직무 이력을 출력하세요.
select e.employee_id, e.first_name, nvl(j.job_id, e.job_id)
from employees e, job_history j
where e.employee_id = j.employee_id(+)
order by e.employee_id;


/*Outer Join*/
--조인 조건에 사용하는 필드에 null이 포함되어 있을 경우 Outer join을 사용한다.
select e.first_name, m.first_name
from employees e, employees m
where e.manager_id = m.employee_id(+)
--    and e.first_name='Steven' and e.last_name='King';
;
--마찬가지로
select e.first_name, m.first_name
from employees e
left outer join employees m on e.manager_id = m.employee_id
--    where e.first_name='Steven' and e.last_name='King';
;


/*John 사원의 이름과 부서이름, 부서위치를 출력하세요.*/
select e.first_name, d.department_name, l.street_address
from employees e, departments d, locations l
where e.department_id = d.department_id(+) and d.location_id = l.location_id
    and e.first_name='John';

select e.first_name, d.department_name, l.city
from employees e
join departments d on e.department_id = d.department_id(+)
join locations l on d.location_id = l.location_id
where e.first_name='John';

/*사번이 103인 사원의 사원번호, 이름, 급여, 매니저이름, 부서이름을 출력하세요.*/
select e.employee_id, e.first_name, e.salary, m.first_name as manager_name, d.department_name
from employees e, employees m, departments d
where e.manager_id=m.employee_id and e.department_id = d.department_id and e.employee_id = 103;

/*모든 사원들의 사번, 이름, 급여, 매니저이름, 매니저급여, 부서이름을 출력하세요.*/
select e.employee_id, e.first_name, e.salary, m.first_name as manager_name, m.salary as manager_salary, d.department_name
from employees e, employees m, departments d
where e.manager_id=m.employee_id(+) and e.department_id = d.department_id(+);
