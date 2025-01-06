create database Library_Management;
use Library_Management;

create table library_branch(
library_branch_Branchid int primary key auto_increment,
library_branch_BranchName varchar(225)  ,
library_branch_BranchAddress varchar(225));


create table publisher(
publisher_PublisherName varchar(225) primary key,
publisher_PublisherAddress varchar(225) ,
publisher_PublisherPhone varchar(225));

create table borrower(
borrower_CardNo int primary key  auto_increment,
borrower_BorrowerName varchar(225),
borrower_BorrowerAddress varchar(225),
borrower_BorrowerPhone varchar(225));

create table books(
book_BookID int primary key auto_increment,
book_Title varchar(255),
book_PublisherName varchar(255),
foreign key  (book_PublisherName) references publisher (publisher_PublisherName));

create table authors(
book_authors_BookID int primary key auto_increment,
book_authors_AuthorName varchar(255),
foreign key (book_authors_BookID) references books(book_BookID) on delete cascade on update cascade);

create table book_copies(
book_copies_copiesID int primary key auto_increment,
book_copies_BookID int ,
book_copies_BranchID int ,
book_copies_No_Of_Copies int,
foreign key  (book_copies_BookID) references books(book_BookID) on delete cascade on update cascade,
foreign key (book_copies_BranchID) references library_branch(library_branch_Branchid)  on delete cascade on update cascade);

create table books_loans(
book_loans_loanID int primary key auto_increment,
book_loans_BookID int ,
book_loans_BranchID int ,
book_loans_CardNo int,
book_loans_DateOut date,
book_loans_DueDate date,
foreign key (book_loans_BookID) references books (book_BookID) on delete cascade on update cascade,
foreign key (book_loans_BranchID) references library_branch (library_branch_Branchid) on delete cascade on update cascade,
foreign key (book_loans_CardNo) references borrower (borrower_CardNo) on delete cascade on update cascade);

-- 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

-- 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?

-- 3.Retrieve the names of all borrowers who do not have any books checked out.

-- 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 

-- 5. For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

-- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".


-- 1. How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

select * from books;
select *  from book_copies;
select * from library_branch;

select b.book_title,lb.library_branch_BranchName,sum(bc.book_copies_No_Of_Copies) as total_copies from books as b
left join book_copies as bc
on b.book_BookID  = bc.book_copies_BookID
join library_branch as lb 
on lb.library_branch_Branchid = bc.book_copies_BranchID
where b.book_title = "The Lost Tribe" and lb.library_branch_BranchName = "Sharpstown"
group by b.book_title,lb.library_branch_BranchName;

-- 2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select * from book_copies;
select * from library_branch;
select * from book_copies;

select b.book_title,sum(bc.book_copies_No_Of_Copies),lb.library_branch_BranchName  from books as b
join book_copies as bc
on b.book_BookID  = bc.book_copies_BookID
join library_branch as lb 
on lb.library_branch_Branchid = bc.book_copies_BranchID
group by b.book_title,lb.library_branch_BranchName
having  b.book_title = "The Lost Tribe";

-- 3. Retrieve the names of all borrowers who do not have any books checked out.

select * from borrower;
select * from books_loans;

SELECT br.borrower_BorrowerName FROM borrower as br
LEFT JOIN books_loans as bl 
ON br.borrower_CardNo = bl.book_loans_CardNo
WHERE bl.book_loans_CardNo IS NULL;

-- 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 

select * from borrower;
select * from books;
select *  from books_loans;


select book_Title,borrower_BorrowerName,borrower_BorrowerAddress from books_loans as bl
join library_branch as lb
on lb.library_branch_Branchid = bl.book_loans_BranchID 
join books as b
on b.book_BookID = bl.book_loans_BookID
join borrower as br 
on bl.book_loans_CardNo = br.borrower_CardNo
where lb.library_branch_BranchName = 'Sharpstown' and bl.book_loans_DueDate = "2018-03-08";

-- 5. For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

select * from library_branch ;
select * from  books_loans;

SELECT lb.library_branch_BranchName, COUNT(bl.book_loans_loanID) AS TotalBooksLoaned FROM books_loans as bl
JOIN library_branch as lb
ON bl.book_loans_BranchID = lb.library_branch_Branchid
GROUP BY lb.library_branch_BranchName;

-- 6. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
select * from borrower;
select * from books_loans;

select borrower_BorrowerName from borrower as br
join books_loans as bl 
on  br.borrower_CardNo = bl.book_loans_CardNo;

SELECT br.borrower_BorrowerName, br.borrower_BorrowerAddress, COUNT(bl.book_loans_BookID) AS BooksCheckedOut FROM borrower
JOIN books_loans as bl
ON br.borrower_CardNo = bl.book_loans_CardNo
GROUP BY br.borrower_CardNo, br.borrower_BorrowerName, br.borrower_BorrowerAddress
HAVING COUNT(bl.book_loans_BookID) > 5;

-- 7. For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

select * from books;
select * from book_copies;
select * from library_branch;

select * from authors
where book_authors_AuthorName = 'Stephen King';

select * from library_branch
where library_branch_BranchName = 'Central';


SELECT b.book_Title, SUM(bc.book_copies_No_Of_Copies) AS TotalCopies FROM books as b 
JOIN authors as a
ON b.book_BookID = a.book_authors_BookID
JOIN book_copies as bc 
ON b.book_BookID = bc.book_copies_BookID
JOIN library_branch as lb
ON bc.book_copies_BranchID = lb.library_branch_Branchid
WHERE a.book_authors_AuthorName = 'Stephen King' AND lb.library_branch_BranchName = 'Central'
GROUP BY b.book_Title;




