class TelegramReminderController < Telegram::Bot::UpdatesController
  def start!(*)
    respond_with :message, text: 'Hello!'
  end

  def message(message)
    # puts message["file_id"].inspect
    # 'https://api.telegram.org/file/bot6873736492:AAFzurnuY2RKjCYSymvl5ReUYi6TF-OGAWI/voice/file_0.oga'
    # # file = Telegram.bots[:reminder].get_file(file_id: message["voice"]["file_id"])
    # puts file
    # puts from # {"id"=>1142352607, "is_bot"=>false, "first_name"=>"Марат", "last_name"=>"Каримов", "username"=>"MaRat_2112", "language_code"=>"ru"}
    # puts message["text"]
    # respond_with :message, text: "Иди нахуй"

    result =  GigaChat::Operations::Request.(params: { message: message["text"] })
    puts result[:reply]
    respond_with :message, text: result[:reply]
  end
end
