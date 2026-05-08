class Admin::ExternalEventCandidateBulkAction
  attr_reader :action, :candidates

  def initialize(action:, candidates:)
    @action = action.to_s
    @candidates = candidates
  end

  def call
    count = 0

    candidates.find_each do |candidate|
      case action
      when "approve"
        EtkinlikIo::CandidatePublisher.new(candidate).call
      when "reject"
        candidate.update!(status: "rejected")
      when "skip"
        candidate.update!(status: "skipped")
      else
        next
      end

      count += 1
    end

    count
  end

  def approval_errors
    candidates.filter_map do |candidate|
      next if candidate.approved?

      event = EtkinlikIo::CandidatePublisher.new(candidate).preview_event
      next if event.valid?

      "#{candidate.title.presence || candidate.external_id}: #{event.errors.full_messages.to_sentence}"
    end
  end
end
