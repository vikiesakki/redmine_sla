CREATE OR REPLACE VIEW sla_view_journal_statuses AS

-- First, get the initial status change or fallback to issue's status
SELECT DISTINCT
    issues.id AS issue_id,
    sla_get_date(FIRST_VALUE(issues.created_on) OVER (PARTITION BY issues.id ORDER BY journal_details.id)) AS issue_created_on,
    sla_get_date(FIRST_VALUE(issues.closed_on) OVER (PARTITION BY issues.id ORDER BY journal_details.id)) AS issue_closed_on,
    sla_get_date(FIRST_VALUE(issues.created_on) OVER (PARTITION BY issues.id ORDER BY journal_details.id)) AS journals_created_on,
    COALESCE(
      FIRST_VALUE(CAST(journal_details.old_value AS UNSIGNED)) OVER (PARTITION BY issues.id ORDER BY journal_details.id),
      issues.status_id
    ) AS journal_detail_old_value,
    COALESCE(
      FIRST_VALUE(CAST(journal_details.old_value AS UNSIGNED)) OVER (PARTITION BY issues.id ORDER BY journal_details.id),
      issues.status_id
    ) AS journal_detail_value
FROM issues
LEFT JOIN journals ON issues.id = journals.journalized_id
LEFT JOIN journal_details 
  ON journals.id = journal_details.journal_id 
 AND journal_details.property = 'attr'
 AND journal_details.prop_key = 'status_id'

UNION

-- Then add all explicit journal changes
SELECT
    issues.id AS issue_id,
    sla_get_date(issues.created_on) AS issue_created_on,
    sla_get_date(issues.closed_on) AS issue_closed_on,
    sla_get_date(journals.created_on) AS journals_created_on,
    CAST(journal_details.old_value AS UNSIGNED) AS journal_detail_old_value,
    CAST(journal_details.value AS UNSIGNED) AS journal_detail_value
FROM issues
INNER JOIN journals ON issues.id = journals.journalized_id
INNER JOIN journal_details 
  ON journals.id = journal_details.journal_id 
 AND journal_details.property = 'attr'
 AND journal_details.prop_key = 'status_id';
