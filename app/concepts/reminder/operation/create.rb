class Reminder::Operation::Create < ApplicationOperation
  step Subprocess(Parser::Operation::Request),
        In() => [ :message ],
        Out() => { reply: :reminder_data }
  step :validate_reminder_data
  fail :handle_invalid_reminder
  step :parse_date_time
  step :schedule_reminder
  step :create_reminder
  step :prepare_message

  private

  def validate_reminder_data(ctx, reminder_data:, **)
    return unless reminder_data.is_a?(Hash)
    reminder_data["date"].present? && reminder_data["time"].present? && reminder_data["action"].present?
  end

  def handle_invalid_reminder(ctx, reminder_data:, **)
    ctx[:result_message] = "Неверные данные: #{reminder_data}"
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
    ctx[:result_message] = "Напоминание создано: #{reminder.action} в #{reminder.scheduled_at}"
  end
end
