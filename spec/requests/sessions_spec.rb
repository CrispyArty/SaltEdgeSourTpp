# frozen_string_literal: true

describe 'Sessions', type: :request do
  before do
    Rails.cache.clear
  end

  describe "GET /sessions/create/:uuid" do

    let(:consent) { { consent_status: 'valid' } }

    before do
      allow(SaltEdge::ConsentShowService).to receive(:call).and_return(consent)
    end

    context "has cached user:[uuid]:consent_creation" do
      let(:uuid) { "641ad3cb-027e-4587-adcb-ae49b0688b0b" }

      it "successful login" do
        Rails.cache.write("user:#{uuid}:consent_creation", { consent_id: "11" })

        get sessions_create_path(uuid: uuid)
        expect(response).to have_http_status(302)
        expect(session[:consent_id]).to eq('11')
      end
    end

    context "not found cached user:[uuid]:consent_creation" do
      let(:uuid) { "641ad3cb-027e-4587-adcb-ae49b0688b0b" }
      let(:unrelated_uuid) { "239f5693-cc1a-4cf4-a0c3-a885d6d85b5c" }

      it "responds with 422 Unprocessable Entity" do
        Rails.cache.write("user:#{unrelated_uuid}:consent_creation", { consent_id: "11" })

        get sessions_create_path(uuid: uuid)
        expect(response).to have_http_status(422)
        expect(session[:consent_id]).to be_nil
      end
    end
  end

  describe "GET /sessions/redirect" do
    let(:show_response) { { consent_status: 'received', sca_redirect_link: 'https://example.com/redirect' } }
    let(:create_response) { { consent_id: '11', consent_status: 'accepted' } }
    let(:uuid) { "641ad3cb-027e-4587-adcb-ae49b0688b0b" }

    before do
      allow(SecureRandom).to receive(:uuid).and_return(uuid)
      allow(::SaltEdge::ConsentCreateService).to receive(:call).and_return(create_response)
      allow(::SaltEdge::ConsentShowService).to receive(:call).and_return(show_response)
    end

    it "calls api with correct params" do
      expect(::SaltEdge::ConsentCreateService).to receive(:call).with(redirect_url: sessions_create_url(uuid: uuid))
      expect(::SaltEdge::ConsentShowService).to receive(:call).with(consent_id: '11')
      get sessions_redirect_path
    end

    it "writes in cache user :uuid" do
      get sessions_redirect_path
      expect(Rails.cache.fetch("user:#{uuid}:consent_creation")).to include(consent_id: '11')
    end

    it "successfully redirected to the bank" do
      get sessions_redirect_path
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("https://example.com/redirect")
    end

  end

end
