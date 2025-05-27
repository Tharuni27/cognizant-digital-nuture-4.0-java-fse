-- 1. User Upcoming Events
SELECT 
    e.title AS event_title,
    e.city AS event_city,
    e.start_date AS event_start_date
FROM 
    Events e
JOIN 
    Registrations r ON e.event_id = r.event_id
JOIN 
    Users u ON r.user_id = u.user_id
WHERE 
    e.status = 'upcoming' AND e.city = u.city
ORDER BY 
    e.start_date;

-- 2. Top Rated Events
SELECT 
    e.title AS event_title,
    AVG(f.rating) AS average_rating
FROM 
    Events e
JOIN 
    Feedback f ON e.event_id = f.event_id
GROUP BY 
    e.event_id
HAVING 
    COUNT(f.feedback_id) >= 10
ORDER BY 
    average_rating DESC;

-- 3. Inactive Users
SELECT 
    u.full_name, u.email
FROM 
    Users u
LEFT JOIN 
    Registrations r ON u.user_id = r.user_id
WHERE 
    r.registration_date IS NULL OR r.registration_date < CURDATE() - INTERVAL 90 DAY;

-- 4. Peak Session Hours
SELECT 
    e.title AS event_title,
    COUNT(s.session_id) AS session_count
FROM 
    Events e
JOIN 
    Sessions s ON e.event_id = s.event_id
WHERE 
    TIME(s.start_time) BETWEEN '10:00:00' AND '12:00:00'
GROUP BY 
    e.event_id;

-- 5. Most Active Cities
SELECT 
    e.city,
    COUNT(DISTINCT r.user_id) AS distinct_user_count
FROM 
    Events e
JOIN 
    Registrations r ON e.event_id = r.event_id
GROUP BY 
    e.city
ORDER BY 
    distinct_user_count DESC
LIMIT 5;

-- 6. Event Resource Summary
SELECT 
    e.title AS event_title,
    COUNT(CASE WHEN r.resource_type = 'pdf' THEN 1 END) AS pdf_count,
    COUNT(CASE WHEN r.resource_type = 'image' THEN 1 END) AS image_count,
    COUNT(CASE WHEN r.resource_type = 'link' THEN 1 END) AS link_count
FROM 
    Events e
LEFT JOIN 
    Resources r ON e.event_id = r.event_id
GROUP BY 
    e.event_id;

-- 7. Low Feedback Alerts
SELECT 
    u.full_name AS user_name,
    f.comments AS feedback_comments,
    e.title AS event_title
FROM 
    Feedback f
JOIN 
    Users u ON f.user_id = u.user_id
JOIN 
    Events e ON f.event_id = e.event_id
WHERE 
    f.rating < 3;

-- 8. Sessions per Upcoming Event
SELECT 
    e.title AS event_title,
    COUNT(s.session_id) AS session_count
FROM 
    Events e
LEFT JOIN 
    Sessions s ON e.event_id = s.event_id
WHERE 
    e.status = 'upcoming'
GROUP BY 
    e.event_id;

-- 9. Organizer Event Summary
SELECT 
    u.full_name AS organizer_name,
    COUNT(e.event_id) AS total_events,
    e.status
FROM 
    Events e
JOIN 
    Users u ON e.organizer_id = u.user_id
GROUP BY 
    u.user_id, e.status;

-- 10. Feedback Gap
SELECT 
    e.title AS event_title
FROM 
    Events e
LEFT JOIN 
    Feedback f ON e.event_id = f.event_id
WHERE 
    f.feedback_id IS NULL AND EXISTS (
        SELECT 1 
        FROM Registrations r 
        WHERE r.event_id = e.event_id
    );