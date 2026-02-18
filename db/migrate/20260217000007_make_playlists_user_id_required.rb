class MakePlaylistsUserIdRequired < ActiveRecord::Migration[7.2]
  def change
    change_column_null :playlists, :user_id, false
  end
end
