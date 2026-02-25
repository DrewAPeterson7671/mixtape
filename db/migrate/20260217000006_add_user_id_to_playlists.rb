class AddUserIdToPlaylists < ActiveRecord::Migration[7.2]
  def change
    add_reference :playlists, :user, foreign_key: true
  end
end
