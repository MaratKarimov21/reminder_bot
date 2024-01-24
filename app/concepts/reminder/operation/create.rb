class Reminder::Operation::Create < ApplicationOperation
  pass :prepare_params
  pass Subprocess(Recognizer::Operation::Request), Out() => ->(ctx, **) { ctx[:reply] ? { message: ctx[:reply] } : {} }
  step Subprocess(Reminder::Operation::Preprocess), In() => { message: :string }, Out() => { string: :message }
  step Subprocess(Parser::Operation::Request), In() => [ :message ], Out() => { reply: :parsed_message }
  step Model(User, :find_by, :username)
  step :create_reminder
  step :prepare_message

  # step :send_reminder

  private

  def prepare_params(ctx, params:, **)
    return unless params[:username]
    ctx[:file_id] = params[:file_id]
    ctx[:message] = params[:message]
    ctx[:username] = params[:username]
  end

  def create_reminder(ctx, parsed_message:, **)
    puts (parsed_message["date"] + " " + parsed_message["time"])
    # return unless parsed_message.is_a?(Hash)
    datetime = DateTime.parse("#{parsed_message["date"]} #{parsed_message["time"]} MSK") # TODO: Add timezone

    ReminderJob.set(wait_until: datetime).perform_later(ctx[:model], parsed_message["action"])
  end

  def prepare_message(ctx, parsed_message:, **)
    ctx[:message] = "Напоминание создано: #{parsed_message["action"]} в #{parsed_message["time"]} #{parsed_message["date"]}"
  end
end
