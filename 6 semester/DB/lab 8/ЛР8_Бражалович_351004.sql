-- Бражалович Александр, Лабораторная 8, 351004
-- 1. Создать хранимую функцию, возвращающую список идентификаторов всех
--    дочерних вершин заданной вершины на глубину, не более заданной.
--    (Для базы данных "Исследование", таблица site_pages)

CREATE OR ALTER FUNCTION fn_get_child_pages
(
    @parent_id INT,
    @max_depth INT
)
RETURNS TABLE
AS
RETURN
(
    WITH RecursiveCTE AS
    (
        SELECT sp_id, sp_parent, 0 AS depth
        FROM site_pages
        WHERE sp_id = @parent_id

        UNION ALL

        SELECT p.sp_id, p.sp_parent, c.depth + 1
        FROM site_pages p
        INNER JOIN RecursiveCTE c ON p.sp_parent = c.sp_id
        WHERE c.depth < @max_depth
    )
    SELECT sp_id
    FROM RecursiveCTE
    WHERE sp_id <> @parent_id
);
GO


-- 3. Написать хранимую функцию, возвращающую список идентификаторов
--    вершин на пути от корня дерева к заданной вершине.
--    (Для базы данных "Исследование", таблица site_pages)

CREATE OR ALTER FUNCTION fn_get_path_to_root
(
    @node_id INT
)
RETURNS TABLE
AS
RETURN
(
    WITH PathCTE AS
    (
        SELECT sp_id, sp_parent
        FROM site_pages
        WHERE sp_id = @node_id

        UNION ALL

        SELECT p.sp_id, p.sp_parent
        FROM site_pages p
        INNER JOIN PathCTE c ON p.sp_id = c.sp_parent
    )
    SELECT sp_id
    FROM PathCTE
);
GO

-- 8. Написать запрос, показывающий по каждой выдаче книг номер дня недели
--    (1 -- понедельник, 2 -- вторник и т.д.) и порядковый номер
--    соответствующего дня недели в году.

SET DATEFIRST 1;  -- понедельник = 1

SELECT
    sb_id,
    DATEPART(weekday, sb_finish) AS weekday_number,
    (DATEPART(dayofyear, sb_finish) - 1) / 7 + 1 AS weekday_ordinal
FROM subscriptions;
GO


-- 9. Написать хранимую функцию, формирующую набор из указанного количества
--    случайных гарантированно неповторяющихся идентификаторов читателей.

CREATE OR ALTER FUNCTION fn_random_subscribers
(
    @count INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP(@count) s_id
    FROM subscribers
    ORDER BY NEWID()
);
GO


-- 11. Извлечь в виде сводной таблицы информацию о том, какое количество
--     книг было возвращено в библиотеку в каждый месяц каждого года.

WITH ReturnStats AS
(
    SELECT
        YEAR(sb_finish) AS Year,
        MONTH(sb_finish) AS Month,
        COUNT(*) AS ReturnsCount
    FROM subscriptions
    WHERE sb_is_active = 'N'
    GROUP BY YEAR(sb_finish), MONTH(sb_finish)
)
SELECT *
FROM ReturnStats
PIVOT
(
    SUM(ReturnsCount)
    FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PivotTable
ORDER BY Year;
GO