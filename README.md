# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/bhargavidimple/library_management_system/blob/main/library_er.png)

- **Database Creation**: Created a database named `library`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books(isbn,book_title,category,rental_price,status,author,publisher)values
("978-1-60129-456-2", 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select *from books;
```
**Task 2: Update an Existing Member's Address**

```sql
select *from members;
update members set member_address="Praksam 123" where member_id="C101";
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issued_status where issued_id="IS121";
select *from issued_status where issued_id="IS121";
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from issued_status where issued_emp_id="E101";'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select issued_emp_id ,count(*) as issued_books_count from 
issued_status group by issued_emp_id having issued_books_count>1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table booksissued as 
select issued_book_isbn,issued_book_name,count(*) as total_book_cnt from issued_status group by issued_book_name,issued_book_isbn; --  or below one 
 select * from booksissued;

 create table books_cnt as 
select b.isbn,b.book_title,count(iss.issued_id) as issued_count from books b 
join issued_status iss on b.isbn=iss.issued_book_isbn group by 1,b.book_title;
select * from books_cnt;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select *from books where category="Classic";
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select b.category ,sum(b.rental_price) from books b join issued_status iss on
b.isbn=iss.issued_book_isbn group by 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select *from members;
select member_name from members where reg_date>=date_sub(curdate(),interval 200 day);
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select e.emp_name ,m.emp_name as manager_name ,e.salary,
b.branch_address,b.branch_id from  employees e
join branch b on b.branch_id=e.branch_id left join employees m on b.manager_id=m.emp_id;

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
select *from books;
create table expensive_books AS
SELECT * FROM books WHERE rental_price > 7.00;
select *from expensive_books;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select *from issued_status iss left join return_status rs on
iss.issued_id=rs.issued_id where rs.return_id is null;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
    
    select m.member_id,m.member_name,i.issued_book_name,i.issued_date ,datediff(curdate(),i.issued_date) as over_due
 from members m
join issued_status i on i.issued_member_id=m.member_id 
left join return_status r on r.issued_id=i.issued_id   where r.return_date is null
and datediff(curdate(),i.issued_date)>30 order by m.member_id;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

DELIMITER //
CREATE PROCEDURE add_return_records(in return_id varchar(10),in issued_id varchar(10),in book_quality varchar(15))
begin
declare v_isbn varchar(50); 
 insert into return_status (return_id,issued_id,return_date,book_quality)
 values(return_id,issued_id,curdate(),book_quality);
 select issued_book_isbn into v_isbn  from issued_status i where i.issued_id=issued_id;
 update books set status="yes" where isbn=v_isbn;
select "Notice:Thank you for returning the book";
end //
delimiter ;
select *from return_status where return_id="RS135";
delete from return_status where return_id="RS135";

call add_return_records("RS135","IS135","good");
call add_return_records("RS148","IS140","BAD"); -- adding another record

-- veryfying the record
select *from issued_status where issued_id="IS140";
select *from books where isbn="978-0-330-25864-8";


```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
select i.issued_member_id,count(*) as issued from members m join issued_status i on
 i.issued_member_id=m.member_id and i.issued_date>=date_sub(curdate(),interval 2 Month)
 group by i.issued_member_id having count(*)>=1;
 -- or we can do as subquery
 create table active_members as 
 select * from members m where m.member_id in (
 select distinct i.issued_member_id from issued_status i where
 i.issued_date>=date_sub(curdate(),interval 2 Month));
 select *from active_members;
 
 -- verificaton by using the below query 
select * from issued_status  where issued_date>=date_sub(curdate(),interval 2 Month);
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

create table branch_perfomance as 
 select b.branch_id ,b.manager_id,count(i.issued_id) as number_of_books ,
 count(r.return_id) as no_of_returns ,sum(bo.rental_price) as total_revenue 
 from issued_status  i join employees e on e.emp_id=i.issued_emp_id 
 join branch b on b.branch_id=e.branch_id left join return_status r on r.issued_id=i.issued_id
 join books bo on bo.isbn=i.issued_book_isbn group by b.branch_id,b.manager_id;
 
 select *from branch_perfomance;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select e.emp_name ,count(i.issued_id) as number_of_books ,e.branch_id  from employees e
join issued_status i on i.issued_emp_id=e.emp_id 
group by e.emp_id order by count(*) desc limit 3;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql

select i.issued_id,m.member_id,m.member_name ,i.issued_book_name ,count(*) as damagedcount from members m 
join issued_status i on i.issued_member_id=m.member_id join return_status r on
r.issued_id=i.issued_id where r.book_quality="Damaged" group by i.issued_id having count(*)>=1;
```


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

select *from books;
 select *from issued_status;
 
 delimiter //
 
 create procedure  issue_books(
 p_issued_id varchar(20) ,
 p_issued_member_id varchar(10),
 p_issued_book_isbn varchar(30),
 p_issued_emp_id varchar(20))
 begin
    declare v_status varchar(10);
   select status into v_status from books where isbn=p_issued_book_isbn;
   if v_status="yes" then 
   insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
   values(p_issued_id,p_issued_member_id,curdate(),p_issued_book_isbn,p_issued_emp_id);
   update books set status="no" where isbn=p_issued_book_isbn;
   select "Book records added succesfully!";
   else
    select "Sorry to inform you  the book you have asked is unavailable";
   end if;
end //
DELIMITER ;

 select *from books;-- '978-0-06-112008-4' yes 978-0-375-41398-8 no
 select *from issued_status where issued_id="IS155";
 select *from books where isbn="978-0-06-112008-4";
 call issue_books("IS155","C108",'978-0-06-112008-4',"E104");
 call issue_books("IS156","C108",'978-0-375-41398-8',"E104");
 
```





## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.



## Author - Bhargavi

