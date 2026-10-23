# QueueLess — Digital Queue & Token Management System

QueueLess is a web-based digital queue management system developed using Java, JSP, Servlets, and MySQL. It helps students generate queue tokens and monitor their status while allowing staff to manage queues efficiently.

## Features

### Student Module
- Student registration and login
- Generate tokens for different departments
- View current token number and queue status
- Track the number of people ahead in the queue
- Automatically refresh queue status
- Cancel a token while it is waiting
- View token history

### Staff Module
- Staff login
- View and manage department queues
- Call the next waiting token
- Complete or skip tokens
- Monitor token statuses and waiting queues

### Database Module
- MySQL database integration
- User and department management
- Token and token-history records
- Persistent storage of queue information

## Technologies Used

- **Programming Language:** Java
- **Frontend:** HTML, CSS, JSP
- **Backend:** Java Servlets
- **Database:** MySQL
- **Database Connectivity:** JDBC
- **IDE:** NetBeans
- **Application Server:** GlassFish

## Project Structure

```text
QueueLess/
├── src/java/controller/   # Java servlets and controllers
├── web/                   # JSP pages and web resources
├── database/              # Database creation script
├── nbproject/             # NetBeans project metadata
├── build.xml              # Ant build configuration
└── README.md              # Project documentation
```

## Database Setup

1. Install and start MySQL.
2. Open MySQL Workbench or another MySQL client.
3. Run the SQL script located at `database/queueless_db.sql`.
4. Configure the database connection in `controller.DBConnection`.
5. Ensure the MySQL Connector/J JDBC driver is available to the project.

## Running the Project

1. Open the QueueLess project in NetBeans.
2. Configure the required Java and GlassFish server settings.
3. Configure MySQL and the JDBC driver.
4. Build and deploy the project to the configured server.
5. Open the application through the local server URL.

## Purpose

QueueLess aims to reduce physical waiting lines, improve queue transparency, and make token management more organized for students and staff.

## Academic Project

Developed as an Advanced Java academic project for learning and demonstrating Java web development, servlet-based request handling, JSP integration, and database connectivity.
