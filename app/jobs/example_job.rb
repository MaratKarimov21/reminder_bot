class ExampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "Hello world!"
  end
end
