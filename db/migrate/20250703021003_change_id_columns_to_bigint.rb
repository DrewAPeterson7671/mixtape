class ChangeIdColumnsToBigint < ActiveRecord::Migration[7.2]
  def change
    change_column(:albums, :release_type_id, :bigint)
    change_column(:albums, :edition_id, :bigint)
    change_column(:albums, :media_id, :bigint)
    change_column(:artists, :priority_id, :bigint)
    change_column(:artists, :phase_id, :bigint)
    change_column(:playlists, :genre_id, :bigint)
    change_column(:tracks, :media_id, :bigint)
  end
end
