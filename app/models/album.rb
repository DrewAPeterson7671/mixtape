class Album < ApplicationRecord
  has_and_belongs_to_many :artists
  has_many :album_tracks, dependent: :destroy
  has_many :tracks, through: :album_tracks
  belongs_to :medium, optional: true
  belongs_to :release_type, optional: true

  has_many :user_albums, dependent: :destroy
  has_many :users, through: :user_albums

  validates :title, presence: true
  validate :title_unique_per_artist

  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1500, less_than_or_equal_to: ->(_album) { Date.current.year } }, allow_nil: true

  def artist_name
    artists.map(&:name)
  end

  def release_type_name
    release_type&.name
  end

  def medium_name
    medium&.name
  end

  private

  def title_unique_per_artist
    if various_artists
      if Album.where(various_artists: true)
              .where("lower(title) = ?", title.to_s.downcase)
              .where.not(id: id)
              .exists?
        errors.add(:title, "already exists as a Various Artists album")
      end
    else
      artist_ids_to_check = artists.map(&:id).presence || []
      return if artist_ids_to_check.empty?

      artist_ids_to_check.each do |aid|
        if Album.joins(:artists)
                .where(artists: { id: aid })
                .where("lower(albums.title) = ?", title.to_s.downcase)
                .where.not(id: id)
                .exists?
          artist_name = Artist.find(aid).name
          errors.add(:title, "already exists for artist #{artist_name}")
          break
        end
      end
    end
  end
end
