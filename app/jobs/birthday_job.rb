class BirthdayJob < ApplicationJob
  def perform(*)
    birthdays_at(Date.today).each do |birthday|
      Telegram.bots[:reminder].send_message(chat_id: birthday.user.telegram_id,
                                            text: "Сегодня день рождения празднует #{birthday.person}!")
    end

    birthdays_at(Date.today + 3.days).each do |birthday|
      Telegram.bots[:reminder].send_message(chat_id: birthday.user.telegram_id,
                                            text: "Через 3 дня день рождения празднует #{birthday.person}!")
    end

    birthdays_at(Date.today + 10.days).each do |birthday|
      Telegram.bots[:reminder].send_message(chat_id: birthday.user.telegram_id,
                                            text: "Через 10 дней день рождения празднует #{birthday.person}!")
    end
  end

  private

  def birthdays_at(date)
    Birthday.where("EXTRACT(MONTH FROM date) = ? AND EXTRACT(DAY FROM date) = ?", date.month, date.day)
  end
end
