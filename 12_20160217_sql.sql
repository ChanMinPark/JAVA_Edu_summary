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
