select * from employees;

/*급여가 가장 많은 사원부터 적은 순으로 10명의 이름과 급여를 출력하세요.*/
--rownum사용
--(1)
select first_name, salary
from (select first_name, salary
      from employees
      order by salary desc)
where rownum between 1 and 10;

--(2)
select first_name, salary
from (select first_name, salary
      from employees
      where rownum between 1 and 10
      order by salary desc)
;

--분석 함수 사용
select first_name, salary
from (select first_name, salary,
      row_number() over (order by salary desc) as row_number
      from employees
      order by salary desc)
where row_number between 11 and 20;


/* 3중 쿼리 */
--rownum은 between에서 사용될 때 1부터 찾지 않으면 값을 찾을 수 없다.
--rownum을 이용해서 1 이외의 값으로 시작하는 데이터를 찾으려면 3중 쿼리를 사용한다.
select first_name, salary
from (select first_name, salary, rownum as rnum
      from (select first_name, salary
            from employees
            order by salary desc)
      )
where rnum between 11 and 20;

--분석 함수 사용
select first_name, salary
from (select first_name, salary,
      row_number() over (order by salary desc) as row_number
      from employees
      order by salary desc)
where row_number between 11 and 20;

--위의 두 개의 실행 계획을 비교해보시오.


/*계층적 쿼리*/
--모든 사원의 관계도를 출력하라.
select employee_id,
        lpad(' ', 3*(level-1))||first_name||' '||last_name, level
from employees
start with manager_id is null
connect by prior employee_id=manager_id
order siblings by first_name;
--siblings by절에는 열별칭 사용 불가

--113번 사원의 매니저들을 출력하라. 상위 계층구조를 모두 출력하라.
select employee_id,
      lpad(' ', 3*(level-1))||first_name||' '||last_name,
      level
from employees
start with employee_id=113
connect by prior manager_id = employee_id;
--prior는 start with가 뭐냐에 따라 위치가 바뀐다.


/*listagg*/
--listagg(expr, 'delimiter') within group(order by 순서열이름)
--expr을 delimiter로 구분해서 로우를 컬럼으로 변환해 조회하는 함수(=여러 행을 한 행으로 조회하는 함수)

--부서별 사원의 이름을 입사일 순으로 출력하세요.
select department_id,
      listagg(first_name, ', ') within group(order by hire_date) as names
from employees
group by department_id;


/*unpivot*/
--실습을 위한 테이블 생성(unpivot 전의 원래 테이블)
create table sales (
  employee_id     number(6),
  week_id         number(6),
  sales_mon       number(8,2),
  sales_tue       number(8,2),
  sales_wed       number(8,2),
  sales_thu       number(8,2),
  sales_fri       number(8,2));
  
insert into sales values(1101,4,100,150,80,60,120);
insert into sales values(1102,5,300,300,230,120,150);

commit;
select * from sales;

--실습을 위한 테이블 생성(unpivot 후의 테이블)
create table sales_data(
  employee_id       number(6),
  week_id           number(2),
  week_day          varchar2(10),
  sales             number(8,2)
);
select * from sales_data;
insert all into sales_data values (employee_id, week_id, week_day, sales)
select *
from sales
unpivot
  (
    sales
    for week_day in(sales_mon, sales_tue, sales_wed, sales_thu, sales_fri)
  );


/*순환 서브쿼리 예*/
--모든 사원의 관계도를 출력하라.(계층형 쿼리와 같은 결과로 출력하라.)
with recursive(employee_id, manager_id, full_name, lvl )
  as (select employee_id, manager_id, first_name||' '||last_name,1
      from employees
      where manager_id is null /*start with manager_id is null*/
      
      union all
      
      select e.employee_id, e.manager_id,
            e.first_name||' '||e.last_name, r.lvl+1
      from employees e, recursive r
      where e.manager_id=r.employee_id /*connect by prior employee_id = manager_id*/
      )
  search depth first by employee_id set order_seq
select employee_id, lpad(' ',3*(lvl-1))||full_name as full_name, lvl, order_seq
from recursive;


/*RANK 함수*/
--집계용 문법
----rank(조건값) within group (order by 조건값 컬럼명)
--분석용 문법
----rank() over (order by 조건컬럼명)
select first_name, salary,
      rank() over (order by salary desc) as rank,
      dense_rank() over (order by salary desc) as densc_rank,
      round(cume_dist() over (order by salary desc),4) as cume_dict,
      round(percent_rank() over (order by salary desc),4) as pct_rank,
      row_number() over (order by salary desc) as row_number,
      rownum --의사열
from employees
order by salary desc;
