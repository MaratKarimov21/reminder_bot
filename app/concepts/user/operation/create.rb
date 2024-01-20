class User::Operation::Create < ApplicationOperation
  step Model(User, :new, :username)
  step Contract::Build(constant: User::Contract::Create)
  step Contract::Validate()
  step Contract::Persist()
end
