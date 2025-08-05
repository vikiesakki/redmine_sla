DELIMITER //

DROP PROCEDURE IF EXISTS sla_get_spent //

CREATE PROCEDURE sla_get_spent (
  IN p_issue_id INT,
  IN p_sla_type_id INT,
  OUT out_spent INT
)
BEGIN
  DECLARE v_sla_cache_id INT;
  DECLARE v_start_date DATETIME;
  DECLARE v_end_date DATETIME;
  DECLARE v_calendar_id INT;
  DECLARE v_sla_level_id INT;
  DECLARE v_created_on DATETIME DEFAULT NOW();
  DECLARE v_updated_on DATETIME DEFAULT NOW();
  DECLARE v_project_id INT;
  DECLARE v_tracker_id INT;

  IF p_issue_id IS NULL OR p_sla_type_id IS NULL THEN
    SET out_spent = NULL;
    RETURN;
  END IF;

  -- Fetch SLA cache info
  SELECT id, start_date, project_id, tracker_id, sla_level_id
  INTO v_sla_cache_id, v_start_date, v_project_id, v_tracker_id, v_sla_level_id
  FROM sla_caches
  WHERE issue_id = p_issue_id
  LIMIT 1;

  IF v_sla_cache_id IS NULL THEN
    SET out_spent = NULL;
    RETURN;
  END IF;

  -- Get issue closed_on or use current time
  SELECT
    COALESCE(closed_on, NOW())
  INTO v_end_date
  FROM issues
  WHERE id = p_issue_id;

  -- Count the spent time
  SELECT COUNT(*) INTO out_spent
  FROM calendar_minutes cm
  JOIN sla_view_roll_statuses vs
    ON vs.issue_id = p_issue_id
   AND cm.minute BETWEEN vs.from_status_date AND DATE_SUB(vs.to_status_date, INTERVAL 1 MINUTE)
  JOIN sla_schedules ss
    ON (DAYOFWEEK(cm.minute) - 1 = ss.dow)
   AND CAST(cm.minute AS TIME) BETWEEN ss.start_time AND ss.end_time
  JOIN sla_calendars sc ON sc.id = ss.sla_calendar_id
  JOIN sla_levels sl ON sl.sla_calendar_id = sc.id AND sl.id = v_sla_level_id
  JOIN sla_project_trackers spt
    ON spt.sla_id = sl.sla_id
   AND spt.project_id = v_project_id
   AND spt.tracker_id = v_tracker_id
  WHERE cm.minute BETWEEN v_start_date AND v_end_date
    AND vs.from_status_id IN (
      SELECT DISTINCT status_id
      FROM sla_statuses
      WHERE sla_type_id = p_sla_type_id
    )
    AND NOT EXISTS (
      SELECT 1
      FROM sla_holidays h
      JOIN sla_calendar_holidays ch
        ON ch.sla_holiday_id = h.id
       AND ch.sla_calendar_id = sc.id
       AND ch.match = FALSE
      WHERE h.date = DATE(cm.minute)
    );

  -- Insert or update cache
  INSERT INTO sla_cache_spents (
    sla_cache_id, project_id, issue_id, sla_type_id,
    spent, created_on, updated_on
  ) VALUES (
    v_sla_cache_id, v_project_id, p_issue_id, p_sla_type_id,
    out_spent, v_created_on, v_updated_on
  )
  ON DUPLICATE KEY UPDATE
    updated_on = VALUES(updated_on),
    spent = VALUES(spent);

END //

DELIMITER ;
