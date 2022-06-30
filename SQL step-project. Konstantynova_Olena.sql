-- ЗАПРОСЫ:

SELECT  YEAR(from_date),                                                                                       -- 1  
AVG(salary) OVER (PARTITION BY YEAR(from_date)) AS avg_salary
FROM employees.salaries
GROUP BY YEAR(from_date)
;


SELECT distinct dept_emp.dept_no,                                                                                  -- 2    
AVG(salary) OVER (PARTITION BY dept_emp.dept_no) AS avg_dept_salary
FROM employees.dept_emp
LEFT JOIN employees.salaries ON salaries.emp_no = dept_emp.emp_no
WHERE salaries.to_date = '9999-01-01' AND dept_emp.to_date = '9999-01-01'
;

SELECT dept_emp.dept_no, YEAR(dept_emp.from_date),                                                                  -- 3 
AVG(salary) OVER (PARTITION BY dept_emp.dept_no ORDER BY YEAR(dept_emp.from_date)) AS avg_dept_salary
FROM employees.dept_emp
LEFT JOIN employees.salaries ON salaries.emp_no = dept_emp.emp_no
WHERE YEAR(dept_emp.from_date) = YEAR(salaries.from_date)
GROUP BY dept_emp.dept_no, YEAR(dept_emp.from_date)
;


SELECT	max_count_emp.years, max_count_emp.dept_no, 										--  4
		max_count_emp.max_count_emp, max_count_emp.avg_dept_salary						 
FROM																					
			(SELECT  count_emp.*,  
			MAX(count_emp.count_emp) OVER (PARTITION BY count_emp.years) AS max_count_emp
			FROM 
					(SELECT dept_emp.dept_no, YEAR(dept_emp.from_date) as years, count(dept_emp.emp_no)as count_emp,
					AVG(salary) OVER (PARTITION BY dept_emp.dept_no ORDER BY YEAR(dept_emp.from_date)) AS avg_dept_salary
					FROM employees.dept_emp
					LEFT JOIN employees.salaries ON salaries.emp_no = dept_emp.emp_no
					WHERE YEAR(dept_emp.from_date) = YEAR(salaries.from_date)
					GROUP BY dept_emp.dept_no, YEAR(dept_emp.from_date))AS count_emp
			) AS max_count_emp 
 WHERE  max_count_emp.count_emp = max_count_emp.max_count_emp          
;

SELECT employees.*, dept_manager.dept_no, dept_manager.from_date, dept_manager.to_date, datediff(curdate(), from_date) as days_on_the_position                -- 5
FROM employees.dept_manager
LEFT JOIN employees.employees ON dept_manager.emp_no = employees.emp_no
WHERE dept_manager.to_date = '9999-01-01'
ORDER BY days_on_the_position DESC
LIMIT 1
;


SELECT dept_emp.dept_no, salaries.emp_no,                                                                                        -- 6          
ABS(salaries.salary - AVG(salary) OVER (PARTITION BY dept_emp.dept_no)) AS dif_salary
FROM employees.dept_emp
LEFT JOIN employees.salaries ON salaries.emp_no = dept_emp.emp_no
WHERE salaries.to_date = '9999-01-01' AND dept_emp.to_date = '9999-01-01'
ORDER BY dif_salary DESC
LIMIT 10
;


SELECT month_cume_salary.*																						               	-- 7 
FROM (
			SELECT dept_emp.dept_no, salaries.emp_no, salaries.salary/12 AS month_salary,
			SUM(salaries.salary/12) OVER (PARTITION BY dept_emp.dept_no ORDER BY salaries.salary/12) AS month_sum_salary                                                                      
			FROM employees.dept_emp
			LEFT JOIN employees.salaries ON salaries.emp_no = dept_emp.emp_no
			WHERE salaries.to_date = '9999-01-01') AS month_cume_salary
WHERE  month_sum_salary <= 500000
;



-- ДИЗАЙН БАЗЫ ДАННЫХ:

CREATE DATABASE IF NOT EXISTS courses;                                     -- 1

CREATE TABLE if not exists students (
student_no  	    INT auto_increment,
teacher_no  		INT NOT NULL,
course_no			INT NOT NULL,
student_name		VARCHAR(255) NOT NULL,  
email 				VARCHAR(255) NOT NULL,
birth_date          DATE NOT NULL,
PRIMARY KEY (student_no, birth_date),
INDEX st_email_index (email))
		PARTITION BY RANGE (year(birth_date)) (                            
		partition p1 values less than (1995),
		partition p2 values less than (2000),
		partition p3 values less than (2005),
		partition p4 values less than (maxvalue)
		)
;

DESCRIBE students;

CREATE TABLE IF NOT EXISTS teachers (
teacher_no  		 INT,
teacher_name		 VARCHAR(255) NOT NULL,
phone_no			 VARCHAR(255) NOT NULL,
PRIMARY KEY (teacher_no),
UNIQUE th_phone_index (phone_no)
  );

DESCRIBE teachers;

CREATE TABLE IF NOT EXISTS courses (
course_no  		 INT,
course_name		 VARCHAR(255) NOT NULL,
start_date		 DATE NOT NULL,
end_date 		 DATE,
PRIMARY KEY (course_no, start_date)
  );
  
DESCRIBE courses;

INSERT INTO courses (course_no, course_name, start_date, end_date)                 -- 2
VALUES  (01, 'graphic design', '2021-09-30', '2021-12-30'),
		(02, 'motion design',  '2021-10-04', '2022-01-15'),
		(03, 'UI/UX design',   '2021-10-12', '2022-02-01'),
		(04, 'commercial illustration', '2021-10-22', '2022-01-31'),
		(05, 'mobile app design', '2021-10-28', '2022-02-15'),
		(06, 'interior design', '2021-11-01', '2022-03-01'),
		(07, '3D visualization', '2021-11-05', '2022-02-13')
    ;

select *
from courses;

INSERT INTO teachers (teacher_no, teacher_name, phone_no)
VALUES  (11, 'Viktor Zastavnov', '099-776-56-34'),
		(12, 'Irina Grineva', '050-007-16-22'),
		(13, 'Aleksandr Vetrenko', '066-831-49-49'),
        (14, 'Oleg Volinets', '093-225-52-11'),
        (15, 'Anna Belaya', '095-993-12-74'),
        (16, 'Pavel Vashuk', '096-845-61-32'),
		(17, 'Maria Belich', '099-143-55-35')
;

select *
from teachers;

INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)
VALUES  (12, 2, 'Elena Kramarenko', 'ElenaKramarenko@ukr.net','1991-03-16'),
		(16, 6, 'Olga Dronova', 'OlgaDronova@ukr.net', '1998-12-21'),
		(15, 5, 'Pavel Drevniov', 'PavelDrevniov@gmail.com', '2001-01-11'),
        (11, 1, 'Inna Sazonova', 'InnaSazonova@gmail.com', '2006-07-09'),
        (13, 3, 'Lana Ivanova', 'LanaIvanova@mail.ru', '2002-10-23'),
        (13, 3, 'Ruslan Averenko', 'RuslanAverenko@mail.ru', '1997-05-27'),
		(14, 4, 'Ivan Lapenko', 'IvanLapenko@gmail.com', '1995-02-13'),
        (17, 7, 'Maksim Petrov', 'MaksimPetrov@gmail.com', '2003-02-13'),
		(12, 2, 'Artem Petrenko', 'ArtemPetrenko@gmail.com', '2004-09-19'),
        (16, 6, 'Alyona Malinova', 'AlyonaMalinova@gmail.com', '1993-04-29'),
        (11, 1, 'Boris Malinov', 'BorisMalinov@gmail.com', '1992-08-18')
;

SELECT *                                                 
FROM students;

SELECT *                                                 -- 3
FROM students
WHERE birth_date = '2003-02-13'
;

EXPLAIN SELECT *                                            
FROM students
WHERE birth_date = '2003-02-13'
;

 /* id,  select_type,  table,         partitions,   type,    possible_keys,   key,    key_len,    ref,    rows,     filtered,      Extra
   '1',  'SIMPLE',    'students',     'p3',         'ALL',   NULL,            NULL,   NULL,       NULL,   '4',      '25.00',       'Using where' */
   

SELECT *                                                       -- 4
FROM teachers
WHERE phone_no = '093-225-52-11'
;

EXPLAIN SELECT *                                            
FROM teachers
WHERE phone_no = '093-225-52-11'
;

/* id,    select_type,   table,       partitions,    type,       possible_keys,         key,              key_len,    ref,       rows,    filtered,    Extra
  '1',    'SIMPLE',      'teachers',  NULL,          'const',    'th_phone_index',      'th_phone_index', '1022',    'const',    '1',     '100.00',    NULL */ 
  
ALTER table teachers
ALTER  INDEX th_phone_index INVISIBLE;

EXPLAIN SELECT *                                            
FROM teachers
WHERE phone_no = '093-225-52-11'
;

/* id,     select_type,   table,        partitions,     type,      possible_keys,    key,       key_len,    ref,     rows,     filtered,     Extra
   '1',    'SIMPLE',      'teachers',    NULL,          'ALL',     NULL,             NULL,      NULL,       NULL,    '7',      '14.29',      'Using where'*/

ALTER table teachers
ALTER  INDEX th_phone_index VISIBLE;

INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)                  -- 5
VALUES  (12, 2, 'Elina Kozachenko', 'ElinaKozachenko@gmail.com','1999-06-16'),
		(12, 2, 'Elina Kozachenko', 'ElinaKozachenko@gmail.com','1999-06-16'),
        (12, 2, 'Elina Kozachenko', 'ElinaKozachenko@gmail.com','1999-06-16')
        ;


SELECT *, COUNT(*)	as duplicates																-- 6 
FROM students
GROUP BY student_name
HAVING 
    COUNT(*) > 1
    ;
    