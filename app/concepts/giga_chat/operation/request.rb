module GigaChat
  module Operation
    class Request < Trailblazer::Operation
      step Subprocess(GetAccessToken)
      step :prepare_body
      step :prepare_headers
      step :send_request
      step :extract_response

      private

      def prepare_body(ctx, message:, **)
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
              "content": "Будет присылатся пользовательский текст напоминания, например 'Напомни завтра в 4 сделать маникюр'. Нужно сформировать json куда распарсить данные, он содержит поля: action - событие или действие о котором нужно напомнить, date - дата события в формате ГГГГ-ММ-ДД с учетом что сейчас #{Date.today.to_s} среда, например завтра это #{Date.tomorrow.to_s}, time - время события в формате ЧЧ:ММ с учетом что сейчас #{Time.now.strftime("%k:%M")} например 'половина двенадцатого' - это 12:30 или 23:30 в зависимости от контекста, убедись что время и дата представлены в правильных числовых форматах"
            },
            {
              "role": "user",
              "content": message || "Привет, как дела?"
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
        response_message = JSON.parse(response).dig("choices", 0, "message", "content")
        ctx[:reply] = JSON.parse(response_message)

        puts ctx[:reply]
        true
      end
    end
  end
end