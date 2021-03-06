select * from employees;

/*이름이 David인 사원의 정보를 조회하세요.*/
select * from employees where first_name='David';
--위의 경우에는 David의 스펠이 대소문자가 어떻게 되어 있는지 정확히 알 때만 사용할 수있다.
--David의 스펠이 대소문자가 어떻게 입력되어 있는지 모를때는 함수를 사용한다.
select * from employees where lower(first_name)='david';
--이 경우에는 무조건 소문자로 변환해서 비교하기 때문에 대소문자 상관없이 david를 검색 할 수 있다.

/*1. 입사일이 2005년도인 사원의 모든 정보를 조회하세요.*/
--(1)
select * from employees where hire_date between '05/01/01' and '05/12/31';
--(2)
select * from employees where hire_date like '05%';

/*2. 급여가 10000보다 큰 사원의 이름과 부서번호, 직무아이디, 급여를 출력하세요.*/
select department_id, job_id, salary from employees where salary > 10000;

/*3. 20번 부서 사원의 이름, 성, 급여를 출력하세요.*/
select first_name, last_name, salary from employees where department_id=20;
-- 이름을 하나의 열로 출력하려면 아래와 같이 하면 된다.
select first_name||' '||last_name as full_name, salary from employees where department_id=20;
select concat(first_name, last_name) as full_name, salary from employees where department_id=20;

/*4. David라는 이름을 가진 사원이 몇 명인지 출력하세요.*/
select count(*) from employees where lower(first_name)='david';

/*5. 사원 번호가 103인 사원의 이름, 성, 입사일, 급여, 보너스율을 출력하세요.*/
select first_name, last_name, hire_date, salary, commission_pct
from employees
where employee_id = 103;

/*커미션을 받지 않는 사원의 수를 출력하세요.*/
select count(*) from employees where commission_pct is null;

/*20번 부서 사원들의 이름과 연봉(salary+salary*commission_pct)을 출력하세요.*/
--(1) nvl 이용
select concat(first_name, last_name) as full_name, salary+salary*nvl(commission_pct, 0) as ann_salary
from employees where department_id = 20;
--(2) nvl2 이용
select concat(first_name, last_name) as full_name, nvl2(commission_pct, salary+salary*commission_pct, salary) as ann_salary
from employees where department_id = 20;
--(3) 추가적으로 연봉에 세자리마다 구분기호 (,)를 넣고 금액 앞에 ($)를 붙여 출력하세요.
select concat(first_name, last_name) as full_name, to_char(nvl2(commission_pct, salary+salary*commission_pct, salary), '$999,999') as ann_salary
from employees where department_id = 20;

/*50번 부서 사원의 이름(full name)과 연봉을 세자리마다 구분기호와 $를 포함하도록 출력하되 연봉이 큰 사원부터 작은 순서로 출력하세요.*/
select concat(first_name, last_name) as full_name, to_char(nvl2(commission_pct, salary+salary*commission_pct, salary), '$999,999') as ann_salary
from employees where department_id = 50 order by ann_salary desc;

/*위 결과에 이름을 최대 20자로 출력하고 이름 오른쪽에 남는 공백을 (*)로 출력하세요.*/
select rpad(concat(first_name, last_name),20, '*') as full_name, to_char(nvl2(commission_pct, salary+salary*commission_pct, salary), '$999,999') as ann_salary
from employees where department_id = 50 order by ann_salary desc;

/*급여는 소수점 2자리를 포함한 총 8자리로 출력하고 왼쪽을 0으로 채우세요. */
select rpad(concat(first_name, last_name),20, '*') as full_name
      , to_char(nvl2(commission_pct, salary+salary*commission_pct, salary), '$099,999.99') as ann_salary
from employees where department_id = 50 order by ann_salary desc;

/*위 결과에 입사일과, 현재까지 근무한 개월수를 출력하세요.
입사일은 2005년 03월 15일 형식으로 출력하세요.
현재 날짜는 SYSDATE입니다.*/
select rpad(concat(first_name, last_name),20, '*') as full_name
      , to_char(nvl2(commission_pct, salary+salary*commission_pct, salary), '$099,999.99') as ann_salary
      , to_char(hire_date, 'YYYY"년" MM"월" DD"일"') as hire_date
      , trunc(months_between(sysdate, hire_date)) as Continuous_service_month
from employees where department_id = 50 order by ann_salary desc;


/*직무가 IT_PROG인 사원들 중에서 급여가 5000 이상인 사원들의
이름(full_name), 연봉, 입사일(2005-02-15 형식), 근무한 일 수를 출력하세요.
이름 순으로 정렬하며,
이름은 최대 20자리, 남는 자리는 *로 채우고
연봉은 $표시와 소수점 2자리를 포함한 최대 8자리, 남는 자리는 0으로 채워 출력하세요.*/
select rpad(concat(first_name, last_name),20, '*') as full_name
      , to_char(nvl2(commission_pct, salary+salary*commission_pct, salary), '$099,999.99') as ann_salary
      , to_char(hire_date, 'YYYY"-"MM"-"DD') as hire_date
      , trunc(sysdate - hire_date) as Continuous_service_day
from employees
where lower(job_id) = 'it_prog' and salary >= 5000
order by full_name;



/*1. 이메일에 lee를 포함하는 사원의 모든 정보를 출력하세요. */
select * from employees where lower(email) like '%lee%';

/*2. 매니저 아이디가 103인 사원들의 이름과 급여, 직무아이디를 출력하세요. */
select concat(first_name, last_name) as full_name, salary, job_id
from employees
where manager_id=103;

/*3. 80번 부서에 근무하면서 급여가 10000이상인 사원들의
이름과 연봉(salary+salary*commission_pct)을 출력하세요.
이름은 Full Name으로 출력하며 17자리로 출력하세요. 남은 자리는 *로 채우세요.
연봉은 소수점 2자리를 포함한 총 7자리로 출력하며, 남은 자리는 0으로 채우세요.
연봉 맨 앞에 $ 표시를 하며 연봉순으로 정렬하세요.*/
select lpad(concat(first_name, last_name),17,'*') as full_name
      , to_char(coalesce(salary+salary*commission_pct, salary),'$09,999.00') as ann_sal
from employees
where department_id=80 and salary >=10000
order by ann_sal;

/*4. 모든 사원의 이름과 근무 년수를 입사일을 현재 일자를 기준으로 근무한 년수를
5년차, 10년차, 15년차로 표시하세요.
5년~9년 근무한 사원은 5년차로 표시합니다. 나머지는 기타로 표시합니다.
근무 년수는 근무개월수/12로 계산합니다.*/
select concat(first_name, last_name) as full_name
    , decode(trunc((months_between(sysdate, hire_date)/12)/5),
          1, '5년차',
          2, '10년차',
          3, '15년차',
             '기타') as years
from employees;
--select * from employees;

/*5. 모든 사원의 전화번호를 ###.####.#### 이라면 ###-####-#### 형식으로 출력하세요. */
select replace(phone_number, '.', '-') as phone_number from employees;

/*6. 80번 부서에 근무하면서 직무가 SA_MAN인 사원의 정보와
20번 부서에 근무하면서 매니저 아이디가 100인 사원의 정보를 출력하세요.*/
select * from employees
where (department_id=80 and lower(job_id) = 'sa_man') or (department_id=20 and manager_id=100);
