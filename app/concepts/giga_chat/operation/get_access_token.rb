module GigaChat
  module Operation
    class GetAccessToken < ApplicationOperation
      step :request_access_token
      step :extract_access_token

      private

      def request_access_token(ctx, **)

        ctx[:response] = Rails.cache.fetch("giga_chat_access_token", expires_in: 1.hour) do
          puts "request_access_token ggc"
          HTTParty.post(url, body: body, headers: headers).body
        end
        puts "access_token_set"
        true
      end

      def extract_access_token(ctx, **)
        ctx[:access_token] = JSON.parse(ctx[:response])["access_token"]
      end

      def url
        "https://ngw.devices.sberbank.ru:9443/api/v2/oauth"
      end

      def headers
        {
          "RqUID" => "6f0b1291-c7f3-43c6-bb2e-9f3efb2dc98e",
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Bearer NzMyNGY0MzgtNzFlYS00YjIzLWJmNjEtMTU0MmQxNjc5OTc1OmY1ZjFjZmIzLWU4M2UtNGIwYy1iZjQ5LTFkZGU0MWQ3MGU1Mg=="
        }
      end

      def body
        {
          "scope" => "GIGACHAT_API_PERS"
        }
      end
    end
  end
end