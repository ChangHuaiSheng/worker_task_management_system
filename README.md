# Personal Info
Name : Chang Huai Sheng

Matric No : 297670

# worker_task_management_system
This is the worker task management system for Individual Assignment 2

# Database Setup for XAMPP
After starting XAMPP, go to XAMPP Control Panel and get the IPV4 Address, copy the IP address and paste it in the url in myconfig.dart (Take note that different connection have different IP address so you have to check it everytime)
![image](https://github.com/user-attachments/assets/5810c109-b4a8-4bb6-b6fd-d745ff487bb2)

![image](https://github.com/user-attachments/assets/0f5d4f11-86fb-49b3-a382-47fc66d25635)

Open the localhost website in XAMPP and create a new database named wtms_db , then create a table named workers with this query:

CREATE TABLE `wtms_db`.`workers` (
`id` INT NOT NULL AUTO_INCREMENT , 
`full_name` VARCHAR(100) NOT NULL , 
`email` VARCHAR(100) NOT NULL , 
`password` VARCHAR(255) NOT NULL , 
`phone` VARCHAR(20) NOT NULL , 
`address` TEXT NOT NULL ,
 	PRIMARY KEY (`id`), 
UNIQUE (`email`)
) ENGINE = InnoDB;

#PHP API Backend

Copy the wtms folder in 
https://github.com/ChangHuaiSheng/worker_task_management_system/tree/main/wtms/wtms/php
and paste it in your XAMPP's htdocs folder 

#Run App
You can use Android Studio Emulator or any External Devices to test the app 
