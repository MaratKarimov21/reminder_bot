class SaluteSpeech::Operation::GetVoiceFile < ApplicationOperation
  step :prepare_file_data
  step :prepare_file_url
  step :get_file_data
  
  private
  
  def prepare_file_data(ctx, params:, **)
    ctx[:file_data] = Telegram.bots[:reminder].get_file(file_id: params[:file_id])
  end
  
  def prepare_file_url(ctx, file_data:, **)
    ctx[:file_url] = "https://api.telegram.org/file/bot6873736492:AAFzurnuY2RKjCYSymvl5ReUYi6TF-OGAWI/#{file_data['result']['file_path']}"
  end

  def get_file_data(ctx, file_url:, **)
    ctx[:binary] = HTTParty.get(file_url).parsed_response

  end
end