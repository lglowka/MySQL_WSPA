CREATE DATABASE glowka;
USE glowka;
CREATE TABLE employee (
  emp_id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  birth_date DATE,
  sex VARCHAR(1),
  salary INT,
  super_id INT,
  branch_id INT
);

CREATE TABLE branch (
  branch_id INT PRIMARY KEY,
  branch_name VARCHAR(40),
  mgr_id INT,
  mgr_start_date DATE,
  FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

ALTER TABLE employee
ADD FOREIGN KEY(branch_id)
REFERENCES branch(branch_id)
ON DELETE SET NULL;

ALTER TABLE employee
ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id)
ON DELETE SET NULL;

CREATE TABLE client (
  client_id INT PRIMARY KEY,
  client_name VARCHAR(40),
  branch_id INT,
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);

CREATE TABLE works_with (
  emp_id INT,
  client_id INT,
  total_sales INT,
  PRIMARY KEY(emp_id, client_id),
  FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
  FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TABLE branch_supplier (
  branch_id INT,
  supplier_name VARCHAR(40),
  supply_type VARCHAR(40),
  PRIMARY KEY(branch_id, supplier_name),
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);


-- -----------------------------------------------------------------------------

-- Corporate
INSERT INTO employee VALUES(100, 'David', 'Wallace', '1967-11-17', 'M', 250000, NULL, NULL);

INSERT INTO branch VALUES(1, 'Corporate', 100, '2006-02-09');

UPDATE employee
SET branch_id = 1
WHERE emp_id = 100;

INSERT INTO employee VALUES(101, 'Jan', 'Levinson', '1961-05-11', 'F', 110000, 100, 1);

-- Scranton
INSERT INTO employee VALUES(102, 'Michael', 'Scott', '1964-03-15', 'M', 75000, 100, NULL);

INSERT INTO branch VALUES(2, 'Scranton', 102, '1992-04-06');

UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;

INSERT INTO employee VALUES(103, 'Angela', 'Martin', '1971-06-25', 'F', 63000, 102, 2);
INSERT INTO employee VALUES(104, 'Kelly', 'Kapoor', '1980-02-05', 'F', 55000, 102, 2);
INSERT INTO employee VALUES(105, 'Stanley', 'Hudson', '1958-02-19', 'M', 69000, 102, 2);

-- Stamford
INSERT INTO employee VALUES(106, 'Josh', 'Porter', '1969-09-05', 'M', 78000, 100, NULL);

INSERT INTO branch VALUES(3, 'Stamford', 106, '1998-02-13');

UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

INSERT INTO employee VALUES(107, 'Andy', 'Bernard', '1973-07-22', 'M', 65000, 106, 3);
INSERT INTO employee VALUES(108, 'Jim', 'Halpert', '1978-10-01', 'M', 71000, 106, 3);


-- BRANCH SUPPLIER
INSERT INTO branch_supplier VALUES(2, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Patriot Paper', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'J.T. Forms & Labels', 'Custom Forms');
INSERT INTO branch_supplier VALUES(3, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(3, 'Stamford Labels', 'Custom Forms');

-- CLIENT
INSERT INTO client VALUES(400, 'Dunmore Highschool', 2);
INSERT INTO client VALUES(401, 'Lackawana Country', 2);
INSERT INTO client VALUES(402, 'FedEx', 3);
INSERT INTO client VALUES(403, 'John Daly Law, LLC', 3);
INSERT INTO client VALUES(404, 'Scranton Whitepages', 2);
INSERT INTO client VALUES(405, 'Times Newspaper', 3);
INSERT INTO client VALUES(406, 'FedEx', 2);

-- WORKS_WITH
INSERT INTO works_with VALUES(105, 400, 55000);
INSERT INTO works_with VALUES(102, 401, 267000);
INSERT INTO works_with VALUES(108, 402, 22500);
INSERT INTO works_with VALUES(107, 403, 5000);
INSERT INTO works_with VALUES(108, 403, 12000);
INSERT INTO works_with VALUES(105, 404, 33000);
INSERT INTO works_with VALUES(107, 405, 26000);
INSERT INTO works_with VALUES(102, 406, 15000);
INSERT INTO works_with VALUES(105, 406, 130000);

-- 
INSERT INTO branch VALUES(4, 'Buffalo', NULL, NULL);

-- 1. Znajdz wszystkie szkoly wsrod klientow firmy
SELECT *
FROM client
WHERE client_name LIKE '%school%';

-- 2. wyswietl imie i nazwisko oraz pensje wszystkich pracownikow od najwyzszych do najnizszych zarobkow
SELECT first_name, last_name, salary
FROM employee
ORDER BY salary DESC;

-- 3. Znajdz wszystkich klientow i dostawcow firmy
SELECT client_name AS Company_Names
FROM client
UNION
SELECT supplier_name 
FROM branch_supplier;

-- 4. Znajdz wszystkich zatrudnionych menadzerow(id, imie, nazwisko) oraz nazwy ich oddzialow
SELECT employee.emp_id, employee.first_name, employee.last_name, branch.branch_name
FROM employee
JOIN branch
ON employee.emp_id = branch.mgr_id;

-- 5. Wyswietl imiona i nazwiska menadzerow oraz id i nazwy wszystkich oddzialow 
SELECT employee.first_name, employee.last_name, branch.branch_id, branch.branch_name
FROM employee
RIGHT JOIN branch
ON employee.emp_id = branch.mgr_id;

-- 6. Wyswietl id, imiona i nazwiska wszystkich pracownikow oraz id i nazwy klientow z ktorymi wspolpracuja
SELECT employee.emp_id, employee.first_name, employee.last_name, works_with.client_id, client.client_name
FROM employee
LEFT JOIN works_with
ON employee.emp_id = works_with.emp_id
LEFT JOIN client
ON works_with.client_id = client.client_id;

-- 7. Znajdz wszystkich pracownikow ktorych przelozonym jest Michael Scott

SELECT emp_id, first_name, last_name
FROM employee
WHERE super_id = (
	SELECT emp_id
	FROM employee
	WHERE last_name = 'Scott' AND first_name = 'Michael'
    );

-- 8. Znajdz dane wszystkich pracownikow (id, imie, nazwisko)  ktorzy sprzedali pojedynczemu klietowi produkty za ponad 30k$

SELECT employee.emp_id, employee.first_name, employee.last_name
FROM employee
WHERE employee.emp_id IN (
	SELECT works_with.emp_id
	FROM works_with
	WHERE works_with.total_sales > 30000
    );
    
-- 9. Znajdz wszystkich klientow ktorych obsluguje oddzial zarzadzany przez Michaela Scotta

SELECT client.client_name
FROM client
WHERE client.branch_id IN (
	SELECT branch.branch_id
	FROM branch
	WHERE branch.mgr_id IN (
		SELECT employee.emp_id
		FROM employee
		WHERE employee.last_name = 'Scott' AND employee.first_name = 'Michael'
)
);

-- 10. Znajdz dostawce papieru dla dzialu zarzadzanego przez Michaela Scotta
SELECT branch_supplier.supplier_name
FROM branch_supplier
WHERE branch_supplier.supply_type = 'Paper' AND branch_supplier.branch_id = (
	SELECT branch.branch_id
	FROM branch
	WHERE branch.mgr_id = (
		SELECT employee.emp_id
		FROM employee
		WHERE last_name = 'Scott' AND first_name = 'Michael'
		)
	);
    
-- 11. Wyswietl srednia pensje menagerow w firmie

SELECT AVG(employee.salary)
FROM employee
WHERE employee.emp_id IN (
	SELECT branch.mgr_id
    FROM branch
    );
    
-- 12. Wyswietl sume wartosci wszystkich sprzedanych produktow przez Stanleya Hudsona
SELECT SUM(works_with.total_sales)
FROM works_with
WHERE works_with.emp_id = (
	SELECT employee.emp_id
    FROM employee
    WHERE employee.last_name = 'Hudson' AND employee.first_name = 'Stanley'
    );

-- 13. Wyswietl sume sprzedazy calego oddzialu Scranton
SELECT SUM(works_with.total_sales)
FROM works_with
WHERE works_with.emp_id IN (
	SELECT employee.emp_id
    FROM employee
    WHERE employee.branch_id = (
		SELECT branch.branch_id 
        FROM branch
        WHERE branch.branch_name = 'Scranton'
        )
	);



