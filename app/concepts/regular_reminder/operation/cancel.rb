class RegularReminder::Operation::Cancel < ApplicationOperation
  step Model(RegularReminder, :find)
  step :cancel_reminder

  private

  def cancel_reminder(ctx, model:, **)
    model.job.discard_job("canceled")
    model.destroy
  end
end
