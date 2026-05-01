namespace :events do
  desc "Warm optimized Active Storage variants for existing event images"
  task warm_image_variants: :environment do
    warmed = 0
    skipped = 0
    failed = 0

    Event.with_attached_image.find_each do |event|
      unless event.image.attached? && event.image.variable?
        skipped += 1
        next
      end

      Event::IMAGE_VARIANTS.each do |name, transformations|
        event.image.variant(transformations).processed
        warmed += 1
      rescue StandardError => error
        failed += 1
        warn "Event #{event.id} #{name} variant failed: #{error.class}: #{error.message}"
      end
    end

    puts "Warmed #{warmed} variants. Skipped #{skipped} events. Failed #{failed} variants."
  end
end
