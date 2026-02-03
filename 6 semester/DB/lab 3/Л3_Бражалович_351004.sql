-- Бражалович Александр, Лабораторная 3, 351004
-- 2. Показать список книг, относящихся ровно к одному жанру.
WITH GenreStats AS (
    SELECT 
        b_id, 
        COUNT(*) AS g_count
    FROM [m2m_books_genres]
    GROUP BY b_id
)
SELECT 
    [books].b_name
FROM [books] 
JOIN GenreStats ON [books].b_id = GenreStats.b_id
WHERE GenreStats.g_count = 1;

-- 22.	Показать читателей наибольшего количества жанров (не важно, брали ли они кни-ги, каждая из которых относится одновременно к многим жанрам, или же просто много книг из разных жанров, каждая из которых относится к небольшому количе-ству жанров).
SELECT TOP 1 WITH TIES
    [subscribers].[s_name],
    COUNT(DISTINCT [m2m_books_genres].[g_id]) AS GenresCount
FROM [subscribers]
JOIN [subscriptions] ON [subscribers].[s_id] = [subscriptions].[sb_subscriber]
JOIN [m2m_books_genres] ON [subscriptions].[sb_book] = [m2m_books_genres].[b_id]
GROUP BY [subscribers].[s_id], [subscribers].[s_name]
ORDER BY GenresCount DESC;

-- 23.	Показать читателя, последним взявшего в библиотеке книгу.
SELECT TOP 1
    [subscribers].[s_name]
FROM [subscribers]
JOIN [subscriptions] ON [subscribers].[s_id] = [subscriptions].[sb_subscriber]
ORDER BY [subscriptions].[sb_start] DESC;

-- 24.	Показать читателя (или читателей, если их окажется несколько), дольше всего держащего у себя книгу (учитывать только случаи, когда книга не возвращена).
SELECT TOP 1 WITH TIES
    [subscribers].[s_name],
    [subscriptions].[sb_start]
FROM [subscribers]
JOIN [subscriptions] ON [subscribers].[s_id] = [subscriptions].[sb_subscriber]
WHERE [subscriptions].[sb_is_active] = 'Y'
ORDER BY [subscriptions].[sb_start] ASC;

-- 25.	Показать, какую книгу (или книги, если их несколько) каждый читатель взял в свой последний визит в библиотеку.
SELECT 
    [SubData].[s_name],
    [SubData].[b_name]
FROM (
    SELECT 
        [subscribers].[s_name],
        [books].[b_name],
        RANK() OVER (PARTITION BY [subscribers].[s_id] ORDER BY [subscriptions].[sb_start] DESC) AS LastVisitRank
    FROM [subscribers]
    JOIN [subscriptions] ON [subscribers].[s_id] = [subscriptions].[sb_subscriber]
    JOIN [books] ON [subscriptions].[sb_book] = [books].[b_id]
) AS [SubData]
WHERE [SubData].[LastVisitRank] = 1;