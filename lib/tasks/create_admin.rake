namespace :admin do
  desc "Create an admin user"
  task create: :environment do
    User.create!(
      email: "admin@example.com",
      password: "admin123",
      password_confirmation: "admin123",
      admin: true
    )
    puts "Admin user created."
  end
end
