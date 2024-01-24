class TelegramReminderController < Telegram::Bot::UpdatesController
  def start!(*)
    result = ::User::Operation::Create.wtf?(params: start_params)

    if result.success?
      respond_with :message, text: 'Hello!'
    end
  end

  def message(message)
    Telegram.bots[:reminder].send_chat_action(chat_id: message["chat"]["id"], action: "typing")
    # puts message["file_id"].inspect
    # 'https://api.telegram.org/file/bot6873736492:AAFzurnuY2RKjCYSymvl5ReUYi6TF-OGAWI/voice/file_0.oga'

    # result = Recognizer::Operation::Request.wtf?(params: { file_id: message["voice"]["file_id"] })
    # respond_with :message, text: result[:reply]
    # puts file
    # puts from # {"id"=>1142352607, "is_bot"=>false, "first_name"=>"Марат", "last_name"=>"Каримов", "username"=>"MaRat_2112", "language_code"=>"ru"}
    # puts message["text"]
    # respond_with :message, text: "Иди нахуй"
    result =  Reminder::Operation::Create.wtf?(params: { file_id: message.dig("voice", "file_id"), message: message["text"], username: from["username"] })
    if result.success?
      respond_with :message, text: result[:message]
    else
      signal, (ctx, _) = result
      # puts signal.inspect
    end

    # result = Parser::Operation::Request.wtf?(params: { file_id: message.dig("voice", "file_id"), message: message["text"] } )
    # if result.success?
    #   respond_with :message, text: result[:reply]
    # else
    #   signal, (ctx, _) = result
    #   puts signal.inspect
    # end
  end

  def start_params
    from[:telegram_id] = from.delete("id")
    from
  end
end
