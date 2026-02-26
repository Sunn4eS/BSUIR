-- Бражалович Александр, Лабораторная 7, 351004
-- 8. Создать хранимую процедуру, выполняющую подсчёт количества записей в указанной таблице
--    таким образом, чтобы она возвращала максимально корректные данные,
--    даже если для достижения этого результата придётся пожертвовать производительностью.

CREATE OR ALTER PROCEDURE usp_CountRecordsMaxCorrectness
    @table_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @count INT;

    -- Используем уровень изоляции SERIALIZABLE (или подсказку HOLDLOCK),
    -- чтобы предотвратить вставку/удаление строк во время подсчёта.
    SET @sql = N'
        SELECT @cnt = COUNT(*)
        FROM ' + QUOTENAME(@table_name) + ' WITH (SERIALIZABLE);';

    EXEC sp_executesql @sql, N'@cnt INT OUTPUT', @cnt = @count OUTPUT;

    SELECT @count AS record_count;
END;
GO

-- 1. Создать хранимую процедуру, которая:
--    a. добавляет каждой книге два случайных жанра;
--    b. отменяет совершённые действия, если в процессе работы хотя бы одна операция вставки
--       завершилась ошибкой в силу дублирования значения первичного ключа таблицы «m2m_books_genres»
--       (т.е. у такой книги уже был такой жанр).

CREATE OR ALTER PROCEDURE usp_AddRandomGenres
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @b_id INT, @g1 INT, @g2 INT;
        DECLARE book_cursor CURSOR FOR
            SELECT b_id FROM books;

        OPEN book_cursor;
        FETCH NEXT FROM book_cursor INTO @b_id;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Выбираем два различных случайных жанра
            SELECT TOP 1 @g1 = g_id FROM genres ORDER BY NEWID();
            SELECT TOP 1 @g2 = g_id FROM genres WHERE g_id <> @g1 ORDER BY NEWID();

            -- Вставляем первую связь
            INSERT INTO m2m_books_genres (b_id, g_id) VALUES (@b_id, @g1);
            -- Вставляем вторую связь
            INSERT INTO m2m_books_genres (b_id, g_id) VALUES (@b_id, @g2);

            FETCH NEXT FROM book_cursor INTO @b_id;
        END;

        CLOSE book_cursor;
        DEALLOCATE book_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Если ошибка связана с дубликатом первичного ключа (нарушение уникальности)
        IF ERROR_NUMBER() = 2627
            THROW 50001, 'Невозможно добавить жанр: дублирование первичного ключа. Все изменения отменены.', 1;
        ELSE
            THROW;
    END CATCH
END;
GO


-- 2. Создать хранимую процедуру, которая:
--    a. увеличивает значение поля «b_quantity» для всех книг в два раза;
--    b. отменяет совершённое действие, если по итогу выполнения операции
--       среднее количество экземпляров книг превысит значение 50.

CREATE OR ALTER PROCEDURE usp_DoubleBookQuantity
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    UPDATE books SET b_quantity = b_quantity * 2;

    DECLARE @avg_quantity FLOAT;
    SELECT @avg_quantity = AVG(CAST(b_quantity AS FLOAT)) FROM books;

    IF @avg_quantity > 50
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'Среднее количество книг превысило 50. Изменения отменены.', 1;
    END
    ELSE
        COMMIT TRANSACTION;
END;
GO


-- 3. Написать запросы, которые, будучи выполненными параллельно,
--    обеспечивали бы следующий эффект:
--    a. первый запрос должен считать количество выданных на руки и возвращённых в библиотеку книг
--       и не зависеть от запросов на обновление таблицы «subscriptions» (не ждать их завершения);
--    b. второй запрос должен инвертировать значения поля «sb_is_active» таблицы subscriptions
--       с «Y» на «N» и наоборот и не зависеть от первого запроса (не ждать его завершения).

-- Первый запрос (чтение с минимальными блокировками)
SELECT sb_is_active, COUNT(*) AS count
FROM subscriptions WITH (NOLOCK)
GROUP BY sb_is_active;

-- Второй запрос (инвертирование)
UPDATE subscriptions SET sb_is_active = CASE sb_is_active WHEN 'Y' THEN 'N' ELSE 'Y' END;


-- 5. Написать код, в котором запрос, инвертирующий значения поля «sb_is_active» таблицы «subscriptions»
--    с «Y» на «N» и наоборот, будет иметь максимальные шансы на успешное завершение
--    в случае возникновения ситуации взаимной блокировки с другими транзакциями.

SET DEADLOCK_PRIORITY HIGH;  -- Повышаем приоритет текущей транзакции
UPDATE subscriptions SET sb_is_active = CASE sb_is_active WHEN 'Y' THEN 'N' ELSE 'Y' END;