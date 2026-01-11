CREATE PROCEDURE InitializeDatabase
    @DaysBack INT = 30
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tcnt INT;
    DECLARE @pcnt INT;
    DECLARE @ucnt INT;
    SELECT @tcnt = COUNT(*) FROM TimeLog;
    SELECT @pcnt = COUNT(*) FROM Project;
    SELECT @ucnt = COUNT(*) FROM [User];

    
    -- Delete all content from tables
    DELETE FROM TimeLog;
    DELETE FROM Project;
    DELETE FROM [User];
    DELETE FROM Requests;
    
    -- Reset identity seeds
    IF @tcnt > 0
        DBCC CHECKIDENT ('TimeLog', RESEED, -1);
    ELSE 
        DBCC CHECKIDENT ('TimeLog', RESEED, 0);
    IF @pcnt > 0
        DBCC CHECKIDENT ('Project', RESEED, -1);
    ELSE 
        DBCC CHECKIDENT ('Project', RESEED, 0);
    IF @ucnt > 0
        DBCC CHECKIDENT ('[User]', RESEED, -1);
    ELSE 
        DBCC CHECKIDENT ('[User]', RESEED, 0);
    
    -- Declare lookup lists
    DECLARE @FirstNames TABLE (name NVARCHAR(50));
    INSERT INTO @FirstNames VALUES 
        ('John'), ('Gringo'), ('Mark'), ('Lisa'), ('Maria'), 
        ('Sonya'), ('Philip'), ('Jose'), ('Lorenzo'), ('George'), ('Justin');
    
    DECLARE @LastNames TABLE (name NVARCHAR(50));
    INSERT INTO @LastNames VALUES 
        ('Johnson'), ('Lamas'), ('Jackson'), ('Brown'), ('Mason'), 
        ('Rodriguez'), ('Roberts'), ('Thomas'), ('Rose'), ('McDonalds');
    
    DECLARE @Domains TABLE (domain NVARCHAR(50));
    INSERT INTO @Domains VALUES ('hotmail.com'), ('gmail.com'), ('live.com');
    
    -- Generate 100 users with unique emails
    DECLARE @i INT = 0;
    DECLARE @firstName NVARCHAR(50);
    DECLARE @lastName NVARCHAR(50);
    DECLARE @domain NVARCHAR(50);
    DECLARE @email NVARCHAR(100);
    DECLARE @emailSuffix INT;
    
    WHILE @i < 100
    BEGIN
        -- Random first name
        SELECT @firstName = name 
        FROM (SELECT TOP 1 name FROM @FirstNames ORDER BY NEWID()) fn;

        -- Random last name
        SELECT @lastName = name 
        FROM (SELECT TOP 1 name FROM @LastNames ORDER BY NEWID()) ln;

        -- Random domain
        SELECT @domain = domain 
        FROM (SELECT TOP 1 domain FROM @Domains ORDER BY NEWID()) d;
        
        -- Generate email (add suffix if duplicate)
        SET @emailSuffix = 0;
        SET @email = LOWER(@firstName) + '.' + LOWER(@lastName) + '@' + @domain;
        
        -- Check for uniqueness and add suffix if needed
        WHILE EXISTS (SELECT 1 FROM [User] WHERE email = @email)
        BEGIN
            SET @emailSuffix = @emailSuffix + 1;
            SET @email = LOWER(@firstName) + '.' + LOWER(@lastName) + CAST(@emailSuffix AS NVARCHAR) + '@' + @domain;
        END
        
        -- Insert user
        INSERT INTO [User] (first_name, last_name, email)
        VALUES (@firstName, @lastName, @email);
        
        SET @i = @i + 1;
    END
    
    -- Create projects
    INSERT INTO Project (project_name) VALUES ('My own');
    INSERT INTO Project (project_name) VALUES ('Free Time');
    INSERT INTO Project (project_name) VALUES ('Work');
    
    -- Generate TimeLog entries for each user
    DECLARE @userId INT;
    DECLARE @numEntries INT;
    DECLARE @entryCount INT;
    DECLARE @projectId INT;
    DECLARE @logDate DATE;
    DECLARE @hours FLOAT;
    DECLARE @dailyTotal FLOAT;
    DECLARE @maxHours FLOAT = 8.0;
    DECLARE @minDate DATE = DATEADD(DAY, -@DaysBack, GETDATE());
    
    DECLARE user_cursor CURSOR FOR SELECT id FROM [User];
    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @userId;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Random number of entries between 1 and 20
        SET @numEntries = ABS(CHECKSUM(NEWID()) % 20) + 1;
        SET @entryCount = 0;
        
        WHILE @entryCount < @numEntries
        BEGIN
            -- Random project
            SELECT @projectId = id 
            FROM (SELECT TOP 1 id FROM Project ORDER BY NEWID()) p;
            
            -- Random date within range
            SET @logDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % @DaysBack), @minDate);
            
            -- Random hours between 0.25 and 8.00
            SET @hours = ROUND((ABS(CHECKSUM(NEWID()) % 775) + 25) / 100.0, 2);
            
            -- Check daily total for this user and date
            SELECT @dailyTotal = ISNULL(SUM(hours), 0)
            FROM TimeLog
            WHERE user_id = @userId AND date = @logDate;
            
            -- Only insert if it won't exceed 8 hours for the day
            IF (@dailyTotal + @hours) <= @maxHours
            BEGIN
                INSERT INTO TimeLog (user_id, project_id, date, hours)
                VALUES (@userId, @projectId, @logDate, @hours);
                
                SET @entryCount = @entryCount + 1;
            END
            ELSE IF @dailyTotal < @maxHours
            BEGIN
                -- Insert remaining hours to reach exactly 8 or close to it
                SET @hours = @maxHours - @dailyTotal;
                IF @hours >= 0.25
                BEGIN
                    INSERT INTO TimeLog (user_id, project_id, date, hours)
                    VALUES (@userId, @projectId, @logDate, @hours);
                    
                    SET @entryCount = @entryCount + 1;
                END
            END
            -- If day is full, try another date in next iteration
        END
        
        FETCH NEXT FROM user_cursor INTO @userId;
    END
    
    CLOSE user_cursor;
    DEALLOCATE user_cursor;
END
GO

-- =============================================
-- Execute the stored procedure
-- =============================================
-- EXEC InitializeDatabase;  -- Uses default 30 days
-- EXEC InitializeDatabase @DaysBack = 60;  -- Custom date range