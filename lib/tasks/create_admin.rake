namespace :admin do
  desc "Create an admin user"
  task create: :environment do
    email = ENV["ADMIN_EMAIL"].to_s.strip
    password = ENV["ADMIN_PASSWORD"].to_s

    raise "ADMIN_EMAIL is required" if email.blank?

    user = User.find_or_initialize_by(email: email)
    user.name = ENV.fetch("ADMIN_NAME", "Unizone Admin")
    user.admin = true

    if user.encrypted_password.blank?
      raise "ADMIN_PASSWORD is required for a new user" if password.blank?
      user.password = password
      user.password_confirmation = password
    elsif password.present?
      user.password = password
      user.password_confirmation = password
    end

    user.save!

    puts "Admin user ready: #{email}"
  end
end
