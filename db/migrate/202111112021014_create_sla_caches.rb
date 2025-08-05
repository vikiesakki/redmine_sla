class CreateSlaCaches < ActiveRecord::Migration[5.2]

  def change
  reversible do |dir|

    dir.up do

      create_table :sla_caches, id: false do |t|
        t.bigint :id, null: false
        t.belongs_to :project, null: false, foreign_key: { name: 'sla_caches_projects_fkey', on_delete: :cascade }
        t.belongs_to :issue, null: false, foreign_key: { name: 'sla_caches_issues_fkey', on_delete: :cascade }
        t.belongs_to :tracker, null: false, foreign_key: { name: 'sla_caches_trackers_fkey', on_delete: :cascade }
        t.belongs_to :sla_level, null: false, foreign_key: { name: 'sla_caches_sla_levels_fkey', on_delete: :cascade }
        t.datetime :start_date, null: false
        t.datetime :created_on, null: false, default: -> { 'CURRENT_TIMESTAMP' }
        t.datetime :updated_on, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      end
      say "Created table sla_caches"

      # Add primary key on `id`
      execute "ALTER TABLE sla_caches ADD PRIMARY KEY (id);"

      # Add indexes
      add_index :sla_caches, :project_id, name: 'sla_caches_projects_key'
      say "Created index on table sla_caches"

      add_index :sla_caches, :issue_id, unique: true, name: 'sla_caches_issues_ukey'
      say "Created unique index on table sla_caches"

      # Note: MySQL does not support 'USING INDEX' in ALTER CONSTRAINT.
      # The unique index already acts as a constraint.
      say "Unique constraint enforced by unique index sla_caches_issues_ukey"

      # Execute MySQL-compatible functions (make sure these SQL files are compatible)
      execute File.read(File.expand_path('../../sql_functions/sla_get_level_overlap.sql', __FILE__))
      say "Created function sla_get_level_overlap"

      execute File.read(File.expand_path('../../sql_functions/sla_get_level.sql', __FILE__))
      say "Created function sla_get_level"
    end

    dir.down do
      execute "DROP FUNCTION IF EXISTS sla_get_level;"
      say "Dropped function sla_get_level"

      drop_table :sla_caches
      say "Dropped table sla_caches"
    end

  end
end


end
