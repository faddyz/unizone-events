PASSWORD = "password123"

USERS = [
  { email: "admin@example.com", name: "Avery Admin", admin: true },
  { email: "mina@example.com", name: "Mina Kaya" },
  { email: "leo@example.com", name: "Leo Arslan" },
  { email: "zeynep@example.com", name: "Zeynep Studio" },
  { email: "deniz@example.com", name: "Deniz Collective" },
  { email: "arya@example.com", name: "Arya Yilmaz" },
  { email: "can@example.com", name: "Can Sahin" },
  { email: "mel@example.com", name: "Melis Park" },
  { email: "member@example.com", name: "Jordan Member" },
  { email: "organizer@example.com", name: "Mina Organizer" }
].freeze

EVENTS = [
  {
    host: "mina@example.com",
    title: "Rooftop Indie Session",
    description: "A warm open-air night with local indie bands, sunset DJ breaks, and easy room to meet new people between sets.",
    location: "Kadikoy Rooftop",
    date: 4.days.from_now.change(hour: 20, min: 0),
    category: "music",
    price: 14,
    status: "published"
  },
  {
    host: "leo@example.com",
    title: "AI Builders Jam",
    description: "A fast-moving build night for students, founders, and curious makers turning rough ideas into working product demos.",
    location: "Levent Tech Loft",
    date: 6.days.from_now.change(hour: 18, min: 30),
    category: "technology",
    price: 0,
    status: "published"
  },
  {
    host: "zeynep@example.com",
    title: "Street Poster Walk",
    description: "Explore color, type, paste-ups, and tiny details across the neighborhood with a designer-led walk and coffee stop.",
    location: "Karakoy Square",
    date: 7.days.from_now.change(hour: 11, min: 0),
    category: "art",
    price: 8,
    status: "published"
  },
  {
    host: "deniz@example.com",
    title: "Late Night Vinyl Market",
    description: "Dig through crates, trade favorites, and stay for a compact DJ set built from records found during the night.",
    location: "Bomonti Hall",
    date: 9.days.from_now.change(hour: 21, min: 0),
    category: "party",
    price: 10,
    status: "published"
  },
  {
    host: "arya@example.com",
    title: "Creative Coding Picnic",
    description: "Bring a laptop, a blanket, and one visual idea. We will prototype playful sketches in a relaxed park setup.",
    location: "Macka Park",
    date: 11.days.from_now.change(hour: 15, min: 0),
    category: "workshop",
    price: 0,
    status: "published"
  },
  {
    host: "can@example.com",
    title: "Founder Breakfast Circle",
    description: "A focused morning table for early-stage makers to trade launch notes, user feedback, and honest next steps.",
    location: "Beyo Studio Cafe",
    date: 13.days.from_now.change(hour: 9, min: 30),
    category: "networking",
    price: 18,
    status: "published"
  },
  {
    host: "mel@example.com",
    title: "Open Court 3v3 Night",
    description: "Casual team rotation, music on the sideline, and a friendly bracket for players who want a little edge.",
    location: "Moda Courts",
    date: 15.days.from_now.change(hour: 19, min: 0),
    category: "sports",
    price: 5,
    status: "published"
  },
  {
    host: "mina@example.com",
    title: "Tiny Theater Lab",
    description: "Short experimental scenes, audience prompts, and an after-show hang for anyone interested in performance.",
    location: "Cihangir Black Box",
    date: 17.days.from_now.change(hour: 20, min: 30),
    category: "theater",
    price: 12,
    status: "published"
  },
  {
    host: "zeynep@example.com",
    title: "New Media Exhibition Night",
    description: "Interactive installations, projection rooms, and creator talks packed into one evening gallery route.",
    location: "Pera Studio",
    date: 20.days.from_now.change(hour: 19, min: 30),
    category: "exhibition",
    price: 9,
    status: "published"
  },
  {
    host: "leo@example.com",
    title: "Rails Product Night",
    description: "A practical evening for builders shipping polished Rails products with lifecycle-aware UX and server-rendered speed.",
    location: "Istanbul Design Hub",
    date: 23.days.from_now.change(hour: 19, min: 0),
    category: "technology",
    price: 0,
    status: "published"
  },
  {
    host: "deniz@example.com",
    title: "Campus Food Festival",
    description: "Student kitchens, pop-up stalls, local DJs, and enough tables to make the afternoon feel like a block party.",
    location: "Uni Garden",
    date: 26.days.from_now.change(hour: 14, min: 0),
    category: "festival",
    price: 6,
    status: "published"
  },
  {
    host: "arya@example.com",
    title: "Creator Crit Night",
    description: "Small-group feedback for designers, developers, photographers, and anyone trying to sharpen their next release.",
    location: "Galata Workroom",
    date: 29.days.from_now.change(hour: 18, min: 0),
    category: "education",
    price: 0,
    status: "published"
  },
  {
    host: "can@example.com",
    title: "Neighborhood Photo Sprint",
    description: "A timed photo challenge across side streets, ferry views, and night signs with a quick group review after.",
    location: "Besiktas Pier",
    date: 32.days.from_now.change(hour: 17, min: 30),
    category: "art",
    price: 4,
    status: "submitted"
  },
  {
    host: "mel@example.com",
    title: "Zero Waste Supper Club",
    description: "A community dinner built around smart prep, local ingredients, and practical habits you can keep using.",
    location: "Community Kitchen",
    date: 35.days.from_now.change(hour: 19, min: 0),
    category: "general",
    price: 16,
    status: "submitted"
  },
  {
    host: "zeynep@example.com",
    title: "Design Systems Mini Conf",
    description: "Talks and demos about component libraries, product consistency, and making teams faster without boring the interface.",
    location: "Salt Auditorium",
    date: 38.days.from_now.change(hour: 10, min: 0),
    category: "conference",
    price: 22,
    status: "submitted"
  },
  {
    host: "organizer@example.com",
    title: "Sunday Swap Draft",
    description: "A relaxed clothing and book swap that still needs final venue details before it can be reviewed.",
    location: "TBD",
    date: 42.days.from_now.change(hour: 13, min: 0),
    category: "general",
    price: 0,
    status: "draft"
  },
  {
    host: "mina@example.com",
    title: "Secret Warehouse Party",
    description: "A nightlife listing that needs clearer safety, access, and venue information before it can be published.",
    location: "Unconfirmed venue",
    date: 45.days.from_now.change(hour: 22, min: 0),
    category: "party",
    price: 20,
    status: "rejected",
    review_note: "Add the confirmed venue, entry details, age policy, and crowd-safety information before submitting again."
  },
  {
    host: "leo@example.com",
    title: "Cancelled: Hardware Hack Table",
    description: "This event was cancelled after the host lost access to the venue.",
    location: "Maker Garage",
    date: 8.days.from_now.change(hour: 18, min: 0),
    category: "technology",
    price: 0,
    status: "cancelled"
  }
].freeze

def demo_user(email:, name:, admin: false)
  user = User.find_or_initialize_by(email: email)
  user.name = name
  user.admin = admin
  if user.encrypted_password.blank?
    user.password = PASSWORD
    user.password_confirmation = PASSWORD
  end
  user.save!
  user
end

def demo_event(users_by_email, attrs)
  host = users_by_email.fetch(attrs.fetch(:host))
  event = host.events.find_or_initialize_by(title: attrs.fetch(:title))
  status = attrs.fetch(:status)

  event.update!(
    description: attrs.fetch(:description),
    location: attrs.fetch(:location),
    date: attrs.fetch(:date),
    category: attrs.fetch(:category),
    price: attrs.fetch(:price),
    status: status,
    approved: status == "published",
    published_at: status == "published" ? (event.published_at || Time.current) : nil,
    review_note: attrs[:review_note]
  )

  event
end

users_by_email = USERS.to_h { |attrs| [attrs[:email], demo_user(**attrs)] }
events = EVENTS.map { |attrs| demo_event(users_by_email, attrs) }
active_users = users_by_email.values.reject(&:admin?)
rsvp_statuses = %w[going interested going going interested not_going]

events.select(&:published?).each_with_index do |event, event_index|
  active_users.each_with_index do |user, user_index|
    next if user == event.user
    next if (event_index + user_index).modulo(4).zero?

    attendance = Attendance.find_or_initialize_by(user: user, event: event)
    attendance.status = rsvp_statuses[(event_index + user_index) % rsvp_statuses.length]
    attendance.save!
  end
end

puts "Seeded Unizone demo data."
puts "Admin: admin@example.com / #{PASSWORD}"
puts "Sample user: member@example.com / #{PASSWORD}"
puts "Sample host: mina@example.com / #{PASSWORD}"
