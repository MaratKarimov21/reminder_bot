class Telegram::Operation::HandleMessage < ApplicationOperation

  REGULAR_REMINDER_WORDS = %w[каждый каждая каждое каждые каждую ежеминутно
                              ежежечасно ежедневно еженедельно ежемесячно ежегодно]
  REGULAR_REMINDER_REGEX = /\b(?:#{REGULAR_REMINDER_WORDS.join('|')})\b/i

  step :prepare_create_params
  pass Subprocess(Recognizer::Operation::Request),
       Out() => ->(ctx, **) { ctx[:reply] ? { message: ctx[:reply] } : {} }
  step Model(User, :find_by, :username)
  step Subprocess(Reminder::Operation::Preprocess),
       In() => { message: :string },
       Out() => { string: :message }
  step Nested(:decide_entity)


  private

  def prepare_create_params(ctx, params:, **)
    return unless params[:username]
    ctx[:file_id] = params[:file_id]
    ctx[:message] = params[:message]
    ctx[:username] = params[:username]
  end

  def decide_entity(ctx, message:, **)
    REGULAR_REMINDER_REGEX.match?(message) ? RegularReminder::Operation::Create : Reminder::Operation::Create
  end

end

