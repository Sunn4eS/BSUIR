USE computer_repair;

DELIMITER //

-- =================================================================
-- 1. PROCEDURE: sp_create_new_order (Полный цикл приема заказа)
-- =================================================================
-- Создает запись об устройстве и сам заказ в единой транзакции.
DROP PROCEDURE IF EXISTS sp_create_new_order //
CREATE PROCEDURE sp_create_new_order(
    IN p_client_id INT,
    IN p_device_type_id SMALLINT,
    IN p_manufacturer VARCHAR(100),
    IN p_model VARCHAR(100),
    IN p_serial_number VARCHAR(100),
    IN p_problem_desc TEXT,
    IN p_manager_id INT,
    IN p_planned_date DATE,
    OUT p_order_id INT
)
BEGIN
    DECLARE v_device_id INT;

    -- Проверка существования клиента и менеджера
    IF NOT EXISTS (SELECT 1 FROM client WHERE client_id = p_client_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Клиент не найден.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM employee WHERE employee_id = p_manager_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Менеджер не найден.';
    END IF;

    START TRANSACTION;

    -- 1. Добавление устройства
    INSERT INTO device (client_id, device_type_id, manufacturer, model, serial_number, receipt_date, description_of_problem)
    VALUES (p_client_id, p_device_type_id, p_manufacturer, p_model, p_serial_number, CURDATE(), p_problem_desc);

    SET v_device_id = LAST_INSERT_ID();

    -- 2. Добавление заказа
    INSERT INTO repair_order (device_id, employee_id, order_date, planned_completion_date, status)
    VALUES (v_device_id, p_manager_id, CURDATE(), p_planned_date, 'Принят');

    SET p_order_id = LAST_INSERT_ID();

    COMMIT;
END //

-- =================================================================
-- 2. PROCEDURE: sp_update_order_status (Контролируемое обновление статуса)
-- =================================================================
DROP PROCEDURE IF EXISTS sp_update_order_status //
CREATE PROCEDURE sp_update_order_status(
    IN p_order_id INT,
    IN p_new_status ENUM('Принят', 'В работе', 'Готов', 'Выдан', 'Отменен'),
    IN p_engineer_id INT
)
BEGIN
    -- Проверка на "В работе" без инженера
    IF p_new_status = 'В работе' AND p_engineer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Для статуса "В работе" необходимо назначить инженера.';
    END IF;
    
    -- Обновление заказа
    UPDATE repair_order
    SET
        status = p_new_status,
        engineer_id = 
            CASE 
                WHEN p_new_status = 'В работе' AND p_engineer_id IS NOT NULL THEN p_engineer_id -- Назначаем инженера, если статус "В работе"
                ELSE engineer_id 
            END,
        actual_completion_date = 
            CASE 
                WHEN p_new_status = 'Выдан' THEN CURDATE() -- Автоматически проставляем дату выдачи
                ELSE actual_completion_date 
            END
    WHERE order_id = p_order_id;
    
    -- Дополнительная логика (например, уведомление клиента) может быть добавлена здесь
END //


-- =================================================================
-- 3. PROCEDURE: sp_replenish_part_stock (Пополнение запасов)
-- =================================================================
DROP PROCEDURE IF EXISTS sp_replenish_part_stock //
CREATE PROCEDURE sp_replenish_part_stock(
    IN p_part_id INT,
    IN p_quantity INT
)
BEGIN
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Количество для пополнения должно быть положительным.';
    END IF;

    -- Обновление количества
    UPDATE part
    SET stock_quantity = stock_quantity + p_quantity
    WHERE part_id = p_part_id;
    
    -- Проверка, был ли обновлен какой-либо ряд (т.е. существует ли запчасть)
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Запчасть с указанным ID не найдена.';
    END IF;
    
    -- Логирование операции пополнения может быть добавлено в отдельную таблицу
END //


-- =================================================================
-- 4. FUNCTION: sf_get_monthly_revenue (Расчет месячной выручки)
-- =================================================================
DROP FUNCTION IF EXISTS sf_get_monthly_revenue //
CREATE FUNCTION sf_get_monthly_revenue(
    p_year INT,
    p_month INT
)
RETURNS DECIMAL(15, 2)
READS SQL DATA
BEGIN
    DECLARE v_revenue DECIMAL(15, 2);

    SELECT COALESCE(SUM(total_amount), 0.00) INTO v_revenue
    FROM repair_order
    WHERE status = 'Выдан'
      AND YEAR(actual_completion_date) = p_year
      AND MONTH(actual_completion_date) = p_month;

    RETURN v_revenue;
END //

DELIMITER ;

SELECT '✅ Хранимые подпрограммы и функции успешно добавлены.' AS Status;