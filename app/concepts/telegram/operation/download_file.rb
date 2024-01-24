class Telegram::Operation::DownloadFile < ApplicationOperation
  step :prepare_file_data
  step :prepare_file_url
  step :get_file_data

  private

  def prepare_file_data(ctx, file_id:, **)
    ctx[:file_data] = Telegram.bots[:reminder].get_file(file_id: file_id)
  end

  def prepare_file_url(ctx, file_data:, **)
    token = Telegram.bots[:reminder].token
    ctx[:file_url] = "https://api.telegram.org/file/bot#{token}/#{file_data['result']['file_path']}"
  end

  def get_file_data(ctx, file_url:, **)
    ctx[:binary] = HTTParty.get(file_url).parsed_response
  end
end
