class CreateBirthdays < ActiveRecord::Migration[7.0]
  def change
    create_table :birthdays do |t|
      t.references :user, null: false, foreign_key: true
      t.string :person, null: false
      t.datetime :date, null: false

      t.timestamps
    end
  end
end
