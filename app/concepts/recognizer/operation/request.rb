class Recognizer::Operation::Request < ApplicationOperation
  step :validate
  step Subprocess(Recognizer::Operation::GetAccessToken)
  step Subprocess(Telegram::Operation::DownloadFile), In() => [ :file_id ], Out() => { binary: :file }
  step :prepare_headers
  step :send_request
  step :extract_response

 private

  def validate(ctx, file_id:, **)
    file_id.present?
  end

  def prepare_headers(ctx, access_token:, **)
    ctx[:headers] = { "Authorization" => "Bearer #{access_token}", "Content-Type" => "audio/ogg;codecs=opus"  }
  end

  def send_request(ctx, file:, headers:, **)
    ctx[:response] = HTTParty.post(Rails.application.credentials.dig(:sber, :recognize_url),
                                   body: file, headers: headers).body
  end

  def extract_response(ctx, response:, **)
    ctx[:reply] = JSON.parse(response)["result"][0].tap { |it| debugify(ctx, :recognizer_reply, it) }
    true
  end
end
