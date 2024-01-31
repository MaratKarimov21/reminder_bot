class CreateRegularReminders < ActiveRecord::Migration[7.0]
  def change
    create_table :regular_reminders do |t|
      t.references :user, null: false, foreign_key: true
      t.uuid :job_id
      t.string :action
      t.string :interval_type
      t.integer :interval, default: 1

      t.timestamps
    end
  end
end
