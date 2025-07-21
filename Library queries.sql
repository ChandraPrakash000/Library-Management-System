-- Project TASK

-- ### 2. CRUD Operations

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books()
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from books 
where book_title='To Kill a Mockingbird';


-- Task 2: Update an Existing Member's Address

update members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
select * from members 
where member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

select * from issued_status
where issued_id='IS121';

Delete from issued_status 
where issued_id='IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select issued_book_name,
	   issued_emp_id
from issued_status
where issued_emp_id='E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id,
	   count(*) as Total_books
from issued_status
group by issued_emp_id
having count(*) >1
order by count(*) desc;

# OR 

SELECT 
    ist.issued_emp_id,
     e.emp_name
    -- COUNT(*)
FROM issued_status as ist
JOIN
employee as e
ON e.emp_id = ist.issued_emp_id
GROUP BY 1, 2
HAVING COUNT(ist.issued_id) > 1
order by count(ist.issued_id) desc;


-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
create table books_issue_count as
 (
	select issued_book_isbn,issued_book_name,
		   COUNT(issued_book_isbn) as Total_issued_count
	from issued_status
	group by 1,2
	order by count(issued_book_isbn) desc
);

select * from books_issue_count;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

select book_title,
	   category
from books
where category='Children';

-- Task 8: Find Total Rental Income by Category:

select category,
       sum(rental_price) as Total_rental_income
from books
group by 1
order by 2 desc;

-- Task 9. **List Members Who Registered in the Last 180 Days**:

select *
from members
where reg_date >= curdate() - INTERVAL 180 DAY;

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C122', 'Ali', '149 Main St', '2025-06-01'),
('C123', 'Siri', '143 Main St', '2025-05-01');


-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

select e1.emp_name,
	   b.*,
       (e2.emp_name) as manager_name
from employee e1
join branch b on
e1.branch_id = b.branch_id 
join employee e2
on b.manager_id =e2.emp_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
create table rental_price_threshold as 
(
	select *
	from books
	where rental_price >=5
);
select * from rental_price_threshold;


-- Task 12: Retrieve the List of Books Not Yet Returned

select i.issued_id,i.issued_book_name
from issued_status i
left join
return_status r on 
    i.issued_id=r.issued_id
where r.issued_id is null; 

# OR

SELECT 
    DISTINCT ist.issued_book_name,ist.issued_id
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;


### Advanced SQL Operations

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

select i.issued_book_name as book_title,
       m.member_id,
	   m.member_name,
	   i.issued_date,
	   current_date() - i.issued_date as no_of_days
from issued_status i
join members m on m.member_id = i.issued_member_id
join books b on b.isbn = i.issued_book_isbn
where  i.issued_id not in (select issued_id from return_status) and  
curdate() - i.issued_date >=30; 

## OR 

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).

select * from books;


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employee as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 years.

select member_id,member_name as Active_member
from members 
where member_id in ( select issued_member_id from issued_status
                            where datediff(current_date(),issued_date) <= 730
					)
;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
with rankings as 
(
select e.emp_name as Employee_name,
	   count(i.issued_emp_id) as total_books,
       dense_rank() over(order by count(i.issued_id) desc) rnk
from employee e 
join issued_status i on e.emp_id = i.issued_emp_id
group by 1
)
select Employee_name,
	   total_books
from rankings 
where rnk <=3;

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

select * from books;

-- Task 19: Stored Procedure
-- Objective: Create a stored procedure to manage the status of books in a library system.
--   Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
--   If a book is issued, the status should change to 'no'.
--   If a book is returned, the status should change to 'yes'.

-- Task 20: Create Table As Select (CTAS)
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

/* Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines */


    
    
    