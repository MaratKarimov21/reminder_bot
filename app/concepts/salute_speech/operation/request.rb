class SaluteSpeech::Operation::Request < Trailblazer::Operation
  step Subprocess(GetAccessToken)
  step :pull_file
  step :prepare_body
  step :prepare_headers
  step :send_request

  private

  def pull_file(ctx, **)
    ctx[:file] = File.read("salute_speech.txt")
  end


end