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

    respond_with :message, text: "Запланированные напоминания", reply_markup: { inline_keyboard: result[:reply_markup] }
  end

  def birthdays!
    result = Telegram::Operation::BuildBirthdaysList.wtf?(params: { username: from["username"] })

    respond_with :message, text: "Дни рождения", reply_markup: { inline_keyboard: result[:reply_markup] }
  end

  def cart!
    result = Telegram::Operation::BuildProductsList.wtf?(params: { username: from["username"] })
    puts result[:reply_markup]
    respond_with :message, text: "Ваш список покупок", reply_markup: result[:reply_markup]
  end

  def message(message)
    Telegram.bots[:reminder].send_chat_action(chat_id: message["chat"]["id"], action: "typing")
    # puts message["file_id"].inspect
    # 'https://api.telegram.org/file/bot6873736492:AAFzurnuY2RKjCYSymvl5ReUYi6TF-OGAWI/voice/file_0.oga'

    result =  Telegram::Operation::HandleMessage.wtf?(params: {
      file_id: message.dig("voice", "file_id"),
      message: message["text"],
      username: from["username"]
    })
    if result.success?
      message = result[:message] || "fail"
      reply_markup = result[:reply_markup] || reminder_reply_markup(result[:reminder])
      respond_with :message, text: result[:result_message], reply_markup: reply_markup
        # inline_keyboard: [ [
        #                      { text: "Ok", callback_data: "accept_reminder:#{result[:reminder].id}" },
        #                      { text: "Cancel", callback_data: "cancel_reminder:#{result[:reminder].id}" },
        #                      { text: "Edit", callback_data: "edit_reminder:#{result[:reminder].id}" }
        #                    ] ]
      # }
    else
      signal, (ctx, _) = result
      # puts signal.inspect
      respond_with :message, text: result[:result_message] || "fail"
    end
    respond_with :message, text: JSON.pretty_generate(result[:debug])
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
      inline_keyboard: [ [
                          { text: "Ok", callback_data: "accept_reminder:#{reminder.id}" },
                          { text: "Cancel", callback_data: "cancel_reminder:#{reminder.id}" },
                          { text: "Edit", callback_data: "edit_reminder:#{reminder.id}" }
                        ] ]
    }
  end

  def view_birthday_callback_query(id, *args)
    birthday = Birthday.find(id)
    edit_message :text, text: "#{birthday.person} #{birthday.date.strftime("%d.%m.%Y")}", reply_markup: {
      inline_keyboard: [ [
                          { text: "Delete", callback_data: "delete_birthday:#{birthday.id}" }
                        ] ]
    }
  end

  def delete_birthday_callback_query(id, *args)
    birthday = Birthday.find(id)
    birthday.destroy
    result = Telegram::Operation::BuildBirthdaysList.wtf?(params: { username: from["username"] })

    edit_message :text, text: "Дни рождения", reply_markup: { inline_keyboard: result[:reply_markup] }
  end

  def toggle_in_cart_callback_query(id, *args)
    product = Product.find(id)
    product.update(in_cart: !product.in_cart)
    reply_markup = Telegram::Operation::BuildProductsList.wtf?(params: { username: from["username"] })[:reply_markup]
    edit_message :reply_markup, reply_markup: reply_markup
  end

  def clean_cart_callback_query(_,*args)
    current_user.products.where(in_cart: true).destroy_all
    reply_markup = Telegram::Operation::BuildProductsList.wtf?(params: { username: from["username"] })[:reply_markup]
    edit_message :reply_markup, reply_markup: reply_markup
  end

  private

  def reminder_reply_markup(reminder)
    {
      inline_keyboard: [ [
                           { text: "Ok", callback_data: "accept_reminder:#{reminder.id}" },
                           { text: "Cancel", callback_data: "cancel_reminder:#{reminder.id}" },
                           { text: "Edit", callback_data: "edit_reminder:#{reminder.id}" }
                         ] ]
    }
  end

  def cancel_reminder(id)
    Reminder::Operation::Cancel.wtf?(params: { id: id })
  end

  def start_params
    from.tap do |p|
      p[:telegram_id] = p.delete("id")
    end
  end

  def current_user
    User.find_by(telegram_id: from["id"])
  end
end
