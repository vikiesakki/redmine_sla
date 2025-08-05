CREATE OR REPLACE VIEW sla_view_roll_statuses AS

-- First and subsequent status changes
SELECT
  issue_id AS issue_id,
  journal_detail_old_value AS from_status_id,
  LAG(journals_created_on, 1, issue_created_on) OVER (
    PARTITION BY issue_id ORDER BY journals_created_on ASC
  ) AS from_status_date,
  journal_detail_value AS to_status_id,
  journals_created_on AS to_status_date
FROM sla_view_journal_statuses

UNION

-- Always include the final status change with closed_on or current time
SELECT
  issue_id AS issue_id,
  FIRST_VALUE(journal_detail_value) OVER (
    PARTITION BY issue_id ORDER BY journals_created_on DESC
  ) AS from_status_id,
  FIRST_VALUE(journals_created_on) OVER (
    PARTITION BY issue_id ORDER BY journals_created_on DESC
  ) AS from_status_date,
  FIRST_VALUE(journal_detail_value) OVER (
    PARTITION BY issue_id ORDER BY journals_created_on DESC
  ) AS to_status_id,
  COALESCE(issue_closed_on, sla_get_date(NOW())) AS to_status_date
FROM sla_view_journal_statuses;
