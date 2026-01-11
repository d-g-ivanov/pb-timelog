-- =============================================
-- Verification Queries
-- =============================================

-- 1. Check record counts in all tables
SELECT 'Users' as TableName, COUNT(*) as RecordCount FROM [User]
UNION ALL
SELECT 'Projects', COUNT(*) FROM Project
UNION ALL
SELECT 'TimeLog', COUNT(*) FROM TimeLog;

-- 2. Verify 100 unique users with unique emails
SELECT COUNT(*) as TotalUsers, COUNT(DISTINCT email) as UniqueEmails
FROM [User];

-- 3. View sample users
SELECT TOP 10 id, first_name, last_name, email
FROM [User]
ORDER BY id;

-- 4. Verify projects
SELECT * FROM Project;

-- 5. Check TimeLog entries per user (should be between 1-20)
SELECT user_id, COUNT(*) as EntryCount
FROM TimeLog
GROUP BY user_id
ORDER BY EntryCount DESC;

-- 6. Verify daily totals don't exceed 8 hours per user
SELECT user_id, date, SUM(hours) as DailyTotal
FROM TimeLog
GROUP BY user_id, date
HAVING SUM(hours) > 8
ORDER BY DailyTotal DESC;
-- (Should return no rows if constraint is working correctly)

-- 7. View sample TimeLog entries with user and project details
SELECT TOP 20
    tl.id,
    u.first_name + ' ' + u.last_name as UserName,
    p.project_name,
    tl.date,
    tl.hours
FROM TimeLog tl
JOIN [User] u ON tl.user_id = u.id
JOIN Project p ON tl.project_id = p.id
ORDER BY tl.date DESC, u.first_name;

-- 8. Check date range of TimeLog entries
SELECT 
    MIN(date) as EarliestDate,
    MAX(date) as LatestDate,
    DATEDIFF(DAY, MIN(date), MAX(date)) as DateRangeDays
FROM TimeLog;

-- 9. Hours distribution by project
SELECT 
    p.project_name,
    COUNT(*) as EntryCount,
    ROUND(SUM(tl.hours), 2) as TotalHours,
    ROUND(AVG(tl.hours), 2) as AvgHours
FROM TimeLog tl
JOIN Project p ON tl.project_id = p.id
GROUP BY p.project_name
ORDER BY TotalHours DESC;

-- 10. Top 10 users by total hours logged
SELECT TOP 10
    u.first_name + ' ' + u.last_name as UserName,
    COUNT(*) as Entries,
    ROUND(SUM(tl.hours), 2) as TotalHours
FROM TimeLog tl
JOIN [User] u ON tl.user_id = u.id
GROUP BY u.first_name, u.last_name
ORDER BY TotalHours DESC;