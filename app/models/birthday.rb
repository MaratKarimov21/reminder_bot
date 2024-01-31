class Birthday < ApplicationRecord
  belongs_to :user

  validates :person, :date, presence: true
end
