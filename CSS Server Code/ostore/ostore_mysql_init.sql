-- 初始化
DROP TABLE IF EXISTS `ostore_accounts`, `ostore_accounts_products`, `ostore_categories`, `ostore_products`, `ostore_products_categories`, `ostore_products_type`;

-- 账户表
CREATE TABLE IF NOT EXISTS `ostore_accounts` (
  `id` int(11) NOT NULL,
  `point` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
);

-- 分类表
CREATE TABLE IF NOT EXISTS `ostore_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `detail` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
);

-- 产品表
CREATE TABLE IF NOT EXISTS `ostore_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `detail` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
);

-- 产品分类表
CREATE TABLE IF NOT EXISTS `ostore_products_categories` (
  `product_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`product_id`)
);

-- 产品类型表
CREATE TABLE IF NOT EXISTS `ostore_products_type` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`product_id` int(11) NOT NULL,
	`point` int(11) NOT NULL DEFAULT '0',
	`type` enum('amount','validity','forever') NOT NULL DEFAULT 'forever',
	`amount` int(11) NOT NULL DEFAULT '0',
	`second` int(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`)
);

-- 账户产品表
CREATE TABLE IF NOT EXISTS `ostore_accounts_products` (
  `account_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `type` enum('amount','validity','forever') NOT NULL,
  `amount` int(11) NOT NULL DEFAULT '0',
  `validity` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`account_id`,`product_id`)
);