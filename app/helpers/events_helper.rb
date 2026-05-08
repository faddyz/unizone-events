require "cgi"

module EventsHelper
  include Events::CategoryHelper
  include Events::PricingHelper
  include Events::ContentHelper
  include Events::ImageHelper
  include Events::LifecycleHelper
  include Events::FormHelper
  include Events::ExploreHelper
end
