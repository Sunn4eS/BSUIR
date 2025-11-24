-- =================================================================
-- 1. СОЗДАНИЕ И НАСТРОЙКА БАЗЫ ДАННЫХ
-- =================================================================
-- Удаление старой базы данных (если существует) для чистого развертывания
DROP DATABASE IF EXISTS computer_repair;

CREATE DATABASE IF NOT EXISTS computer_repair
    CHARACTER SET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

USE computer_repair;

-- =================================================================
-- 2. СПРАВОЧНЫЕ ТАБЛИЦЫ (НОРМАЛИЗАЦИЯ)
-- =================================================================

-- 2.1. Справочник должностей
CREATE TABLE position_lookup (
    position_id SMALLINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID должности',
    position_name VARCHAR(100) UNIQUE NOT NULL COMMENT 'Название должности'
) COMMENT 'Справочник должностей для нормализации Employee.position';

-- 2.2. Справочник типов устройств
CREATE TABLE device_type_lookup (
    type_id SMALLINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID типа устройства',
    type_name VARCHAR(100) UNIQUE NOT NULL COMMENT 'Название типа устройства'
) COMMENT 'Справочник типов устройств для нормализации Device.device_type';

-- 2.3. Справочник стандартизированных услуг
CREATE TABLE service (
    service_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор услуги',
    name VARCHAR(255) UNIQUE NOT NULL COMMENT 'Название услуги',
    description TEXT COMMENT 'Подробное описание услуги',
    standard_price DECIMAL(10, 2) NOT NULL COMMENT 'Стандартная цена услуги',
    estimated_hours DECIMAL(4, 2) COMMENT 'Норма-часы на выполнение (Оптимизация типа данных)'
) COMMENT 'Справочник стандартизированных услуг';

-- 2.4. Складской справочник запчастей
CREATE TABLE part (
    part_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор запчасти',
    name VARCHAR(255) NOT NULL COMMENT 'Название запчасти',
    article VARCHAR(50) UNIQUE NOT NULL COMMENT 'Артикул (уникальный)',
    purchase_price DECIMAL(10, 2) NOT NULL COMMENT 'Закупочная цена',
    selling_price DECIMAL(10, 2) NOT NULL COMMENT 'Розничная цена',
    stock_quantity INT NOT NULL DEFAULT 0 COMMENT 'Количество на складе',
    is_active BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Флаг активности (Мягкое удаление)',
    
    CONSTRAINT chk_stock_quantity CHECK (stock_quantity >= 0)
) COMMENT 'Складской справочник запчастей и комплектующих';
CREATE INDEX idx_part_name ON part (name);
CREATE INDEX idx_stock_quantity ON part (stock_quantity);


-- =================================================================
-- 3. ОСНОВНЫЕ СУЩНОСТИ (Использование snake_case и единственного числа)
-- =================================================================

-- 3.1. Таблица "Клиенты"
CREATE TABLE client (
    client_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор клиента',
    name VARCHAR(255) NOT NULL COMMENT 'ФИО или Название организации',
    client_type ENUM('Физическое лицо', 'Юридическое лицо') NOT NULL COMMENT 'Тип клиента',
    phone VARCHAR(20) NOT NULL COMMENT 'Контактный телефон',
    email VARCHAR(255) UNIQUE COMMENT 'Email (уникальный)',
    address VARCHAR(255) COMMENT 'Адрес'
) COMMENT 'Основная информация о заказчиках';
CREATE INDEX idx_client_name ON client (name);
CREATE INDEX idx_client_type ON client (client_type); 

-- 3.2. Таблица "Сотрудники"
CREATE TABLE employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор сотрудника',
    full_name VARCHAR(255) NOT NULL COMMENT 'ФИО сотрудника',
    position_id SMALLINT NOT NULL COMMENT 'Внешний ключ к справочнику должностей (Нормализация)',
    specialization VARCHAR(100) COMMENT 'Специализация инженера',
    phone VARCHAR(20) NOT NULL COMMENT 'Контактный телефон',
    
    CONSTRAINT fk_employee_position
        FOREIGN KEY (position_id) REFERENCES position_lookup(position_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Информация о персонале фирмы';
CREATE INDEX idx_employee_specialization ON employee (specialization);

-- 3.3. Таблица "Оборудование"
CREATE TABLE device (
    device_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор устройства',
    client_id INT NOT NULL COMMENT 'Внешний ключ к таблице client',
    device_type_id SMALLINT NOT NULL COMMENT 'Внешний ключ к справочнику типов устройств (Нормализация)',
    manufacturer VARCHAR(100) COMMENT 'Производитель',
    model VARCHAR(100) COMMENT 'Модель',
    serial_number VARCHAR(100) UNIQUE NOT NULL COMMENT 'Серийный номер устройства (уникальный)',
    receipt_date DATE NOT NULL COMMENT 'Дата поступления устройства',
    description_of_problem TEXT COMMENT 'Описание неисправности со слов клиента',
    
    CONSTRAINT fk_device_client FOREIGN KEY (client_id) REFERENCES client(client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_device_type FOREIGN KEY (device_type_id) REFERENCES device_type_lookup(type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Информация об устройствах, сданных в ремонт';
CREATE INDEX idx_receipt_date ON device (receipt_date);


-- 3.4. Таблица "Заказы"
CREATE TABLE repair_order (
    order_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор заказа',
    device_id INT NOT NULL COMMENT 'Внешний ключ к таблице device',
    employee_id INT NOT NULL COMMENT 'Внешний ключ к employee (Менеджер, принявший заказ)',
    engineer_id INT COMMENT 'Внешний ключ к employee (Инженер, назначенный на ремонт)', -- Добавленная связь
    order_date DATE NOT NULL COMMENT 'Дата приема заказа',
    planned_completion_date DATE COMMENT 'Планируемая дата выдачи',
    actual_completion_date DATE COMMENT 'Фактическая дата выдачи',
    initial_diagnosis TEXT COMMENT 'Предварительный диагноз инженера',
    status ENUM('Принят', 'В работе', 'Готов', 'Выдан', 'Отменен') NOT NULL COMMENT 'Текущий статус заказа',
    total_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT 'Общая стоимость заказа (поддерживается триггерами)',
    
    CONSTRAINT fk_order_device FOREIGN KEY (device_id) REFERENCES device(device_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_order_manager FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_order_engineer FOREIGN KEY (engineer_id) REFERENCES employee(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Основной документ, фиксирующий ремонт';
CREATE INDEX idx_order_status ON repair_order (status); 
CREATE INDEX idx_order_date ON repair_order (order_date); 
CREATE INDEX idx_planned_completion_date ON repair_order (planned_completion_date);
CREATE INDEX idx_engineer_id ON repair_order (engineer_id);


-- =================================================================
-- 4. ТАБЛИЦЫ СВЯЗЕЙ (М:М) - Оптимизация ключей
-- =================================================================

-- 4.1. Таблица "Детали Заказа - Услуги"
CREATE TABLE repair_order_service (
    -- order_service_id удален, используется составной PK
    repair_order_id INT NOT NULL COMMENT 'Внешний ключ к таблице repair_order',
    service_id INT NOT NULL COMMENT 'Внешний ключ к таблице service',
    quantity TINYINT NOT NULL DEFAULT 1 COMMENT 'Количество выполненных услуг (Оптимизация типа данных)',
    actual_service_price DECIMAL(10, 2) NOT NULL COMMENT 'Фактическая цена, по которой оказана услуга',
    
    PRIMARY KEY (repair_order_id, service_id), -- Составной первичный ключ (Оптимизация)
    
    CONSTRAINT fk_os_order FOREIGN KEY (repair_order_id) REFERENCES repair_order(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_os_service FOREIGN KEY (service_id) REFERENCES service(service_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Детализация услуг в заказе';

-- 4.2. Таблица "Детали Заказа - Запчасти"
CREATE TABLE repair_order_part (
    -- order_part_id удален, используется составной PK
    repair_order_id INT NOT NULL COMMENT 'Внешний ключ к таблице repair_order',
    part_id INT NOT NULL COMMENT 'Внешний ключ к таблице part',
    quantity TINYINT NOT NULL DEFAULT 1 COMMENT 'Количество использованных запчастей (Оптимизация типа данных)',
    actual_selling_price DECIMAL(10, 2) NOT NULL COMMENT 'Фактическая цена продажи запчасти',
    
    PRIMARY KEY (repair_order_id, part_id), -- Составной первичный ключ (Оптимизация)
    
    CONSTRAINT fk_op_order FOREIGN KEY (repair_order_id) REFERENCES repair_order(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_op_part FOREIGN KEY (part_id) REFERENCES part(part_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Детализация использованных запчастей в заказе';

