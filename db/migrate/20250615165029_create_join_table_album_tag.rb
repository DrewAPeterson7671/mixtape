class CreateJoinTableAlbumTag < ActiveRecord::Migration[7.2]
  def change
      create_join_table :albums, :tags do |t|
      t.index [:album_id, :tag_id], unique: true
      t.index [:tag_id, :album_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :albums_tags, :albums
    add_foreign_key :albums_tags, :tags
  end
end
