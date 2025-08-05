class CreateSlaLogs < ActiveRecord::Migration[5.2]

  def change
    reversible do |dir|
      dir.up do

        create_table :sla_logs do |t|
          t.belongs_to :project, null: true, foreign_key: { name: 'sla_logs_projects_fkey', on_delete: :cascade }
          t.belongs_to :issue, null: true, foreign_key: { name: 'sla_logs_issues_fkey', on_delete: :cascade }
          t.belongs_to :sla_level, null: true, foreign_key: { name: 'sla_logs_sla_levels_fkey', on_delete: :cascade }
          
          # MySQL ENUM column type directly defined here
          t.column :log_level, "ENUM('log_none', 'log_error', 'log_info', 'log_debug')", null: false

          t.text :description, null: false
        end

        say "Created table sla_logs with ENUM log_level"
      end

      dir.down do
        drop_table :sla_logs
        say "Dropped table sla_logs"
      end
    end
  end


end
