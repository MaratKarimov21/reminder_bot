class ReminderJob < ApplicationJob
  def perform(user, message)
    Telegram.bots[:reminder].send_message(chat_id: user.telegram_id, text: message)
  end
end
