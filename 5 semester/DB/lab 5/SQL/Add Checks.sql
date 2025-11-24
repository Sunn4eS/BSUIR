USE computer_repair;

-- =================================================================
-- 1. Проверки для справочников (Цены должны быть > 0)
-- =================================================================

-- Таблица: service
ALTER TABLE service
    ADD CONSTRAINT chk_service_price_positive CHECK (standard_price > 0);

-- Таблица: part
-- chk_stock_quantity уже существует. Добавим проверку цен.
ALTER TABLE part
    ADD CONSTRAINT chk_part_selling_price_positive CHECK (selling_price > 0),
    ADD CONSTRAINT chk_part_purchase_price_positive CHECK (purchase_price > 0);


-- =================================================================
-- 2. Проверки для транзакционных таблиц (Количества и цены)
-- =================================================================

-- Таблица: repair_order_service (Услуги в Заказе)
ALTER TABLE repair_order_service
    ADD CONSTRAINT chk_os_actual_price_positive CHECK (actual_service_price > 0),
    ADD CONSTRAINT chk_os_quantity_used CHECK (quantity > 0);

-- Таблица: repair_order_part (Запчасти в Заказе)
ALTER TABLE repair_order_part
    ADD CONSTRAINT chk_op_actual_price_positive CHECK (actual_selling_price > 0),
    ADD CONSTRAINT chk_op_quantity_used CHECK (quantity > 0);


-- =================================================================
-- 3. Проверки для таблицы "Заказы" (repair_order)
-- =================================================================

-- 3.1. Проверка логики дат: Фактическая дата завершения не может быть раньше даты приема
ALTER TABLE repair_order
    ADD CONSTRAINT chk_dates_consistency CHECK (actual_completion_date IS NULL OR actual_completion_date >= order_date);

-- 3.2. Проверка бизнес-логики: Заказ в статусе "В работе" должен иметь назначенного инженера.
-- Используем (status != 'В работе' OR engineer_id IS NOT NULL), что означает:
-- 1) Если статус НЕ "В работе", то неважно, есть ли инженер (engineer_id может быть NULL).
-- 2) Если статус "В работе", то engineer_id ДОЛЖЕН БЫТЬ NOT NULL.
ALTER TABLE repair_order
    ADD CONSTRAINT chk_engineer_for_in_progress CHECK (
        status != 'В работе' OR engineer_id IS NOT NULL
    );

SELECT '✅ Проверки (CHECK Constraints) успешно добавлены в базу данных.' AS Status;