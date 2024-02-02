class Telegram::Operation::BuildReminderReplyMarkup < ApplicationOperation
  step :build

  private

  def build(ctx, reminder:, **)
    entity = reminder.class == Reminder ? "reminder" : "regular_reminder"
    ctx[:reply_markup] = {
      inline_keyboard: [ [
                           { text: "✅", callback_data: "accept_#{entity}:#{reminder.id}" },
                           { text: "🗑", callback_data: "cancel_#{entity}:#{reminder.id}" },
                           { text: "✏️", callback_data: "edit_#{entity}:#{reminder.id}" }
                         ] ]
    }
  end
end
