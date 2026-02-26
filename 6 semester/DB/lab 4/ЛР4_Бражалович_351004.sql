-- Бражалович Александр, Лабораторная 3, 351004
-- 5. Для всех выдач, произведённых до 1-го января 2012-го года, уменьшить значение дня выдачи на 3.
UPDATE [subscriptions]
SET [sb_start] = DATEADD(day, -3, [sb_start])
WHERE [sb_start] < '2012-01-01';


-- 7. Удалить информацию обо всех выдачах читателям книги с идентификатором 1.
DELETE FROM [subscriptions]
WHERE [sb_book] = 1;


-- 8. Удалить все книги, относящиеся к жанру «Классика».
DELETE FROM [m2m_books_genres]
WHERE [g_id] = (SELECT [g_id] FROM [genres] WHERE [g_name] = N'Классика');

DELETE FROM [m2m_books_authors]
WHERE [b_id] IN (
    SELECT [b_id]
    FROM [books]
    WHERE [b_id] NOT IN (
        SELECT DISTINCT [b_id]
        FROM [m2m_books_genres]
    )
);

DELETE FROM [books]
WHERE [b_id] NOT IN (
    SELECT DISTINCT [b_id]
    FROM [m2m_books_genres]
);

DELETE FROM [genres]
WHERE [g_name] = N'Классика';


-- 9. Удалить информацию обо всех выдачах книг, произведённых после 20-го числа любого месяца любого года.
DELETE FROM [subscriptions]
WHERE DAY([sb_start]) > 20;


-- 10. Добавить в базу данных жанры «Политика», «Психология», «История».
INSERT INTO [genres] ([g_name])
SELECT N'Политика'
WHERE NOT EXISTS (SELECT 1 FROM [genres] WHERE [g_name] = N'Политика');

INSERT INTO [genres] ([g_name])
SELECT N'Психология'
WHERE NOT EXISTS (SELECT 1 FROM [genres] WHERE [g_name] = N'Психология');

INSERT INTO [genres] ([g_name])
SELECT N'История'
WHERE NOT EXISTS (SELECT 1 FROM [genres] WHERE [g_name] = N'История');
