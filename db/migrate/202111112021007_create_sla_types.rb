class CreateSlaTypes < ActiveRecord::Migration[5.2]

  def change
    create_table :sla_types do |t|
      t.string :name, null: false

      t.index :name, unique: true, name: 'sla_types_name_ukey'
    end
    say "Created table sla_types"
  end

end
