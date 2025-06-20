# Personal Info
Name : Chang Huai Sheng

Matric No : 297670

# worker_task_management_system
This is the worker task management system that consist of all elements for the project.

# Database Setup for XAMPP
The database sql file is available under worker_task_management_system/sql directory which can be used to import all the tables and the dummy data available inside once you've created a database with the name wtms_db.

After starting XAMPP, go to XAMPP Control Panel and get the IPV4 Address, copy the IP address and paste it in the url in myconfig.dart (Take note that different connection have different IP address so you have to check it everytime)
![image](https://github.com/user-attachments/assets/5810c109-b4a8-4bb6-b6fd-d745ff487bb2)

![image](https://github.com/user-attachments/assets/0f5d4f11-86fb-49b3-a382-47fc66d25635)

Open the localhost website in XAMPP and create a new database named wtms_db , then create a table named workers with this query:

``` 
CREATE TABLE `tbl_submissions` (
  `id` int(11) NOT NULL,
  `work_id` int(11) NOT NULL,
  `worker_id` int(11) NOT NULL,
  `submission_text` text NOT NULL,
  `submitted_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `tbl_works` (
  `work_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `assigned_to` int(11) NOT NULL,
  `date_assigned` date NOT NULL,
  `due_date` date NOT NULL,
  `status` varchar(20) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `workers` (
  `worker_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `image` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```


After creating the tables, proceed with altering the tables to set auto increment and other indexes.

```
1. Indexes for table `tbl_submissions`

  ALTER TABLE `tbl_submissions`
    ADD PRIMARY KEY (`id`);


2. Indexes for table `tbl_works`

  ALTER TABLE `tbl_works`
    ADD PRIMARY KEY (`work_id`);


3. Indexes for table `workers`

  ALTER TABLE `workers`
    ADD PRIMARY KEY (`worker_id`),
    ADD UNIQUE KEY `email` (`email`);


4. AUTO_INCREMENT for table `tbl_submissions`

  ALTER TABLE `tbl_submissions`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;


5. AUTO_INCREMENT for table `tbl_works`

  ALTER TABLE `tbl_works`
    MODIFY `work_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;


6. AUTO_INCREMENT for table `workers`

  ALTER TABLE `workers`
    MODIFY `worker_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
  COMMIT;
```

After everything is done, insert the dummy datas
 ```
INSERT INTO `tbl_submissions` (`id`, `work_id`, `worker_id`, `submission_text`, `submitted_at`) VALUES
(1, 1, 1, 'Testing', '2025-06-20 21:59:25'),
(2, 6, 1, 'completed too', '2025-06-20 21:59:50'),
(3, 2, 2, 'completed you can change to anything', '2025-06-20 22:02:41'),
(4, 7, 2, 'done', '2025-06-20 22:02:46'),
(5, 3, 3, 'done', '2025-06-20 22:03:49'),
(6, 8, 3, 'done', '2025-06-20 22:03:57'),
(7, 11, 3, 'updated', '2025-06-20 22:04:04'),
(8, 4, 4, 'this is completed', '2025-06-20 22:05:14'),
(9, 9, 4, 'finished maintaining today', '2025-06-20 22:05:24'),
(10, 5, 5, 'done processing', '2025-06-20 22:06:07'),
(11, 10, 5, 'report is completed today', '2025-06-20 22:06:15'),
(12, 1, 1, 'completed preparing materials', '2025-06-20 22:26:37');


INSERT INTO `tbl_works` (`work_id`, `title`, `description`, `assigned_to`, `date_assigned`, `due_date`, `status`) VALUES
(1, 'Prepare Material A', 'Prepare raw material A for assembly.', 1, '2025-05-25', '2025-05-28', 'completed'),
(2, 'Inspect Machine X', 'Conduct inspection for machine X.', 2, '2025-05-25', '2025-05-29', 'completed'),
(3, 'Clean Area B', 'Deep clean work area B before audit.', 3, '2025-05-25', '2025-05-30', 'completed'),
(4, 'Test Circuit Board', 'Perform unit test for circuit batch 4.', 4, '2025-05-25', '2025-05-28', 'completed'),
(5, 'Document Process', 'Write SOP for packaging unit.', 5, '2025-05-25', '2025-05-29', 'completed'),
(6, 'Paint Booth Check', 'Routine check on painting booth.', 1, '2025-05-25', '2025-05-30', 'completed'),
(7, 'Label Inventory', 'Label all boxes in section C.', 2, '2025-05-25', '2025-05-28', 'completed'),
(8, 'Update Database', 'Update inventory in MySQL system.', 3, '2025-05-25', '2025-05-29', 'completed'),
(9, 'Maintain Equipment', 'Oil and tune cutting machine.', 4, '2025-05-25', '2025-05-30', 'completed'),
(10, 'Prepare Report', 'Prepare monthly performance report.', 5, '2025-05-25', '2025-05-30', 'completed'),
(11, 'Clean Area B', 'Deep clean work area B before audit.', 3, '2025-05-25', '2025-05-30', 'completed');


INSERT INTO `workers` (`worker_id`, `full_name`, `email`, `password`, `phone`, `address`, `image`) VALUES
(1, 'Chang Huai Sheng', 'changhuaisheng77@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '123123123', 'Penang', NULL),
(2, 'Hadif Bin Hadif', 'hadif@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '345456', 'SINTOK KEDAH UUM CHANGLUN ', NULL),
(3, 'Isac', 'isac@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '456456', 'Kuala Lumpur, KL', NULL),
(4, 'Damien', 'damien@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '1231321', 'Alor Setar', NULL),
(5, 'Muhammad', 'muhammad@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '3546476476', 'Jitra', NULL),
(6, 'dummyacc', 'dummyacc@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '12322536447', 'Changlun', NULL),
(7, 'Chungus', 'chungus@gmail.com', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', '12313123131231', 'In your dream', NULL),
(8, 'jihahahahahahah', 'jihaha@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '12313131231232131312', 'Random Place', NULL);
```

# PHP API Backend

Copy the wtms folder in 
https://github.com/ChangHuaiSheng/worker_task_management_system/tree/main/wtms/wtms/php
and paste it in your XAMPP's htdocs folder 

# Run App
You can use Android Studio Emulator or any External Devices to test the app 
