class RegularReminder::Operation::Create < ApplicationOperation

  step Subprocess(Parser::Operation::Request),
       In() => ->(ctx, **) { { entity: :regular_reminder } },
       In() => [ :message ],
       Out() => { reply: :reminder_data }
  step :prepare_reminder_data
  left :handle_invalid_reminder
  step :parse_date_time
  step :create_reminder
  step :schedule_reminder
  step :update_reminder
  step Subprocess(Telegram::Operation::BuildReminderReplyMarkup)
  step :prepare_message

  private

  def prepare_reminder_data(ctx, reminder_data:, **)
    return unless reminder_data["action"] && reminder_data["type"]
    reminder_data.tap do |data|
      data["date"] = data["date"].presence || Date.today.strftime("%d.%m.%Y")
      data["time"] = data["time"].presence || Time.now.strftime("%H:%M")
      data["interval"] = data["interval"].to_i.zero? ? 1 : data["interval"].to_i
      data["type"] = data["type"].presence || "single"
    end
  end

  def handle_invalid_reminder(ctx, reminder_data:, **)
    ctx[:result_message] = "Неверные данные: #{reminder_data}"
  end

  def parse_date_time(ctx, reminder_data:, **)
    ctx[:parsed_datetime] = DateTime.parse("#{reminder_data["date"]} #{reminder_data["time"]} MSK")
  rescue
    nil
  end

  def create_reminder(ctx, model:, reminder_data:, **)
    ctx[:reminder] = model.regular_reminders.create(action: reminder_data["action"],
                                                    interval_type: reminder_data["type"],
                                                    interval: reminder_data["interval"])
  end

  def schedule_reminder(ctx, parsed_datetime:, reminder:, **)
    ctx[:job_id] = RegularReminderJob.set(wait_until: parsed_datetime).perform_later(reminder.id).job_id
  end

  def update_reminder(ctx, reminder:, job_id:, **)
    job = GoodJob::Job.find(job_id)
    reminder.update!(job: job)
  end

  def prepare_message(ctx, reminder:, **)
    ctx[:result_message] = "Напоминание создано: #{reminder.action} #{reminder.frequency}"
  end
end
