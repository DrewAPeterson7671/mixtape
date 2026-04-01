require 'rails_helper'

RSpec.describe TestCleanupController, type: :controller do
  describe 'DELETE #destroy' do
    let(:e2e_user) { create(:user, email: 'e2e@test.com', name: 'E2E User') }
    let(:other_user) { create(:user) }

    it 'does not require authentication' do
      delete :destroy, as: :json
      expect(response).to have_http_status(:ok)
    end

    context 'when no E2E user exists' do
      it 'returns zero counts gracefully' do
        delete :destroy, as: :json

        expect(response).to have_http_status(:ok)
        deleted = JSON.parse(response.body)['deleted']
        expect(deleted['user_artists']).to eq(0)
        expect(deleted['user_albums']).to eq(0)
        expect(deleted['user_tracks']).to eq(0)
        expect(deleted['playlists']).to eq(0)
        expect(deleted['artists']).to eq(0)
        expect(deleted['albums']).to eq(0)
        expect(deleted['tracks']).to eq(0)
      end
    end

    context 'user join records' do
      it 'removes the E2E user\'s UserArtist records' do
        create(:user_artist, user: e2e_user, artist: create(:artist))

        expect { delete :destroy, as: :json }.to change(UserArtist, :count).by(-1)
      end

      it 'removes the E2E user\'s UserAlbum records' do
        create(:user_album, user: e2e_user, album: create(:album))

        expect { delete :destroy, as: :json }.to change(UserAlbum, :count).by(-1)
      end

      it 'removes the E2E user\'s UserTrack records' do
        create(:user_track, user: e2e_user, track: create(:track))

        expect { delete :destroy, as: :json }.to change(UserTrack, :count).by(-1)
      end

      it 'does not remove another user\'s join records' do
        artist = create(:artist)
        create(:user_artist, user: e2e_user, artist: artist)
        create(:user_artist, user: other_user, artist: artist)

        expect { delete :destroy, as: :json }.to change(UserArtist, :count).by(-1)
        expect(UserArtist.exists?(user: other_user, artist: artist)).to be true
      end
    end

    context 'orphaned catalog records' do
      it 'deletes artists only the E2E user had' do
        artist = create(:artist)
        create(:user_artist, user: e2e_user, artist: artist)

        expect { delete :destroy, as: :json }.to change(Artist, :count).by(-1)
        expect(Artist.exists?(artist.id)).to be false
      end

      it 'deletes albums only the E2E user had' do
        album = create(:album)
        create(:user_album, user: e2e_user, album: album)

        expect { delete :destroy, as: :json }.to change(Album, :count).by(-1)
        expect(Album.exists?(album.id)).to be false
      end

      it 'deletes tracks only the E2E user had' do
        track = create(:track)
        create(:user_track, user: e2e_user, track: track)

        expect { delete :destroy, as: :json }.to change(Track, :count).by(-1)
        expect(Track.exists?(track.id)).to be false
      end
    end

    context 'shared catalog records' do
      it 'keeps artists that another user also has' do
        artist = create(:artist)
        create(:user_artist, user: e2e_user, artist: artist)
        create(:user_artist, user: other_user, artist: artist)

        expect { delete :destroy, as: :json }.not_to change(Artist, :count)
        expect(Artist.exists?(artist.id)).to be true
      end

      it 'keeps albums that another user also has' do
        album = create(:album)
        create(:user_album, user: e2e_user, album: album)
        create(:user_album, user: other_user, album: album)

        expect { delete :destroy, as: :json }.not_to change(Album, :count)
        expect(Album.exists?(album.id)).to be true
      end

      it 'keeps tracks that another user also has' do
        track = create(:track)
        create(:user_track, user: e2e_user, track: track)
        create(:user_track, user: other_user, track: track)

        expect { delete :destroy, as: :json }.not_to change(Track, :count)
        expect(Track.exists?(track.id)).to be true
      end
    end

    context 'playlists' do
      it 'deletes the E2E user\'s playlists' do
        create(:playlist, user: e2e_user)

        expect { delete :destroy, as: :json }.to change(Playlist, :count).by(-1)
      end

      it 'does not delete another user\'s playlists' do
        create(:playlist, user: e2e_user)
        create(:playlist, user: other_user)

        expect { delete :destroy, as: :json }.to change(Playlist, :count).by(-1)
      end
    end

    context 'E2E user record' do
      it 'keeps the E2E user itself' do
        e2e_user # ensure created
        expect { delete :destroy, as: :json }.not_to change(User, :count)
        expect(User.exists?(e2e_user.id)).to be true
      end
    end

    context 'dependent sub-join records cascade' do
      it 'destroys UserArtistGenre and UserArtistTag via UserArtist' do
        artist = create(:artist)
        create(:user_artist, user: e2e_user, artist: artist)
        create(:user_artist_genre, user: e2e_user, artist: artist, genre: create(:genre, name: 'E2E Genre'))
        create(:user_artist_tag, user: e2e_user, artist: artist, tag: create(:tag, name: 'E2E Tag'))

        expect { delete :destroy, as: :json }
          .to change(UserArtistGenre, :count).by(-1)
          .and change(UserArtistTag, :count).by(-1)
      end

      it 'destroys UserAlbumGenre and UserAlbumTag via UserAlbum' do
        album = create(:album)
        create(:user_album, user: e2e_user, album: album)
        create(:user_album_genre, user: e2e_user, album: album, genre: create(:genre, name: 'E2E Genre'))
        create(:user_album_tag, user: e2e_user, album: album, tag: create(:tag, name: 'E2E Tag'))

        expect { delete :destroy, as: :json }
          .to change(UserAlbumGenre, :count).by(-1)
          .and change(UserAlbumTag, :count).by(-1)
      end

      it 'destroys UserTrackGenre and UserTrackTag via UserTrack' do
        track = create(:track)
        create(:user_track, user: e2e_user, track: track)
        create(:user_track_genre, user: e2e_user, track: track, genre: create(:genre, name: 'E2E Genre'))
        create(:user_track_tag, user: e2e_user, track: track, tag: create(:tag, name: 'E2E Tag'))

        expect { delete :destroy, as: :json }
          .to change(UserTrackGenre, :count).by(-1)
          .and change(UserTrackTag, :count).by(-1)
      end
    end

    context 'stray catalog records (E2E-prefixed with no user associations)' do
      it 'deletes E2E-prefixed artists with no user associations' do
        stray = create(:artist, name: 'E2E Stray Artist')

        expect { delete :destroy, as: :json }.to change(Artist, :count).by(-1)
        expect(Artist.exists?(stray.id)).to be false
      end

      it 'deletes E2E-prefixed albums with no user associations' do
        stray = create(:album, title: 'E2E Stray Album')

        expect { delete :destroy, as: :json }.to change(Album, :count).by(-1)
        expect(Album.exists?(stray.id)).to be false
      end

      it 'deletes E2E-prefixed tracks with no user associations' do
        stray = create(:track, title: 'E2E Stray Track')

        expect { delete :destroy, as: :json }.to change(Track, :count).by(-1)
        expect(Track.exists?(stray.id)).to be false
      end

      it 'keeps E2E-prefixed artists that another user has' do
        artist = create(:artist, name: 'E2E Shared Artist')
        create(:user_artist, user: other_user, artist: artist)

        expect { delete :destroy, as: :json }.not_to change(Artist, :count)
        expect(Artist.exists?(artist.id)).to be true
      end

      it 'keeps non-prefixed artists even with no user associations' do
        safe = create(:artist, name: 'Orphan Real Artist')

        expect { delete :destroy, as: :json }.not_to change(Artist, :count)
        expect(Artist.exists?(safe.id)).to be true
      end
    end

    context 'lookup records with prefix matching' do
      it 'deletes E2E-prefixed tags and keeps others' do
        create(:tag, name: 'E2E Tag')
        safe = create(:tag, name: 'Rock')

        expect { delete :destroy, as: :json }.to change(Tag, :count).by(-1)
        expect(Tag.exists?(safe.id)).to be true
      end

      it 'deletes E2F-prefixed genres and keeps others' do
        create(:genre, name: 'E2F Genre')
        safe = create(:genre, name: 'Jazz')

        expect { delete :destroy, as: :json }.to change(Genre, :count).by(-1)
        expect(Genre.exists?(safe.id)).to be true
      end

      it 'deletes E2E-prefixed editions' do
        create(:edition, name: 'E2E Edition')
        expect { delete :destroy, as: :json }.to change(Edition, :count).by(-1)
      end

      it 'deletes E2E-prefixed media' do
        create(:medium, name: 'E2E Medium')
        expect { delete :destroy, as: :json }.to change(Medium, :count).by(-1)
      end

      it 'deletes E2E-prefixed phases' do
        create(:phase, name: 'E2E Phase')
        expect { delete :destroy, as: :json }.to change(Phase, :count).by(-1)
      end

      it 'deletes E2E-prefixed priorities' do
        create(:priority, name: 'E2E Priority')
        expect { delete :destroy, as: :json }.to change(Priority, :count).by(-1)
      end

      it 'deletes E2E-prefixed release types' do
        create(:release_type, name: 'E2E ReleaseType')
        expect { delete :destroy, as: :json }.to change(ReleaseType, :count).by(-1)
      end
    end

    context 'started_after parameter' do
      it 'skips join records created before started_after' do
        ua = create(:user_artist, user: e2e_user, artist: create(:artist))
        future = (ua.created_at + 1.second).iso8601

        expect { delete :destroy, params: { started_after: future }, as: :json }
          .not_to change(UserArtist, :count)
      end

      it 'deletes join records created at or after started_after' do
        create(:user_artist, user: e2e_user, artist: create(:artist))
        past = 1.minute.ago.iso8601

        expect { delete :destroy, params: { started_after: past }, as: :json }
          .to change(UserArtist, :count).by(-1)
      end

      it 'skips E2E-prefixed lookups created before started_after' do
        tag = create(:tag, name: 'E2E Old Tag')
        future = (tag.created_at + 1.second).iso8601

        expect { delete :destroy, params: { started_after: future }, as: :json }
          .not_to change(Tag, :count)
      end

      it 'deletes E2E-prefixed lookups created at or after started_after' do
        create(:tag, name: 'E2E New Tag')
        past = 1.minute.ago.iso8601

        expect { delete :destroy, params: { started_after: past }, as: :json }
          .to change(Tag, :count).by(-1)
      end

      it 'skips stray catalog records created before started_after' do
        artist = create(:artist, name: 'E2E Old Stray')
        future = (artist.created_at + 1.second).iso8601

        expect { delete :destroy, params: { started_after: future }, as: :json }
          .not_to change(Artist, :count)
      end

      it 'deletes stray catalog records created at or after started_after' do
        create(:artist, name: 'E2E New Stray')
        past = 1.minute.ago.iso8601

        expect { delete :destroy, params: { started_after: past }, as: :json }
          .to change(Artist, :count).by(-1)
      end

      it 'works without started_after (deletes all matching records)' do
        create(:user_artist, user: e2e_user, artist: create(:artist))
        create(:tag, name: 'E2E Tag')
        create(:artist, name: 'E2E Stray')

        delete :destroy, as: :json

        deleted = JSON.parse(response.body)['deleted']
        expect(deleted['user_artists']).to eq(1)
        expect(deleted['tags']).to eq(1)
        expect(deleted['artists']).to eq(2)
      end
    end

    context 'response JSON' do
      it 'returns correct counts for all record types' do
        artist = create(:artist)
        album = create(:album)
        track = create(:track)
        create(:user_artist, user: e2e_user, artist: artist)
        create(:user_album, user: e2e_user, album: album)
        create(:user_track, user: e2e_user, track: track)
        create(:playlist, user: e2e_user)
        create(:tag, name: 'E2E Tag')
        create(:genre, name: 'E2E Genre')
        create(:edition, name: 'E2E Edition')
        create(:medium, name: 'E2E Medium')
        create(:phase, name: 'E2E Phase')
        create(:priority, name: 'E2E Priority')
        create(:release_type, name: 'E2E ReleaseType')

        delete :destroy, as: :json

        expect(response).to have_http_status(:ok)
        deleted = JSON.parse(response.body)['deleted']
        expect(deleted['user_artists']).to eq(1)
        expect(deleted['user_albums']).to eq(1)
        expect(deleted['user_tracks']).to eq(1)
        expect(deleted['playlists']).to eq(1)
        expect(deleted['artists']).to eq(1)
        expect(deleted['albums']).to eq(1)
        expect(deleted['tracks']).to eq(1)
        expect(deleted['tags']).to eq(1)
        expect(deleted['genres']).to eq(1)
        expect(deleted['editions']).to eq(1)
        expect(deleted['media']).to eq(1)
        expect(deleted['phases']).to eq(1)
        expect(deleted['priorities']).to eq(1)
        expect(deleted['release_types']).to eq(1)
      end

      it 'reports zero for shared catalog records that survive' do
        artist = create(:artist)
        create(:user_artist, user: e2e_user, artist: artist)
        create(:user_artist, user: other_user, artist: artist)

        delete :destroy, as: :json

        deleted = JSON.parse(response.body)['deleted']
        expect(deleted['user_artists']).to eq(1)
        expect(deleted['artists']).to eq(0)
      end
    end
  end
end
