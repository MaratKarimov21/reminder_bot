class RegularReminder < ApplicationRecord
  belongs_to :user
  belongs_to :job, class_name: "GoodJob::Job", optional: true

  delegate :scheduled_at, to: :job

  INTERVAL_TYPES = %w[single minute hour day monthday week month year]
  INTERVAL_TYPES_TRANSLATION = {
    "minute" => %w[минуту минуты минут],
    "hour" => %w[час часа часов],
    "day" => %w[день дня дней],
    "week" => %w[неделю недели недель],
    "month" => %w[месяц месяца месяцев],
    "year" => %w[год года лет]
  }

  validates :interval_type, inclusion: { in: INTERVAL_TYPES }

  def frequency
    return "Один раз" if interval_type == "single"
    return "каждое #{scheduled_at.day} число" if interval_type == "monthday"

    every = interval_type.in?(%w[minute week]) ? "каждую" : "каждый"

    case interval % 10
    when 1 then "#{every} #{INTERVAL_TYPES_TRANSLATION[interval_type][0]}"
    when 2..4 then "каждые #{interval} #{INTERVAL_TYPES_TRANSLATION[interval_type][1]}"
    else "каждые #{interval} #{INTERVAL_TYPES_TRANSLATION[interval_type][2]}"
    end
  end
end
