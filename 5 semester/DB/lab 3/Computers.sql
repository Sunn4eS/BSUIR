-- Создание базы данных
CREATE DATABASE IF NOT EXISTS computer_repair;
USE computer_repair;

-- ---------------------------------------------------------------------
-- 1. Таблица "Клиенты" (Clients)
-- ---------------------------------------------------------------------
CREATE TABLE Clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор клиента',
    name VARCHAR(255) NOT NULL COMMENT 'ФИО или Название организации',
    client_type ENUM('Физическое лицо', 'Юридическое лицо') NOT NULL COMMENT 'Тип клиента',
    phone VARCHAR(20) NOT NULL COMMENT 'Контактный телефон',
    email VARCHAR(255) UNIQUE COMMENT 'Email (уникальный)',
    address VARCHAR(255) COMMENT 'Адрес'
) COMMENT 'Основная информация о заказчиках';

-- ---------------------------------------------------------------------
-- 2. Таблица "Сотрудники" (Employees)
-- ---------------------------------------------------------------------
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор сотрудника',
    full_name VARCHAR(255) NOT NULL COMMENT 'ФИО сотрудника',
    position VARCHAR(100) NOT NULL COMMENT 'Должность (Инженер, Менеджер)',
    specialization VARCHAR(100) COMMENT 'Специализация инженера',
    phone VARCHAR(20) NOT NULL COMMENT 'Контактный телефон'
) COMMENT 'Информация о персонале фирмы';

-- ---------------------------------------------------------------------
-- 3. Таблица "Оборудование" (Devices)
-- ---------------------------------------------------------------------
CREATE TABLE Devices (
    device_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор устройства',
    client_id INT NOT NULL COMMENT 'Внешний ключ к таблице Clients',
    device_type VARCHAR(100) NOT NULL COMMENT 'Тип устройства (Ноутбук, ПК, Монитор)',
    manufacturer VARCHAR(100) COMMENT 'Производитель',
    model VARCHAR(100) COMMENT 'Модель',
    serial_number VARCHAR(100) UNIQUE NOT NULL COMMENT 'Серийный номер устройства (уникальный)',
    receipt_date DATE NOT NULL COMMENT 'Дата поступления устройства',
    description_of_problem TEXT COMMENT 'Описание неисправности со слов клиента',
    
    CONSTRAINT fk_device_client FOREIGN KEY (client_id) REFERENCES Clients(client_id)
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) COMMENT 'Информация об устройствах, сданных в ремонт';

-- ---------------------------------------------------------------------
-- 4. Таблица "Заказы" (Orders)
-- ---------------------------------------------------------------------
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор заказа',
    device_id INT NOT NULL COMMENT 'Внешний ключ к таблице Devices',
    employee_id INT NOT NULL COMMENT 'Внешний ключ к таблице Employees (назначенный инженер)',
    order_date DATE NOT NULL COMMENT 'Дата приема заказа',
    planned_completion_date DATE COMMENT 'Планируемая дата выдачи',
    actual_completion_date DATE COMMENT 'Фактическая дата выдачи',
    initial_diagnosis TEXT COMMENT 'Предварительный диагноз инженера',
    status ENUM('Принят', 'В работе', 'Готов', 'Выдан', 'Отменен') NOT NULL COMMENT 'Текущий статус заказа',
    total_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT 'Общая стоимость заказа',
    
    CONSTRAINT fk_order_device FOREIGN KEY (device_id) REFERENCES Devices(device_id)
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_employee FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) COMMENT 'Основной документ, фиксирующий ремонт';

-- ---------------------------------------------------------------------
-- 5. Таблица "Услуги" (Services)
-- ---------------------------------------------------------------------
CREATE TABLE Services (
    service_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор услуги',
    name VARCHAR(255) UNIQUE NOT NULL COMMENT 'Название услуги',
    description TEXT COMMENT 'Подробное описание услуги',
    standard_price DECIMAL(10, 2) NOT NULL COMMENT 'Стандартная цена услуги',
    estimated_hours DECIMAL(5, 2) COMMENT 'Норма-часы на выполнение'
) COMMENT 'Справочник стандартизированных услуг';

-- ---------------------------------------------------------------------
-- 6. Таблица "Запчасти" (Parts)
-- ---------------------------------------------------------------------
CREATE TABLE Parts (
    part_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор запчасти',
    name VARCHAR(255) NOT NULL COMMENT 'Название запчасти',
    article VARCHAR(50) UNIQUE NOT NULL COMMENT 'Артикул (уникальный)',
    purchase_price DECIMAL(10, 2) NOT NULL COMMENT 'Закупочная цена',
    selling_price DECIMAL(10, 2) NOT NULL COMMENT 'Розничная цена',
    stock_quantity INT NOT NULL DEFAULT 0 COMMENT 'Количество на складе',
    
    CONSTRAINT chk_stock_quantity CHECK (stock_quantity >= 0)
) COMMENT 'Складской справочник запчастей и комплектующих';

-- ---------------------------------------------------------------------
-- 7. Таблица "Детали Заказа - Услуги" (OrderServices)
-- ---------------------------------------------------------------------
CREATE TABLE OrderServices (
    order_service_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор записи',
    order_id INT NOT NULL COMMENT 'Внешний ключ к таблице Orders',
    service_id INT NOT NULL COMMENT 'Внешний ключ к таблице Services',
    quantity INT NOT NULL DEFAULT 1 COMMENT 'Количество выполненных услуг',
    actual_service_price DECIMAL(10, 2) NOT NULL COMMENT 'Фактическая цена, по которой оказана услуга',
    
    CONSTRAINT fk_os_order FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT fk_os_service FOREIGN KEY (service_id) REFERENCES Services(service_id)
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    -- Уникальность пары (order_id, service_id) для предотвращения дублирования услуг в одном заказе
    UNIQUE KEY uk_order_service (order_id, service_id)
) COMMENT 'Детализация услуг в заказе';

-- ---------------------------------------------------------------------
-- 8. Таблица "Детали Заказа - Запчасти" (OrderParts)
-- ---------------------------------------------------------------------
CREATE TABLE OrderParts (
    order_part_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Уникальный идентификатор записи',
    order_id INT NOT NULL COMMENT 'Внешний ключ к таблице Orders',
    part_id INT NOT NULL COMMENT 'Внешний ключ к таблице Parts',
    quantity INT NOT NULL DEFAULT 1 COMMENT 'Количество использованных запчастей',
    actual_selling_price DECIMAL(10, 2) NOT NULL COMMENT 'Фактическая цена продажи запчасти',
    
    CONSTRAINT fk_op_order FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT fk_op_part FOREIGN KEY (part_id) REFERENCES Parts(part_id)
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    -- Уникальность пары (order_id, part_id)
    UNIQUE KEY uk_order_part (order_id, part_id)
) COMMENT 'Детализация использованных запчастей в заказе';