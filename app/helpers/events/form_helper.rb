module Events
  module FormHelper
    def event_form_field_error?(model, attribute)
      model.errors[attribute].any?
    end

    def event_form_field_error_id(attribute)
      "event-#{attribute.to_s.tr("_", "-")}-error"
    end

    def event_form_field_error_message(model, attribute)
      model.errors.full_messages_for(attribute).to_sentence
    end

    def event_form_control_classes(model, attribute, base: "event-form-control")
      class_names(base, "is-invalid": event_form_field_error?(model, attribute))
    end

    def event_form_aria(model, attribute, describedby: nil)
      ids = [ describedby ]
      invalid = event_form_field_error?(model, attribute)
      ids << event_form_field_error_id(attribute) if invalid

      {
        invalid: invalid ? "true" : "false",
        describedby: ids.compact_blank.join(" ").presence
      }.compact
    end

  end
end
