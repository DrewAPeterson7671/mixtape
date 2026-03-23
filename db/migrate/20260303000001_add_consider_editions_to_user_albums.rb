class AddConsiderEditionsToUserAlbums < ActiveRecord::Migration[7.2]
  def change
    add_column :user_albums, :consider_editions, :boolean, default: false, null: false
  end
end
