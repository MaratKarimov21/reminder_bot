class User < ApplicationRecord
  has_many :reminders
  has_many :regular_reminders
  has_many :birthdays

  validates :username, uniqueness: true
end
