Create database library_db;
use library_db;

-- Creating Branch Table
Drop table if exists branch;
create table branch
(
	branch_id varchar(15) Primary key,
	 manager_id	varchar(15),
	 branch_address varchar(55),
	 contact_no  varchar(15)
);

 -- Creating Employees Table 
Drop table if exists employee;
create table employee
(
	emp_id varchar(25) primary Key,
	emp_name varchar(25),
	position varchar(25),
	salary int,
	branch_id varchar(25)
);

-- Creating Books Table
Drop table if exists books;
Create table books
(
   isbn varchar(20) primary key,
   book_title varchar(75),
   category varchar(15),
   rental_price float,
   status varchar(10),
   author varchar(35),
   publisher varchar(55)
);

-- Creating Table Members

Drop table if exists members;
Create table members
(
  member_id varchar(15) primary key,
  member_name varchar(30),
  member_address varchar(75),
  reg_date date
);

Drop table if exists issued_staus;
Create table issued_status
(
    issued_id varchar(10) primary key,
	issued_member_id varchar(15),
	issued_book_name varchar(75),
	issued_date date,
	issued_book_isbn varchar(30),
	issued_emp_id varchar(15)
);


Drop table if exists return_staus;
Create table return_status
(
    return_id varchar(10) primary key,
	issued_id varchar(10),
	return_book_name varchar(75),
	return_date date,
	return_book_isbn varchar(25)
);
