USE computer_repair;

DELIMITER //

-- =================================================================
-- 1. ТРИГГЕРЫ ДЛЯ АВТОМАТИЧЕСКОГО ЗАПОЛНЕНИЯ ЦЕН (BEFORE INSERT)
-- =================================================================

-- Триггер для автоматического заполнения цены услуги
DROP TRIGGER IF EXISTS trg_ros_set_default_price;
CREATE TRIGGER trg_ros_set_default_price
BEFORE INSERT ON repair_order_service
FOR EACH ROW
BEGIN
    -- Если фактическая цена не задана (NULL или 0), берем стандартную цену из справочника service
    IF NEW.actual_service_price IS NULL OR NEW.actual_service_price = 0 THEN
        SELECT standard_price INTO NEW.actual_service_price
        FROM service
        WHERE service_id = NEW.service_id;
    END IF;
END //

-- Триггер для автоматического заполнения цены запчасти
DROP TRIGGER IF EXISTS trg_rop_set_default_price;
CREATE TRIGGER trg_rop_set_default_price
BEFORE INSERT ON repair_order_part
FOR EACH ROW
BEGIN
    -- Если фактическая цена не задана (NULL или 0), берем розничную цену из справочника part
    IF NEW.actual_selling_price IS NULL OR NEW.actual_selling_price = 0 THEN
        SELECT selling_price INTO NEW.actual_selling_price
        FROM part
        WHERE part_id = NEW.part_id;
    END IF;
END //


-- =================================================================
-- 2. ТРИГГЕРЫ ДЛЯ УПРАВЛЕНИЯ ЗАПАСАМИ (INVENTORY MANAGEMENT)
-- =================================================================

-- 2.1. AFTER INSERT: Списание со склада при добавлении запчасти в заказ
DROP TRIGGER IF EXISTS trg_rop_stock_decrease_insert;
CREATE TRIGGER trg_rop_stock_decrease_insert
AFTER INSERT ON repair_order_part
FOR EACH ROW
BEGIN
    UPDATE part
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE part_id = NEW.part_id;
END //

-- 2.2. AFTER UPDATE: Корректировка склада при изменении количества в заказе
DROP TRIGGER IF EXISTS trg_rop_stock_update;
CREATE TRIGGER trg_rop_stock_update
AFTER UPDATE ON repair_order_part
FOR EACH ROW
BEGIN
    -- Если количество ИЗМЕНИЛОСЬ
    IF OLD.quantity <> NEW.quantity THEN
        -- Разница: OLD.quantity - NEW.quantity
        -- Если разница положительна (количество уменьшилось), stock_quantity увеличивается
        -- Если разница отрицательна (количество увеличилось), stock_quantity уменьшается
        UPDATE part
        SET stock_quantity = stock_quantity + (OLD.quantity - NEW.quantity)
        WHERE part_id = NEW.part_id;
    END IF;
END //

-- 2.3. AFTER DELETE: Возврат на склад при удалении запчасти из заказа
DROP TRIGGER IF EXISTS trg_rop_stock_increase_delete;
CREATE TRIGGER trg_rop_stock_increase_delete
AFTER DELETE ON repair_order_part
FOR EACH ROW
BEGIN
    UPDATE part
    SET stock_quantity = stock_quantity + OLD.quantity
    WHERE part_id = OLD.part_id;
END //

DELIMITER ;

SELECT '✅ Новые триггеры для управления ценами и запасами успешно добавлены.' AS Status;