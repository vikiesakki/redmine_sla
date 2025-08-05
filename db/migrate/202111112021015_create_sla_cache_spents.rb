class CreateSlaCacheSpents < ActiveRecord::Migration[5.2]

  def change
    reversible do |dir|
      dir.up do
        create_table :sla_cache_spents do |t|
          t.belongs_to :sla_cache, null: false, foreign_key: { name: 'sla_cache_spents_sla_caches_fkey', on_delete: :cascade }
          t.belongs_to :project, null: false, foreign_key: { name: 'sla_caches_projects_fkey', on_delete: :cascade }
          t.belongs_to :issue, null: false, foreign_key: { name: 'sla_cache_spents_issues_fkey', on_delete: :cascade }
          t.belongs_to :sla_type, null: false, foreign_key: { name: 'sla_cache_spents_sla_types_fkey', on_delete: :cascade }
          t.integer :spent, null: false
          t.datetime :created_on, null: false, default: -> { 'CURRENT_TIMESTAMP' }
          t.datetime :updated_on, null: false, default: -> { 'CURRENT_TIMESTAMP' }
        end
        say "Created table sla_cache_spents"

        # Corrected indexes on sla_cache_spents (was mistakenly on sla_caches)
        add_index :sla_cache_spents, :project_id, name: 'sla_cache_spents_projects_key'
        add_index :sla_cache_spents, :issue_id, name: 'sla_cache_spents_issues_key'
        say "Created indexes on table sla_cache_spents"

        # Unique index on sla_cache_id and sla_type_id
        add_index :sla_cache_spents, [:sla_cache_id, :sla_type_id], unique: true, name: 'sla_cache_spents_sla_caches_sla_types_ukey', comment: "Important for upsert logic"
        say "Created unique index on table sla_cache_spents"

        # MySQL does NOT support 'USING INDEX' in ADD CONSTRAINT - skip this
        say "Unique constraint enforced by unique index sla_cache_spents_sla_caches_sla_types_ukey"

        execute File.read(File.expand_path('../../sql_functions/sla_get_spent.sql', __FILE__))
        say "Created function sla_get_spent"
      end

      dir.down do
        execute "DROP FUNCTION IF EXISTS sla_get_spent;"
        say "Dropped function sla_get_spent"

        drop_table :sla_cache_spents
        say "Dropped table sla_cache_spents"
      end
    end
  end


end
