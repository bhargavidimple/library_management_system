use library;

show tables;
select *from return_status;
select *from  books;
select *from issued_status;
select *from employees;
select *from branch;
select *from members;

-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue
-- joining the tables issued_table ,members,return table (for title books  table also but it is also present in the issued table) 
select m.member_id,m.member_name,i.issued_book_name,i.issued_date ,datediff(curdate(),i.issued_date) as over_due
 from members m
join issued_status i on i.issued_member_id=m.member_id 
left join return_status r on r.issued_id=i.issued_id   where r.return_date is null
and datediff(curdate(),i.issued_date)>30 order by m.member_id;
 
/*Update Book Status on Return
Write a query to update the status of books in the books table to yes
when they are returned (based on entries in the return_status table */
select *from issued_status;
select *from books where isbn='978-0-451-52994-2';
-- manually setting the status as no 
update books set status="no" where isbn="978-0-451-52994-2";
select *from return_status ;
-- lets say he returned the book today we need to change the status in booko table and also aadd a recrod in the return status 
insert into return_status (return_id,issued_id,return_date,book_quality)
values("RS125","IS130",CURDATE(),"good");
-- updating 
update books set status="yes" where isbn="978-0-451-52994-2";

-- using the stored procedures in the sql
 select *from return_status;
 
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

/* Branch Performance Report
Create a query that generates a performance report for each branch, showing the number 
of books issued, the number of books returned, and the total revenue generated from book
 rentals*/
 select *from branch; -- branch id,managers id
 select *from issued_status;  -- issued_id
 select *from return_status; -- issued id
 select *from books; -- rental price ,isbn
 select *from employees; -- branchid ,emp_id 
 create table branch_perfomance as 
 select b.branch_id ,b.manager_id,count(i.issued_id) as number_of_books ,
 count(r.return_id) as no_of_returns ,sum(bo.rental_price) as total_revenue 
 from issued_status  i join employees e on e.emp_id=i.issued_emp_id 
 join branch b on b.branch_id=e.branch_id left join return_status r on r.issued_id=i.issued_id
 join books bo on bo.isbn=i.issued_book_isbn group by b.branch_id,b.manager_id;
 
 select *from branch_perfomance;
 
 /*Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
 containing members who have issued at least one book in the last 2 months.*/
 select *from issued_status;
 select *from members;
 
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
 
 /*Write a query to find the top 3 employees who have processed the most book issues. 
 Display the employee name, number of books processed, and their branch.*/

select e.emp_name ,count(i.issued_id) as number_of_books ,e.branch_id  from employees e
join issued_status i on i.issued_emp_id=e.emp_id 
group by e.emp_id order by count(*) desc limit 3;
 
/*identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status 
"damaged" in the books table. Display the member name, book title, and the number of times
 they've issued damaged books.*/
 
select *from  return_status where book_quality="Damaged";

select i.issued_id,m.member_id,m.member_name ,i.issued_book_name ,count(*) as damagedcount from members m 
join issued_status i on i.issued_member_id=m.member_id join return_status r on
r.issued_id=i.issued_id where r.book_quality="Damaged" group by i.issued_id having count(*)>=1;

/* Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the 
library based on its issuance. The procedure should function as follows: The stored
 procedure should take the book_id as an input parameter. The procedure should first
 check if the book is available (status = 'yes'). If the book is available, it should 
 be issued, and the status in the books table should be updated to 'no'. If the book is 
 not available (status = 'no'), the procedure should return an error message indicating 
 that the book is currently not available.*/
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
 
 