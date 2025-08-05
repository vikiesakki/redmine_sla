class CreateSlaCalendarHolidays < ActiveRecord::Migration[5.2]

  def change
    create_table :sla_calendar_holidays do |t|
      t.belongs_to :sla_calendar,
                   null: false,
                   foreign_key: {
                     name: 'sla_calendar_holidays_sla_calendars_fkey',
                     on_delete: :cascade
                   }
      t.belongs_to :sla_holiday,
                   null: false,
                   foreign_key: {
                     name: 'sla_calendar_holidays_sla_holidays_fkey',
                     on_delete: :cascade
                   }
      t.boolean :match, null: false, default: false
    end

    say "Created table sla_calendar_holidays"

    add_index :sla_calendar_holidays,
              [:sla_calendar_id, :sla_holiday_id],
              unique: true,
              name: 'sla_calendar_holidays_ukey'

    say "Created unique index sla_calendar_holidays_ukey"
  end

end