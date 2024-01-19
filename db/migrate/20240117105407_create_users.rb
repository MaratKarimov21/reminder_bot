class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.bigint :telegram_id, null: false
      t.boolean :is_bot
      t.string :first_name
      t.string :last_name
      t.string :username, null: false
      t.string :language_code

      t.timestamps
    end
  end
end
