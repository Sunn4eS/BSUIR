-- Бражалович Александр, Лабораторная 6, 351004
-- 1. Создать хранимую функцию, получающую на вход идентификатор читателя
--    и возвращающую список идентификаторов книг, которые он уже прочитал
--    и вернул в библиотеку.

CREATE OR ALTER FUNCTION fn_get_returned_books (@subscriber_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT sb_book AS book_id
    FROM subscriptions
    WHERE sb_subscriber = @subscriber_id
      AND sb_is_active = 'N'
);
GO


-- 3. Создать хранимую функцию, получающую на вход идентификатор читателя
--    и возвращающую 1, если у читателя на руках сейчас менее десяти книг,
--    и 0 в противном случае.

CREATE OR ALTER FUNCTION fn_has_less_than_ten_books (@subscriber_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*)
    FROM subscriptions
    WHERE sb_subscriber = @subscriber_id
      AND sb_is_active = 'Y';

    RETURN CASE WHEN @count < 10 THEN 1 ELSE 0 END;
END;
GO


-- 4. Создать хранимую функцию, получающую на вход год издания книги и
--    возвращающую 1, если книга издана менее ста лет назад, и 0 в
--    противном случае.

CREATE OR ALTER FUNCTION fn_is_book_less_than_100_years (@publication_year SMALLINT)
RETURNS BIT
AS
BEGIN
    DECLARE @current_year INT = YEAR(GETDATE());
    RETURN CASE WHEN (@current_year - @publication_year) < 100 THEN 1 ELSE 0 END;
END;
GO


-- 5. Создать хранимую процедуру, обновляющую все поля типа DATE (если такие есть)
--    всех записей указанной таблицы на значение текущей даты.

CREATE OR ALTER PROCEDURE usp_update_date_fields_to_current
    @table_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX) = N'';
    DECLARE @col_name NVARCHAR(128);

    DECLARE col_cursor CURSOR FOR
        SELECT c.name
        FROM sys.tables t
        JOIN sys.columns c ON t.object_id = c.object_id
        JOIN sys.types ty ON c.user_type_id = ty.user_type_id
        WHERE t.name = @table_name
          AND ty.name IN ('date', 'datetime', 'smalldatetime', 'datetime2');

    OPEN col_cursor;
    FETCH NEXT FROM col_cursor INTO @col_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = @sql + N'UPDATE ' + QUOTENAME(@table_name) + 
                    N' SET ' + QUOTENAME(@col_name) + N' = GETDATE(); ';
        FETCH NEXT FROM col_cursor INTO @col_name;
    END;

    CLOSE col_cursor;
    DEALLOCATE col_cursor;

    IF @sql <> N''
        EXEC sp_executesql @sql;
    ELSE
        PRINT N'В таблице нет полей с типом даты.';
END;
GO


-- 9. Создать хранимую процедуру, автоматически создающую и наполняющую
--    данными таблицу «arrears», в которой должны быть представлены
--    идентификаторы и имена читателей, у которых до сих пор находится на
--    руках хотя бы одна книга, по которой дата возврата установлена в
--    прошлом относительно текущей даты.

CREATE OR ALTER PROCEDURE usp_create_arrears_table
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('arrears', 'U') IS NOT NULL
        DROP TABLE arrears;

    CREATE TABLE arrears (
        subscriber_id INT NOT NULL,
        subscriber_name NVARCHAR(150) NOT NULL,
        overdue_books_count INT NOT NULL,
        PRIMARY KEY (subscriber_id)
    );

    INSERT INTO arrears (subscriber_id, subscriber_name, overdue_books_count)
    SELECT s.s_id, s.s_name, COUNT(*) AS cnt
    FROM subscribers s
    JOIN subscriptions sub ON s.s_id = sub.sb_subscriber
    WHERE sub.sb_is_active = 'Y'
      AND sub.sb_finish < CAST(GETDATE() AS DATE)
    GROUP BY s.s_id, s.s_name;
END;
GO