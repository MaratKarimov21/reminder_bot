class Reminder::Operation::Update < Reminder::Operation::Create
  step :prepare_update_params, replace: :prepare_create_params
  step :find_reminder, replace: :schedule_reminder
  step :update_reminder, replace: :create_reminder

  private

  def prepare_update_params(ctx, params:, **)
    return unless params[:username] && params[:reminder_id]
    ctx[:file_id] = params[:file_id]
    ctx[:message] = params[:message]
    ctx[:username] = params[:username]
    ctx[:reminder_id] = params[:reminder_id]
  end

  def find_reminder(ctx, reminder_id:, **)
    ctx[:reminder] = Reminder.find(reminder_id)
  end

  def update_reminder(ctx, reminder:, reminder_data:, parsed_datetime:, **)
    reminder.update(action: reminder_data["action"])
    reminder.job.reschedule_job(parsed_datetime)
  end
end
