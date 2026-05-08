class Admin::ExternalEventCandidateBulkWorkflow
  Result = Struct.new(:notice, :alert, keyword_init: true)

  attr_reader :action, :candidate_ids, :scope, :filtered_scope

  def initialize(action:, candidate_ids:, scope:, filtered_scope:)
    @action = action.to_s
    @candidate_ids = Array(candidate_ids).reject(&:blank?)
    @scope = scope
    @filtered_scope = filtered_scope
  end

  def call
    return approve_filtered if action == "approve_filtered"

    candidates = scope.where(id: candidate_ids)
    return Result.new(alert: "Once aday sec.") if candidates.blank?

    bulk_action = Admin::ExternalEventCandidateBulkAction.new(action: action, candidates: candidates)
    errors = approval_errors_for(bulk_action)
    return Result.new(alert: approval_error_message(errors)) if errors.present?

    count = bulk_action.call

    Result.new(notice: "#{count} aday guncellendi.")
  end

  private

  def approve_filtered
    candidates = filtered_scope.pending
    return Result.new(alert: "Onaylanacak aday yok.") if candidates.blank?

    bulk_action = Admin::ExternalEventCandidateBulkAction.new(action: "approve", candidates: candidates)
    errors = bulk_action.approval_errors
    return Result.new(alert: approval_error_message(errors)) if errors.present?

    count = bulk_action.call

    Result.new(notice: "#{count} aday yayinlandi.")
  end

  def approval_errors_for(bulk_action)
    action == "approve" ? bulk_action.approval_errors : []
  end

  def approval_error_message(errors)
    "Yayina alinamayan adaylar: #{errors.join(" ? ")}"
  end
end
