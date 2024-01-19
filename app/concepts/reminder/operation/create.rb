class Reminder::Operation::Create < Trailblazer::Operation
  step Subprocess(Reminder::Operation::Preprocess), In() => {message: :string}, Out() => {string: :message}
  step Subprocess(GigaChat::Operation::Request)
  step Model(User, :find_by, :username)
  step :create_reminder
  step :prepare_message

  # step :send_reminder

  private

  def create_reminder(ctx, reply:, **)
    puts (reply["date"] + " " + reply["time"])
    # return unless reply.is_a?(Hash)
    datetime = DateTime.parse("#{reply["date"]} #{reply["time"]} MSK") # TODO: Add timezone

    ReminderJob.set(wait_until: datetime).perform_later(ctx[:model], reply["action"])
    GoodJob::Execution
  end

  def prepare_message(ctx, reply:, **)
    ctx[:message] = "Напоминание создано: #{reply["action"]} в #{reply["time"]} #{reply["date"]}"
  end

  # def send_reminder(ctx, message:, **)
  #   puts "send_reminder"
  #   Telegram.bots[:reminder].send_message(chat_id: ctx[:model].telegram_id, text: message)
  # end
end