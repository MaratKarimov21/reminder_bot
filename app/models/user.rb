class User < ApplicationRecord
  has_many :reminders
  has_many :regular_reminders

  validates :username, uniqueness: true
end
