class RegularReminder < ApplicationRecord
  belongs_to :user
  belongs_to :job, class_name: "GoodJob::Job", optional: true

  delegate :scheduled_at, to: :job

  INTERVAL_TYPES = %w[single minute hour day monthday week month year]

  validates :interval_type, inclusion: { in: INTERVAL_TYPES }
end
