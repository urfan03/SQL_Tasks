--Task 1
SELECT
    c.CustomerName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(p.Price * od.Quantity) AS TotalAmountSpent,
    (
        SELECT p.Category
        FROM Products p
        JOIN OrderDetails od2 ON p.ProductID = od2.ProductID
        JOIN Orders o2 ON od2.OrderID = o2.OrderID
        WHERE o2.CustomerID = c.CustomerID
        GROUP BY p.Category
        ORDER BY SUM(od2.Quantity) DESC
        LIMIT 1
    ) AS FavoriteProductCategory
FROM
    Customers c
JOIN
    Orders o ON c.CustomerID = o.CustomerID
JOIN
    OrderDetails od ON o.OrderID = od.OrderID
JOIN
    Products p ON od.ProductID = p.ProductID
GROUP BY
    c.CustomerID, c.CustomerName;

-- Task 2

SELECT
    s.StudentName,
    c.CourseName,
    (SELECT MAX(e.Grade)
     FROM Enrollments e
     WHERE e.StudentID = s.StudentID AND e.CourseID = c.CourseID) AS HighestGrade,
    (SELECT AVG(e2.Grade)
     FROM Enrollments e2
     WHERE e2.StudentID = s.StudentID) AS AverageGrade
FROM
    Students s
JOIN
    Enrollments e ON s.StudentID = e.StudentID
JOIN
    Courses c ON e.CourseID = c.CourseID
GROUP BY
    s.StudentID, s.StudentName, c.CourseName
HAVING
    AverageGrade > 75;


--Task 3

SELECT
    a.ArticleID,
    a.Title,
    COUNT(c.CommentID) AS CommentCount
FROM
    Articles a
LEFT JOIN
    Comments c ON a.ArticleID = c.ArticleID
GROUP BY
    a.ArticleID, a.Title
ORDER BY
    a.PublishedDate DESC
LIMIT 10;

CREATE INDEX idx_articles_publisheddate ON Articles (PublishedDate);
CREATE INDEX idx_comments_articleid ON Comments (ArticleID);

--Task 4

DELIMITER //

CREATE PROCEDURE TransferFunds(
    IN p_FromAccountID INT,
    IN p_ToAccountID INT,
    IN p_Amount DECIMAL(10, 2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF (SELECT Balance FROM Accounts WHERE AccountID = p_FromAccountID) >= p_Amount THEN
        UPDATE Accounts
        SET Balance = Balance - p_Amount
        WHERE AccountID = p_FromAccountID;

        UPDATE Accounts
        SET Balance = Balance + p_Amount
        WHERE AccountID = p_ToAccountID;

        INSERT INTO Transactions (FromAccountID, ToAccountID, Amount, TransactionDate)
        VALUES (p_FromAccountID, p_ToAccountID, p_Amount, NOW());

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END //

DELIMITER ;

