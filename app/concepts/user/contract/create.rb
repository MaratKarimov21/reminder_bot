class User::Contract::Create < Reform::Form
  extend ActiveModel::ModelValidations

  property :telegram_id
  property :is_bot
  property :first_name
  property :last_name
  property :username
  property :language_code

  validates :telegram_id, :username, presence: true
end
