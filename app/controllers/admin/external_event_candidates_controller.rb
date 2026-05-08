require_dependency Rails.root.join("app/presenters/admin/external_event_candidate_index_presenter").to_s
require_dependency Rails.root.join("app/services/admin/external_event_candidate_bulk_workflow").to_s

class Admin::ExternalEventCandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_index!
  before_action :set_candidate, only: [ :show, :approve, :reject, :skip ]

  def index
    set_index_state
  end

  def show
    authorize @candidate
    @approval = Admin::ExternalEventCandidateApprovalDefaults.new(@candidate).to_h
  end

  def scan
    authorize ExternalEventCandidate, :scan?
    dry_run = ActiveModel::Type::Boolean.new.cast(params[:dry_run])
    run = EtkinlikIo::Scanner.new(scan_params.to_h, save: !dry_run).call
    action = dry_run ? "Dry-run tamamlandı" : "Tarama kaydedildi"
    redirect_to admin_external_event_candidates_path, notice: "#{action}: #{run.fetched_count} kayıt, #{run.new_candidate_count} yeni aday."
  rescue EtkinlikIo::Client::MissingTokenError
    redirect_to admin_external_event_candidates_path, alert: "ETKINLIK_API_TOKEN eksik. ENV veya api.env içinde tanımla."
  rescue EtkinlikIo::Client::Error => error
    redirect_to admin_external_event_candidates_path, alert: "Etkinlik.io isteği başarısız: #{error.message}"
  end

  def approve
    authorize @candidate, :approve?
    EtkinlikIo::CandidatePublisher.new(@candidate, approval_params.to_h).call
    redirect_back fallback_location: admin_external_event_candidate_path(@candidate), notice: "Etkinlik yayına alındı.", status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    redirect_back fallback_location: admin_external_event_candidate_path(@candidate), alert: "Yayına alma başarısız: #{error.record.errors.full_messages.to_sentence}", status: :see_other
  end

  def reject
    authorize @candidate, :reject?
    @candidate.update!(status: "rejected")
    redirect_back fallback_location: admin_external_event_candidates_path(preset: "rejected"), notice: "Aday reddedildi."
  end

  def skip
    authorize @candidate, :skip?
    @candidate.update!(status: "skipped")
    redirect_back fallback_location: admin_external_event_candidates_path(preset: "skipped"), notice: "Aday geçildi."
  end

  def bulk
    authorize ExternalEventCandidate, :bulk?
    result = bulk_workflow.call
    redirect_to candidate_index_location, result.to_h.compact.merge(status: :see_other)
  rescue ActiveRecord::RecordInvalid => error
    redirect_to candidate_index_location, alert: "Toplu islem durdu: #{error.record.errors.full_messages.to_sentence}", status: :see_other
  end

  def cleanup
    authorize ExternalEventCandidate, :cleanup?
    report = EtkinlikIo::CandidateCleanup.new.call
    redirect_to admin_external_event_candidates_path, notice: "Temizlik: #{report[:expired_marked]} expired, #{report[:pruned] + report[:expired_deleted]} silindi, #{report[:approved_payloads_stripped]} hafifletildi."
  end

  def reset_import_pool
    authorize ExternalEventCandidate, :reset_import_pool?
    deleted_count = policy_scope(ExternalEventCandidate).where.not(status: %w[approved skipped rejected]).delete_all
    redirect_to admin_external_event_candidates_path, notice: "Karar verilmemis havuz temizlendi: #{deleted_count} aday silindi."
  end

  private

  def authorize_index!
    authorize ExternalEventCandidate
  end

  def set_candidate
    @candidate = policy_scope(ExternalEventCandidate).find(params[:id])
  end

  def set_index_state
    @candidate_index = Admin::ExternalEventCandidateIndexPresenter.new(scope: policy_scope(ExternalEventCandidate), params: params)
    @preset_tabs = @candidate_index.preset_tabs
    @preset = @candidate_index.preset
    @query = @candidate_index.query
    @per_page = @candidate_index.per_page
    @stats = @candidate_index.stats
    @last_run = @candidate_index.last_run
    @recent_runs = @candidate_index.recent_runs
    @scan_city_options = @candidate_index.scan_city_options
    @scan_format_options = @candidate_index.scan_format_options
    @scan_category_options = @candidate_index.scan_category_options
    @candidates = @candidate_index.candidates
  end

  def filtered_candidates
    candidate_index.filtered_candidates
  end

  def filtered_candidates_scope(preset, query)
    candidate_index.filtered_candidates_scope(preset, query, last_run: @last_run)
  end

  def bulk_filtered_candidates_scope
    candidate_index.filtered_candidates_scope(params[:preset].to_s, params[:query].to_s.strip, last_run: nil)
  end

  def candidate_index
    @candidate_index ||= Admin::ExternalEventCandidateIndexPresenter.new(scope: policy_scope(ExternalEventCandidate), params: params)
  end

  def bulk_workflow
    Admin::ExternalEventCandidateBulkWorkflow.new(
      action: params[:bulk_action],
      candidate_ids: params[:candidate_ids],
      scope: policy_scope(ExternalEventCandidate),
      filtered_scope: bulk_filtered_candidates_scope
    )
  end

  def scan_params
    params.permit(
      :start_date,
      :end_date,
      :venue_type,
      :batch_size,
      :max_scan_limit,
      :include_low_priority,
      city_slugs: [],
      format_ids: [],
      category_ids: []
    )
  end

  def approval_params
    return {} unless params[:approval].present?

    params.require(:approval).permit(:title, :category, :city, :location, :description, :starts_at, :ends_at, :ticket_url, :external_url, :external_is_free, :editor_score)
  end

  def per_page_param
    value = params[:per_page].to_i
    [ 20, 50, 100 ].include?(value) ? value : 20
  end

  def candidate_index_location
    admin_external_event_candidates_path(
      preset: params[:preset],
      query: params[:query],
      per_page: per_page_param,
      page: params[:page].presence
    )
  end

end
