-- DROP FUNCTION IF EXISTS sla_get_date CASCADE ;
-- CREATE FUNCTION sla_get_date(p_date TIMESTAMP WITHOUT TIME ZONE) RETURNS TIMESTAMP WITHOUT TIME ZONE
--     LANGUAGE sql
--     AS $BODY$
-- -- SET SESSION timezone TO 'Etc/UTC';
-- SELECT DATE_TRUNC( 'MINUTE', TIMEZONE(
--   (
--     SELECT COALESCE( 
--       (
--         SELECT SUBSTRING( value FROM 'sla_time_zone: ([a-z,A-Z,/]*)')
--         FROM settings
--         WHERE name LIKE 'plugin_redmine_sla'
--       ), 'Etc/UTC' )
--   ), p_date AT TIME ZONE 'Etc/UTC'
-- ) )
-- $BODY$


DELIMITER //

DROP FUNCTION IF EXISTS sla_get_date //

CREATE FUNCTION sla_get_date(p_date DATETIME)
RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE tz VARCHAR(64);

    -- Get the timezone from settings, default to 'Etc/UTC'
    SELECT
        COALESCE(
            SUBSTRING_INDEX(SUBSTRING_INDEX(value, 'sla_time_zone: ', -1), '\n', 1),
            'Etc/UTC'
        )
    INTO tz
    FROM settings
    WHERE name LIKE 'plugin_redmine_sla'
    LIMIT 1;

    -- Convert the time from UTC to target timezone and truncate to minute
    RETURN DATE_FORMAT(CONVERT_TZ(p_date, 'UTC', tz), '%Y-%m-%d %H:%i:00');
END //

DELIMITER ;