require 'rails_helper'

RSpec.describe TestCleanupController, type: :controller do
  describe 'DELETE #destroy' do
    it 'deletes artists whose names start with E2E' do
      create(:artist, name: 'E2E Test Artist 123')
      create(:artist, name: 'Keep This Artist')

      expect {
        delete :destroy, format: :json
      }.to change(Artist, :count).by(-1)

      expect(Artist.where(name: 'Keep This Artist')).to exist
      expect(Artist.where(name: 'E2E Test Artist 123')).not_to exist
    end

    it 'deletes artists whose names start with E2F' do
      create(:artist, name: 'E2F FilterArtist 456')

      expect {
        delete :destroy, format: :json
      }.to change(Artist, :count).by(-1)
    end

    it 'deletes albums whose titles start with E2E' do
      create(:album, title: 'E2E Test Album 123')
      create(:album, title: 'Keep This Album')

      expect {
        delete :destroy, format: :json
      }.to change(Album, :count).by(-1)

      expect(Album.where(title: 'Keep This Album')).to exist
      expect(Album.where(title: 'E2E Test Album 123')).not_to exist
    end

    it 'deletes tracks whose titles start with E2E' do
      create(:track, title: 'E2E Test Track 123')
      create(:track, title: 'Keep This Track')

      expect {
        delete :destroy, format: :json
      }.to change(Track, :count).by(-1)

      expect(Track.where(title: 'Keep This Track')).to exist
      expect(Track.where(title: 'E2E Test Track 123')).not_to exist
    end

    it 'deletes E2E settings records (genres, tags, media, phases, priorities, release_types)' do
      create(:genre, name: 'E2E Genre 123')
      create(:genre, name: 'Keep Genre')
      create(:tag, name: 'E2E Tag 123')
      create(:medium, name: 'E2E Medium 123')
      create(:phase, name: 'E2E Phase 123')
      create(:priority, name: 'E2E Priority 123')
      create(:release_type, name: 'E2E ReleaseType 123')

      delete :destroy, format: :json

      expect(Genre.where(name: 'E2E Genre 123')).not_to exist
      expect(Genre.where(name: 'Keep Genre')).to exist
      expect(Tag.where(name: 'E2E Tag 123')).not_to exist
      expect(Medium.where(name: 'E2E Medium 123')).not_to exist
      expect(Phase.where(name: 'E2E Phase 123')).not_to exist
      expect(Priority.where(name: 'E2E Priority 123')).not_to exist
      expect(ReleaseType.where(name: 'E2E ReleaseType 123')).not_to exist
    end

    it 'returns JSON with deleted counts' do
      create(:artist, name: 'E2E Artist A')
      create(:artist, name: 'E2E Artist B')
      create(:genre, name: 'E2E Genre X')

      delete :destroy, format: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['deleted']
      expect(json['artists']).to eq(2)
      expect(json['genres']).to eq(1)
      expect(json['tracks']).to eq(0)
      expect(json['albums']).to eq(0)
    end

    it 'destroys dependent user preferences when deleting catalog records' do
      user = create(:user)
      artist = create(:artist, name: 'E2E Cascade Artist')
      create(:user_artist, user: user, artist: artist, rating: 5)

      expect {
        delete :destroy, format: :json
      }.to change(UserArtist, :count).by(-1)
    end

    it 'does not require authentication' do
      # No sign_in call — should still work
      delete :destroy, format: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
