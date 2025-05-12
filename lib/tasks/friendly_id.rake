namespace :friendly_id do
  desc "Generate slugs for existing events"
  task regenerate_slugs: :environment do
    puts "Generating slugs for existing events..."
    Event.find_each do |event|
      puts "Processing event ##{event.id}: #{event.title}"
      event.slug = nil
      event.save!
    end
    puts "Done!"
  end
end 