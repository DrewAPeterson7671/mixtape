class User < ApplicationRecord
  has_many :user_artists, dependent: :destroy
  has_many :user_albums, dependent: :destroy
  has_many :user_tracks, dependent: :destroy
  has_many :playlists, dependent: :destroy
  has_many :genres, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :editions, dependent: :destroy
  has_many :media, dependent: :destroy
  has_many :epochs, dependent: :destroy
  has_many :phases, dependent: :destroy
  has_many :priorities, dependent: :destroy
  has_many :release_types, dependent: :destroy

  after_create :seed_default_lookups

  private

  DEFAULT_GENRES = %w[Rock Pop Jazz Classical Hip-Hop Electronic R&B Country Folk Metal Blues Reggae Punk Soul Funk].freeze
  DEFAULT_MEDIA = %w[CD Vinyl Digital Cassette Streaming].freeze
  DEFAULT_RELEASE_TYPES = ["LP", "EP", "Single", "Compilation", "Live", "Soundtrack", "Box Set"].freeze
  DEFAULT_EDITIONS = %w[Standard Deluxe Remastered Limited Anniversary].freeze
  DEFAULT_PHASES = ["Discovery", "Exploration", "Deep Dive", "Complete"].freeze
  DEFAULT_PRIORITIES = %w[High Medium Low Backlog].freeze

  def seed_default_lookups
    DEFAULT_GENRES.each { |name| genres.create!(name: name) }
    DEFAULT_MEDIA.each { |name| media.create!(name: name) }
    DEFAULT_RELEASE_TYPES.each { |name| release_types.create!(name: name) }
    DEFAULT_EDITIONS.each { |name| editions.create!(name: name) }
    DEFAULT_PHASES.each { |name| phases.create!(name: name) }
    DEFAULT_PRIORITIES.each { |name| priorities.create!(name: name) }
  end
end
