class AddEpochIdToUserAlbumsAndUserTracks < ActiveRecord::Migration[7.2]
  def change
    add_reference :user_albums, :epoch, foreign_key: true, null: true
    add_reference :user_tracks, :epoch, foreign_key: true, null: true
  end
end
