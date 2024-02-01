class Profile < ApplicationRecord
  DEFAULTS = {
    morning_at: "08:00",
    afternoon_at: "13:00",
    evening_at: "18:00"
  }

  belongs_to :user

  validates :morning_at, :afternoon_at, :evening_at, presence: true

  def settings
    {
      morning_at: morning_at.strftime("%H:%M"),
      afternoon_at: afternoon_at.strftime("%H:%M"),
      evening_at: evening_at.strftime("%H:%M")
    }
  end
end
