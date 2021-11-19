--1. Müəyyən Publisher tərəfindən çap olunmuş minimum səhifəli kitabların siyahısını çıxaran funksiya yazın
ALTER FUNCTION MinPageBooks(@PressName NVARCHAR(MAX))
RETURNS  Table
RETURN 
(
  SELECT TOP(5)Books.Name AS BookName, Books.Pages,Press.[Name] AS PressName FROM Books INNER JOIN Press
  ON Books.Id_Press=Press.Id
  WHERE Press.Name=@PressName
  ORDER BY Books.Pages 
)
SELECT * FROM MinPageBooks('BHV')

--2. Orta səhifə sayı N-dən çox səhifəli kitab çap edən Publisherlərin adını qaytaran funksiya yazın. 
--N parameter olaraq göndərilir.
CREATE FUNCTION AvgPagesOfPublishers(@BooksPage int)
RETURNS TABLE
RETURN
(
   SELECT Press.Name AS PressName ,AVG(Pages) AS PagesAVG FROM Books INNER JOIN Press
   ON Books.Id_Press=Press.Id
   GROUP BY Press.Name
   HAVING AVG(Pages)>@BooksPage
)

SELECT * FROM AvgPagesOfPublishers(450)

--3. Müəyyən Publisher tərəfindən çap edilmiş bütün kitab səhifələrinin cəmini tapan və qaytaran funksiya yazın.

ALTER FUNCTION SumPagesOfBooks(@PressName NVARCHAR(MAX))
RETURNS  Table
RETURN 
(
  SELECT Press.[Name] AS PressName, SUM(Pages) AS SumPagesOfBooks FROM Books INNER JOIN Press
  ON Books.Id_Press=Press.Id
  WHERE Press.Name=@PressName
  GROUP BY Press.Name 
)

SELECT * FROM SumPagesOfBooks('BHV')

--4. Müəyyən iki tarix aralığında kitab götürmüş Studentlərin ad və soyadını list şəklində qaytaran funksiya yazın

CREATE FUNCTION BetweenTwoDateOfSudents(@DateOut1 DATETIME,@DateOut2 DATETIME)
RETURNS TABLE
RETURN
(
  SELECT Students.FirstName,Students.LastName FROM Students INNER JOIN S_Cards
  ON Students.Id=S_Cards.Id_Student
  WHERE @DateOut1<S_Cards.DateOut AND S_Cards.DateOut<@DateOut2
)

SELECT * FROM BetweenTwoDateOfSudents('1998.11.30','2002.02.08')

--5. Müəyyən kitabla hal hazırda işləyən bütün tələbələrin siyahısını qaytaran funksiya yazın.
CREATE FUNCTION StudentsWorking(@BookName NVARCHAR(MAX))
RETURNS TABLE
RETURN
(
  SELECT Students.FirstName,Students.LastName,Books.Name AS BooksName FROM Students INNER JOIN S_Cards
  ON Students.Id=S_Cards.Id_Student INNER JOIN Books
  ON Books.Id=S_Cards.Id_Book
  WHERE Books.Name=@BookName AND S_Cards.DateIn IS NULL
)
SELECT*FROM S_Cards
SELECT*FROM Students
SELECT*FROM Books
SELECT*FROM Press
--6. Çap etdiyi bütün səhifə cəmi N-dən böyük olan Publisherlər haqqında informasiya qaytaran funksiya yazın.
CREATE FUNCTION CridentialsOfPublisher(@PAGE int)
RETURNS TABLE
RETURN
(
   SELECT Press.Id,Press.Name,SUM(Pages) AS SumOfPages FROM Books INNER JOIN Press
   ON Books.Id_Press=Press.Id
   GROUP BY Press.Name,Press.Id
   HAVING SUM(Pages)>@PAGE
)
SELECT * FROM CridentialsOfPublisher(2500)

--7.Studentlər arasında Ən popular yazici və onun götürülmüş kitablarının 
--sayı haqqında informasiya verən funksiya yazın

CREATE FUNCTION PopularityStudents()
RETURNS TABLE
RETURN
(
  SELECT TOP(1) WITH TIES Authors.FirstName,COUNT(Authors.FirstName)AS Popularity ,Books.[Name] AS BookName
  FROM Students INNER JOIN S_Cards
  ON Students.Id=S_Cards.Id_Student INNER JOIN Books
  ON Id_Book=Books.Id INNER JOIN Authors
  ON Id_Author=Authors.Id
  GROUP BY Authors.FirstName,Books.Name
  ORDER BY Popularity DESC
)

SELECT * FROM PopularityStudents()

--8. Write a function that returns a list of books that were taken by both teachers and students.
--Studentlər və Teacherlər (hər ikisi) tərəfindən götürülmüş (ortaq - həm onlar həm bunlar) kitabların listini qaytaran funksiya yazın.
CREATE FUNCTION SameBooks()
RETURNS TABLE
RETURN
(
SELECT Books.[Name] AS [Book Name] 
FROM Books INNER JOIN S_Cards 
ON S_Cards.Id_Book = Books.Id
INTERSECT
SELECT Books.[Name] AS [Book Name] 
FROM Books 
INNER JOIN T_Cards ON T_Cards.Id_Book = Books.Id
)

SELECT * FROM SameBooks()

--9. Kitab götürməyən tələbələrin sayını qaytaran funksiya yazın.

CREATE FUNCTION NotTakeBook()
RETURNS int
AS
BEGIN
  DECLARE @count int=0;
  SELECT @count=COUNT(Students.Id) FROM S_Cards FULL JOIN Students
  ON Students.Id=S_Cards.Id_Student
  WHERE Id_Book IS NULL
RETURN @count;
END


DECLARE @result int = 0
EXEC @result = NotTakeBook 
PRINT @result


--10. Kitabxanaçılar və onların verdiyi kitabların sayını qaytaran funksiya yazın.

CREATE FUNCTION LibAllBooks()
RETURNS TABLE
RETURN
(
  SELECT Libs.LastName,Libs.FirstName,
  ((SELECT COUNT(*) 
  FROM S_Cards
  WHERE S_Cards.Id_Lib = Libs.Id
  GROUP BY S_Cards.Id_Lib) +
  (SELECT COUNT(*) 
  FROM T_Cards
  WHERE T_Cards.Id_Lib = Libs.Id
  GROUP BY T_Cards.Id_Lib)) AS Total
  FROM Libs
)

SELECT * FROM LibAllBooks()