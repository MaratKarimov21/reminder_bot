class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.time :morning_at
      t.time :afternoon_at
      t.time :evening_at

      t.timestamps
    end
  end
end
