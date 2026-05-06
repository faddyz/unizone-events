class ImportRun < ApplicationRecord
  enum :status, {
    running: "running",
    completed: "completed",
    failed: "failed"
  }, default: :running, validate: true

  validates :source, :status, presence: true

  scope :recent, -> { order(started_at: :desc, created_at: :desc) }

  def finish!(attrs = {})
    update!(attrs.merge(status: "completed", finished_at: Time.current))
  end

  def fail!(message)
    update!(status: "failed", error_message: message.to_s.truncate(2_000), finished_at: Time.current)
  end
end
