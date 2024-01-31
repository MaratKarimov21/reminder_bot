module Recognizer
  module Operation
    class GetAccessToken < ApplicationOperation
      step :prepare_data
      step :request_access_token

      private

      def prepare_data(ctx, **)
        ctx[:url] = Rails.application.credentials.dig(:sber, :auth_url)
        ctx[:body] = { "scope" => "SALUTE_SPEECH_PERS" }
        ctx[:headers] = {
          "RqUID" => "6f0b1291-c7f3-43c6-bb2e-9f3efb2dc98e",
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Bearer #{Rails.application.credentials.dig(:sber, :recognize_token)}"
        }
      end

      def request_access_token(ctx, url:, body:, headers:, **)
        response = HTTParty.post(url, body: body, headers: headers)
        return unless response.ok?

        ctx[:access_token] = Rails.cache.fetch("recognizer_access_token", expires_in: 30.minutes) do
          ctx[:debug][:recognizer_access_token_requested] = true
          response.parsed_response["access_token"]
        end
      end
    end
  end
end
