require 'rails_helper'

RSpec.describe AlbumsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array of albums with user preferences' do
      album = create(:album, title: 'OK Computer')
      create(:user_album, user: user, album: album, rating: 5, listened: true)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      entry = json.find { |a| a['id'] == album.id }
      expect(entry['title']).to eq('OK Computer')
      expect(entry['rating']).to eq(5)
      expect(entry['listened']).to eq(true)
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single album JSON' do
      album = create(:album, title: 'OK Computer')
      get :show, params: { id: album.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['title']).to eq('OK Computer')
    end
  end

  describe 'POST #create' do
    it 'creates an Album and UserAlbum and returns 201' do
      expect {
        post :create, params: { album: { title: 'New Album', year: 2020, rating: 4 } }, format: :json
      }.to change(Album, :count).by(1).and change(UserAlbum, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['title']).to eq('New Album')
      expect(json['rating']).to eq(4)
    end

    it 'returns 422 with invalid params' do
      post :create, params: { album: { title: '' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'updates album and user preferences' do
      album = create(:album, title: 'Old Title')
      create(:user_album, user: user, album: album)
      patch :update, params: { id: album.id, album: { title: 'New Title', rating: 3, listened: true } }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['title']).to eq('New Title')
      expect(json['rating']).to eq(3)
      expect(json['listened']).to eq(true)
    end
  end

  describe 'DELETE #destroy' do
    it 'removes only the UserAlbum, not the Album' do
      album = create(:album)
      create(:user_album, user: user, album: album)
      expect {
        delete :destroy, params: { id: album.id }, format: :json
      }.to change(UserAlbum, :count).by(-1).and change(Album, :count).by(0)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'unauthenticated' do
    it 'returns 401 when not logged in' do
      session.delete(:user_id)
      get :index, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
