class CreateSlaCalendars < ActiveRecord::Migration[5.2]

  def change
    create_table :sla_calendars do |t|
      t.text :name, null: false
      t.datetime :created_on, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_on, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      # NOTE: MySQL can't create indexes on TEXT columns without length
      # If you're using MySQL and need uniqueness, consider changing `name` to `string` (varchar)
    end
    # If you still want to index `name`, change to `string` OR add a prefix length
    # t.string :name, null: false # preferred for indexing in MySQL
    # MySQL can't index TEXT without prefix length, so this will error unless name is string
    add_index :sla_calendars, :name, unique: true, name: 'sla_calendars_name_ukey'
  end

end
