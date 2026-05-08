class Admin::ExternalEventCandidateApprovalDefaults
  attr_reader :candidate

  def initialize(candidate)
    @candidate = candidate
  end

  def to_h
    mapped = candidate.mapped_data.to_h
    {
      title: mapped["title"].presence || candidate.title,
      category: mapped["category"].presence || candidate.category,
      city: mapped["city"].presence || candidate.city,
      location: mapped["location"].presence || candidate.venue,
      description: mapped["description"],
      starts_at: candidate.starts_at,
      ends_at: candidate.ends_at,
      ticket_url: candidate.ticket_url,
      external_url: candidate.external_url,
      external_is_free: mapped["external_is_free"],
      editor_score: candidate.resolved_event&.editor_score
    }
  end
end
