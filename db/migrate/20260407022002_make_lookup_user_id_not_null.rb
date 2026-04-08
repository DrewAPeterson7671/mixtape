# frozen_string_literal: true

class MakeLookupUserIdNotNull < ActiveRecord::Migration[7.2]
  LOOKUP_TABLES = %i[genres tags editions media phases priorities release_types].freeze

  DEFAULT_LOOKUPS = {
    genres: %w[Rock Pop Jazz Classical Hip-Hop Electronic R&B Country Folk Metal Blues Reggae Punk Soul Funk],
    media: %w[CD Vinyl Digital Cassette Streaming],
    release_types: ["LP", "EP", "Single", "Compilation", "Live", "Soundtrack", "Box Set"],
    editions: %w[Standard Deluxe Remastered Limited Anniversary],
    phases: %w[Discovery Exploration Deep\ Dive Complete],
    priorities: %w[High Medium Low Backlog]
  }.freeze

  # User-scoped tables that reference lookups (have user_id for reassignment)
  USER_SCOPED_REFS = {
    genres: [
      { table: "user_artist_genres", fk: "genre_id", user_col: "user_id" },
      { table: "user_album_genres",  fk: "genre_id", user_col: "user_id" },
      { table: "user_track_genres",  fk: "genre_id", user_col: "user_id" },
      { table: "playlists",          fk: "genre_id", user_col: "user_id" }
    ],
    tags: [
      { table: "user_artist_tags", fk: "tag_id", user_col: "user_id" },
      { table: "user_album_tags",  fk: "tag_id", user_col: "user_id" },
      { table: "user_track_tags",  fk: "tag_id", user_col: "user_id" }
    ],
    editions: [
      { table: "user_albums", fk: "default_edition_id", user_col: "user_id" }
    ],
    phases: [
      { table: "user_artists", fk: "phase_id", user_col: "user_id" }
    ],
    priorities: [
      { table: "user_artists", fk: "priority_id", user_col: "user_id" }
    ]
  }.freeze

  # Catalog-scoped tables referencing lookups (no user_id — NULL out or delete)
  CATALOG_REFS = {
    tags: [
      { table: "playlists_tags", fk: "tag_id", action: :delete }
    ],
    editions: [
      { table: "album_tracks", fk: "edition_id", action: :nullify }
    ],
    media: [
      { table: "albums", fk: "medium_id", action: :nullify },
      { table: "tracks", fk: "medium_id", action: :nullify }
    ],
    release_types: [
      { table: "albums", fk: "release_type_id", action: :nullify }
    ]
  }.freeze

  def up
    user_ids = execute("SELECT id FROM users").map { |row| row["id"] }

    LOOKUP_TABLES.each do |table|
      # 1. Seed defaults for each existing user
      defaults = DEFAULT_LOOKUPS[table] || []
      user_ids.each do |uid|
        defaults.each do |name|
          execute <<~SQL.squish
            INSERT INTO #{table} (name, user_id, created_at, updated_at)
            VALUES (#{connection.quote(name)}, #{uid}, NOW(), NOW())
            ON CONFLICT DO NOTHING
          SQL
        end
      end

      # 2. Reassign user-scoped FK references from system records to user's own
      (USER_SCOPED_REFS[table] || []).each do |ref|
        # Reassign where a matching user record exists
        execute <<~SQL.squish
          UPDATE #{ref[:table]} t
          SET #{ref[:fk]} = sub.new_id
          FROM (
            SELECT t2.ctid AS row_ctid, l.id AS new_id
            FROM #{ref[:table]} t2
            JOIN #{table} sys ON sys.id = t2.#{ref[:fk]} AND sys.user_id IS NULL
            JOIN #{table} l   ON l.name = sys.name AND l.user_id = t2.#{ref[:user_col]}
          ) sub
          WHERE t.ctid = sub.row_ctid
        SQL

        # Delete rows that still reference system records (can't be reassigned)
        execute <<~SQL.squish
          DELETE FROM #{ref[:table]}
          WHERE #{ref[:fk]} IN (SELECT id FROM #{table} WHERE user_id IS NULL)
        SQL
      end

      # 3. Handle catalog-scoped references (no user_id to reassign from)
      (CATALOG_REFS[table] || []).each do |ref|
        if ref[:action] == :delete
          execute <<~SQL.squish
            DELETE FROM #{ref[:table]}
            WHERE #{ref[:fk]} IN (SELECT id FROM #{table} WHERE user_id IS NULL)
          SQL
        else
          execute <<~SQL.squish
            UPDATE #{ref[:table]}
            SET #{ref[:fk]} = NULL
            WHERE #{ref[:fk]} IN (SELECT id FROM #{table} WHERE user_id IS NULL)
          SQL
        end
      end

      # 4. Delete system records
      execute "DELETE FROM #{table} WHERE user_id IS NULL"

      # 5. Remove the system-name partial unique index
      remove_index table, name: "index_#{table}_on_name_system", if_exists: true

      # 6. Replace conditional per-user index with unconditional one
      remove_index table, name: "index_#{table}_on_name_user", if_exists: true
      add_index table, [:name, :user_id], unique: true, name: "index_#{table}_on_name_and_user_id"

      # 7. Make user_id NOT NULL
      change_column_null table, :user_id, false
    end
  end

  def down
    LOOKUP_TABLES.each do |table|
      change_column_null table, :user_id, true

      remove_index table, name: "index_#{table}_on_name_and_user_id", if_exists: true
      add_index table, [:name, :user_id], unique: true, name: "index_#{table}_on_name_user",
                                          where: "user_id IS NOT NULL"
      add_index table, [:name], unique: true, name: "index_#{table}_on_name_system",
                                where: "user_id IS NULL"
    end
  end
end
