-- Create Database named TimeTrackingDB
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TimeTrackingDB')
BEGIN
    CREATE DATABASE TimeTrackingDB;
END
GO

USE TimeTrackingDB;
GO

-- Create User Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
BEGIN
    CREATE TABLE [User] (
        id INT PRIMARY KEY IDENTITY(1,1),
        first_name NVARCHAR(50) NOT NULL,
        last_name NVARCHAR(50) NOT NULL,
        email NVARCHAR(100) NOT NULL UNIQUE
    );
END

-- Create Project Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Project')
BEGIN
    CREATE TABLE Project (
        id INT PRIMARY KEY IDENTITY(1,1),
        project_name NVARCHAR(100) NOT NULL
    );
END

-- Create TimeLog Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TimeLog')
BEGIN
    CREATE TABLE TimeLog (
        id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL,
        project_id INT NOT NULL,
        date DATE NOT NULL,
        hours FLOAT NOT NULL CHECK (hours > 0 AND hours <= 8),
        FOREIGN KEY (user_id) REFERENCES [User](id),
        FOREIGN KEY (project_id) REFERENCES Project(id)
    );
END


-- Create Requests Table for RPC-Service
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Requests')
BEGIN
    CREATE TABLE Requests (
        id INT PRIMARY KEY IDENTITY(1,1),
        request_id UNIQUEIDENTIFIER NOT NULL,
        req_date DATETIME NOT NULL,
        param NVARCHAR(255) NOT NULL,
        data NVARCHAR(MAX) NOT NULL
    );
END

GO