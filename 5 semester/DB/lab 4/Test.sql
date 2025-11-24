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



-- Индексы для Clients
CREATE INDEX idx_client_type ON Clients (client_type);
CREATE INDEX idx_client_name ON Clients (name);

-- Индексы для Employees
CREATE INDEX idx_employee_position ON Employees (position);
CREATE INDEX idx_employee_specialization ON Employees (specialization);

-- Индексы для Devices
CREATE INDEX idx_device_type ON Devices (device_type);
CREATE INDEX idx_receipt_date ON Devices (receipt_date);

-- Индексы для Orders
CREATE INDEX idx_order_status ON Orders (status);
CREATE INDEX idx_order_date ON Orders (order_date);
CREATE INDEX idx_planned_completion_date ON Orders (planned_completion_date);

-- Индексы для Parts
CREATE INDEX idx_part_name ON Parts (name);
CREATE INDEX idx_stock_quantity ON Parts (stock_quantity);

-- Применение изменений

SELECT 'Все необходимые индексы добавлены.' AS Status;

--


ALTER TABLE Clients CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE Employees CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE Devices CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE Orders CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE Services CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE Parts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE OrderServices CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE OrderParts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
--




-- 1. Таблица Clients -> client
RENAME TABLE Clients TO client;

-- 2. Таблица Employees -> employee
RENAME TABLE Employees TO employee;

-- 3. Таблица Devices -> device
RENAME TABLE Devices TO device;

-- 4. Таблица Orders -> order
RENAME TABLE Orders TO `order`; 
-- Внимание: 'order' является зарезервированным словом в SQL (ORDER BY), поэтому ее лучше заключать в обратные кавычки (`).
-- Альтернатива: order_ticket или repair_order. Я выберу repair_order для безопасности.
RENAME TABLE `order` TO repair_order;


-- 5. Таблица Services -> service
RENAME TABLE Services TO service;

-- 6. Таблица Parts -> part
RENAME TABLE Parts TO part;

-- 7. Таблица OrderServices -> repair_order_service
RENAME TABLE OrderServices TO repair_order_service;

-- 8. Таблица OrderParts -> repair_order_part
RENAME TABLE OrderParts TO repair_order_part;



-- 1. Добавление нового столбца для ID назначенного инженера
ALTER TABLE repair_order
    ADD COLUMN engineer_id INT COMMENT 'Внешний ключ к таблице employee (Инженер, назначенный на ремонт)';

-- 2. Создание нового внешнего ключа, связывающего Заказ с Инженером
ALTER TABLE repair_order
    ADD CONSTRAINT fk_order_engineer 
    FOREIGN KEY (engineer_id) 
    REFERENCES employee(employee_id)
        ON UPDATE CASCADE      -- При изменении ID сотрудника, обновить и здесь
        ON DELETE RESTRICT;   -- Нельзя удалить сотрудника, пока у него есть назначенные заказы

SELECT 'Критически важная связь с назначенным инженером добавлена.' AS Status;



-- A. Нормализация должностей (position)
-- 1. Создание справочника должностей
CREATE TABLE position_lookup (
    position_id SMALLINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID должности',
    position_name VARCHAR(100) UNIQUE NOT NULL COMMENT 'Название должности'
) COMMENT 'Справочник должностей';

-- 2. Изменение таблицы employee для использования FK
-- (Предполагается, что данные будут мигрированы перед удалением старого столбца)
ALTER TABLE employee
    ADD COLUMN position_id SMALLINT COMMENT 'Внешний ключ к справочнику должностей';

-- 3. Добавление внешнего ключа
ALTER TABLE employee
    ADD CONSTRAINT fk_employee_position
        FOREIGN KEY (position_id) REFERENCES position_lookup(position_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

ALTER TABLE employee
    DROP COLUMN position; -- Удаление избыточного столбца VARCHAR


-- B. Нормализация типов устройств (device_type)
-- 1. Создание справочника типов устройств
CREATE TABLE device_type_lookup (
    type_id SMALLINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID типа устройства',
    type_name VARCHAR(100) UNIQUE NOT NULL COMMENT 'Название типа устройства'
) COMMENT 'Справочник типов устройств';

-- 2. Изменение таблицы device для использования FK
ALTER TABLE device
    ADD COLUMN device_type_id SMALLINT COMMENT 'Внешний ключ к справочнику типов устройств';

-- 3. Добавление внешнего ключа
ALTER TABLE device
    ADD CONSTRAINT fk_device_type
        FOREIGN KEY (device_type_id) REFERENCES device_type_lookup(type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

ALTER TABLE device
    DROP COLUMN device_type; -- Удаление избыточного столбца VARCHAR
    