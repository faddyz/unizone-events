class Admin::ExternalEventCandidatesController < ApplicationController
  PRESETS = Admin::ExternalEventCandidateFilter::PRESETS

  before_action :authenticate_user!
  before_action :authorize_index!
  before_action :set_candidate, only: [ :show, :approve, :reject, :skip ]

  def index
    @preset_tabs = PRESETS
    @preset = Admin::ExternalEventCandidateFilter.normalize_preset(params[:preset])
    @query = params[:query].to_s.strip
    @per_page = per_page_param
    @stats = ExternalEventCandidate.status_counts
    @last_run = ImportRun.where(source: ExternalEventCandidate::SOURCE_ETKINLIK_IO).recent.first
    @recent_runs = ImportRun.where(source: ExternalEventCandidate::SOURCE_ETKINLIK_IO).recent.limit(4)
    @scan_city_options = EtkinlikIo::Catalog.city_options
    @scan_format_options = EtkinlikIo::Catalog.format_options
    @scan_category_options = EtkinlikIo::Catalog.category_options
    @candidates = filtered_candidates.page(params[:page]).per(@per_page)
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
    action = params[:bulk_action].to_s

    if action == "approve_filtered"
      candidates = filtered_candidates_scope(params[:preset].to_s, params[:query].to_s.strip).pending
      if candidates.blank?
        redirect_to candidate_index_location, alert: "Onaylanacak aday yok.", status: :see_other
        return
      end

      bulk_action = Admin::ExternalEventCandidateBulkAction.new(action: "approve", candidates: candidates)
      errors = bulk_action.approval_errors
      if errors.present?
        redirect_to candidate_index_location, alert: "Yayina alinamayan adaylar: #{errors.join(" ? ")}", status: :see_other
        return
      end

      count = bulk_action.call

      redirect_to candidate_index_location, notice: "#{count} aday yayinlandi.", status: :see_other
      return
    end

    candidates = policy_scope(ExternalEventCandidate).where(id: Array(params[:candidate_ids]).reject(&:blank?))

    if candidates.blank?
      redirect_to candidate_index_location, alert: "Once aday sec.", status: :see_other
      return
    end

    bulk_action = Admin::ExternalEventCandidateBulkAction.new(action: action, candidates: candidates)

    if action == "approve"
      errors = bulk_action.approval_errors
      if errors.present?
        redirect_to candidate_index_location, alert: "Yayina alinamayan adaylar: #{errors.join(" ? ")}", status: :see_other
        return
      end
    end

    count = bulk_action.call

    redirect_to candidate_index_location, notice: "#{count} aday guncellendi.", status: :see_other
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

  def filtered_candidates
    filtered_candidates_scope(@preset, @query)
  end

  def filtered_candidates_scope(preset, query)
    Admin::ExternalEventCandidateFilter.new(
      scope: policy_scope(ExternalEventCandidate),
      preset: preset,
      query: query,
      last_run: @last_run
    ).results
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
