module SaluteSpeech
  module Operation
    class GetAccessToken < Trailblazer::Operation
      step :request_access_token
      step :extract_access_token

      private

      def request_access_token(ctx, **)
        puts "request_access_token"
        ctx[:response] = HTTParty.post(url, body: body, headers: headers).body
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
          "Authorization" => "Bearer OTM3YjQ5MWItM2Q0MC00MmM2LThiMmQtODMzYmZlYTBhMDhiOjBkNjQ2NmQ0LWFjNDQtNDNlNC1iZGU4LTZlY2MxYzAyNTliOQ=="
        }
      end

      def body
        {
          "scope" => "SALUTE_SPEECH_PERS"
        }
      end
    end
  end
end