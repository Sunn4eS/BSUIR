-- 1. Создать представление, позволяющее получать список читателей с количеством находящихся у каждого читателя на руках книг,
--    но отображающее только таких читателей, по которым имеются задолженности,
--    т.е. на руках у читателя есть хотя бы одна книга, которую он должен был вернуть до наступления текущей даты.

CREATE VIEW v_debtors AS
SELECT s.s_id, s.s_name, COUNT(*) AS books_on_hands
FROM subscribers s
JOIN subscriptions sub ON s.s_id = sub.sb_subscriber
WHERE sub.sb_is_active = 'Y'
GROUP BY s.s_id, s.s_name
HAVING COUNT(CASE WHEN sub.sb_finish < CAST(GETDATE() AS DATE) THEN 1 END) > 0;
GO


-- 5. Создать представление, возвращающее всю информацию из таблицы subscriptions,
--    преобразуя даты из полей sb_start и sb_finish в формат «ГГГГ-ММ-ДД НН»,
--    где «НН» — день недели в виде своего полного названия (т.е. «Понедельник», «Вторник» и т.д.)

CREATE VIEW v_subscriptions_with_weekday AS
SELECT 
    sb_id,
    sb_subscriber,
    sb_book,
    CONVERT(varchar(10), sb_start, 120) + ' ' + DATENAME(weekday, sb_start) AS sb_start_formatted,
    CONVERT(varchar(10), sb_finish, 120) + ' ' + DATENAME(weekday, sb_finish) AS sb_finish_formatted,
    sb_is_active
FROM subscriptions;
GO


-- 12. Модифицировать схему базы данных таким образом, чтобы таблица «subscribers»
--     хранила информацию о том, сколько раз читатель брал в библиотеке книги
--     (этот счётчик должен инкрементироваться каждый раз, когда читателю выдаётся книга;
--     уменьшение значения этого счётчика не предусмотрено).

ALTER TABLE subscribers ADD s_borrow_count INT NOT NULL DEFAULT 0;
GO

CREATE TRIGGER trg_subscribers_borrow_increment
ON subscriptions
AFTER INSERT
AS
BEGIN
    UPDATE subscribers
    SET s_borrow_count = s_borrow_count + ins.cnt
    FROM subscribers s
    INNER JOIN (
        SELECT sb_subscriber, COUNT(*) AS cnt
        FROM inserted
        GROUP BY sb_subscriber
    ) ins ON s.s_id = ins.sb_subscriber;
END;
GO


-- 13. Создать триггер, не позволяющий добавить в базу данных информацию о выдаче книги,
--     если выполняется хотя бы одно из условий:
--     - дата выдачи или возврата приходится на воскресенье;
--     - читатель брал за последние полгода более 100 книг;
--     - промежуток времени между датами выдачи и возврата менее трёх дней.

CREATE TRIGGER trg_subscriptions_prevent_insert
ON subscriptions
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM (SELECT DISTINCT sb_subscriber FROM inserted) d
        WHERE (
            SELECT COUNT(*)
            FROM subscriptions s
            WHERE s.sb_subscriber = d.sb_subscriber
              AND s.sb_start >= DATEADD(month, -6, GETDATE())
        ) + (
            SELECT COUNT(*)
            FROM inserted i
            WHERE i.sb_subscriber = d.sb_subscriber
        ) > 100
    )
    BEGIN
        RAISERROR('Читатель брал за последние полгода более 100 книг (с учётом текущей выдачи)', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATENAME(weekday, sb_start) = N'воскресенье'
           OR DATENAME(weekday, sb_finish) = N'воскресенье'
           OR DATEDIFF(day, sb_start, sb_finish) < 3
    )
    BEGIN
        RAISERROR('Дата выдачи или возврата приходится на воскресенье, либо интервал менее 3 дней', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO


-- 14. Создать триггер, не позволяющий выдать книгу читателю,
--     у которого на руках находится пять и более книг,
--     при условии, что суммарное время, оставшееся до возврата всех выданных ему книг,
--     составляет менее одного месяца.

CREATE TRIGGER trg_subscriptions_prevent_by_remaining_time
ON subscriptions
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM (SELECT DISTINCT sb_subscriber FROM inserted) d
        WHERE (
            SELECT COUNT(*)
            FROM subscriptions s
            WHERE s.sb_subscriber = d.sb_subscriber
              AND s.sb_is_active = 'Y'
        ) >= 5
        AND (
            SELECT SUM(
                CASE WHEN DATEDIFF(day, GETDATE(), s.sb_finish) < 0
                     THEN 0
                     ELSE DATEDIFF(day, GETDATE(), s.sb_finish)
                END
            )
            FROM subscriptions s
            WHERE s.sb_subscriber = d.sb_subscriber
              AND s.sb_is_active = 'Y'
        ) < 30 
    )
    BEGIN
        RAISERROR('У читателя 5 или более книг, а суммарное оставшееся время до их возврата менее месяца', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO