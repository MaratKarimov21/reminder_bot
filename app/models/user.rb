class User < ApplicationRecord
  has_many :reminders
  has_many :regular_reminders
  has_many :birthdays
  has_many :products

  validates :username, uniqueness: true
end
