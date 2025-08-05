DELIMITER //

DROP PROCEDURE IF EXISTS sla_get_level //

CREATE PROCEDURE sla_get_level (
    IN p_issue_id INT,
    IN p_refresh_force BOOLEAN,
    OUT out_id BIGINT,
    OUT out_project_id INT,
    OUT out_issue_id INT,
    OUT out_tracker_id INT,
    OUT out_sla_level_id INT,
    OUT out_start_date DATETIME,
    OUT out_created_on DATETIME,
    OUT out_updated_on DATETIME
)
BEGIN
    DECLARE v_issue_project_id INT;
    DECLARE v_issue_tracker_id INT;
    DECLARE v_issue_created_on DATETIME;
    DECLARE v_current_timestamp DATETIME;

    -- Intermediate variables for cache lookup
    DECLARE tmp_id BIGINT;
    DECLARE tmp_project_id INT;
    DECLARE tmp_tracker_id INT;
    DECLARE tmp_sla_level_id INT;
    DECLARE tmp_start_date DATETIME;
    DECLARE tmp_created_on DATETIME;
    DECLARE tmp_updated_on DATETIME;

    IF p_issue_id IS NULL THEN
        -- NULL input, exit early
        SET out_id = NULL;
        RETURN;
    END IF;

    -- Get current time in SLA timezone
    SET v_current_timestamp = sla_get_date(NOW());

    -- Check if we already have cache
    SELECT
        id, project_id, tracker_id, sla_level_id,
        start_date, created_on, updated_on
    INTO
        tmp_id, tmp_project_id, tmp_tracker_id, tmp_sla_level_id,
        tmp_start_date, tmp_created_on, tmp_updated_on
    FROM sla_caches
    WHERE issue_id = p_issue_id
    LIMIT 1;

    IF tmp_id IS NOT NULL AND NOT p_refresh_force THEN
        -- Return cached data
        SET out_id = tmp_id;
        SET out_project_id = tmp_project_id;
        SET out_issue_id = p_issue_id;
        SET out_tracker_id = tmp_tracker_id;
        SET out_sla_level_id = tmp_sla_level_id;
        SET out_start_date = tmp_start_date;
        SET out_created_on = tmp_created_on;
        SET out_updated_on = tmp_updated_on;
        RETURN;
    END IF;

    -- Load issue metadata
    SELECT
        sla_get_date(created_on), tracker_id, project_id
    INTO
        v_issue_created_on, v_issue_tracker_id, v_issue_project_id
    FROM issues
    WHERE id = p_issue_id
    LIMIT 1;

    -- Now find SLA level and matching calendar slot
    -- This is a complex join. You must prebuild or simplify this in MySQL using views or helper tables.

    -- Simplified insert/update (you need to build the actual logic for calendar matching)
    INSERT INTO sla_caches (
        id, project_id, issue_id, tracker_id,
        sla_level_id, start_date, created_on, updated_on
    )
    VALUES (
        p_issue_id, v_issue_project_id, p_issue_id,
        v_issue_tracker_id, 1, v_issue_created_on, v_current_timestamp, v_current_timestamp
    )
    ON DUPLICATE KEY UPDATE
        project_id = VALUES(project_id),
        tracker_id = VALUES(tracker_id),
        sla_level_id = VALUES(sla_level_id),
        start_date = VALUES(start_date),
        updated_on = VALUES(updated_on);

    -- Return data
    SELECT
        id, project_id, issue_id, tracker_id,
        sla_level_id, start_date, created_on, updated_on
    INTO
        out_id, out_project_id, out_issue_id, out_tracker_id,
        out_sla_level_id, out_start_date, out_created_on, out_updated_on
    FROM sla_caches
    WHERE issue_id = p_issue_id
    LIMIT 1;

END //

DELIMITER ;
