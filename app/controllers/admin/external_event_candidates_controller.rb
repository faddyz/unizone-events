class Admin::ExternalEventCandidatesController < ApplicationController
  PRESETS = [
    [ "complete", "Tam Uygun" ],
    [ "new", "Yeni Gelenler" ],
    [ "low_priority", "Dusuk Oncelik" ],
    [ "incomplete", "Eksik Bilgili" ],
    [ "approved", "Yayina Alinan" ],
    [ "skipped", "Gecilen" ],
    [ "rejected", "Reddedilen" ]
  ].freeze

  before_action :authenticate_user!
  before_action :authorize_index!
  before_action :set_candidate, only: [ :show, :approve, :reject, :skip ]

  def index
    @preset_tabs = PRESETS
    @preset = PRESETS.map(&:first).include?(params[:preset].to_s) ? params[:preset].to_s : "complete"
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
    @approval = approval_defaults(@candidate)
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
        redirect_to admin_external_event_candidates_path(preset: params[:preset], query: params[:query], per_page: per_page_param), alert: "Onaylanacak aday yok.", status: :see_other
        return
      end

      errors = bulk_approval_errors(candidates)
      if errors.present?
        redirect_to admin_external_event_candidates_path(preset: params[:preset], query: params[:query], per_page: per_page_param), alert: "Yayina alinamayan adaylar: #{errors.join(" ? ")}", status: :see_other
        return
      end

      count = 0
      candidates.find_each do |candidate|
        EtkinlikIo::CandidatePublisher.new(candidate).call
        count += 1
      end

      redirect_to admin_external_event_candidates_path(preset: params[:preset], query: params[:query], per_page: per_page_param), notice: "#{count} aday yayinlandi.", status: :see_other
      return
    end

    candidates = policy_scope(ExternalEventCandidate).where(id: Array(params[:candidate_ids]).reject(&:blank?))
    count = 0

    if candidates.blank?
      redirect_to admin_external_event_candidates_path(preset: params[:preset], query: params[:query], per_page: per_page_param), alert: "Once aday sec.", status: :see_other
      return
    end

    if action == "approve"
      errors = bulk_approval_errors(candidates)
      if errors.present?
        redirect_to admin_external_event_candidates_path(preset: params[:preset], query: params[:query], per_page: per_page_param), alert: "Yayina alinamayan adaylar: #{errors.join(" ? ")}", status: :see_other
        return
      end
    end

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

    redirect_to admin_external_event_candidates_path(preset: params[:preset], query: params[:query], per_page: per_page_param), notice: "#{count} aday guncellendi.", status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    redirect_to admin_external_event_candidates_path(preset: params[:preset], query: params[:query], per_page: per_page_param), alert: "Toplu islem durdu: #{error.record.errors.full_messages.to_sentence}", status: :see_other
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
    scope = policy_scope(ExternalEventCandidate).order(priority: :desc, starts_at: :asc, created_at: :desc)
    scope = apply_preset(scope, preset)
    if query.present?
      needle = "%#{query.downcase}%"
      scope = scope.where("LOWER(title) LIKE :query OR LOWER(venue) LIKE :query OR LOWER(city) LIKE :query", query: needle)
    end
    scope
  end

  def apply_preset(scope, preset)
    case preset.to_s
    when "complete"
      scope.pending.where.not(category: [ "theater", "family" ])
           .where.not(poster_url: [ nil, "" ])
           .where("starts_at IS NOT NULL AND (city IS NOT NULL OR venue_type = 'ONLINE') AND (venue IS NOT NULL OR venue_type = 'ONLINE') AND (ticket_url IS NOT NULL OR external_url IS NOT NULL)")
           .where("COALESCE(ends_at, starts_at) >= ?", Time.current)
    when "new"
      since = @last_run&.started_at || 24.hours.ago
      scope.pending.where("first_seen_at >= ? OR created_at >= ?", since, 24.hours.ago)
    when "low_priority"
      scope.where(status: %w[pending hidden expired])
           .where("category IN (?) OR hidden_reason = ?", %w[theater family community], "low_priority_category")
    when "incomplete"
      scope.pending.where("poster_url IS NULL OR poster_url = '' OR starts_at IS NULL OR category IS NULL OR (venue IS NULL AND venue_type != 'ONLINE') OR (ticket_url IS NULL AND external_url IS NULL)")
    when "approved", "skipped", "rejected"
      scope.where(status: preset)
    else
      scope.pending
    end
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

    params.require(:approval).permit(:title, :category, :city, :location, :description, :starts_at, :ends_at, :ticket_url, :external_url, :external_is_free)
  end

  def approval_defaults(candidate)
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
      external_is_free: mapped["external_is_free"]
    }
  end


  def per_page_param
    value = params[:per_page].to_i
    [ 20, 50, 100 ].include?(value) ? value : 20
  end

  def bulk_approval_errors(candidates)
    candidates.filter_map do |candidate|
      next if candidate.approved?

      event = EtkinlikIo::CandidatePublisher.new(candidate).preview_event
      next if event.valid?

      "#{candidate.title.presence || candidate.external_id}: #{event.errors.full_messages.to_sentence}"
    end
  end
end
