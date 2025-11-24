USE computer_repair;

-- =================================================================
-- 1. Представление: vw_active_orders_summary (Сводка активных заказов)
-- =================================================================
-- Показывает все заказы, которые находятся в работе или ожидают начала.
DROP VIEW IF EXISTS vw_active_orders_summary;

CREATE VIEW vw_active_orders_summary AS
SELECT
    ro.order_id AS 'Order ID',
    ro.status AS 'Статус',
    ro.order_date AS 'Дата приема',
    ro.planned_completion_date AS 'Планируемая дата завершения',
    c.name AS 'Клиент',
    c.phone AS 'Телефон клиента',
    dtl.type_name AS 'Тип устройства',
    d.model AS 'Модель устройства',
    d.serial_number AS 'Серийный номер',
    mgr.full_name AS 'Менеджер (Принял)',
    eng.full_name AS 'Инженер (Назначен)'
FROM
    repair_order ro
JOIN
    device d ON ro.device_id = d.device_id
JOIN
    client c ON d.client_id = c.client_id
JOIN
    device_type_lookup dtl ON d.device_type_id = dtl.type_id
JOIN
    employee mgr ON ro.employee_id = mgr.employee_id -- Менеджер
LEFT JOIN
    employee eng ON ro.engineer_id = eng.employee_id -- Инженер (может быть NULL)
WHERE
    ro.status IN ('Принят', 'В работе');

-- =================================================================
-- 2. Представление: vw_full_invoice_details (Полный детализированный счет)
-- =================================================================
-- Объединяет услуги и запчасти в единый детализированный список для инвойса.
DROP VIEW IF EXISTS vw_full_invoice_details;

CREATE VIEW vw_full_invoice_details AS
-- Услуги
SELECT
    ros.repair_order_id AS 'Order ID',
    'Услуга' AS 'Тип позиции',
    s.name AS 'Наименование',
    ros.quantity AS 'Количество',
    ros.actual_service_price AS 'Цена за ед.',
    (ros.quantity * ros.actual_service_price) AS 'Сумма'
FROM
    repair_order_service ros
JOIN
    service s ON ros.service_id = s.service_id

UNION ALL

-- Запчасти
SELECT
    rop.repair_order_id AS 'Order ID',
    'Запчасть' AS 'Тип позиции',
    p.name AS 'Наименование',
    rop.quantity AS 'Количество',
    rop.actual_selling_price AS 'Цена за ед.',
    (rop.quantity * rop.actual_selling_price) AS 'Сумма'
FROM
    repair_order_part rop
JOIN
    part p ON rop.part_id = p.part_id;

-- =================================================================
-- 3. Представление: vw_engineer_performance (Производительность инженеров)
-- =================================================================
-- Рассчитывает ключевые метрики для инженеров, основываясь на завершенных заказах.
DROP VIEW IF EXISTS vw_engineer_performance;

CREATE VIEW vw_engineer_performance AS
SELECT
    e.full_name AS 'Инженер',
    COUNT(ro.order_id) AS 'Завершено заказов',
    -- Среднее время выполнения (разница между фактическим завершением и приемом)
    AVG(DATEDIFF(ro.actual_completion_date, ro.order_date)) AS 'Среднее время ремонта (дни)'
FROM
    employee e
JOIN
    repair_order ro ON e.employee_id = ro.engineer_id
WHERE
    ro.status = 'Выдан' -- Только завершенные заказы
GROUP BY
    e.employee_id, e.full_name
ORDER BY
    'Завершено заказов' DESC, 'Среднее время ремонта (дни)' ASC;

-- =================================================================
-- 4. Представление: vw_inventory_status_and_value (Состояние склада и стоимость)
-- =================================================================
-- Показывает текущий складской запас и его общую стоимость.
DROP VIEW IF EXISTS vw_inventory_status_and_value;

CREATE VIEW vw_inventory_status_and_value AS
SELECT
    p.article AS 'Артикул',
    p.name AS 'Наименование',
    p.stock_quantity AS 'Остаток на складе',
    p.purchase_price AS 'Закупочная цена',
    p.selling_price AS 'Розничная цена',
    (p.stock_quantity * p.purchase_price) AS 'Общая закупочная стоимость',
    (p.stock_quantity * p.selling_price) AS 'Общая розничная стоимость'
FROM
    part p
ORDER BY
    p.stock_quantity ASC;


    