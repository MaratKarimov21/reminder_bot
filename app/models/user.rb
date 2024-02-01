class User < ApplicationRecord
  has_many :reminders
  has_many :regular_reminders
  has_many :birthdays
  has_many :products
  has_one :profile

  validates :username, uniqueness: true
end
