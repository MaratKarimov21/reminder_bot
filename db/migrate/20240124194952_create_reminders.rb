class CreateReminders < ActiveRecord::Migration[7.0]
  def change
    create_table :reminders do |t|
      t.references :user, null: false
      t.uuid :job_id, null: false
      t.string :action

      t.timestamps
    end
  end
end
