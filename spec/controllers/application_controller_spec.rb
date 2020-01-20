require 'rails_helper'

describe ApplicationController, type: :controller do
  describe 'GET #index' do
    def do_request
      get :index
    end

    it 'should be render :index' do
      do_request
      expect(response).to render_template :index
    end
  end
end
