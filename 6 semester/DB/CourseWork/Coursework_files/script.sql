/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

CREATE DATABASE IF NOT EXISTS `musicstore_pro` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE `musicstore_pro`;

-- ==============================================================================
-- БЛОК 1: ГЕОГРАФИЯ И АДРЕСА (4 таблицы)
-- ==============================================================================

DROP TABLE IF EXISTS `countries`;
CREATE TABLE `countries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `iso_code` varchar(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `iso_code` (`iso_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `regions`;
CREATE TABLE `regions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `country_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_region_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `cities`;
CREATE TABLE `cities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `region_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_city_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `addresses`;
CREATE TABLE `addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `city_id` int NOT NULL,
  `street` varchar(150) NOT NULL,
  `building` varchar(50) NOT NULL,
  `apartment` varchar(50) DEFAULT NULL,
  `postal_code` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================================================
-- БЛОК 2: ПОЛЬЗОВАТЕЛИ И АВТОРИЗАЦИЯ (6 таблиц)
-- ==============================================================================

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `user_info`;
CREATE TABLE `user_info` (
  `user_id` int NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `default_address_id` int DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_userinfo_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_userinfo_address` FOREIGN KEY (`default_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`),
  CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `module` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE `role_permissions` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_perm` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================================================
-- БЛОК 3: HR И ПЕРСОНАЛ (6 таблиц)
-- ==============================================================================

DROP TABLE IF EXISTS `departments`;
CREATE TABLE `departments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `positions`;
CREATE TABLE `positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `department_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `base_salary` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_pos_dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `hire_date` date NOT NULL,
  `termination_date` date DEFAULT NULL,
  `status` enum('Активен', 'В отпуске', 'Уволен') DEFAULT 'Активен',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_emp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `employee_positions`;
CREATE TABLE `employee_positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `position_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ep_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ep_pos` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `work_schedules`;
CREATE TABLE `work_schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `work_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_day_off` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ws_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `payroll`;
CREATE TABLE `payroll` (
  `id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `paid_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_pr_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================================================
-- БЛОК 4: КАТАЛОГ И ХАРАКТЕРИСТИКИ ТОВАРОВ (9 таблиц)
-- ==============================================================================

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `subcategories`;
CREATE TABLE `subcategories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_subcat_cat` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `brands`;
CREATE TABLE `brands` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `country_id` int DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  CONSTRAINT `fk_brand_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `product_lines`;
CREATE TABLE `product_lines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `brand_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `launch_year` year DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_pline_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `instruments`;
CREATE TABLE `instruments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subcategory_id` int NOT NULL,
  `brand_id` int NOT NULL,
  `product_line_id` int DEFAULT NULL,
  `model_name` varchar(255) NOT NULL,
  `description` text,
  `base_price` decimal(10,2) NOT NULL,
  `average_rating` decimal(3,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_inst_subcat` FOREIGN KEY (`subcategory_id`) REFERENCES `subcategories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_inst_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_inst_pline` FOREIGN KEY (`product_line_id`) REFERENCES `product_lines` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `instrument_variants`;
CREATE TABLE `instrument_variants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `instrument_id` int NOT NULL,
  `sku` varchar(50) NOT NULL,
  `color` varchar(50) DEFAULT NULL,
  `material` varchar(100) DEFAULT NULL,
  `price_modifier` decimal(10,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`),
  CONSTRAINT `fk_ivar_inst` FOREIGN KEY (`instrument_id`) REFERENCES `instruments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `spec_keys`;
CREATE TABLE `spec_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,  -- Например: 'Количество струн', 'Тип клавиш', 'Мензура'
  `unit` varchar(20) DEFAULT NULL, -- Например: 'мм', 'шт.'
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `instrument_specs`;
CREATE TABLE `instrument_specs` (
  `variant_id` int NOT NULL,
  `spec_key_id` int NOT NULL,
  `spec_value` varchar(255) NOT NULL,
  PRIMARY KEY (`variant_id`, `spec_key_id`),
  CONSTRAINT `fk_ispec_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ispec_key` FOREIGN KEY (`spec_key_id`) REFERENCES `spec_keys` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `instrument_images`;
CREATE TABLE `instrument_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `variant_id` int NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `is_main` tinyint(1) DEFAULT '0',
  `display_order` int DEFAULT '0',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_iimg_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

USE `musicstore_pro`;

-- ==============================================================================
-- БЛОК 5: СКЛАД И ПОСТАВКИ (7 таблиц)
-- ==============================================================================

DROP TABLE IF EXISTS `warehouses`;
CREATE TABLE `warehouses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `address_id` int NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_wh_address` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `warehouse_zones`;
CREATE TABLE `warehouse_zones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL,
  `zone_code` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_wz_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `inventory`;
CREATE TABLE `inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL,
  `zone_id` int DEFAULT NULL,
  `variant_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_inv_zone_variant` (`warehouse_id`, `zone_id`, `variant_id`),
  CONSTRAINT `fk_inv_wh` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inv_zone` FOREIGN KEY (`zone_id`) REFERENCES `warehouse_zones` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_inv_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE `suppliers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `address_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_sup_address` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `acquisitions`;
CREATE TABLE `acquisitions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `supplier_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `status` enum('Запланировано','В пути','Доставлено','Отменено') DEFAULT 'Запланировано',
  `expected_date` date DEFAULT NULL,
  `actual_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_acq_sup` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_acq_wh` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `acquisition_items`;
CREATE TABLE `acquisition_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `acquisition_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `quantity` int NOT NULL,
  `purchase_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_acqi_acq` FOREIGN KEY (`acquisition_id`) REFERENCES `acquisitions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_acqi_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `inventory_transactions`;
CREATE TABLE `inventory_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `variant_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `transaction_type` enum('Приход', 'Расход', 'Списание', 'Инвентаризация') NOT NULL,
  `quantity_change` int NOT NULL,
  `transaction_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_itrans_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_itrans_wh` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================================================
-- БЛОК 6: КОРЗИНА И ЗАКАЗЫ (8 таблиц)
-- ==============================================================================

DROP TABLE IF EXISTS `shopping_carts`;
CREATE TABLE `shopping_carts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE `cart_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cart_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cart_var` (`cart_id`, `variant_id`),
  CONSTRAINT `fk_ci_cart` FOREIGN KEY (`cart_id`) REFERENCES `shopping_carts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ci_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `shipping_methods`;
CREATE TABLE `shipping_methods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `base_cost` decimal(10,2) NOT NULL,
  `estimated_days` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `order_statuses`;
CREATE TABLE `order_statuses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `status_id` int NOT NULL,
  `shipping_method_id` int DEFAULT NULL,
  `shipping_address_id` int DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT '0.00',
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ord_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_ord_status` FOREIGN KEY (`status_id`) REFERENCES `order_statuses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_ord_smethod` FOREIGN KEY (`shipping_method_id`) REFERENCES `shipping_methods` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ord_saddr` FOREIGN KEY (`shipping_address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_oi_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_oi_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `order_status_history`;
CREATE TABLE `order_status_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `status_id` int NOT NULL,
  `changed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `comment` text,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_osh_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_osh_status` FOREIGN KEY (`status_id`) REFERENCES `order_statuses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `order_tracking`;
CREATE TABLE `order_tracking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `tracking_number` varchar(100) NOT NULL,
  `courier_name` varchar(100) DEFAULT NULL,
  `shipped_date` datetime DEFAULT NULL,
  `delivered_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_otrack_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================================================
-- БЛОК 7: ОПЛАТЫ, СЧЕТА И СКИДКИ (5 таблиц)
-- ==============================================================================

DROP TABLE IF EXISTS `payment_methods`;
CREATE TABLE `payment_methods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `is_paid` tinyint(1) DEFAULT '0',
  `issued_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  CONSTRAINT `fk_invc_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_id` int NOT NULL,
  `payment_method_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `paid_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Успешно','Ошибка','В обработке') DEFAULT 'Успешно',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_pay_invc` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pay_method` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `promocodes`;
CREATE TABLE `promocodes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `discount_percent` decimal(5,2) NOT NULL,
  `valid_from` datetime NOT NULL,
  `valid_until` datetime NOT NULL,
  `max_uses` int DEFAULT NULL,
  `current_uses` int DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `order_promocodes`;
CREATE TABLE `order_promocodes` (
  `order_id` int NOT NULL,
  `promocode_id` int NOT NULL,
  PRIMARY KEY (`order_id`, `promocode_id`),
  CONSTRAINT `fk_opromo_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_opromo_promo` FOREIGN KEY (`promocode_id`) REFERENCES `promocodes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================================================
-- БЛОК 8: МАСТЕРСКАЯ, АРЕНДА И ОТЗЫВЫ (6 таблиц)
-- ==============================================================================

DROP TABLE IF EXISTS `repair_services`;
CREATE TABLE `repair_services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `base_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `service_tickets`;
CREATE TABLE `service_tickets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `instrument_info` varchar(255) NOT NULL,
  `issue_description` text NOT NULL,
  `status` enum('Создана','В диагностике','В ремонте','Готово','Выдано клиенту') DEFAULT 'Создана',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_sticket_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sticket_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `service_ticket_items`;
CREATE TABLE `service_ticket_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ticket_id` int NOT NULL,
  `service_id` int NOT NULL,
  `price_charged` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_sti_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `service_tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sti_service` FOREIGN KEY (`service_id`) REFERENCES `repair_services` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `rentals`;
CREATE TABLE `rentals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `variant_id` int NOT NULL,
  `rental_start` date NOT NULL,
  `rental_end` date NOT NULL,
  `daily_rate` decimal(10,2) NOT NULL,
  `status` enum('Забронировано','В аренде','Возвращено','Просрочено') DEFAULT 'Забронировано',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_rent_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rent_var` FOREIGN KEY (`variant_id`) REFERENCES `instrument_variants` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `instrument_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `comment` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_rev_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rev_inst` FOREIGN KEY (`instrument_id`) REFERENCES `instruments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
USE `musicstore_pro`;

DELIMITER //

-- ==============================================================================
-- 1. ТРИГГЕРЫ ДЛЯ ОТЗЫВОВ И РЕЙТИНГОВ
-- Автоматический пересчет среднего рейтинга инструмента при добавлении отзыва
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_reviews_after_insert`//
CREATE TRIGGER `trg_reviews_after_insert` AFTER INSERT ON `reviews`
FOR EACH ROW
BEGIN
    DECLARE v_avg_rating DECIMAL(3,2);

    SELECT IFNULL(AVG(rating), 0) INTO v_avg_rating
    FROM `reviews`
    WHERE `instrument_id` = NEW.instrument_id;

    UPDATE `instruments`
    SET `average_rating` = v_avg_rating
    WHERE `id` = NEW.instrument_id;
END//

DROP TRIGGER IF EXISTS `trg_reviews_after_delete`//
CREATE TRIGGER `trg_reviews_after_delete` AFTER DELETE ON `reviews`
FOR EACH ROW
BEGIN
    DECLARE v_avg_rating DECIMAL(3,2);

    SELECT IFNULL(AVG(rating), 0) INTO v_avg_rating
    FROM `reviews`
    WHERE `instrument_id` = OLD.instrument_id;

    UPDATE `instruments`
    SET `average_rating` = v_avg_rating
    WHERE `id` = OLD.instrument_id;
END//

-- ==============================================================================
-- 2. ТРИГГЕРЫ СКЛАДА И ИНВЕНТАРИЗАЦИИ
-- Защита от отрицательных остатков и авто-обновление склада по транзакциям
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_inventory_before_update`//
CREATE TRIGGER `trg_inventory_before_update` BEFORE UPDATE ON `inventory`
FOR EACH ROW
BEGIN
    IF NEW.quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Критическая ошибка: остаток на складе не может быть меньше нуля!';
    END IF;
END//

DROP TRIGGER IF EXISTS `trg_inv_transactions_after_insert`//
CREATE TRIGGER `trg_inv_transactions_after_insert` AFTER INSERT ON `inventory_transactions`
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'Приход' THEN
        INSERT INTO `inventory` (`warehouse_id`, `variant_id`, `quantity`)
        VALUES (NEW.warehouse_id, NEW.variant_id, NEW.quantity_change)
        ON DUPLICATE KEY UPDATE `quantity` = `quantity` + NEW.quantity_change;
    ELSEIF NEW.transaction_type IN ('Расход', 'Списание') THEN
        UPDATE `inventory`
        SET `quantity` = `quantity` - NEW.quantity_change
        WHERE `warehouse_id` = NEW.warehouse_id AND `variant_id` = NEW.variant_id;
    END IF;
END//

-- ==============================================================================
-- 3. ТРИГГЕРЫ ДЛЯ ЗАКАЗОВ
-- Автоматическое ведение истории изменения статусов заказов
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_orders_after_insert`//
CREATE TRIGGER `trg_orders_after_insert` AFTER INSERT ON `orders`
FOR EACH ROW
BEGIN
    INSERT INTO `order_status_history` (`order_id`, `status_id`, `comment`)
    VALUES (NEW.id, NEW.status_id, 'Заказ успешно создан');
END//

DROP TRIGGER IF EXISTS `trg_orders_after_update`//
CREATE TRIGGER `trg_orders_after_update` AFTER UPDATE ON `orders`
FOR EACH ROW
BEGIN
    -- Если статус заказа изменился, фиксируем это в истории
    IF NEW.status_id != OLD.status_id THEN
        INSERT INTO `order_status_history` (`order_id`, `status_id`, `comment`)
        VALUES (NEW.id, NEW.status_id, 'Статус обновлен системой или менеджером');
    END IF;
END//

-- ==============================================================================
-- 4. ТРИГГЕРЫ ФИНАНСОВ И ОПЛАТЫ
-- Авто-закрытие инвойсов и смена статуса заказа при успешной оплате
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_payments_after_insert`//
CREATE TRIGGER `trg_payments_after_insert` AFTER INSERT ON `payments`
FOR EACH ROW
BEGIN
    DECLARE v_invoice_total DECIMAL(10,2);
    DECLARE v_total_paid DECIMAL(10,2);
    DECLARE v_order_id INT;
    DECLARE v_paid_status_id INT;

    -- Получаем данные инвойса
    SELECT `total_amount`, `order_id` INTO v_invoice_total, v_order_id
    FROM `invoices` WHERE `id` = NEW.invoice_id;

    -- Считаем все успешные платежи по этому инвойсу
    SELECT IFNULL(SUM(`amount`), 0) INTO v_total_paid
    FROM `payments`
    WHERE `invoice_id` = NEW.invoice_id AND `status` = 'Успешно';

    -- Если оплачено полностью или с избытком
    IF v_total_paid >= v_invoice_total THEN
        -- Закрываем инвойс
        UPDATE `invoices` SET `is_paid` = 1 WHERE `id` = NEW.invoice_id;

        -- Получаем ID статуса "Оплачен" и обновляем заказ
        SELECT `id` INTO v_paid_status_id FROM `order_statuses` WHERE `name` = 'Оплачен' LIMIT 1;
        IF v_paid_status_id IS NOT NULL THEN
            UPDATE `orders` SET `status_id` = v_paid_status_id WHERE `id` = v_order_id;
        END IF;
    END IF;
END//

-- ==============================================================================
-- 5. ТРИГГЕРЫ ПРОМОКОДОВ
-- Проверка лимитов и срока действия промокода перед применением к заказу
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_order_promo_before_insert`//
CREATE TRIGGER `trg_order_promo_before_insert` BEFORE INSERT ON `order_promocodes`
FOR EACH ROW
BEGIN
    DECLARE v_max_uses INT;
    DECLARE v_current_uses INT;
    DECLARE v_valid_until DATETIME;
    DECLARE v_valid_from DATETIME;

    SELECT `max_uses`, `current_uses`, `valid_until`, `valid_from`
    INTO v_max_uses, v_current_uses, v_valid_until, v_valid_from
    FROM `promocodes` WHERE `id` = NEW.promocode_id;

    IF NOW() < v_valid_from OR NOW() > v_valid_until THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Срок действия промокода истек или еще не начался.';
    END IF;

    IF v_max_uses IS NOT NULL AND v_current_uses >= v_max_uses THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Лимит использований данного промокода исчерпан.';
    END IF;

    -- Увеличиваем счетчик использований
    UPDATE `promocodes` SET `current_uses` = `current_uses` + 1 WHERE `id` = NEW.promocode_id;
END//

-- ==============================================================================
-- 6. ТРИГГЕРЫ ДЛЯ УСЛУГ И РЕМОНТА
-- Автоматическое проставление даты завершения ремонта гитар/синтезаторов
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_service_tickets_before_update`//
CREATE TRIGGER `trg_service_tickets_before_update` BEFORE UPDATE ON `service_tickets`
FOR EACH ROW
BEGIN
    -- Если статус меняется на "Готово" или "Выдано", и дата завершения еще пустая
    IF NEW.status IN ('Готово', 'Выдано клиенту') AND OLD.status NOT IN ('Готово', 'Выдано клиенту') THEN
        IF NEW.completed_at IS NULL THEN
            SET NEW.completed_at = CURRENT_TIMESTAMP;
        END IF;
    END IF;
END//

DELIMITER ;

USE `musicstore_pro`;

DELIMITER //

-- ==============================================================================
-- 7. ТРИГГЕРЫ ДЛЯ АРЕНДЫ (Rentals)
-- Автоматическое списание инструмента со склада при выдаче в аренду
-- и возврат на склад после окончания аренды.
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_rentals_status_update`//
CREATE TRIGGER `trg_rentals_status_update` AFTER UPDATE ON `rentals`
FOR EACH ROW
BEGIN
    DECLARE v_warehouse_id INT;

    -- Находим основной склад (для простоты берем первый активный склад)
    SELECT id INTO v_warehouse_id FROM `warehouses` WHERE `is_active` = 1 LIMIT 1;

    -- Если статус изменился на "В аренде" (Выдали клиенту) -> Списываем 1 шт.
    IF NEW.status = 'В аренде' AND OLD.status != 'В аренде' THEN
        INSERT INTO `inventory_transactions` (`variant_id`, `warehouse_id`, `transaction_type`, `quantity_change`, `reason`)
        VALUES (NEW.variant_id, v_warehouse_id, 'Расход', 1, CONCAT('Выдача в аренду #', NEW.id));
    END IF;

    -- Если статус изменился на "Возвращено" -> Возвращаем 1 шт. на склад
    IF NEW.status = 'Возвращено' AND OLD.status != 'Возвращено' THEN
        INSERT INTO `inventory_transactions` (`variant_id`, `warehouse_id`, `transaction_type`, `quantity_change`, `reason`)
        VALUES (NEW.variant_id, v_warehouse_id, 'Приход', 1, CONCAT('Возврат из аренды #', NEW.id));
    END IF;
END//

-- ==============================================================================
-- 8. ТРИГГЕР ЗАЩИТЫ ЗАКАЗОВ
-- Запрещает удалять товары из заказа, если он уже оплачен, отправлен или завершен.
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_order_items_before_delete`//
CREATE TRIGGER `trg_order_items_before_delete` BEFORE DELETE ON `order_items`
FOR EACH ROW
BEGIN
    DECLARE v_status_name VARCHAR(50);

    -- Узнаем текущий статус заказа, из которого пытаются удалить товар
    SELECT os.name INTO v_status_name
    FROM `orders` o
    JOIN `order_statuses` os ON o.status_id = os.id
    WHERE o.id = OLD.order_id;

    -- Блокируем удаление для всех статусов, кроме "Новый"
    IF v_status_name NOT IN ('Новый') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: Нельзя удалять товары из оплаченного или отправленного заказа!';
    END IF;
END//

-- ==============================================================================
-- 9. ТРИГГЕР АКТУАЛИЗАЦИИ КОРЗИНЫ
-- При добавлении, изменении или удалении товара в корзине, обновляем время
-- `updated_at` самой корзины (чтобы фоновый планировщик не удалил ее как брошенную)
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_cart_items_after_insert`//
CREATE TRIGGER `trg_cart_items_after_insert` AFTER INSERT ON `cart_items`
FOR EACH ROW
BEGIN
    UPDATE `shopping_carts` SET `updated_at` = CURRENT_TIMESTAMP WHERE `id` = NEW.cart_id;
END//

DROP TRIGGER IF EXISTS `trg_cart_items_after_update`//
CREATE TRIGGER `trg_cart_items_after_update` AFTER UPDATE ON `cart_items`
FOR EACH ROW
BEGIN
    UPDATE `shopping_carts` SET `updated_at` = CURRENT_TIMESTAMP WHERE `id` = NEW.cart_id;
END//

DROP TRIGGER IF EXISTS `trg_cart_items_after_delete`//
CREATE TRIGGER `trg_cart_items_after_delete` AFTER DELETE ON `cart_items`
FOR EACH ROW
BEGIN
    UPDATE `shopping_carts` SET `updated_at` = CURRENT_TIMESTAMP WHERE `id` = OLD.cart_id;
END//

-- ==============================================================================
-- 10. ТРИГГЕРЫ HR-МОДУЛЯ (УВОЛЬНЕНИЕ СОТРУДНИКА)
-- Если сотрудника увольняют, автоматически проставляем дату увольнения и
-- закрываем его активные должности.
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_employees_before_update`//
CREATE TRIGGER `trg_employees_before_update` BEFORE UPDATE ON `employees`
FOR EACH ROW
BEGIN
    -- Если статус меняется на "Уволен"
    IF NEW.status = 'Уволен' AND OLD.status != 'Уволен' THEN
        -- Ставим дату увольнения сегодняшним днем (если она не была указана вручную)
        IF NEW.termination_date IS NULL THEN
            SET NEW.termination_date = CURDATE();
        END IF;
    END IF;
END//

DROP TRIGGER IF EXISTS `trg_employees_after_update`//
CREATE TRIGGER `trg_employees_after_update` AFTER UPDATE ON `employees`
FOR EACH ROW
BEGIN
    -- Если сотрудника уволили, автоматически завершаем его работу на всех должностях
    IF NEW.status = 'Уволен' AND OLD.status != 'Уволен' THEN
        UPDATE `employee_positions`
        SET `end_date` = CURDATE()
        WHERE `employee_id` = NEW.id AND `end_date` IS NULL;
    END IF;
END//

-- ==============================================================================
-- 11. ТРИГГЕР СОЗДАНИЯ ПОЛЬЗОВАТЕЛЯ (АВТО-ПРОФИЛЬ)
-- При регистрации нового пользователя в таблице `users` автоматически создаем
-- пустую связанную запись в `user_info` и новую `shopping_carts` (Корзину)
-- ==============================================================================
DROP TRIGGER IF EXISTS `trg_users_after_insert`//
CREATE TRIGGER `trg_users_after_insert` AFTER INSERT ON `users`
FOR EACH ROW
BEGIN
    -- Создаем пустой профиль (Имя и Фамилию потом заполнит сам клиент)
    INSERT INTO `user_info` (`user_id`, `first_name`, `last_name`)
    VALUES (NEW.id, 'Новый', 'Пользователь');

    -- Сразу создаем ему персональную корзину
    INSERT INTO `shopping_carts` (`user_id`)
    VALUES (NEW.id);
END//

DELIMITER ;

USE `musicstore_pro`;

-- ==============================================================================
-- БЛОК 9: ПРЕДСТАВЛЕНИЯ (VIEWS)
-- Удобные "виртуальные таблицы" для аналитики, витрины и дашбордов
-- ==============================================================================

-- 1. Витрина товаров (Полная информация об инструментах со стоимостью и фото)
DROP VIEW IF EXISTS `v_catalog_full`;
CREATE VIEW `v_catalog_full` AS
SELECT
    i.id AS instrument_id,
    v.id AS variant_id,
    b.name AS brand,
    c.name AS category,
    i.model_name,
    v.sku,
    v.color,
    (i.base_price + v.price_modifier) AS final_price,
    i.average_rating,
    img.image_url AS main_image
FROM `instruments` i
JOIN `brands` b ON i.brand_id = b.id
JOIN `subcategories` subcat ON i.subcategory_id = subcat.id
JOIN `categories` c ON subcat.category_id = c.id
JOIN `instrument_variants` v ON i.id = v.instrument_id
LEFT JOIN `instrument_images` img ON v.id = img.variant_id AND img.is_main = 1
WHERE v.is_active = 1;

-- 2. Сводка по складам (Актуальные остатки по зонам и товарам)
DROP VIEW IF EXISTS `v_inventory_status`;
CREATE VIEW `v_inventory_status` AS
SELECT
    w.name AS warehouse_name,
    z.zone_code,
    b.name AS brand,
    i.model_name,
    v.sku,
    v.color,
    inv.quantity
FROM `inventory` inv
JOIN `warehouses` w ON inv.warehouse_id = w.id
LEFT JOIN `warehouse_zones` z ON inv.zone_id = z.id
JOIN `instrument_variants` v ON inv.variant_id = v.id
JOIN `instruments` i ON v.instrument_id = i.id
JOIN `brands` b ON i.brand_id = b.id
WHERE inv.quantity > 0;

-- 3. Ежемесячная статистика продаж (Выручка и количество заказов)
DROP VIEW IF EXISTS `v_monthly_sales`;
CREATE VIEW `v_monthly_sales` AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.id) AS total_orders,
    SUM(o.total_amount) AS total_revenue
FROM `orders` o
JOIN `order_statuses` os ON o.status_id = os.id
WHERE os.name NOT IN ('Отменен')
GROUP BY sales_month
ORDER BY sales_month DESC;

-- 4. Активность клиентов (Сумма покупок, количество заказов и ремонтов)
DROP VIEW IF EXISTS `v_user_activity`;
CREATE VIEW `v_user_activity` AS
SELECT
    u.id AS user_id,
    u.email,
    ui.first_name,
    ui.last_name,
    COUNT(DISTINCT o.id) AS successful_orders,
    IFNULL(SUM(o.total_amount), 0) AS lifetime_value_lTV,
    COUNT(DISTINCT st.id) AS total_repair_tickets
FROM `users` u
LEFT JOIN `user_info` ui ON u.id = ui.user_id
LEFT JOIN `orders` o ON u.id = o.user_id AND o.status_id = (SELECT id FROM `order_statuses` WHERE name='Завершен')
LEFT JOIN `service_tickets` st ON u.id = st.user_id
GROUP BY u.id, u.email, ui.first_name, ui.last_name
ORDER BY lifetime_value_lTV DESC;

-- 5. Активные аренды (Контроль просрочек)
DROP VIEW IF EXISTS `v_active_rentals`;
CREATE VIEW `v_active_rentals` AS
SELECT
    r.id AS rental_id,
    u.email AS client_email,
    ui.phone AS client_phone,
    i.model_name,
    v.sku,
    r.rental_start,
    r.rental_end,
    r.status,
    DATEDIFF(r.rental_end, CURDATE()) AS days_left
FROM `rentals` r
JOIN `users` u ON r.user_id = u.id
JOIN `user_info` ui ON u.id = ui.user_id
JOIN `instrument_variants` v ON r.variant_id = v.id
JOIN `instruments` i ON v.instrument_id = i.id
WHERE r.status IN ('Забронировано', 'В аренде', 'Просрочено');


-- ==============================================================================
-- БЛОК 10: ХРАНИМЫЕ ПРОЦЕДУРЫ (STORED PROCEDURES)
-- Инкапсулированная сложная бизнес-логика транзакций
-- ==============================================================================

DELIMITER //

-- 1. ОФОРМЛЕНИЕ ЗАКАЗА (Checkout)
-- Забирает товары из корзины, формирует заказ, генерирует счет и очищает корзину
DROP PROCEDURE IF EXISTS `sp_checkout_cart`//
CREATE PROCEDURE `sp_checkout_cart`(
    IN p_user_id INT,
    IN p_shipping_method_id INT,
    IN p_shipping_address_id INT
)
BEGIN
    DECLARE v_cart_id INT;
    DECLARE v_order_id INT;
    DECLARE v_shipping_cost DECIMAL(10,2) DEFAULT 0;
    DECLARE v_items_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_status_new_id INT;

    -- Обработчик ошибок для отката транзакции при сбое
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Ищем корзину пользователя
    SELECT id INTO v_cart_id FROM `shopping_carts` WHERE user_id = p_user_id LIMIT 1;
    IF v_cart_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Корзина пользователя не найдена.';
    END IF;

    -- Проверяем, есть ли товары в корзине
    IF NOT EXISTS (SELECT 1 FROM `cart_items` WHERE cart_id = v_cart_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Корзина пуста.';
    END IF;

    -- Получаем стоимость доставки
    IF p_shipping_method_id IS NOT NULL THEN
        SELECT base_cost INTO v_shipping_cost FROM `shipping_methods` WHERE id = p_shipping_method_id;
    END IF;

    -- Ищем ID статуса "Новый"
    SELECT id INTO v_status_new_id FROM `order_statuses` WHERE name = 'Новый' LIMIT 1;
    IF v_status_new_id IS NULL THEN SET v_status_new_id = 1; END IF;

    -- Создаем запись о заказе
    INSERT INTO `orders` (`user_id`, `status_id`, `shipping_method_id`, `shipping_address_id`)
    VALUES (p_user_id, v_status_new_id, p_shipping_method_id, p_shipping_address_id);
    SET v_order_id = LAST_INSERT_ID();

    -- Переносим товары из корзины в order_items с расчетом актуальной цены
    INSERT INTO `order_items` (`order_id`, `variant_id`, `quantity`, `unit_price`)
    SELECT
        v_order_id,
        ci.variant_id,
        ci.quantity,
        (i.base_price + iv.price_modifier)
    FROM `cart_items` ci
    JOIN `instrument_variants` iv ON ci.variant_id = iv.id
    JOIN `instruments` i ON iv.instrument_id = i.id
    WHERE ci.cart_id = v_cart_id;

    -- Подсчитываем общую сумму товаров
    SELECT IFNULL(SUM(quantity * unit_price), 0) INTO v_items_total
    FROM `order_items`
    WHERE order_id = v_order_id;

    -- Обновляем итоговую сумму заказа (товары + доставка)
    UPDATE `orders`
    SET `total_amount` = v_items_total + v_shipping_cost
    WHERE id = v_order_id;

    -- Формируем счет на оплату (Invoice)
    INSERT INTO `invoices` (`order_id`, `invoice_number`, `total_amount`)
    VALUES (v_order_id, CONCAT('INV-', YEAR(CURDATE()), '-', LPAD(v_order_id, 6, '0')), v_items_total + v_shipping_cost);

    -- Очищаем корзину
    DELETE FROM `cart_items` WHERE cart_id = v_cart_id;

    COMMIT;

    SELECT v_order_id AS new_order_id, (v_items_total + v_shipping_cost) AS total_to_pay;
END//


-- 2. ПРИЕМКА ТОВАРА НА СКЛАД (Process Delivery)
-- Меняет статус закупки и автоматически создает транзакции склада (что, через триггер, обновит inventory)
DROP PROCEDURE IF EXISTS `sp_process_acquisition`//
CREATE PROCEDURE `sp_process_acquisition`(
    IN p_acquisition_id INT
)
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE v_warehouse_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT `status`, `warehouse_id` INTO v_status, v_warehouse_id
    FROM `acquisitions`
    WHERE id = p_acquisition_id;

    IF v_status = 'Доставлено' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка: Данная поставка уже была принята.';
    END IF;

    -- Изменяем статус закупки
    UPDATE `acquisitions`
    SET `status` = 'Доставлено', `actual_date` = CURRENT_TIMESTAMP
    WHERE id = p_acquisition_id;

    -- Создаем складские транзакции (Приход) для каждой позиции в закупке.
    -- Наш триггер 'trg_inv_transactions_after_insert' автоматически закинет это в таблицу inventory!
    INSERT INTO `inventory_transactions` (`variant_id`, `warehouse_id`, `transaction_type`, `quantity_change`, `reason`)
    SELECT
        variant_id,
        v_warehouse_id,
        'Приход',
        quantity,
        CONCAT('Поставка №', p_acquisition_id)
    FROM `acquisition_items`
    WHERE acquisition_id = p_acquisition_id;

    COMMIT;
END//

DELIMITER ;
USE `musicstore_pro`;

-- ==============================================================================
-- 7. ТРЕВОЖНЫЙ ОСТАТОК (Для отдела закупок)
-- Показывает товары, которых осталось критически мало на всех складах суммарно
-- ==============================================================================
DROP VIEW IF EXISTS `v_low_stock_alerts`;
CREATE VIEW `v_low_stock_alerts` AS
SELECT
    b.name AS brand,
    i.model_name,
    v.sku,
    v.color,
    IFNULL(SUM(inv.quantity), 0) AS total_quantity
FROM `instrument_variants` v
JOIN `instruments` i ON v.instrument_id = i.id
JOIN `brands` b ON i.brand_id = b.id
LEFT JOIN `inventory` inv ON v.id = inv.variant_id
WHERE v.is_active = 1
GROUP BY b.name, i.model_name, v.sku, v.color
HAVING total_quantity <= 3 -- Порог тревоги: 3 штуки или меньше
ORDER BY total_quantity ASC;


-- ==============================================================================
-- 8. ЗАКАЗЫ НА СБОРКУ И ДОСТАВКУ (Для логистов и кладовщиков)
-- Выводит оплаченные или новые заказы, которые нужно собрать и отправить
-- ==============================================================================
DROP VIEW IF EXISTS `v_orders_to_fulfill`;
CREATE VIEW `v_orders_to_fulfill` AS
SELECT
    o.id AS order_id,
    os.name AS order_status,
    o.order_date,
    u.email AS client_email,
    sm.name AS shipping_method,
    CONCAT(addr.postal_code, ', ', c.name, ', ', addr.street, ' ', addr.building) AS full_address,
    o.total_amount
FROM `orders` o
JOIN `order_statuses` os ON o.status_id = os.id
JOIN `users` u ON o.user_id = u.id
LEFT JOIN `shipping_methods` sm ON o.shipping_method_id = sm.id
LEFT JOIN `addresses` addr ON o.shipping_address_id = addr.id
LEFT JOIN `cities` c ON addr.city_id = c.id
WHERE os.name IN ('Новый', 'Оплачен')
ORDER BY o.order_date ASC;


-- ==============================================================================
-- 9. ЭФФЕКТИВНОСТЬ ПРОМОКОДОВ (Для маркетологов)
-- Оценивает, сколько денег принес каждый промокод
-- ==============================================================================
DROP VIEW IF EXISTS `v_promocode_performance`;
CREATE VIEW `v_promocode_performance` AS
SELECT
    p.code,
    p.discount_percent,
    p.current_uses,
    p.max_uses,
    IFNULL(SUM(o.total_amount), 0) AS revenue_generated,
    p.valid_until,
    IF(p.valid_until < NOW(), 'Истек', 'Активен') AS promo_status
FROM `promocodes` p
LEFT JOIN `order_promocodes` op ON p.id = op.promocode_id
LEFT JOIN `orders` o ON op.order_id = o.id AND o.status_id != (SELECT id FROM order_statuses WHERE name='Отменен')
GROUP BY p.id, p.code, p.discount_percent, p.current_uses, p.max_uses, p.valid_until;


-- ==============================================================================
-- 10. АНАЛИТИКА ПО БРЕНДАМ (Для коммерческого директора)
-- Кто приносит больше всего денег в магазине (Fender, Gibson, Yamaha и т.д.)
-- ==============================================================================
DROP VIEW IF EXISTS `v_brand_performance`;
CREATE VIEW `v_brand_performance` AS
SELECT
    b.name AS brand_name,
    COUNT(DISTINCT i.id) AS unique_models,
    IFNULL(SUM(oi.quantity), 0) AS total_items_sold,
    IFNULL(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM `brands` b
LEFT JOIN `instruments` i ON b.id = i.brand_id
LEFT JOIN `instrument_variants` iv ON i.id = iv.instrument_id
LEFT JOIN `order_items` oi ON iv.id = oi.variant_id
LEFT JOIN `orders` o ON oi.order_id = o.id AND o.status_id != (SELECT id FROM order_statuses WHERE name='Отменен')
GROUP BY b.id, b.name
ORDER BY total_revenue DESC;


-- ==============================================================================
-- 11. КАТАЛОГ СОТРУДНИКОВ (Для HR-отдела)
-- Полная сводка по персоналу, их должностям, отделам и зарплатам
-- ==============================================================================
DROP VIEW IF EXISTS `v_employee_directory`;
CREATE VIEW `v_employee_directory` AS
SELECT
    e.id AS employee_id,
    ui.first_name,
    ui.last_name,
    u.email,
    d.name AS department,
    p.title AS position,
    p.base_salary,
    e.hire_date,
    e.status
FROM `employees` e
JOIN `users` u ON e.user_id = u.id
JOIN `user_info` ui ON u.id = ui.user_id
JOIN `employee_positions` ep ON e.id = ep.employee_id AND (ep.end_date IS NULL OR ep.end_date >= CURDATE())
JOIN `positions` p ON ep.position_id = p.id
JOIN `departments` d ON p.department_id = d.id;