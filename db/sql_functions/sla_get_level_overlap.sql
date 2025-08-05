CREATE TABLE calendar_minutes (
  minute DATETIME PRIMARY KEY
);

-- Fill with minutes over 7 days (you can schedule this)
INSERT INTO calendar_minutes (minute)
SELECT DATE_ADD(NOW(), INTERVAL seq MINUTE)
FROM (
  SELECT @row := @row + 1 AS seq
  FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
        UNION ALL SELECT 8 UNION ALL SELECT 9) AS ones,
       (SELECT 0 UNION ALL SELECT 10 UNION ALL SELECT 20 UNION ALL SELECT 30
        UNION ALL SELECT 40 UNION ALL SELECT 50 UNION ALL SELECT 60) AS tens,
       (SELECT @row := 0) AS init
) AS minutes
WHERE seq <= 10080;  -- 7 days * 24 hours * 60 minutes



DELIMITER //

DROP FUNCTION IF EXISTS sla_get_level_overlap //

CREATE FUNCTION sla_get_level_overlap(p_sla_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_overlap_found BOOLEAN DEFAULT FALSE;

    -- Check for overlapping time slots on the same calendar minute
    SELECT 1 INTO v_overlap_found
    FROM (
        SELECT cm.minute
        FROM calendar_minutes cm
        JOIN sla_schedules ss
            ON DAYOFWEEK(cm.minute) - 1 = ss.dow  -- MySQL: Sunday = 1, PostgreSQL = 0
           AND CAST(cm.minute AS TIME) BETWEEN ss.start_time AND ss.end_time
        JOIN sla_calendars sc ON sc.id = ss.sla_calendar_id
        JOIN sla_levels sl ON sl.sla_calendar_id = sc.id
        JOIN sla_project_trackers spt ON spt.sla_id = sl.sla_id
        WHERE sl.sla_id = p_sla_id
          AND ss.match = TRUE
        GROUP BY cm.minute
        HAVING COUNT(*) > 1
        LIMIT 1
    ) AS overlapping;

    RETURN v_overlap_found;
END //

DELIMITER ;
