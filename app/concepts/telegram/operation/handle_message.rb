class Telegram::Operation::HandleMessage < ApplicationOperation

  REGULAR_REMINDER_WORDS = %w[каждый каждая каждое каждые каждую ежеминутно
                              ежежечасно ежедневно еженедельно ежемесячно ежегодно]
  REGULAR_REMINDER_REGEX = /\b(?:#{REGULAR_REMINDER_WORDS.join('|')})\b/i
  BIRTHDAY_REMINDER_REGEX = /\b(?:день рождения|дня рождения|дней рождения|день рождение| др )\b/i
  PRODUCT_REGEX = /\b(?:корзина|корзину|корзине|список продуктов|список покупок| в список|^купить|^нужно купить)\b/i

  step :prepare_params
  pass Subprocess(Recognizer::Operation::Request),
       Out() => ->(ctx, **) { ctx[:reply] ? { message: ctx[:reply] } : {} }
  step Model(User, :find_by, :username)
  step :prepare_tod_settings
  step Subprocess(Reminder::Operation::Preprocess),
       In() => { message: :string },
       In() => [:tod_settings],
       Out() => { string: :message }
  step Nested(:decide_entity)


  private

  def prepare_params(ctx, params:, **)
    return unless params[:username]
    ctx[:file_id] = params[:file_id]
    ctx[:message] = params[:message]
    ctx[:username] = params[:username]
  end

  def prepare_tod_settings(ctx, model:, **)
    ctx[:tod_settings] = model.profile.settings
  end

  def decide_entity(ctx, message:, **)
    return RegularReminder::Operation::Create if REGULAR_REMINDER_REGEX.match?(message)
    return Birthday::Operation::Create if BIRTHDAY_REMINDER_REGEX.match?(message)
    return Product::Operation::Create if PRODUCT_REGEX.match?(message)
    Reminder::Operation::Create
  end

end

