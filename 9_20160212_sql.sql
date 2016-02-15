/*
insert예시1.
insert into 테이블 (열이름, ...)
values (값, ...);

insert예시2.
insert into 테이블 (열이름, ...)
select 문장;
이 경우는 select 한 결과를 테이블에 저장하는 것이다.


--update예시1.
--update 테이블명
--set 컬럼=값, ...
--where 업데이트 할 행조건
*/

--홍길동의 나이를 확인하고 나이를 32호 변경하세요.
select * from namecard;
update namecard set age=32 where name='홍길동';
select * from namecard;

--no 값을 2로 변경시켜보자.
update namecard set no=2 where name='홍길동';
/*에러가 발생한다. 왜냐하면 no는 pk이므로 중복을 허용하지 않는다. no 2는 이미 있기 때문에 에러가 발생한다.
하지만 no를 3으로 수정하면 3은 없기때문에 수정이 가능하다.
마찬가지로 email도 기존의 데이터와 같은 값으로 삽입/수정 할 수 없다. email는 unique로 설정 되어 있기 때문이다.*/

--나이가 설정되지 않는 고객의 나이를 -1로 설정하세요.
update namecard set age=-1 where age is null;
select * from namecard;
--null확인은 'is null', null 아닌지 판단은 'is not null'
--select 문에서도 동일하게 사용.


--namecard와 동일한 구조를 갖는 테이블을 생성할 때, CTAS구조를 사용
create table namecard_new as select * from namecard where 0=1;
--0=1은 거짓이기에 반환 값은 없지만 구조는 옮길 수 있다.
--데이터까지 옮기고 싶다면 1=1
desc namecard_new;
select * from namecard_new;

--namecard_new에 새로운 데이터 입력
insert into namecard_new values (1, '홍길서', 'hong2@hong.com', 35);
insert into namecard_new values (2, '홍길남', 'nam@hong.com', 30);
select * from namecard_new;


--merge에서 사용하기 위해서 sequence를 만든다.
create sequence namecard_seq
start with 10
cache 10;
--sequence는 오라클에서 사용하는 것이다.
--다른 DBMS에서는 가장 큰 값을 조회하고 그 값의 +1을 넣어줘야 한다.

--seq 사용 예.
--seq를 한번 사용한 후에 currval을 확인할 수 있다.
insert into namecard values (namecard_seq.NEXTVAL, '이순신', 'lee@lee.com', 40);
select namecard_seq.CURRVAL from dual;
select * from namecard;

--이제 namecard_new의 데이터들을 namecard로 옮긴다. merge를 이용해서.
merge into namecard a/*테이블 별칭*/
using namecard_new b
on (a.email = b.email)
when matched then
  update/*merge에서 테이블 이름 생략가능*/ set a.name=b.name, a.age=b.age
when not matched then
  insert/*merge에서 테이블 이름 생략가능*/ (a.no, a.name, a.email, a.age)
  values (namecard_seq.NEXTVAL, b.name, b.email, b.age);
--확인
select * from namecard;


--이제 delete를 실습해 보자.
--namecard에서 홍길동 고객의 데이터를 삭제하세요.
select * from namecard;
delete from namecard where name='홍길동';
select * from namecard;


--delete from namecard;
--commit;
--위의 2줄과
truncate table namecard;
--이거 한줄이 같다. 성능면에서 truncate가 좋다.
--확실히 지워도 된다면 truncate를 쓰자. commit되는 것이므로 rollback 할 수 없다.
select * from namecard;
rollback;
select * from namecard;


--의사컬럼
--select 문장에서 사용할 수 있는 열들
desc employees;
select rownum, rowid, employee_id from employees;
--rownum : select 한 결과 집합들에 번호를 붙여준다.
--   특징 : 
--rowid : 테이블에 저장된 각 행의 주소값


--모든 사원의 연봉을 출력하세요.
--연봉은 급여*12 + 급여*12*보너스율
--참고! null값과의 연산 결과는 무조건 null이다.
--nvl함수를 배우지 않았으므로 연봉 계산은 급여*12만 가능
select first_name, salary*12 from employees;

--문자열을 연결시켜주는 || (문자연산자)
select first_name||'-'||last_name as name, salary*12 "annSal"
from employees;

/*
where salary > ALL(2000, 3000, 4000);
> ALL --가장 큰 값보다 큰
< ALL --가장 작은 값보다 작은
> ANY --가장 작은 값보다 큰
< ANY --가장 큰 값보다 작은
SOME은 ANY의 동의어(Synonym)

AND, OR, NOT
AND가 OR보다 우선순위가 높다.
*/
--50번 부서에 근무하거나 급여가 3000보다 큰 사원
--그리고 JOB_ID가 SH_CLERK인사원의 사원번호와 급여, 부서번호, 잡아이디를 출력하세요
select employee_id, salary, department_id, job_id
from employees
where (department_id=50 or salary > 3000)
  and job_id='SH_CLERK';
  

--count() 함수는 갯수를 세는 함수
--보너스를 받지 못하는 사원의 수는 몇명 입니까?
select count(*) from employees where commission_pct is null;
--0을 찾으면 안된다. null을 찾아야 한다.
select count(*) from employees where commission_pct = 0;


--사원번호 100번부터 110번까지 사원번호, 이름, 급여를 출력하세요.
select employee_id, first_name||'-'||last_name, salary from employees where employee_id between 100 and 110;

--IN: =ANY와 같은 의미
--부서번호가 50,60,70,80,90 인 사원의 모든 정보를 출력하세요.
select * from employees
where department_id in (50,60,70,80,90);


--10000원보다 큰 급여를 받는 사원이 있는 부서의 모든 사원정보를 출력하세요.
select * from employees a
where exists (select * from employees b where a.department_id = b.department_id AND b.salary > 10000);


-- 문자열을 포함하는 행을 찾아준다.
-- 문자, 날짜 타입에서 사용할 수 있다.
-- 문자열에 %(0개 이상 문자열), _(1개 문자)를 사용할 수 있다.
--ex. 이름이 A로 시작하는 문자열 -> 'A%'
select * from employees
where first_name like 'A%';


-- ceil 함수 예제. -3.4 , -3.6 , 3.4 , 3.6
select ceil(-3.4), floor(-3.4), round(-3.4), trunc(-3.4) from dual;
-- -3, -4, -3, -3
select ceil(-3.6), floor(-3.6), round(-3.6), trunc(-3.6) from dual;
-- -3, -4, -4, -3
select ceil(3.4), floor(3.4), round(3.4), trunc(3.4) from dual;
-- 4, 3, 3, 3
select ceil(3.6), floor(3.6), round(3.6), trunc(3.6) from dual;
-- 4, 3, 4, 3


--함수 실습
select power(2,3) from dual;
select sqrt(9) from dual;
select mod(5,2) from dual;
select remainder(5,2) from dual;
select exp(0) from dual;
select log(10,2) from dual;

--문자열 함수
select sysdate from dual;               --시스템 시간
select initcap('helloworld') from dual; --첫 글자 대문자
select lower('HelloWorld') from dual;   --전부 소문자로 변환
select upper('HelloWorld') from dual;   --전부 대문자로 변환
select length('HelloWorld') from dual;  --문자열 길이
select length('안녕하세요') from dual;   --문자열 길이, 문자의 수를 반환, 5
select lengthb('안녕하세요') from dual;  --문자열 길이, 바이트 수를 반환, 15
--현재 인코딩이 utf-8이기 때문에 한글 한글자당 3byte여서 15가 나온다. euc-kr은 한글 한글자당 2byte여서 10이 나온다.
--현재 인코딩 확인 : select * from nls_database_parameters;
select concat('Hello', 'World') from dual;    --문자열 합치기, ||와 동일
select substr('HelloWorld', 6, 3) from dual;  --6번째 문자부터 3개의 문자 반환
select substr('안녕하세요', 3,3) from dual;
select substrb('안녕하세요', 7,9) from dual;
select instr('HelloWorld', 'W') from dual;    --찾는 문자의 위치를 반환, 6
select instr('HelloWorld', 'w') from dual;    --찾지 못하면 0을 반환
select instr('안녕하세요', '하') from dual;
select instrb('안녕하세요', '하') from dual;    --찾는 문자열의 위츠를 바이트로 반환
select rpad(first_name, 10, '-') as name, lpad(salary, 10, '*') as sal from employees;
select ltrim('HelloWorld', 'Hello') from dual; --왼쪽 Hello를 제거
select ltrim('  HelloWorld') from dual;        --왼쪽 공백 제거
select trim('  HelloWorld  ') from dual;       --양쪽 공백을 제거해준다.
select replace('HelloWorld', 'Hello', 'Nice') from dual;    --Hello를 Nice로 변경
select replace('Hello World', ' ', '') from dual;           --가운데 공백 제거


--날짜 관련 함수
select sysdate, systimestamp from dual;
select add_months(sysdate, 1), add_months(sysdate, -1) from dual;
select months_between(sysdate, add_months(sysdate, 1)) mon1, months_between(add_months(sysdate,1), sysdate) mon2 from dual;
select last_day(sysdate) from dual;
select sysdate, round(sysdate, 'month'), trunc(sysdate, 'month') from dual;
select next_day(sysdate, '금요일') from dual;

--변환 함수
select to_char(123456789, '999,999,999') from dual;
select to_char(sysdate, 'YYYY-MM-DD') from dual;
select to_number('123456') from dual;
select to_date('20140101', 'YYYY-MM-DD') from dual;
select to_date('20140101 13:44:50', 'YYYY-MM-DD HH24:MI:SS') from dual;


--Null 관련 함수
--모든 사원의 이름과 연봉(급여*12+보너스)를 출력하세요.
--NVL(열이름, null일 때 값)
--NVL(열이름, null 아닐 때 값, null일 때 값) -> 열의 타입과 출력되는 타입이 다를 때 사용될 수 있음.
--쉽게 외우는 방법은 가장 마지막 인자가 널 일 때의 값.
--COALEACE(표현식1, 표현식 2, ...) --null이 아닌 첫 번째 표현식을 반환
--LNNVL(조건식) : 조건식의 결과가 FALSE, UNKNOWN이면 TREU, TRUE이면 FALSE를 반환
select first_name, salary + salary*nvl(commission_pct,0) as ann_sal from employees;
select first_name, nvl2(commission_pct, salary+(salary*commission_pct),salary) as ann_sal from employees;
select first_name, coalesce(salary+(salary*commission_pct), salary) as ann_sal from employees;

--보너스가 650달러 보다 작거나 보너스가 없는 사원들에게 별도의 상품권을 지급하려 합니다.
--해당 사원들의 이름과 보너스를 출력하세요.
select first_name, coalesce(salary*commission_pct, 0) as bouns from employees
where coalesce(salary*commission_pct, 0) < 650;
select first_name, coalesce(salary*commission_pct, 0) as bouns from employees
where lnnvl(salary*commission_pct >= 650);


--CASE 표현식
--사원의 입사일에 따라 전반기/후반기 입사 여부를 출력하세요.
--CASE 표현식, 크거나 작은 조건을 처리할 경우 사용
--CASE 조건 WHEN 조건1 THEN 출력1
--         [WHEN 조건2, THEN 출력2]
--         ...
--         ELSE 출력n
--END "열별칭"
--CASE 다음 조건식은 생략할 수 있으며, 생략할 경우 WHEN 절에 조건식이 나온다.
select first_name, to_char(hire_date, 'YYYY-MM-DD') as hire_date,
  case
    when to_char(hire_date, 'MM') between '01' and '06' then '전반기 입사'
    when to_char(hire_date, 'MM') between '07' and '12' then '후반기 입사'
    ELSE '모름'
  end as 입사시기
  from employees;
