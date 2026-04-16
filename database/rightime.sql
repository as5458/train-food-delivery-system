-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: right_time
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cancelled_orders`
--

DROP TABLE IF EXISTS `cancelled_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cancelled_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancelled_by` int DEFAULT NULL,
  `cancelled_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `fk_cancel_user` (`cancelled_by`),
  CONSTRAINT `fk_cancel_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cancel_user` FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cancelled_orders`
--

LOCK TABLES `cancelled_orders` WRITE;
/*!40000 ALTER TABLE `cancelled_orders` DISABLE KEYS */;
INSERT INTO `cancelled_orders` VALUES (1,9,'Train left early',8,'2026-03-30 08:43:45'),(2,10,'Customer request',10,'2026-03-30 08:43:45'),(33,1,'Train delayed',2,'2026-04-11 00:07:45'),(34,4,'Customer request',3,'2026-04-11 00:07:45'),(35,7,'Late delivery',4,'2026-04-11 00:07:45'),(36,268,'Changed plan',2,'2026-04-11 00:07:45'),(37,269,'Out of stock',3,'2026-04-11 00:07:45'),(38,270,'Restaurant closed',2,'2026-04-11 00:07:45'),(39,272,'Wrong order',3,'2026-04-11 00:07:45'),(40,274,'Duplicate order',4,'2026-04-11 00:07:45'),(41,280,'Payment failed',2,'2026-04-11 00:07:45'),(42,285,'Train cancelled',3,'2026-04-11 00:07:45');
/*!40000 ALTER TABLE `cancelled_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deliveries`
--

DROP TABLE IF EXISTS `deliveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deliveries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `partner_id` int DEFAULT NULL,
  `order_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ASSIGNED','DISPATCHED','DELIVERED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delivery_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `partner_id` (`partner_id`),
  CONSTRAINT `deliveries_ibfk_1` FOREIGN KEY (`partner_id`) REFERENCES `delivery_partners` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deliveries`
--

LOCK TABLES `deliveries` WRITE;
/*!40000 ALTER TABLE `deliveries` DISABLE KEYS */;
INSERT INTO `deliveries` VALUES (1,1,'ORD101','DELIVERED',NULL),(2,1,'ORD102','DELIVERED',NULL),(3,2,'ORD103','DISPATCHED',NULL),(4,3,'ORD104','ASSIGNED',NULL);
/*!40000 ALTER TABLE `deliveries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_assignments`
--

DROP TABLE IF EXISTS `delivery_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `staff_id` int NOT NULL,
  `assigned_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivered_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_staff` (`staff_id`),
  CONSTRAINT `fk_assign_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assign_staff` FOREIGN KEY (`staff_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_assignments`
--

LOCK TABLES `delivery_assignments` WRITE;
/*!40000 ALTER TABLE `delivery_assignments` DISABLE KEYS */;
INSERT INTO `delivery_assignments` VALUES (1,3,4,'2026-03-30 08:43:45',NULL),(2,6,5,'2026-03-30 08:43:45',NULL);
/*!40000 ALTER TABLE `delivery_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_partners`
--

DROP TABLE IF EXISTS `delivery_partners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_partners` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','BUSY','OFFLINE') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_partners`
--

LOCK TABLES `delivery_partners` WRITE;
/*!40000 ALTER TABLE `delivery_partners` DISABLE KEYS */;
INSERT INTO `delivery_partners` VALUES (1,'Ravi Kumar','9876543210','ACTIVE','2026-04-09 20:06:31'),(2,'Karan Singh','9123456780','BUSY','2026-04-09 20:06:31'),(3,'Amit Das','9988776655','ACTIVE','2026-04-09 20:06:31');
/*!40000 ALTER TABLE `delivery_partners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discount_campaigns`
--

DROP TABLE IF EXISTS `discount_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discount_campaigns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `coupon_code` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_type` enum('percentage','flat') COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `usage_limit` int NOT NULL DEFAULT '100',
  `used_count` int NOT NULL DEFAULT '0',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coupon_code` (`coupon_code`),
  KEY `idx_coupon` (`coupon_code`),
  KEY `fk_campaign_creator` (`created_by`),
  CONSTRAINT `fk_campaign_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discount_campaigns`
--

LOCK TABLES `discount_campaigns` WRITE;
/*!40000 ALTER TABLE `discount_campaigns` DISABLE KEYS */;
INSERT INTO `discount_campaigns` VALUES (1,'Weekend Express Deal',NULL,'WKND20','percentage',20.00,100,62,'2026-03-28','2026-03-30',1,1,'2026-03-30 08:43:45'),(2,'First Order Offer',NULL,'FIRST50','flat',50.00,50,18,'2026-03-01','2026-03-31',1,1,'2026-03-30 08:43:45'),(3,'Summer Specials',NULL,'SUMMER15','percentage',15.00,200,0,'2026-04-01','2026-04-30',1,1,'2026-03-30 08:43:45'),(4,'Loyalty Bonus',NULL,'LOYAL10','percentage',10.00,80,29,'2026-03-15','2026-04-15',1,1,'2026-03-30 08:43:45');
/*!40000 ALTER TABLE `discount_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_ref` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` int NOT NULL,
  `restaurant_id` int NOT NULL,
  `train_id` int NOT NULL,
  `coach` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `seat` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `drop_time` time DEFAULT NULL,
  `status` enum('pending','ready','assigned','dispatched','delivered','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `total_amount` decimal(10,2) DEFAULT '0.00',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_ref` (`order_ref`),
  KEY `idx_order_ref` (`order_ref`),
  KEY `idx_customer` (`customer_id`),
  KEY `idx_restaurant` (`restaurant_id`),
  KEY `idx_train` (`train_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_order_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_order_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_order_train` FOREIGN KEY (`train_id`) REFERENCES `trains` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=481 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'#ORD-8921',8,1,1,'S4','22','12:15:00','pending',350.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(2,'#ORD-8922',9,2,2,'B2','45','12:30:00','ready',420.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(3,'#ORD-8923',10,3,3,'A1','12','12:45:00','assigned',275.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(4,'#ORD-8924',11,4,4,'S1','05','13:05:00','pending',190.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(5,'#ORD-8925',12,5,5,'B3','30','13:15:00','ready',310.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(6,'#ORD-8926',13,2,1,'H1','04','11:50:00','dispatched',480.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(7,'#ORD-8927',14,4,6,'S3','18','13:35:00','pending',220.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(8,'#ORD-8928',15,3,7,'B4','33','13:50:00','ready',395.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(9,'#ORD-8915',8,1,1,'A2','10','11:45:00','cancelled',350.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(10,'#ORD-8910',10,4,3,'B1','22','10:30:00','cancelled',190.00,NULL,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(266,'ORD-866113',6,1,2,'A1','18','12:55:00','delivered',321.81,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(267,'ORD-260685',8,2,4,'H1','2','10:48:46','dispatched',201.26,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(268,'ORD-446247',6,3,5,'H1','21','13:14:08','pending',188.13,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(269,'ORD-572130',2,2,2,'S4','29','11:44:39','pending',598.51,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(270,'ORD-823456',2,2,1,'B2','5','10:20:47','ready',181.72,NULL,'2026-04-08 10:16:25','2026-04-15 13:40:51'),(271,'ORD-533516',7,4,3,'S4','22','11:53:48','assigned',478.03,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(272,'ORD-955760',7,2,3,'B2','38','12:21:06','pending',215.38,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(273,'ORD-236050',5,4,4,'H1','44','10:31:20','delivered',214.54,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(274,'ORD-471140',9,4,3,'H1','27','13:38:58','pending',107.48,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(275,'ORD-743485',8,3,1,'A1','15','10:44:50','delivered',498.80,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(276,'ORD-828561',8,2,5,'S4','15','13:50:48','delivered',400.98,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(277,'ORD-561724',4,2,3,'S4','34','11:47:46','delivered',593.14,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(278,'ORD-555380',1,4,3,'B2','34','14:46:16','dispatched',131.06,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(279,'ORD-633137',1,4,1,'H1','44','13:23:43','dispatched',538.51,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(280,'ORD-596476',7,3,5,'A1','3','13:14:21','pending',321.72,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(281,'ORD-634967',1,2,3,'B2','32','14:42:51','delivered',241.12,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(282,'ORD-889148',6,1,5,'B2','4','10:48:13','dispatched',412.84,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(283,'ORD-497308',5,4,3,'B2','20','13:56:54','dispatched',302.35,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(284,'ORD-624145',7,3,2,'H1','17','11:26:47','assigned',273.23,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(285,'ORD-981019',7,3,2,'B2','30','14:49:07','pending',264.83,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(286,'ORD-630973',5,2,1,'B2','24','12:19:48','delivered',189.57,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(287,'ORD-288372',6,2,1,'A1','7','12:35:32','ready',336.29,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(288,'ORD-381454',4,4,3,'B2','48','14:32:21','dispatched',515.64,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(289,'ORD-661228',1,2,4,'B2','35','12:01:57','delivered',373.58,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(290,'ORD-763841',1,1,2,'A1','28','12:37:32','delivered',272.76,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(291,'ORD-854764',9,5,3,'A1','1','13:37:44','assigned',487.27,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(292,'ORD-265783',7,3,4,'B2','29','13:30:27','dispatched',497.17,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(293,'ORD-800925',10,4,2,'B2','40','14:54:44','assigned',556.19,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(294,'ORD-543453',10,1,5,'B2','10','13:25:56','delivered',217.43,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(295,'ORD-355584',7,2,3,'H1','21','13:19:22','pending',313.33,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(296,'ORD-212737',10,3,4,'A1','21','13:19:23','pending',316.26,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(297,'ORD-312406',5,3,3,'A1','42','14:08:44','dispatched',466.95,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(298,'ORD-533739',2,3,1,'A1','13','13:52:24','pending',310.59,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(299,'ORD-127280',2,4,3,'S4','2','11:12:35','pending',483.54,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(300,'ORD-456853',4,4,1,'B2','42','14:33:08','pending',454.48,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(301,'ORD-348195',6,5,4,'H1','8','11:15:33','dispatched',206.97,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(302,'ORD-818382',10,2,3,'B2','33','10:34:47','dispatched',477.89,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(303,'ORD-384428',9,2,3,'A1','23','11:12:24','delivered',377.74,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(304,'ORD-443839',3,2,3,'B2','5','14:59:06','dispatched',361.66,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(305,'ORD-972755',4,4,4,'H1','25','14:10:38','dispatched',183.43,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(306,'ORD-686125',4,5,2,'S4','38','12:55:12','dispatched',467.07,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(307,'ORD-723053',8,3,3,'A1','3','14:15:44','pending',543.12,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(308,'ORD-249492',4,1,5,'H1','47','14:30:39','dispatched',521.25,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(309,'ORD-898872',2,2,5,'B2','19','13:27:36','ready',460.35,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(310,'ORD-518863',8,2,3,'S4','16','14:11:47','ready',457.26,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(311,'ORD-120004',7,5,1,'S4','42','11:08:51','dispatched',401.92,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(312,'ORD-466424',10,2,4,'A1','46','11:56:44','ready',536.44,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(313,'ORD-174309',2,4,5,'H1','2','13:52:15','dispatched',357.25,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(314,'ORD-827136',3,4,5,'B2','16','11:41:34','dispatched',464.40,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(315,'ORD-820045',9,4,4,'H1','31','10:24:24','assigned',406.90,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(316,'ORD-936881',6,1,5,'B2','45','12:10:47','assigned',148.89,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(317,'ORD-940423',6,5,4,'H1','39','14:19:11','pending',396.43,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(318,'ORD-539935',9,5,1,'S4','5','12:05:44','delivered',506.61,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(319,'ORD-711102',6,3,2,'H1','36','13:45:10','assigned',470.01,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(320,'ORD-374566',9,1,2,'H1','24','14:02:49','dispatched',491.37,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(321,'ORD-628528',10,1,4,'H1','21','12:09:14','delivered',296.68,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(322,'ORD-637024',6,4,3,'H1','28','12:20:50','dispatched',592.02,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(323,'ORD-524687',8,1,3,'H1','43','13:44:58','ready',498.12,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(324,'ORD-441364',9,1,4,'B2','35','11:46:23','dispatched',377.93,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(325,'ORD-432791',1,1,1,'A1','22','13:57:35','dispatched',150.96,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(326,'ORD-827760',8,3,5,'A1','16','14:29:06','assigned',194.24,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(327,'ORD-557152',9,5,1,'S4','29','10:58:51','ready',408.45,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(328,'ORD-959899',7,4,5,'H1','18','11:33:34','assigned',339.19,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(329,'ORD-353731',6,1,3,'B2','31','13:49:02','delivered',405.54,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(330,'ORD-765205',4,3,4,'S4','20','14:40:27','assigned',443.28,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(331,'ORD-667691',4,5,1,'S4','7','13:35:16','ready',582.27,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(332,'ORD-881382',9,5,3,'S4','5','12:05:08','delivered',542.36,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(333,'ORD-150042',5,1,1,'B2','5','12:53:33','dispatched',311.51,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(334,'ORD-847325',5,5,2,'H1','32','11:42:37','dispatched',570.38,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(335,'ORD-816048',1,4,2,'A1','12','13:12:56','assigned',383.40,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(336,'ORD-982477',9,3,5,'A1','12','12:37:02','delivered',558.46,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(337,'ORD-738946',9,2,3,'A1','43','14:31:18','delivered',209.55,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(338,'ORD-121477',8,3,2,'H1','42','11:56:48','assigned',101.40,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(339,'ORD-594260',7,3,2,'H1','26','10:30:48','delivered',337.00,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(340,'ORD-173589',10,2,4,'S4','25','11:14:34','dispatched',184.46,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(341,'ORD-975050',4,5,4,'B2','43','10:54:11','ready',215.56,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(342,'ORD-789074',6,3,4,'H1','45','12:22:58','dispatched',203.48,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(343,'ORD-678498',7,2,4,'H1','50','11:40:14','dispatched',369.70,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(344,'ORD-317365',5,4,1,'H1','15','10:44:24','delivered',511.56,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(345,'ORD-376299',9,3,3,'B2','50','10:16:09','ready',219.51,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(346,'ORD-151210',3,5,5,'A1','41','12:54:01','assigned',412.59,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(347,'ORD-691819',2,5,5,'S4','16','14:12:41','ready',580.06,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(348,'ORD-695433',6,5,5,'S4','41','14:37:06','ready',228.33,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(349,'ORD-606921',9,2,3,'B2','18','13:00:24','delivered',124.67,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(350,'ORD-572807',7,3,5,'B2','48','11:43:34','delivered',205.08,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(351,'ORD-897101',10,5,5,'H1','17','10:43:57','dispatched',303.31,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(352,'ORD-466541',9,1,5,'H1','35','14:56:01','delivered',257.30,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(353,'ORD-186900',5,1,4,'A1','2','13:06:38','delivered',145.42,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(354,'ORD-214174',2,3,2,'A1','24','14:50:21','assigned',249.25,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(355,'ORD-964540',3,3,5,'A1','29','13:03:50','ready',519.63,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(356,'ORD-487684',6,4,3,'A1','19','12:19:33','ready',511.36,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(357,'ORD-500653',1,1,1,'A1','49','13:52:06','delivered',389.30,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(358,'ORD-127140',3,2,5,'S4','26','12:35:04','pending',477.47,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(359,'ORD-722596',7,2,4,'B2','49','13:06:24','pending',163.98,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(360,'ORD-855244',1,4,4,'S4','10','12:06:26','assigned',341.67,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(361,'ORD-450994',7,1,2,'S4','3','11:51:23','dispatched',306.45,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(362,'ORD-553118',7,5,2,'S4','19','10:09:17','ready',128.24,NULL,'2026-04-08 13:16:25','2026-04-08 14:28:50'),(363,'ORD-815007',4,3,4,'H1','35','12:27:55','ready',339.09,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(364,'ORD-682857',6,1,2,'A1','13','13:17:57','assigned',499.60,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(365,'ORD-321276',3,3,4,'H1','21','12:08:33','delivered',207.22,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(366,'ORD-295891',10,2,1,'H1','20','10:36:26','assigned',497.42,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(367,'ORD-107960',1,1,1,'A1','42','13:02:27','assigned',492.18,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(368,'ORD-486376',1,1,2,'H1','9','14:35:15','pending',365.11,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(369,'ORD-834634',7,4,4,'S4','49','14:13:15','ready',164.88,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(370,'ORD-880904',4,2,3,'A1','43','12:33:55','pending',438.35,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(371,'ORD-315516',5,3,5,'S4','46','14:04:44','ready',256.30,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(372,'ORD-637527',5,3,2,'H1','3','14:48:05','dispatched',224.73,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(373,'ORD-187344',4,3,5,'S4','48','10:58:18','ready',176.53,NULL,'2026-04-08 12:16:25','2026-04-14 11:12:37'),(374,'ORD-242925',9,4,4,'S4','23','10:19:30','delivered',444.01,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(375,'ORD-538331',10,1,3,'H1','7','11:40:07','ready',244.86,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(376,'ORD-550775',5,5,1,'H1','26','11:28:41','delivered',480.30,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(377,'ORD-811344',10,1,1,'A1','19','11:43:11','dispatched',182.96,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(378,'ORD-151155',6,3,2,'S4','17','13:57:10','delivered',251.53,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(379,'ORD-678763',1,3,2,'S4','5','13:58:03','dispatched',220.23,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(380,'ORD-484322',1,5,4,'A1','8','10:40:19','ready',506.06,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(381,'ORD-298272',2,5,1,'S4','10','14:33:43','ready',235.82,NULL,'2026-04-08 12:16:25','2026-04-14 16:55:48'),(382,'ORD-954484',7,3,5,'S4','2','14:17:33','ready',390.82,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(383,'ORD-392001',10,5,4,'S4','31','14:03:48','ready',461.73,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(384,'ORD-488469',4,4,2,'A1','18','10:11:58','ready',472.69,NULL,'2026-04-08 13:16:25','2026-04-14 11:12:31'),(385,'ORD-822677',4,3,3,'A1','13','13:15:08','assigned',430.49,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(386,'ORD-734201',4,3,2,'A1','14','11:33:33','dispatched',498.88,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(387,'ORD-415343',6,3,5,'H1','50','10:47:44','delivered',477.57,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(388,'ORD-923663',9,3,2,'A1','1','14:49:52','delivered',209.06,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(389,'ORD-503506',4,3,4,'S4','34','14:00:00','delivered',379.52,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(390,'ORD-479601',7,5,5,'H1','23','13:26:26','pending',222.09,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(391,'ORD-501889',2,2,1,'B2','49','12:42:48','delivered',331.84,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(392,'ORD-933119',1,3,5,'S4','45','13:50:30','pending',411.86,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(393,'ORD-941835',10,1,5,'S4','27','14:29:14','delivered',443.43,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(394,'ORD-975951',5,2,2,'A1','4','14:29:09','ready',485.57,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(395,'ORD-619173',10,1,2,'A1','11','12:12:40','dispatched',443.06,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(396,'ORD-150683',5,5,2,'B2','39','11:44:42','assigned',188.68,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(397,'ORD-305735',5,4,2,'A1','44','14:32:32','delivered',106.85,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(398,'ORD-175808',8,3,1,'B2','5','12:33:52','ready',597.43,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(399,'ORD-357562',3,3,4,'S4','12','11:37:06','delivered',409.63,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(400,'ORD-867162',3,4,3,'A1','28','11:35:57','delivered',446.62,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(401,'ORD-363763',5,2,2,'S4','6','13:41:58','ready',357.50,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(402,'ORD-213193',1,4,4,'A1','48','10:44:57','delivered',589.93,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(403,'ORD-341650',7,2,3,'H1','6','13:15:27','delivered',479.44,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(404,'ORD-599743',9,4,5,'S4','27','12:44:42','pending',229.39,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(405,'ORD-978102',7,2,1,'A1','22','13:11:00','delivered',316.26,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(406,'ORD-538598',8,2,3,'S4','15','13:39:11','dispatched',428.48,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(407,'ORD-916014',7,2,4,'H1','41','12:55:46','assigned',515.17,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(408,'ORD-553037',8,1,2,'A1','6','14:57:29','dispatched',117.78,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(409,'ORD-776008',7,5,5,'B2','4','11:49:28','dispatched',163.37,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(410,'ORD-211284',6,2,3,'H1','39','11:39:47','ready',420.34,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(411,'ORD-261599',3,4,3,'S4','34','12:16:08','ready',507.29,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(412,'ORD-453218',9,1,1,'H1','7','10:34:01','pending',330.17,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(413,'ORD-753260',2,4,4,'H1','33','14:44:34','dispatched',111.13,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(414,'ORD-897209',1,4,5,'H1','1','10:38:40','assigned',373.34,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(415,'ORD-304111',3,2,2,'B2','42','10:26:38','delivered',383.21,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(416,'ORD-966595',1,1,5,'A1','30','13:23:11','dispatched',190.93,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(417,'ORD-423772',9,1,3,'S4','20','11:36:38','assigned',266.25,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(418,'ORD-476583',3,5,1,'B2','48','12:33:53','dispatched',547.36,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(419,'ORD-444592',7,2,1,'H1','32','13:56:08','pending',575.58,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(420,'ORD-988880',3,2,2,'A1','3','10:58:52','delivered',455.13,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(421,'ORD-755888',8,3,1,'A1','5','11:10:59','delivered',534.77,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(422,'ORD-452102',2,4,3,'A1','20','14:34:55','ready',215.21,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(423,'ORD-217057',8,2,4,'B2','39','13:22:43','pending',301.61,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(424,'ORD-621497',7,2,1,'A1','49','14:12:57','ready',547.06,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(425,'ORD-459629',2,3,2,'H1','49','12:37:56','dispatched',183.60,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(426,'ORD-494670',5,5,5,'H1','15','10:41:28','delivered',459.67,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(427,'ORD-481086',8,3,3,'A1','28','13:01:14','ready',163.38,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(428,'ORD-973937',5,2,2,'A1','1','13:30:22','assigned',173.84,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(429,'ORD-545382',4,1,3,'H1','21','11:07:12','delivered',492.48,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(430,'ORD-908026',8,5,4,'H1','37','11:20:08','pending',535.43,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(431,'ORD-227728',9,5,4,'A1','2','10:05:57','ready',111.21,NULL,'2026-04-08 14:16:25','2026-04-08 14:28:48'),(432,'ORD-322670',1,3,2,'B2','12','11:43:09','pending',221.72,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(433,'ORD-577334',5,5,5,'A1','25','11:08:57','dispatched',498.39,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(434,'ORD-163055',7,1,4,'B2','37','11:51:01','dispatched',266.02,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(435,'ORD-979912',2,3,4,'B2','48','13:21:09','assigned',321.48,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(436,'ORD-443637',7,2,2,'S4','20','10:02:48','delivered',247.24,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(437,'ORD-559686',10,1,3,'B2','31','13:44:56','delivered',271.86,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(438,'ORD-804416',1,4,5,'S4','11','14:12:51','assigned',329.17,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(439,'ORD-210320',2,2,4,'H1','42','14:14:27','dispatched',180.19,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(440,'ORD-471881',4,3,1,'A1','49','13:50:39','delivered',301.09,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(441,'ORD-749455',1,1,2,'A1','14','13:16:16','assigned',255.70,NULL,'2026-04-08 13:16:25','2026-04-08 14:16:25'),(442,'ORD-125551',6,4,5,'S4','38','12:34:25','ready',139.77,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(443,'ORD-890542',2,5,3,'S4','22','12:09:38','delivered',554.56,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(444,'ORD-445606',9,1,1,'S4','26','12:19:32','dispatched',323.44,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(445,'ORD-374183',8,4,4,'H1','12','13:18:09','dispatched',190.49,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(446,'ORD-544483',5,4,3,'H1','9','10:52:33','ready',245.93,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(447,'ORD-971722',8,4,4,'A1','8','13:06:03','dispatched',348.10,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(448,'ORD-861449',9,4,3,'H1','7','13:56:48','assigned',271.26,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(449,'ORD-463251',8,3,4,'B2','28','11:07:53','assigned',500.23,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(450,'ORD-254743',4,1,2,'S4','6','13:08:37','delivered',185.56,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(451,'ORD-633322',7,4,3,'B2','8','13:39:10','ready',571.66,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(452,'ORD-413369',7,1,4,'B2','5','13:26:04','pending',484.43,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(453,'ORD-483835',1,1,4,'S4','16','13:05:56','pending',582.19,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(454,'ORD-770507',8,3,1,'B2','11','10:09:56','assigned',419.31,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(455,'ORD-852102',6,1,1,'H1','28','14:29:25','delivered',352.03,NULL,'2026-04-08 14:16:25','2026-04-08 14:16:25'),(456,'ORD-545293',5,5,5,'H1','5','12:39:38','assigned',319.29,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(457,'ORD-589287',9,2,3,'B2','17','12:45:57','dispatched',199.37,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(458,'ORD-817332',10,2,5,'S4','5','13:30:01','ready',170.11,NULL,'2026-04-08 07:16:25','2026-04-08 14:16:25'),(459,'ORD-427158',10,4,2,'H1','38','13:51:03','dispatched',518.33,NULL,'2026-04-08 12:16:25','2026-04-08 14:16:25'),(460,'ORD-968086',10,4,1,'B2','38','11:53:17','dispatched',163.93,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(461,'ORD-127487',2,3,5,'H1','47','14:49:44','pending',289.01,NULL,'2026-04-08 09:16:25','2026-04-08 14:16:25'),(462,'ORD-540983',3,5,4,'H1','2','13:07:35','pending',300.08,NULL,'2026-04-08 08:16:25','2026-04-08 14:16:25'),(463,'ORD-977906',4,5,3,'H1','1','11:30:45','assigned',283.73,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(464,'ORD-333390',9,4,3,'B2','42','14:18:38','dispatched',291.06,NULL,'2026-04-08 10:16:25','2026-04-08 14:16:25'),(465,'ORD-550936',10,1,4,'A1','8','13:37:45','pending',388.85,NULL,'2026-04-08 11:16:25','2026-04-08 14:16:25'),(466,'ORD9201',1,1,1,'S4','22','12:30:00','cancelled',350.00,'Train delayed','2026-04-10 23:59:47','2026-04-10 23:59:47'),(467,'ORD9202',2,2,2,'B2','45','13:00:00','cancelled',420.00,'Customer request','2026-04-10 23:59:47','2026-04-10 23:59:47'),(468,'ORD9203',3,3,3,'A1','12','13:15:00','cancelled',275.00,'Late delivery','2026-04-10 23:59:47','2026-04-10 23:59:47'),(469,'ORD9204',4,4,4,'S1','05','13:30:00','cancelled',190.00,'Changed plan','2026-04-10 23:59:47','2026-04-10 23:59:47'),(470,'ORD9205',5,5,5,'B3','30','14:00:00','cancelled',310.00,'Out of stock','2026-04-10 23:59:47','2026-04-10 23:59:47'),(471,'ORD9206',1,2,1,'H1','04','14:30:00','cancelled',480.00,'Restaurant closed','2026-04-10 23:59:47','2026-04-10 23:59:47'),(472,'ORD9207',2,4,6,'S3','18','15:00:00','cancelled',220.00,'Wrong order','2026-04-10 23:59:47','2026-04-10 23:59:47'),(473,'ORD9208',3,1,7,'B4','33','15:30:00','cancelled',395.00,'Duplicate order','2026-04-10 23:59:47','2026-04-10 23:59:47'),(474,'ORD9209',4,2,3,'A2','10','16:00:00','cancelled',350.00,'Payment failed','2026-04-10 23:59:47','2026-04-10 23:59:47'),(475,'ORD9210',5,3,2,'C1','20','16:30:00','cancelled',260.00,'Train delay','2026-04-10 23:59:47','2026-04-10 23:59:47'),(476,'ORD9211',1,4,4,'B1','15','17:00:00','cancelled',300.00,'Address issue','2026-04-10 23:59:47','2026-04-10 23:59:47'),(477,'ORD9212',2,5,5,'S2','40','17:30:00','cancelled',280.00,'Customer unavailable','2026-04-10 23:59:47','2026-04-10 23:59:47'),(478,'ORD9213',3,1,6,'H2','07','18:00:00','cancelled',500.00,'Order mistake','2026-04-10 23:59:47','2026-04-10 23:59:47'),(479,'ORD9214',4,2,7,'A3','22','18:30:00','cancelled',450.00,'Train cancelled','2026-04-10 23:59:47','2026-04-10 23:59:47'),(480,'ORD9215',5,3,1,'S6','55','19:00:00','cancelled',330.00,'Late preparation','2026-04-10 23:59:47','2026-04-10 23:59:47');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurants`
--

DROP TABLE IF EXISTS `restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `outlet_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `station` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_station` (`station`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurants`
--

LOCK TABLES `restaurants` WRITE;
/*!40000 ALTER TABLE `restaurants` DISABLE KEYS */;
INSERT INTO `restaurants` VALUES (1,'Haldiram\'s Express','Station Outlet A1','Nagpur','0712-2345678','haldirams@gmail.com',1,'2026-03-30 08:43:45'),(2,'Nagpur Kitchen','Platform 2','Nagpur','0712-3456789','nagpurkitchen@gmail.com',1,'2026-03-30 08:43:45'),(3,'Biryani House','West Wing Exit','Nagpur','0712-4567890','biryanihouse@gmail.com',1,'2026-03-30 08:43:45'),(4,'Rail Dhaba','Main Concourse','Nagpur','0712-5678901','raildhaba@gmail.com',1,'2026-03-30 08:43:45'),(5,'Spice Route','Gate 3','Nagpur','0712-6789012','spiceroute@gmail.com',1,'2026-03-30 08:43:45'),(6,'KFC Station','South Exit','Nagpur','0712-7890123','kfc.ngp@gmail.com',1,'2026-03-30 08:43:45'),(7,'Domino\'s Pizza','Platform 1','Nagpur','0712-8901234','dominos.ngp@gmail.com',1,'2026-03-30 08:43:45'),(8,'Bikanerwala','Gate 1','Nagpur','0712-9012345','bikanerwala@gmail.com',1,'2026-03-30 08:43:45');
/*!40000 ALTER TABLE `restaurants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `train_delays`
--

DROP TABLE IF EXISTS `train_delays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `train_delays` (
  `id` int NOT NULL AUTO_INCREMENT,
  `train_id` int NOT NULL,
  `delay_minutes` int NOT NULL DEFAULT '0',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reported_by` int DEFAULT NULL,
  `reported_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_train` (`train_id`),
  KEY `fk_delay_reporter` (`reported_by`),
  CONSTRAINT `fk_delay_reporter` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_delay_train` FOREIGN KEY (`train_id`) REFERENCES `trains` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `train_delays`
--

LOCK TABLES `train_delays` WRITE;
/*!40000 ALTER TABLE `train_delays` DISABLE KEYS */;
INSERT INTO `train_delays` VALUES (1,1,35,'Signal failure near Wardha',2,'2026-03-30 08:43:45'),(2,2,18,'Late departure from Howrah',2,'2026-03-30 08:43:45');
/*!40000 ALTER TABLE `train_delays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trains`
--

DROP TABLE IF EXISTS `trains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trains` (
  `id` int NOT NULL AUTO_INCREMENT,
  `train_number` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `train_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `route` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `train_number` (`train_number`),
  KEY `idx_train_number` (`train_number`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trains`
--

LOCK TABLES `trains` WRITE;
/*!40000 ALTER TABLE `trains` DISABLE KEYS */;
INSERT INTO `trains` VALUES (1,'12290','Duronto Express','Mumbai CST → Nagpur'),(2,'12834','Howrah Express','Howrah → Nagpur'),(3,'22692','Rajdhani Express','Delhi → Nagpur'),(4,'12106','Vidarbha Express','Mumbai CST → Gondia'),(5,'12140','Sewagram Express','Mumbai CST → Wardha'),(6,'12291','Chennai Express','Chennai → Nagpur'),(7,'12293','Pune Express','Pune → Nagpur'),(8,'12289','Nagpur Duronto','Nagpur → Secunderabad');
/*!40000 ALTER TABLE `trains` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','station_master','delivery_staff','customer') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'customer',
  `station` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_phone` (`phone`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin User','admin@righttime.in','9800000001','hashed_pw','admin',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(2,'Rakesh Kumar','rakesh@righttime.in','9876543210','hashed_pw','station_master','Nagpur',1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(3,'Sunita Patel','sunita@righttime.in','9845012345','hashed_pw','station_master','Mumbai',1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(4,'Arjun Singh','arjun@righttime.in','9812340001','hashed_pw','delivery_staff','Nagpur',1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(5,'Meena Rao','meena@righttime.in','9812340002','hashed_pw','delivery_staff','Nagpur',1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(6,'Vijay Kumar','vijay@righttime.in','9812340003','hashed_pw','delivery_staff','Nagpur',1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(7,'Priya Lal','priya@righttime.in','9812340004','hashed_pw','delivery_staff','Nagpur',1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(8,'Amit Verma','amit.verma@gmail.com','9901234567','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(9,'Deepa Nair','deepa.nair@gmail.com','9902345678','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(10,'Ramesh Gupta','ramesh.gupta@gmail.com','9903456789','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(11,'Kavita Singh','kavita.singh@gmail.com','9904567890','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(12,'Sanjay Mehta','sanjay.mehta@gmail.com','9905678901','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(13,'Pooja Iyer','pooja.iyer@gmail.com','9906789012','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(14,'Mohan Das','mohan.das@gmail.com','9907890123','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(15,'Rekha Tiwari','rekha.tiwari@gmail.com','9908901234','hashed_pw','customer',NULL,1,'2026-03-30 08:43:45','2026-03-30 08:43:45'),(16,'ankit sengupta','as5458@srmist.edu.in','9999999999','$2b$12$cDe.ciAmk56dcqxXzVG.RO9Jt3m44EToifjrHfT2X9C6WEDeR/o6.','customer',NULL,1,'2026-04-01 00:28:55','2026-04-01 00:28:55'),(17,'Rajeswari de','rs5458@srmist.edu.in','9999999999','$2b$12$0mh9/3X.uE9hdwsyv7S48eRxLhzUjx2Q.UqSnZTdgM.FG0eeRrbVa','customer',NULL,1,'2026-04-14 11:04:52','2026-04-14 11:04:52');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-16 14:30:59
