module GigaChat
  module Operations
    class Request < Trailblazer::Operation
      step Subprocess(GetAccessToken)
      step :prepare_body
      step :prepare_headers
      step :send_request
      step :extract_response

      private

      def prepare_body(ctx, params:, **)
        ctx[:body] = {
          "model": "GigaChat:latest",
          "temperature": 0.87,
          "top_p": 0.47,
          "n": 1,
          "max_tokens": 512,
          "repetition_penalty": 1.07,
          "stream": false,
          "update_interval": 0,
          "messages": [
            {
              "role": "system",
              "content": "Действуй как переводчик, переводи на английский язык только то что тебе присылается",
            },
            {
              "role": "user",
              "content": params[:message] || "Привет, как дела?"
            }
          ]
        }.to_json
      end

      def prepare_headers(ctx, access_token:, **)
        ctx[:headers] = { "Authorization" => "Bearer #{access_token}"  }
      end

      def send_request(ctx, body:, headers:, **)
        url = "https://gigachat.devices.sberbank.ru/api/v1/chat/completions"
        ctx[:response] = HTTParty.post(url, body: body, headers: headers).body
      end

      def extract_response(ctx, response:, **)
        ctx[:reply] = JSON.parse(response).dig("choices", 0, "message", "content")
      end
    end
  end
end