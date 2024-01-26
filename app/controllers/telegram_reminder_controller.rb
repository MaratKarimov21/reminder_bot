class TelegramReminderController < Telegram::Bot::UpdatesController
  include CallbackQueryContext
  include MessageContext
  include Session

  def start!(*)
    result = ::User::Operation::Create.wtf?(params: start_params)

    if result.success?
      respond_with :message, text: 'Hello!'
    end
  end

  def reminders!
    result = Telegram::Operation::BuildRemindersList.wtf?(params: { username: from["username"] })

    respond_with :message, text: "Заплвнированные напоминания", reply_markup: { inline_keyboard: result[:reply_markup] }
  end

  def message(message)
    # Telegram.bots[:reminder].send_chat_action(chat_id: message["chat"]["id"], action: "typing")
    # puts message["file_id"].inspect
    # 'https://api.telegram.org/file/bot6873736492:AAFzurnuY2RKjCYSymvl5ReUYi6TF-OGAWI/voice/file_0.oga'

    # result = Recognizer::Operation::Request.wtf?(params: { file_id: message["voice"]["file_id"] })
    # respond_with :message, text: result[:reply]
    # puts file
    # puts from # {"id"=>1142352607, "is_bot"=>false, "first_name"=>"Марат", "last_name"=>"Каримов", "username"=>"MaRat_2112", "language_code"=>"ru"}
    # puts message["text"]
    # respond_with :message, text: "Иди нахуй"
    result =  Reminder::Operation::Create.wtf?(params: {
      file_id: message.dig("voice", "file_id"),
      message: message["text"],
      username: from["username"]
    })
    if result.success?
      respond_with :message, text: result[:message], reply_markup: {
        inline_keyboard: [[
                            { text: "Ok", callback_data: "accept_reminder:#{result[:reminder].id}" },
                            { text: "Cancel", callback_data: "cancel_reminder:#{result[:reminder].id}" },
                            { text: "Edit", callback_data: "edit_reminder:#{result[:reminder].id}" }
                          ]]
      }
    else
      signal, (ctx, _) = result
      # puts signal.inspect
      respond_with :message, text: result[:message]
    end
    respond_with :message, text: result[:debug].to_json

    # respond_with :message, text: "result[:message]",
    #              reply_markup: {
    #                inline_keyboard: [[
    #                                    { text: "Ok", callback_data: "accept_reminder:1" },
    #                                    { text: "Cancel", callback_data: "cancel_reminder:1" },
    #                                    { text: "Edit", callback_data: "edit_reminder:1" }
    #                                  ]] }
  end


  def accept_reminder_callback_query(*args)
    edit_message :reply_markup, inline_keyboard: []
  end

  def edit_reminder_callback_query(id, *args)
    cancel_reminder(id)
    edit_message :reply_markup, inline_keyboard: []
    edit_message :text, text: "Повторите ваш запрос"
  end

  def cancel_reminder_callback_query(id, *args)
    cancel_reminder(id)
    edit_message :reply_markup, inline_keyboard: []
    edit_message :text, text: "Напоминание отменено"
  end

  def view_reminder_callback_query(id, *args)
    reminder = Reminder.find(id)
    respond_with :message, text: reminder.action, reply_markup: {
      inline_keyboard: [[
                          { text: "Ok", callback_data: "accept_reminder:#{reminder.id}" },
                          { text: "Cancel", callback_data: "cancel_reminder:#{reminder.id}" },
                          { text: "Edit", callback_data: "edit_reminder:#{reminder.id}" }
                        ]]
    }
  end

  private

  def cancel_reminder(id)
    Reminder::Operation::Cancel.wtf?(params: { id: id })
  end

  def start_params
    from.tap do |p|
      p[:telegram_id] = p.delete("id")
    end
  end
end
