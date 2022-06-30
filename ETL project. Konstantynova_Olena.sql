USE employees;                                  

-- 1

DELIMITER $$

CREATE PROCEDURE hire_emp (IN p_first_name VARCHAR(14), 
						   IN p_last_name VARCHAR(16),
                           IN p_birth_date DATE,  
                           IN p_gender ENUM('M','F'), 
						   IN p_dept_no VARCHAR(4), 
                           IN p_title VARCHAR (50), 
                           IN p_salary INT)

BEGIN

DECLARE v_from_date DATE; 
DECLARE v_to_date DATE; 
DECLARE v_emp_no INT;

SET v_from_date := current_date(); 
SET v_to_date := '9999-01-01';

SELECT MAX(emp_no)+1 FROM employees
INTO v_emp_no;


IF p_title not in ( select title
					from employees.titles) THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Введена несуществующая должность';
END IF;

IF p_salary <= 30000 THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Введена неправильная зарплата';
END IF;

INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date)
VALUES (v_emp_no, p_birth_date, p_first_name, p_last_name , p_gender, v_from_date);

INSERT INTO  dept_emp (emp_no, dept_no, from_date, to_date)
VALUES (v_emp_no, p_dept_no, v_from_date, v_to_date);

INSERT INTO  salaries (emp_no, salary, from_date, to_date)
VALUES (v_emp_no, p_salary, v_from_date, v_to_date);

INSERT INTO  titles (emp_no, title, from_date, to_date)
VALUES (v_emp_no, p_title, v_from_date, v_to_date);


commit;

END$$

DELIMITER ;

/*CALL hire_emp ('Olena', 'Konstantynova', '1990-01-10', 'F', 'd005', 'Engineer', '64000');

CALL employees.hire_emp('Anna', 'Ivanova', '1987-10-03', 'F', 'd005', 'Stff', '6000');

select *
from employees
order by 1 desc;

select *
from dept_emp
order by 1 desc;

select *
from salaries
order by 1 desc;

select *
from titles
order by 1 desc;*/

-- 2

DELIMITER $$

CREATE PROCEDURE new_salary ( IN P_emp_no INT, IN p_salary INT)

BEGIN

DECLARE v_from_date DATE;
DECLARE v_to_date DATE; 
SET v_from_date := current_date(), 
	v_to_date := '9999-01-01';


IF P_emp_no not in ( select emp_no
					 from employees) THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Введен несуществующий номер сотрудника';
END IF;

UPDATE employees.salaries
set to_date = v_from_date
where emp_no = P_emp_no
and to_date >= current_date();

insert into salaries (emp_no, salary, from_date, to_date)
VALUES (P_emp_no, p_salary, v_from_date, v_to_date);

commit;

END$$

DELIMITER ;

/*CALL new_salary (10032, 76000);

select * 
from salaries
where emp_no = 10032; */



-- 3

DELIMITER $$

CREATE PROCEDURE quit_emp ( IN P_emp_no INT )

BEGIN

DECLARE v_to_date DATE;
SET v_to_date := current_date();

IF P_emp_no not in ( select emp_no
					 from employees) THEN
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'Введен несуществующий номер сотрудника';
END IF;

update dept_emp
set to_date = v_to_date
where emp_no = P_emp_no
and to_date >= current_date();

update salaries
set to_date = v_to_date
where emp_no = P_emp_no
and to_date >= current_date();

update titles
set to_date = v_to_date
where emp_no = P_emp_no
and to_date >= current_date();

commit;

END$$

DELIMITER ;


/* call quit_emp( 500000 );

select *
from dept_emp
order by 1 desc;

select *
from salaries
order by 1 desc;

select *
from titles
order by 1 desc;*/


-- 4

DELIMITER $$

CREATE FUNCTION current_salary ( P_emp_no INT) RETURNS INT
DETERMINISTIC

BEGIN

DECLARE v_salary int;
 
SELECT salaries.salary
INTO v_salary
FROM salaries
WHERE to_date >= now() AND emp_no = P_emp_no;

RETURN v_salary;

END$$

DELIMITER ;

-- SELECT current_salary(10032);