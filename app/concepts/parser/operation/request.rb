module Parser
  module Operation
    class Request < ApplicationOperation
      step ->(ctx, message:, **) { message.present? }
      step Subprocess(GetAccessToken)
      step :prepare_body
      step :prepare_headers
      step :send_request
      step :extract_response

      private

      def prepare_body(ctx, message:, entity: :reminder, **)
        return unless message
        ctx[:body] = {
          "model": "GigaChat:latest",
          "temperature": 2,
          # "top_p": 0.47,
          "n": 1,
          "max_tokens": 512,
          "repetition_penalty": 1.07,
          "stream": false,
          "update_interval": 0,
          "messages": [
            {
              "role": "system",
              "content": I18n.t("chat.#{entity}",
                                today: Date.today,
                                tomorrow: Date.tomorrow,
                                time: Time.now.strftime("%H:%M"))
            },
            {
              "role": "user",
              "content": message
            }
          ]
        }.to_json
      end

      def prepare_headers(ctx, access_token:, **)
        ctx[:headers] = { "Authorization" => "Bearer #{access_token}"  }
      end

      def send_request(ctx, body:, headers:, **)
        response = HTTParty.post(Rails.application.credentials.dig(:sber, :chat_url), body: body, headers: headers)

        ctx[:response] = response.ok? ? response.body : nil.tap { debugify(ctx, :parser_error, response) }
      end

      def extract_response(ctx, response:, **)
        ctx[:raw_reply] = JSON.parse(response).dig("choices", 0, "message", "content").tap do |it|
          debugify(ctx, :parser_raw_reply, it)
        end
        ctx[:reply] = JSON.parse(ctx[:raw_reply]).tap { |it| debugify(ctx, :parser_reply, it) }
      rescue ParseError
        nil
      end
    end
  end
end
