class RegularReminderJob < ApplicationJob
  def perform(reminder_id)
    reminder = RegularReminder.find_by(id: reminder_id)
    return unless reminder
    send_message(reminder.action, reminder.user)
    return if reminder.interval_type == "single"
    job_id = schedule_next_reminder(reminder)
    reminder.update(job_id: job_id)
  rescue => e
    Rails.logger.error e
    puts e
  end

  private

  def send_message(text, user)
    Telegram.bots[:reminder].send_message(chat_id: user.telegram_id, text: text)
  end

  def schedule_next_reminder(reminder)
    next_time = reminder.interval.send(reminder.interval_type).from_now
    RegularReminderJob.set(wait_until: next_time).perform_later(reminder.id).job_id
  end
end
