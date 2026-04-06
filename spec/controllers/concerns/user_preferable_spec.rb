require 'rails_helper'

RSpec.describe UserPreferable do
  let(:host_class) do
    Class.new do
      include UserPreferable

      attr_reader :current_user

      def initialize(user)
        @current_user = user
      end

      # Expose private methods for direct testing
      public :current_user_artist, :current_user_album, :current_user_track
    end
  end

  let(:user) { create(:user) }
  let(:host) { host_class.new(user) }

  describe '#current_user_artist' do
    it 'returns the existing UserArtist when one exists' do
      artist = create(:artist)
      pref = create(:user_artist, user: user, artist: artist, rating: 4)

      result = host.current_user_artist(artist)
      expect(result).to eq(pref)
      expect(result).to be_persisted
      expect(result.rating).to eq(4)
    end

    it 'initializes a new UserArtist when none exists' do
      artist = create(:artist)

      result = host.current_user_artist(artist)
      expect(result).to be_a(UserArtist)
      expect(result).to be_new_record
      expect(result.user).to eq(user)
      expect(result.artist).to eq(artist)
    end

    it 'does not return another user\'s preference' do
      artist = create(:artist)
      other_user = create(:user)
      create(:user_artist, user: other_user, artist: artist, rating: 5)

      result = host.current_user_artist(artist)
      expect(result).to be_new_record
    end
  end

  describe '#current_user_album' do
    it 'returns the existing UserAlbum when one exists' do
      album = create(:album)
      pref = create(:user_album, user: user, album: album, rating: 3)

      result = host.current_user_album(album)
      expect(result).to eq(pref)
      expect(result).to be_persisted
      expect(result.rating).to eq(3)
    end

    it 'initializes a new UserAlbum when none exists' do
      album = create(:album)

      result = host.current_user_album(album)
      expect(result).to be_a(UserAlbum)
      expect(result).to be_new_record
      expect(result.user).to eq(user)
      expect(result.album).to eq(album)
    end

    it 'does not return another user\'s preference' do
      album = create(:album)
      other_user = create(:user)
      create(:user_album, user: other_user, album: album, rating: 5)

      result = host.current_user_album(album)
      expect(result).to be_new_record
    end
  end

  describe '#current_user_track' do
    it 'returns the existing UserTrack when one exists' do
      track = create(:track)
      pref = create(:user_track, user: user, track: track, rating: 2)

      result = host.current_user_track(track)
      expect(result).to eq(pref)
      expect(result).to be_persisted
      expect(result.rating).to eq(2)
    end

    it 'initializes a new UserTrack when none exists' do
      track = create(:track)

      result = host.current_user_track(track)
      expect(result).to be_a(UserTrack)
      expect(result).to be_new_record
      expect(result.user).to eq(user)
      expect(result.track).to eq(track)
    end

    it 'does not return another user\'s preference' do
      track = create(:track)
      other_user = create(:user)
      create(:user_track, user: other_user, track: track, rating: 5)

      result = host.current_user_track(track)
      expect(result).to be_new_record
    end
  end
end
