namespace :event_images do
  desc "Preprocess event image variants so public pages do not generate them on first view"
  task preprocess: :environment do
    processed_count = 0

    Event.with_attached_image.find_each do |event|
      next unless event.image.attached?

      processed_count += event.preprocess_image_variants
    end

    puts "Processed #{processed_count} event image variants."
  end
end
