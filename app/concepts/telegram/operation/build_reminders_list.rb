class Telegram::Operation::BuildRemindersList < ApplicationOperation
  step Model(User, :find_by, :username), Out() => { model: :user }
  step :find_reminders
  step :map_reminders
  step :find_regular_reminders
  step :map_regular_reminders
  step :build_reply_markup

  private

  def find_reminders(ctx, user:, **)
    scheduled_job_ids = GoodJob::Job.scheduled.pluck(:id)
    ctx[:reminders] = user.reminders.where(job_id: scheduled_job_ids)
  end

  def map_reminders(ctx, reminders:, **)
    ctx[:mapped_reminders] = reminders.map do |r|
      [{ text: "#{r.action} #{r.scheduled_at.strftime("%d.%m.%Y %H:%M")}", callback_data: "view_reminder:#{r.id}" }]
    end
  end

  def find_regular_reminders(ctx, user:, **)
    ctx[:regular_reminders] = user.regular_reminders
  end

  def map_regular_reminders(ctx, regular_reminders:, **)
    ctx[:mapped_regular_reminders] = regular_reminders.map do |r|
      [{ text: "#{r.action} #{r.frequency}", callback_data: "view_regular_reminder:#{r.id}" }]
    end
  end

  def build_reply_markup(ctx, mapped_reminders: [], mapped_regular_reminders: [], **)
    ctx[:reply_markup] = {
      inline_keyboard: mapped_reminders + mapped_regular_reminders
    }
  end
end
