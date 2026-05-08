module Events
  module ExploreHelper
    def explore_filter_params_with(overrides = {})
      next_params = request.query_parameters.slice(
        "query",
        "city",
        "category",
        "date",
        "date_filter",
        "start_date",
        "end_date",
        "time_filter",
        "price_filter",
        "availability_filter",
        "registration_filter",
        "hide_started",
        "sort_by",
        "view"
      )

      overrides.each do |key, value|
        key = key.to_s
        if value.blank?
          next_params.delete(key)
        else
          next_params[key] = value
        end
      end

      next_params
    end

    def explore_events_progress_text(events)
      total_count = events.total_count.to_i
      shown_count = [ events.current_page.to_i * events.limit_value.to_i, total_count ].min

      if shown_count >= total_count
        "#{total_count} etkinliğin tamamı gösteriliyor"
      else
        "1–#{shown_count} / #{total_count} etkinlik gösteriliyor"
      end
    end

    def explore_filter_remove_params(filter)
      next_params = explore_filter_params_with
      key = filter[:key].to_s

      if key == "category" && next_params["category"].is_a?(Array)
        categories = next_params["category"].reject { |category| category.to_s == filter[:value].to_s }
        categories.any? ? next_params["category"] = categories : next_params.delete("category")
      else
        next_params.delete(key)
      end

      next_params
    end

  end
end
