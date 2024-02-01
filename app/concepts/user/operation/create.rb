class User::Operation::Create < ApplicationOperation
  step Model(User, :new, :username)
  step Contract::Build(constant: User::Contract::Create)
  step Contract::Validate()
  step Contract::Persist()
  step :create_profile

  private

  def create_profile(ctx, model:, **)
    ctx[:profile] = model.build_profile(Profile::DEFAULTS).save
  end
end
