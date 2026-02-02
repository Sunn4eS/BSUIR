-- Бражалович Александр, Лабораторная 2, 351004
-- 3.	Показать без повторений идентификаторы книг, которые были взяты читателями. -- 
SELECT DISTINCT 
    sb_book
FROM [subscriptions];


--  12.	Показать идентификатор одного (любого) читателя, взявшего в библиотеке больше всего книг.
SELECT TOP 1 
    sb_subscriber
FROM [subscriptions]
GROUP BY sb_subscriber
ORDER BY COUNT(sb_book) DESC;

-- 15.	Показать, сколько в среднем экземпляров книг есть в библиотеке. --
SELECT 
    AVG(CAST(b_quantity AS FLOAT)) AS [AverageQuantity]
FROM [books];


--16.	Показать в днях, сколько в среднем времени читатели уже зарегистрированы в библиотеке (временем регистрации считать диапазон от первой даты получения читателем книги до текущей даты). --
SELECT AVG(CAST(DATEDIFF(day, FirstVisit, GETDATE()) AS FLOAT)) AS AvgRegDays
FROM (
	SELECT sb_subscriber,
		MIN(sb_start) AS FirstVisit
	FROM [subscriptions]
	GROUP BY sb_subscriber
) AS RegDates

-- 17.	Показать, сколько книг было возвращено и не возвращено в библиотеку (СУБД должна оперировать исходными значениями поля sb_is_active (т.е. «Y» и «N»), а после подсчёта значения «Y» и «N» должны быть преобразованы в «Returned» и «Not returned»). --
SELECT 
    CASE sb_is_active
        WHEN 'N' THEN 'Returned'
        WHEN 'Y' THEN 'Not returned'
    END AS Status,
    COUNT(*) AS BooksCount
FROM [subscriptions]
GROUP BY sb_is_active;