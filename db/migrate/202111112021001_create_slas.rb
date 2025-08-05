class CreateSlas < ActiveRecord::Migration[5.2]

  def change
    create_table :slas do |t|
      t.string :name, null: false
    end
  end
  add_index :slas, :name, unique: true, name: 'slas_name_ukey'

end
