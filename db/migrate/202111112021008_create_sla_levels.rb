class CreateSlaLevels < ActiveRecord::Migration[5.2]

  def change
    create_table :sla_levels do |t|
      t.string :name, null: false
      t.belongs_to :sla,
                   null: false,
                   foreign_key: {
                     name: 'sla_levels_slas_fkey',
                     on_delete: :cascade
                   }
      t.belongs_to :sla_calendar,
                   null: false,
                   foreign_key: {
                     name: 'sla_levels_sla_calendars_fkey',
                     on_delete: :cascade
                   }
      t.belongs_to :custom_field,
                   null: true,
                   foreign_key: {
                     name: 'sla_levels_custom_fields_fkey',
                     on_delete: :cascade
                   }
      # Add the index separately (MySQL-safe)
      t.index :name, unique: true, name: 'sla_levels_name_ukey'
    end
    say "Created table sla_levels"
  end

end
