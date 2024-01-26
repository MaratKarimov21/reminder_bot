class Reminder::Operation::Create < ApplicationOperation
  pass :prepare_create_params
  pass Subprocess(Recognizer::Operation::Request), Out() => ->(ctx, **) { ctx[:reply] ? { message: ctx[:reply] } : {} }
  step Subprocess(Reminder::Operation::Preprocess), In() => { message: :string }, Out() => { string: :message }
  step Subprocess(Parser::Operation::Request), In() => [ :message ], Out() => { reply: :reminder_data }
  step Model(User, :find_by, :username)
  step :validate_reminder_data
  fail :handle_invalid_reminder
  step :parse_date_time
  step :schedule_reminder
  step :create_reminder
  step :prepare_message

  # step :send_reminder

  private

  def prepare_create_params(ctx, params:, **)
    return unless params[:username]
    ctx[:file_id] = params[:file_id]
    ctx[:message] = params[:message]
    ctx[:username] = params[:username]
  end

  def validate_reminder_data(ctx, reminder_data:, **)
    return unless reminder_data.is_a?(Hash)
    reminder_data["date"].present? && reminder_data["time"].present? && reminder_data["action"].present?
  end

  def handle_invalid_reminder(ctx, reminder_data:, **)
    ctx[:message] = "Неверные данные: #{reminder_data}"
  end

  def parse_date_time(ctx, reminder_data:, **)
    ctx[:parsed_datetime] = DateTime.parse("#{reminder_data["date"]} #{reminder_data["time"]} MSK")
  end

  def schedule_reminder(ctx, parsed_datetime:, reminder_data:, **)
    ctx[:job_id] = ReminderJob.set(wait_until: parsed_datetime).perform_later(ctx[:model], reminder_data["action"]).job_id
  end

  def create_reminder(ctx, model:, reminder_data:, job_id:, **)
    job = GoodJob::Job.find(job_id)
    ctx[:reminder] = model.reminders.create(job: job, action: reminder_data["action"])
  end

  def prepare_message(ctx, reminder:, **)
    ctx[:message] = "Напоминание создано: #{reminder.action} в #{reminder.scheduled_at}"
  end
end
