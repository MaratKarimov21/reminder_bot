class Telegram::Operation::BuildRemindersList < ApplicationOperation
  step Model(User, :find_by, :username), Out() => { model: :user }
  step :find_reminders
  step :build_reply_markup

  private

  def find_reminders(ctx, user:, **)
    scheduled_job_ids = GoodJob::Job.scheduled.pluck(:id)
    ctx[:reminders] = user.reminders.where(job_id: scheduled_job_ids)
  end

  def build_reply_markup(ctx, reminders:, **)
    ctx[:reply_markup] = reminders.map { |r| [{ text: r.action, callback_data: "view_reminder:#{r.id}" }] }
  end
end
