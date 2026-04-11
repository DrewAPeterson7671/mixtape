class AddAttributesAndRelatedArtistsToArtists < ActiveRecord::Migration[7.2]
  def change
    add_column :artists, :notes, :text
    add_column :artists, :wikipedia, :text
    add_column :artists, :official_page, :text
    add_column :artists, :bandcamp, :text
    add_column :artists, :last_fm, :text
    add_column :artists, :google_genre_link, :text
    add_column :artists, :all_music, :text
    add_column :artists, :all_music_discography, :text

    create_table :related_artists, id: false do |t|
      t.bigint :artist_id, null: false
      t.bigint :related_artist_id, null: false
    end

    add_index :related_artists, [:artist_id, :related_artist_id], unique: true
    add_index :related_artists, [:related_artist_id, :artist_id], unique: true
    add_foreign_key :related_artists, :artists, column: :artist_id
    add_foreign_key :related_artists, :artists, column: :related_artist_id
  end
end
