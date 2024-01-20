class SaluteSpeech::Operation::Request < Trailblazer::Operation
  step Subprocess(SaluteSpeech::Operation::GetAccessToken)
  step Subprocess(SaluteSpeech::Operation::GetVoiceFile)
  step :prepare_headers
  step :send_request
  step :extract_response

  # SaluteSpeech::Operation::Request.(params: {file_id: "AwACAgIAAxkBAAPNZarGLZmt74McFMl_MbXwT-RhcUYAAsNCAALudlhJPnylX76OZyE0BA"})
  # eyJjdHkiOiJqd3QiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwiYWxnIjoiUlNBLU9BRVAtMjU2In0.GUerGHE4ssv74UZ-QW064zyNFhvFqo8mp0Gy7JSN-CuwPa3zFcP0B6CgrYaiHd8tOabMuW1YI09BkgMX_-YCGTuhzTU77YH_Ac_oLDsvm15M0C7aB2oezuOmzf-SbTDLoGw7QB5003JF38BUOVMHGq7T2WxD8Yv0CHV5fMZOCs3QutVEhw0AqaWNVDzZ9PyKwRjiD9zs7qz5TOEdVM0kw-tRzpcKzo_CZntFYqTOSOZuxYJj0IWTHUKZt7ekLJQW_lbm4diCv7gZyEUlfuxfV1DJRSNnJLicESory93OxUl_7lg_8ocKomg9RJmiixNDrQVkXa0_WH0ifQ-pCFHihQ.hYcbJGdkK6eQUuC8W3rjHQ._DhRlwXK_MFKwQNfYUsB_ousZ4dSwCITzUoqySwuVX4348hXgP1HhGLL7autb4pY7c5xJLTcOFM45ocIL8mN4e5twvcTJvf984Pbmxx3Meq0kN6gcOODwHApdXMka9urmozmsfsinVqn2wKs3clGe6GAL2po7PSZFs-hKWRDKnjbev-MFVSTYXDx5B3OxJ4oyPEkYpZ904qKutN9IIwxIAizQkXRra31ngq_RgXlpuNFqr3TUBmilOMkTDG3XPJh-sv4akj3uUpwZqAyqqnxZZAUeLcyjTT1smSMe7nb2wWLsS8yiEyOySgW9Nu2gwW-uOerjCCAqrbkm3QW0fNXNmSrDEO3Fri6dHXozrg1aHrL_VeQ8wW4xMqXJrLVZ6568cECXG_2eCGNE9jJRmOHkm0jLWJpSXu8EVBT14cUCWP0t18pLswl9kHIadZlszgKLZ-k43pcUAQ5z41N35lPPro-j_iAnPUSHy6nBlfa81Bi1roVot8OkR3tXar81b23dCQBhVhC4oCzngSawz2O44w4W0P2A06uZ6t8GhNvOP9Ui9YtFuGyUr7Q2hk3jcJfgV1fcQGAJ5PDO1TU_IMCNqWL_jJ2Rt9o1Z-_TvFoBt7BsI6tIxVjmTYYgAGdA7os2mVGynnDmSE_xLaDTRhGNC6RGiaMYiktUlZTf4NkgsXRKivN7rhEJXQXRckEfPBgIy1WqfnHZTLrlvHQ1mKkjvF8fS1HiXSuqnzW7uJxdMs.BM7lbiXXUoqmf5KuM5VuZe7zUF_xAOfDcyB6xU68zo0
  private

  def prepare_headers(ctx, access_token:, **)
    ctx[:headers] = { "Authorization" => "Bearer #{access_token}", "Content-Type" => "audio/ogg;codecs=opus"  }
  end

  def send_request(ctx, binary:, headers:, **)
    ctx[:response] = HTTParty.post("https://smartspeech.sber.ru/rest/v1/speech:recognize", body: binary, headers: headers).body
  end

  def extract_response(ctx, response:, **)
    ctx[:reply] = JSON.parse(response)["result"][0]
    true
  end
end
