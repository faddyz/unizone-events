class Admin::ExternalEventCandidateIndexPresenter
  PER_PAGE_OPTIONS = [ 20, 50, 100 ].freeze

  attr_reader :scope, :params

  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def preset_tabs
    Admin::ExternalEventCandidateFilter::PRESETS
  end

  def preset
    @preset ||= Admin::ExternalEventCandidateFilter.normalize_preset(params[:preset])
  end

  def query
    @query ||= params[:query].to_s.strip
  end

  def per_page
    @per_page ||= PER_PAGE_OPTIONS.include?(params[:per_page].to_i) ? params[:per_page].to_i : 20
  end

  def stats
    @stats ||= ExternalEventCandidate.status_counts
  end

  def last_run
    @last_run ||= import_runs.recent.first
  end

  def recent_runs
    @recent_runs ||= import_runs.recent.limit(4)
  end

  def scan_city_options
    @scan_city_options ||= EtkinlikIo::Catalog.city_options
  end

  def scan_format_options
    @scan_format_options ||= EtkinlikIo::Catalog.format_options
  end

  def scan_category_options
    @scan_category_options ||= EtkinlikIo::Catalog.category_options
  end

  def scan_category_groups
    @scan_category_groups ||= scan_category_options
      .map { |label, id, slug| { label: label, id: id, slug: slug, unizone_category: EtkinlikIo::Mapper.category_for_slug(slug) } }
      .group_by { |option| option[:unizone_category] }
  end

  def scan_unizone_category_options
    @scan_unizone_category_options ||= Event.categories.keys.filter_map do |category|
      options = scan_category_groups[category]
      [ category, options ] if options.present?
    end
  end

  def candidates
    @candidates ||= filtered_candidates.page(params[:page]).per(per_page)
  end

  def filtered_candidates
    filtered_candidates_scope(preset, query, last_run: last_run)
  end

  def filtered_candidates_scope(selected_preset, search_query, last_run:)
    Admin::ExternalEventCandidateFilter.new(
      scope: scope,
      preset: selected_preset,
      query: search_query,
      last_run: last_run
    ).results
  end

  private

  def import_runs
    ImportRun.where(source: ExternalEventCandidate::SOURCE_ETKINLIK_IO)
  end
end
