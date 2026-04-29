namespace :admin do
  desc "Create an admin user"
  task create: :environment do
    email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
    password = ENV.fetch("ADMIN_PASSWORD", "password123")

    user = User.find_or_initialize_by(email: email)
    user.name = ENV.fetch("ADMIN_NAME", "Unizone Admin")
    user.admin = true
    if user.encrypted_password.blank? || ENV["ADMIN_PASSWORD"].present?
      user.password = password
      user.password_confirmation = password
    end
    user.save!

    puts "Admin user ready: #{email}"
  end
end
