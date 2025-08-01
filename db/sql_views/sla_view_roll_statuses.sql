-- Issues journals rebuild, with database time zone
CREATE OR REPLACE VIEW sla_view_roll_statuses AS
(
  -- The first and subsequent status changes
	SELECT
	  issue_id AS issue_id,
	  journal_detail_old_value AS from_status_id,
	  LAG(journals_created_on,1,issue_created_on) OVER window_status AS from_status_date,
	  journal_detail_value AS to_status_id,
	  journals_created_on AS to_status_date	FROM sla_view_journal_statuses
	WINDOW window_status AS ( PARTITION BY issue_id ORDER BY journals_created_on ASC )
) UNION (
  -- To always have the last status change with issue closed or now
  SELECT
  	issue_id AS issue_id,
  	FIRST_VALUE(journal_detail_value) OVER window_status AS from_status_id,
  	FIRST_VALUE(journals_created_on) OVER window_status AS from_status_date,
  	FIRST_VALUE(journal_detail_value) OVER window_status AS to_status_id,
  	COALESCE(issue_closed_on,sla_get_date(NOW()::TIMESTAMP WITHOUT TIME ZONE)) AS to_status_date
  FROM sla_view_journal_statuses
  WINDOW window_status AS ( PARTITION BY issue_id ORDER BY journals_created_on DESC )
)