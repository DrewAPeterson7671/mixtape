class CreateJoinTableArtistTag < ActiveRecord::Migration[7.2]
  def change
    create_join_table :artists, :tags do |t|
      t.index [:artist_id, :tag_id], unique: true
      t.index [:tag_id, :artist_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :artists_tags, :artists
    add_foreign_key :artists_tags, :tags
  end
end
