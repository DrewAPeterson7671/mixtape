# System lookup records (user_id: nil) — visible to all users, read-only.
# Idempotent: safe to run multiple times via find_or_create_by!.

genres = %w[Rock Pop Jazz Classical Hip-Hop Electronic R&B Country Folk Metal Blues Reggae Punk Soul Funk]
genres.each { |name| Genre.find_or_create_by!(name: name, user_id: nil) }
puts "Seeded #{genres.size} system genres"

media = %w[CD Vinyl Digital Cassette Streaming]
media.each { |name| Medium.find_or_create_by!(name: name, user_id: nil) }
puts "Seeded #{media.size} system media"

release_types = ["LP", "EP", "Single", "Compilation", "Live", "Soundtrack", "Box Set"]
release_types.each { |name| ReleaseType.find_or_create_by!(name: name, user_id: nil) }
puts "Seeded #{release_types.size} system release types"

editions = %w[Standard Deluxe Remastered Limited Anniversary]
editions.each { |name| Edition.find_or_create_by!(name: name, user_id: nil) }
puts "Seeded #{editions.size} system editions"

phases = %w[Discovery Exploration Deep\ Dive Complete]
phases.each { |name| Phase.find_or_create_by!(name: name, user_id: nil) }
puts "Seeded #{phases.size} system phases"

priorities = %w[High Medium Low Backlog]
priorities.each { |name| Priority.find_or_create_by!(name: name, user_id: nil) }
puts "Seeded #{priorities.size} system priorities"

# Tags are intentionally not seeded — they're too personal/subjective.
