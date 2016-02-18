/*departments 테이블에 새로운 부서를 추가*/
desc departments;

insert into departments (department_id, department_name, location_id)
values (280, 'Programmer', 1700); --manager_id는 null이고, 1700은 미국 시카고

insert into departments
values (290, 'IT Master', 103, 1700); --Alexander(103번 사원)를 manager로 지정

commit;

insert into departments (department_id, department_name)
values (300, 'Engineering');

select * from departments;
rollback;
select * from departments;


/*여러 행 저장하기*/
--CTAS
--Create Table 테이블 명 As Select 문장;

--select한 결과대로 테이블의 구조를 생성되고, 데이터를 저장
create table emp2 as select * from employees; --테이블을 생성하고 저장
select * from emp2;

--구조만 갖는 테이블 생성
create table emp3 as select * from employees where 1=2;
select * from emp3;

--여러행을 저장
insert into emp3 select * from employees;
select * from emp3;


/*INSERT ALL*/
--insert into VS insert all
--  insert into는 한 개 테이블에 데이터를 저장
--  insert all은 여러 개 테이블에 데이터를 저장
--insert all은 어떤 작업에서 도출된 한 데이터를 여러 테이블에 한번에 추가하려 할 때 사용한다.
--insert all은 반드시 select 문이 포함되어야 한다. (select * from 테이블명;)

desc emp2;
select * from emp2;
--300, Kildong, Hong, Khong, 011.624.7902,
--to_date('2015-05-11', 'YYYY-MM-DD'), IT_PROG, 6000, null, 100, 90
--위의 데이터를 employees테이블에 저장하세요.

--300, Kildong, Hong, KHONG, 011.624.7902,
--to_date('2015-05-11', 'YYYY-MM-DD'), IT_PROG, 6000, null, 100, 90
--400, Kilseo, Hong, KSHONG, 011.3402.7902,
--to_date('2015-06-20', 'YYYY-MM-DD'), IT_PROG, 5500, null, 100, 90
--위의 데이터를 300은 emp2, 400은 emp3테이블에 저장하세요.
--한 개 문장을 사용해야 합니다.
insert all
  into emp2
    values (300, 'Kildong', 'Hong', 'KHONG', '011.624.7902',
            to_date('2015-05-11', 'YYYY-MM-DD'), 'IT_PROG', 6000, null, 100, 90)
  into emp3
    values (400, 'Kilseo', 'Hong', 'KSHONG', '011.3402.7902',
            to_date('2015-06-20', 'YYYY-MM-DD'), 'IT_PROG', 5500, null, 100, 90)
  select * from dual; --어떤 테이블로부터 데이터를 가져오지 않고 직접 값을 입력할 때는 dual테이블을 이용한다.
  
select * from emp2;
select * from emp3;


/*INSERT ALL : 열 단위로 나누어 저장*/
--EMP테이블에 있는 데이터를 열  단위로 나누어 저장하고 싶습니다.
--emp_salary 테이블은 사원번호, 사원이름, 급여, 보너스를 저장
--emp_hire_date 테이블은 사원번호, 사원이름, 입사일, 부서번호를 저장
create table emp_salary as
  select employee_id, first_name, salary, commission_pct
  from employees;
create table emp_hire_date as
  select employee_id, first_name, hire_date, department_id
  from employees;
  
--employees 테이블에 신규데이터가 추가 됩니다.
--500, Sunsin, Lee, SLEE, 010.564.0279,
--to_date('2016-02-11', 'YYYY-MM-DD'), IT_PROG, 8000, null, 100, 90
insert into employees
values(500, 'Sunsin', 'Lee', 'SLEE', '010.564.0279',
        to_date('2016-02-11', 'YYYY-MM-DD'), 'IT_PROG', 8000, null, 100, 90);
        
--신규 데이터를 각각 emp_salary와 emp_hire_date 테이블에 나누어 저장하세요.
insert all
  into emp_salary values (employee_id, first_name, salary, commission_pct)
  into emp_hire_date values (employee_id, first_name, hire_date, department_id)
  select * from employees where employee_id =500;
  
select * from emp_salary;
select * from emp_hire_date;


/*INSERT ALL : 행 단위로 나누어 저장*/
--조건을 걸어서 원하는 데이터(행)들만 저장한다.

--EMP_10 테이블을 생성하세요. EMP테이블의 구조만 갖도록 생성하세요.
drop table emp_10; --테이블이 존재한다면 삭제해 줍니다.
create table emp_10 as select * from employees where 1=2;

--EMP_20 테이블을 생성하세요. EMP테이블의 구조만 갖도록 생성하세요.
drop table emp_20; --테이블이 존재한다면 삭제해 줍니다.
create table emp_20 as select * from employees where 1=2;

--행 단위로 나누어 테이블에 저장하고 싶습니다.
insert all
  when department_id=10 then
    into emp_10 values (employee_id, first_name, last_name, email, phone_number,
                        hire_date, job_id, salary, commission_pct, manager_id, department_id)
  when department_id=20 then
    into emp_20 values (employee_id, first_name, last_name, email, phone_number,
                        hire_date, job_id, salary, commission_pct, manager_id, department_id)
  select * from employees;

select * from emp_10;
select * from emp_20;


/*UPDATE*/
--저장된 데이터를 수정하고 싶습니다.
--UPDATE 테이블명
--SET 열이름=값, ...
--WHERE 수정해야할행조건; --WHERE절을 포함하지 않으면 모든 행 데이터가 수정됨.

--103번 사원의 급여를 10%인상하고 싶습니다.
select * from employees where employee_id=103; --기존 9000
update employees
set salary=salary*1.1
where employee_id=103;
select * from employees where employee_id=103;  --수정 9900

select * from employees;

--INSERT, UPDATE, DELETE, MERGE : DML, 트랜잭션을 명시적으로 종료해 줘야 한다.
--ROLLBACK(취소), COMMIT(저장);
--CREATE TABLE : DDL, 트랜잭션을 묵시적으로 종료해 준다. = COMMIT
COMMIT;


/*COMMIT, ROLLBACK, SAVEPOINT*/
--emp3테이블의 정보를 조회하세요.
select * from emp3;

--10번 부서 사원의 정보를 삭제하세요.
delete from emp3 where department_id=10;

--롤백 지점을 생성하세요.
savepoint delete_10;

--20번 부서 사원의 정보를 삭제하세요.
delete from emp3 where department_id=20;

--롤백 지점을 생성하세요.
savepoint delete_20;

--30번 부서 사원의 정보를 삭제하세요.
delete from emp3 where department_id=30;

--직전 작업(30번 부서사원 삭제)을 취소하세요.
rollback to savepoint delete_20;
--savepoint까지 취소가 그 지점까지 commit을 의미하지는 않는다.

select count(*) from emp3;



/*DML과 LOCK*/
create table emp as select employee_id as empno, first_name as ename, salary as sal, department_id as deptno
from employees;
select * from emp;
--이렇게 테이블을 만들어 놓고 SQL Command line 창을 2개 띄운다.
--1번 창에서 어떤 데이터를 수정(update)하고 조회한다.
--2번 창에서 1번 창에서 수정한 데이터를 조회한다.
--이때, 1번화 2번 창에서 조회된 값은 다르다.(1번에서 아직 commit하지 않았기 때문이다.)
--그리고 2번 창에서, 1번 창에서 수정한 데이터를 다시 수정(update)하려한다.
--하지만 이때 update문장을 실행해도 실행이 끝나지 않고 대기상태가 된다.
--왜냐하면 1번 창에서 update후에 commit 또는 rollback하지 않아서 해당 데이터가 LOCK이 걸렸기 때문이다.
--1번 창에서 commit 또는 rollback을 수행하면 2번 창의 명령이 완료된다.



/*객체와 CREATE TABLE*/
--객체 : 테이블, 뷰, 인덱스, 시퀀스, 시노늄
--DDL
--  CREATE : 객체를 생성하기 위한 명령어
--  ALTER : 객체를 변경하기 위한 명령어
--  DROP : 객체를 삭제하기 위한 명령어

--테이블 생성 구문
/*
CREATE TABLE 테이블이름
(
	열이름 타입(크기) 기본값,
	…
)
[TABLESPACE 테이블스페이스명];
*/

CREATE TABLE "DDL_TEST"  --대소문자를 구분해서 문자열을 사용하고 싶을 때는 큰따옴표를 사용한다.
(
  no number(3),
  name varchar2(10),
  birth date default sysdate
)
TABLESPACE users;
select * from "DDL_TEST"; --테이블을 만들때 큰따옴표를 사용했다면 사용할 때도 써줘야 한다.


/*제약조건*/
/*
입력되는 값을 제한하기 위한 것
PK(Primary Key), UK(Unique), FK(Foreign Key), NN(Not Null), CK(Check)
PK(Primary Key) : Null과 중복된 값을 허용하지 않는다.
UK(Unique) : Null은 허용하되, 중복된 값은 허용하지 않는다.
FK(Foreign Key) : 다른 테이블의 열을 찹조한다.
NN(Not Null) : Null을 허용하지 않는다.
CK(Check) : 입력 값의 조건을 설정한다.
테이블 생성시 추가 하거나 테이블 구조를 변경할 때 사용할 수 있다.
테이블 생성시 추가할 때
  열 정의 할 때 제약조건을 명시 할 수 있다.(열단위)
  테이블 생성구문(열 정의 한 후) 마지막 행에 제약조건을 명시 할 수 있다.(테이블 단위)
*/
--사원번호, 이름, 급여, 부서번호를 저장하는 테이블을 생성해야 합니다.
--사원번호는 PK, 이름은 NN, 급여는 10000이하, 부서번호는 dept 테이블을 참조해서 저장
--테이블 이름은 emp4,
--empno, ename, sal, deptno라고 합니다.
--number(4), varchar2(10, number(7,2), number(2)
--열단위 제약조건 추가는
--열이름 타입(크기) [CONSTAINT 제약조건이름] 제약조건;
--제약 조건 이름 : 테이블이름_열이름_제약조건(PK,NN,UK,FK,CK)약어
create table emp4 (
  empno number(4) constraint emp4_empno_pk primary key,
  ename varchar2(10) not null, /*NN 제약조건은 열단위 제약조건 설정 가능하다.*/
  sal number(7,2) constraint emp4_sal_ck check(sal<=10000),
  deptno number(2) constraint emp4_deptno_dept_deptid_fk references departments(department_id)
);
--유니크 제약조건은 UNIQUE를 이용한다.
select * from emp4;

/*제약조건 추가*/
select * from emp4;
--emp4 테이블에 nickname varchar2(20) 열을 추가합니다.
alter table emp4
add(nickname varchar2(20));

--nickname 열에 unique 제약조건을 추가하세요.
select * from emp4;
alter table emp4
add constraint emp4_nickname_uk unique(nickname);

--외래키라면.. constraint 제약조건이름 foreign key(열이름) references 테이블명(열이름)
insert into emp4
values (1000,'KILDONG',20000,10,null); -- "check constraint (%s.%s) violated"
insert into emp4
values (1000,'KILDONG',2000,10,null); --okay
insert into emp4
values (2000,'KILSEO',3000,99,null); --parent key not found
insert into emp4
values (2000,'KILSEO',3000,20,null);  --okay

select * from emp4;


/*제약조건 삭제*/
--제약조건 조회
--USER_CONSTRAINTS 데이터 딕셔너리르 ㄹ통해 조회 가능
select constraint_name, constraint_type, status
from user_constraints
where table_name='EMP4';

--제약조건 삭제
--ALTER TABLE 테이블명
--DROP CONSTRAINT 제약조건이름;

--EMP4 테이블의 nickname 열에 걸려잇는 제약조건을 삭제
alter table emp4
drop constraint emp4_nickname_uk;

select *
from user_constraints
where table_name='EMP4';


/*제약조건 비활성화*/
select * from emp4;
--9999, 'KING', 20000, 10, 'KING'을 저장해야 합니다. 반드시...
insert into emp4 values (9999, 'KING', 20000, 10, 'KING'); --check constraint (%s.%s) violated
--sal에 걸려있는 제약조건을 풀어야 합니다.
--ALTER TABLE 테이블명 DISABLE CONSTRAINT 제약조건이름;
--DISABLE NOVALIDATE (디폴트) : 해당 열의 제약조건만 사용하지 않도록 한다.
--DISABLE VALIDATE : 테이블의 데이터를 수정하지 못하도록 하는 것
--PK, UK는 자동으로 인덱스가 생성되는데 DISABLE하면 인덱스도 삭제된다.

alter table emp4
disable constraint emp4_sal_ck; --제약조건 사용 안함.

insert into emp4 values (9999, 'KING', 20000, 10, 'KING');
select * from emp4;


/*제약조건 활성화*/
--ENABLE NOVALIDATE : 이미 저장되었던 데이터는 제약조건 체크를 하지 않는다.
--ENABLE VALIDATE : 기본값, 이미 저장되었던 데이터도 제약조건을 체크, 만족하지 못하면 활성화 실패한다.

--emp4_sal_ck 제약조건을 활성화
alter table emp4
enable validate constraint emp4_sal_ck; --check constraint violated

alter table emp4
enable novalidate constraint emp4_sal_ck; --기존 저장된 데이터는 제약조건 체크 안 함



/*UNIQUE INDEX*/
create table emp2 as select * from employees;
drop table emp2;
select * from emp2;
--CTAS 명령은 제약조건은 복사 되지 않는다.
--그래서 실행계획에는 풀스캔으로 나온다.

select * from employees where employee_id=103;
--유니크 인덱스가 사용됨
select * from emp2 where employee_id=103;

CREATE UNIQUE INDEX ind_emp2_first_name
ON emp2(first_name);  --유니크 인덱스 생성, 중복된 값 허락 안 함
--여기 부분 안되는 거다. 왜냐면 emp2에는 이미 이름이 중복된 사람이 몇몇 있어서.

INSERT INTO emp2
VALUES (206, 'Steven', 'King', 'STKING', '515.123.8181', '02/06/07', 'AC_ACCOUNT', 8300, null, 100, 100);

SELECT * FROM emp2 WHERE first_name='Steven';



/*뷰*/
--단순 뷰(Simple View)
--복합 뷰(Complex View)
--인라인 뷰(Inline View)
--실체화 뷰(Meterilized View)

select * from USER_ROLE_PRIVS;  --사용자에게 부여된 롤 확인
select * from USER_SYS_PRIVS;  --사용자에게 부여된 권한 확인

--단순 뷰
--한개 테이블을 뷰로 만들어 놓은 것
--10번 부서의 정보만 조회할 수 있도록 뷰를 생성하라
--10번 부서의 정보는 그 부서와 관련된 파트너사에게 정보를 조회할 수 있도록 하기 위해
--[create or replace view v_emp10]
create view v_emp10
as
  select * from employees where department_id=10; --뷰를 생성
--뷰에는 인덱스 생성 못합니다.(실체화 뷰에서는 가능)
--뷰의 데이터는 물리적으로 저장되지 않습니다.

select * from v_emp10;
desc v_emp10;
