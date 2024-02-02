class User < ApplicationRecord
  with_options dependent: :destroy do
    has_many :reminders
    has_many :regular_reminders
    has_many :birthdays
    has_many :products
    has_one :profile
  end


  validates :username, uniqueness: true
end
