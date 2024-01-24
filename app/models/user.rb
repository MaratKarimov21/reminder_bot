class User < ApplicationRecord
  has_many :reminders

  validates :username, uniqueness: true
end
