class Reminder::Operation::Create < ApplicationOperation
  pass :prepare_params
  pass Subprocess(Recognizer::Operation::Request), Out() => ->(ctx, **) { ctx[:reply] ? { message: ctx[:reply] } : {} }
  step Subprocess(Reminder::Operation::Preprocess), In() => { message: :string }, Out() => { string: :message }
  step Subprocess(Parser::Operation::Request), In() => [ :message ], Out() => { reply: :reminder_data }
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

  def create_reminder(ctx, reminder_data:, **)
    # return unless reminder_data.is_a?
    datetime = DateTime.parse("#{reminder_data["date"]} #{reminder_data["time"]} MSK") # TODO: Add timezone
    ctx[:debug][:parsed_datetime] = datetime
    ReminderJob.set(wait_until: datetime).perform_later(ctx[:model], reminder_data["action"])
  end

  def prepare_message(ctx, reminder_data:, **)
    ctx[:message] = "Напоминание создано: #{reminder_data["action"]} в #{reminder_data["time"]} #{reminder_data["date"]}"
  end
end
