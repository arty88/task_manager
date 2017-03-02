require "rails_helper"

RSpec.describe Web::SessionsController, type: :controller do
  describe "GET #new" do
    before { get :new }

    it "renders view new" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user) }
    let(:parameters) { { session: { email: user.email, password: "pass123" } } }

    subject { post :create, params: parameters }

    before { subject }

    it "set user_id in session" do
      expect(session[:user_id]).to eq(user.id)
    end

    it "redirect to root" do
      expect(response).to redirect_to root_path
    end

    context "with invalid attributes" do
      let(:parameters) { { session: { email: "wrong@email.com", password: "-" } } }

      it "doesn not set user_id in session" do
        expect(session[:user_id]).to be_nil
      end

      it "re-render view sign up form" do
        expect(response).to render_template(:new)
      end
    end
  end
end
