class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :job, class_name: "GoodJob::Job"

  delegate :scheduled_at, to: :job
end
