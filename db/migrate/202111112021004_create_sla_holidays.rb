class CreateSlaHolidays < ActiveRecord::Migration[5.2]

  def change
    create_table :sla_holidays do |t|
      t.date :date, null: false
      t.text :name, null: false

      t.index :date, unique: true, name: 'sla_holidays_date_ukey'
    end
    say "Created table sla_holidays"
  end

end