class Translator::Operation::Request < ApplicationOperation
  step :send_request
  step :extract_response

  private

  def send_request(ctx, text:, **)
    EtOrbi::EoTime
    ctx[:response] = HTTParty.post("http://localhost:5000/translate",
                                   body: {q: text, source: "ru", target: "en"}.to_json,
                                   headers: {"Content-Type" => "application/json"}).parsed_response
  end

  def extract_response(ctx, response:, **)
    ctx[:reply] = response["translatedText"]
  end
end
