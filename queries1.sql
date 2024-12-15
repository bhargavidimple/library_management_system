-- library management system  

select *from books; 
select *from employees;
select *from issued_status;
select *from members;
select * from return_status;
select *from branch;

-- 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
select count(*)from books;
insert into books(isbn,book_title,category,rental_price,status,author,publisher)values
("978-1-60129-456-2", 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select *from books;

-- 2.Update an Existing Member's Address
select *from members;
update members set member_address="Praksam 123" where member_id="C101";

-- 3.Delete a Record from the Issued Status Table , Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
select *from issued_status;
delete from issued_status where issued_id="IS121";
select *from issued_status where issued_id="IS121";

-- 4.Retrieve All Books Issued by a Specific Employee , Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status where issued_emp_id="E101";

--  List Members Who Have Issued More Than One Book , Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id ,count(*) as issued_books_count from 
issued_status group by issued_emp_id having issued_books_count>1;

-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
select *from issued_status;
create table booksissued as 
select issued_book_isbn,issued_book_name,count(*) as total_book_cnt from issued_status group by issued_book_name,issued_book_isbn; --  or below one 
 select * from booksissued;
 
 create table books_cnt as 
select b.isbn,b.book_title,count(iss.issued_id) as issued_count from books b 
join issued_status iss on b.isbn=iss.issued_book_isbn group by 1,b.book_title;
select * from books_cnt;

-- Retrieve All Books in a Specific Category:
select *from books where category="Classic";

-- Find Total Rental Income by Category:
select b.category ,sum(b.rental_price) from books b join issued_status iss on
b.isbn=iss.issued_book_isbn group by 1;

-- List Members Who Registered in the Last 200 Days:
select *from members;
select member_name from members where reg_date>=date_sub(curdate(),interval 200 day);

-- List Employees with Their Branch Manager's Name and their branch detail
select *from employees;
select *from branch;
select e.emp_name ,m.emp_name as manager_name ,e.salary,
b.branch_address,b.branch_id from  employees e
join branch b on b.branch_id=e.branch_id left join employees m on b.manager_id=m.emp_id;

--  Create a Table of Books with Rental Price Above a Certain Threshold:

select *from books;
create table expensive_books AS
SELECT * FROM books WHERE rental_price > 7.00;
select *from expensive_books;

-- Retrieve the List of Books Not Yet Returned
select *from return_status;
select *from issued_status;
select *from issued_status iss left join return_status rs on
iss.issued_id=rs.issued_id where rs.return_id is null;

select *from issued_status iss left join return_status rs on
iss.issued_id=rs.issued_id