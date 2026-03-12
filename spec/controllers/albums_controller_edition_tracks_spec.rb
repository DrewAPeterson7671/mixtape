require 'rails_helper'

RSpec.describe AlbumsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'PUT #edition_tracks' do
    let(:album) { create(:album, title: 'OK Computer') }
    let(:edition) { create(:edition, name: 'Deluxe') }
    let(:track1) { create(:track, title: 'Airbag') }
    let(:track2) { create(:track, title: 'Paranoid Android') }
    let(:track3) { create(:track, title: 'Lucky') }

    before do
      create(:user_album, user: user, album: album)
    end

    it 'returns 401 when not authenticated' do
      session.delete(:user_id)
      put :edition_tracks, params: { id: album.id, edition_id: edition.id, tracks: [] }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'saves tracks to an edition with correct position and disc_number' do
      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track1.id, position: 1, disc_number: 1 },
          { track_id: track2.id, position: 2, disc_number: 1 }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      edition_tracks = json['album_tracks'].select { |at| at['edition_id'] == edition.id }
      expect(edition_tracks.length).to eq(2)

      t1 = edition_tracks.find { |at| at['track_id'] == track1.id }
      expect(t1['position']).to eq(1)
      expect(t1['disc_number']).to eq(1)

      t2 = edition_tracks.find { |at| at['track_id'] == track2.id }
      expect(t2['position']).to eq(2)
    end

    it 'removes tracks from edition by setting edition_id to null' do
      create(:album_track, album: album, track: track1, edition: edition, position: 1, disc_number: 1)
      create(:album_track, album: album, track: track2, edition: edition, position: 2, disc_number: 1)

      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track1.id, position: 1, disc_number: 1 }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
      # track2 should now be unsorted (edition_id nil)
      at = AlbumTrack.find_by(album: album, track: track2)
      expect(at.edition_id).to be_nil
      expect(at.position).to be_nil
    end

    it 'adds unsorted track to edition by updating existing null-edition album_track' do
      unsorted = create(:album_track, album: album, track: track1, edition: nil, position: nil)

      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track1.id, position: 1, disc_number: 1 }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
      unsorted.reload
      expect(unsorted.edition_id).to eq(edition.id)
      expect(unsorted.position).to eq(1)
      expect(unsorted.disc_number).to eq(1)
    end

    it 'creates new album_track when track is on another edition (no null-edition row)' do
      other_edition = create(:edition, name: 'Original')
      create(:album_track, album: album, track: track1, edition: other_edition, position: 1, disc_number: 1)

      expect {
        put :edition_tracks, params: {
          id: album.id,
          edition_id: edition.id,
          tracks: [
            { track_id: track1.id, position: 1, disc_number: 1 }
          ]
        }, as: :json
      }.to change(AlbumTrack, :count).by(1)

      expect(response).to have_http_status(:ok)
      # Track should now appear on both editions
      expect(AlbumTrack.where(album: album, track: track1).count).to eq(2)
    end

    it 'clears edition when given empty tracks array' do
      create(:album_track, album: album, track: track1, edition: edition, position: 1, disc_number: 1)
      create(:album_track, album: album, track: track2, edition: edition, position: 2, disc_number: 1)

      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: []
      }, as: :json

      expect(response).to have_http_status(:ok)
      # Both tracks should be unsorted now
      album.reload
      edition_tracks = album.album_tracks.where(edition_id: edition.id)
      expect(edition_tracks.count).to eq(0)

      [track1, track2].each do |track|
        at = AlbumTrack.find_by(album: album, track: track)
        expect(at.edition_id).to be_nil
      end
    end

    it 'returns 422 for non-consecutive disc numbers like [1, 3]' do
      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track1.id, position: 1, disc_number: 1 },
          { track_id: track2.id, position: 2, disc_number: 3 }
        ]
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to include('consecutive')
    end

    it 'accepts all null disc numbers as valid' do
      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track1.id, position: 1, disc_number: nil },
          { track_id: track2.id, position: 2, disc_number: nil }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'accepts consecutive disc numbers [1, 2] as valid' do
      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track1.id, position: 1, disc_number: 1 },
          { track_id: track2.id, position: 2, disc_number: 2 }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'preserves other editions when saving one edition' do
      other_edition = create(:edition, name: 'Original')
      create(:album_track, album: album, track: track1, edition: other_edition, position: 1, disc_number: 1)
      create(:album_track, album: album, track: track2, edition: other_edition, position: 2, disc_number: 1)

      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track3.id, position: 1, disc_number: 1 }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
      # Other edition's tracks should be untouched
      other_tracks = AlbumTrack.where(album: album, edition: other_edition)
      expect(other_tracks.count).to eq(2)
      expect(other_tracks.pluck(:track_id)).to contain_exactly(track1.id, track2.id)
    end

    it 'returns full album JSON with all album_tracks' do
      other_edition = create(:edition, name: 'Original')
      create(:album_track, album: album, track: track1, edition: other_edition, position: 1, disc_number: 1)

      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: [
          { track_id: track2.id, position: 1, disc_number: 1 }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to have_key('title')
      expect(json).to have_key('album_tracks')
      expect(json['album_tracks']).to be_an(Array)
      # Should include tracks from both editions
      track_ids = json['album_tracks'].map { |at| at['track_id'] }
      expect(track_ids).to include(track1.id, track2.id)
    end

    it 'handles saving unsorted tracks (null edition_id)' do
      create(:album_track, album: album, track: track1, edition: edition, position: 1, disc_number: 1)

      put :edition_tracks, params: {
        id: album.id,
        edition_id: nil,
        tracks: [
          { track_id: track2.id, position: 1, disc_number: nil }
        ]
      }, as: :json

      expect(response).to have_http_status(:ok)
      unsorted = AlbumTrack.find_by(album: album, track: track2, edition_id: nil)
      expect(unsorted).to be_present
      expect(unsorted.position).to eq(1)
    end

    it 'deletes edition-specific row when returning track that already has an unsorted row' do
      # Track has both an edition row and an unsorted row
      create(:album_track, album: album, track: track1, edition: nil, position: nil)
      edition_at = create(:album_track, album: album, track: track1, edition: edition, position: 1, disc_number: 1)

      put :edition_tracks, params: {
        id: album.id,
        edition_id: edition.id,
        tracks: []
      }, as: :json

      expect(response).to have_http_status(:ok)
      # The edition-specific row should be deleted, not nullified
      expect(AlbumTrack.exists?(edition_at.id)).to be false
      # The unsorted row should still exist
      expect(AlbumTrack.where(album: album, track: track1, edition_id: nil).count).to eq(1)
    end
  end
end
