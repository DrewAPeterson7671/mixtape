class CreateJoinTableTrackTag < ActiveRecord::Migration[7.2]
  def change
    create_join_table :tracks, :tags do |t|
      t.index [:track_id, :tag_id], unique: true
      t.index [:tag_id, :track_id], unique: true
    end

    # Add foreign key constraints if necessary
    add_foreign_key :tags_tracks, :tracks
    add_foreign_key :tags_tracks, :tags
  end
end
