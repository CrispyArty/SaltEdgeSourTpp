# frozen_string_literal: true

describe ::SaltEdge::LoggingClientService do
  let(:uri_builder) { instance_double(::SaltEdge::UriBuilders::Base, build: "https://api.test/accounts") }
  let(:inner)       { instance_double(::SaltEdge::ClientService) }
  let(:recorded)    { [] }
  let(:logger) do
    ->(payload) { recorded << payload; true }
  end

  let(:result_ok) do
    ::SaltEdge::ApiResult.new(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: '{"accounts":[]}'
    )
  end

  before do
    stub_const("SaltEdge::Logging::ApiRequestLogger", Class.new do
      def initialize(callable) = @callable = callable
      def record(payload) = @callable.call(payload)
    end)
  end

  describe "#get" do
    it "delegates to the inner client, returns its result, and logs the request" do
      expect(inner).to receive(:get).with("accounts", headers: { "Consent-Id" => "c1" }, data: { x: 1 }).and_return(result_ok)

      service = described_class.new(
        inner: inner,
        uri_builder: uri_builder,
        logger: SaltEdge::Logging::ApiRequestLogger.new(logger)
      )

      result = service.get("accounts", headers: { "Consent-Id" => "c1" }, data: { x: 1 })

      expect(result).to eq(result_ok)
      expect(recorded.size).to eq(1)
      payload = recorded.first
      expect(payload[:method]).to eq("GET")
      expect(payload[:url]).to eq("https://api.test/accounts")
      expect(payload[:status]).to eq(200)
      expect(payload[:duration_ms]).to be_a(Numeric)
      expect(payload[:request_headers]).to eq({ "Consent-Id" => "c1" })
      expect(payload[:request_body]).to be_nil
    end
  end

  describe "#post" do
    it "sends a JSON-stringified body to the inner client and logs it" do
      expect(inner).to receive(:post).with("tpp/register", headers: { "X" => "y" }, data: { a: 1 }).and_return(result_ok)

      service = described_class.new(
        inner: inner,
        uri_builder: uri_builder,
        logger: SaltEdge::Logging::ApiRequestLogger.new(logger)
      )

      service.post("tpp/register", headers: { "X" => "y" }, data: { a: 1 })

      payload = recorded.first
      expect(payload[:method]).to eq("POST")
      expect(payload[:request_body]).to eq({ "a" => 1 })
    end
  end

  describe "error path" do
    it "logs the error and re-raises so the API call still propagates" do
      boom = ::SaltEdge::ClientService::ApiError.new("500")
      expect(inner).to receive(:get).and_raise(boom)

      service = described_class.new(
        inner: inner,
        uri_builder: uri_builder,
        logger: SaltEdge::Logging::ApiRequestLogger.new(logger)
      )

      expect { service.get("accounts", headers: {}, data: {}) }.to raise_error(::SaltEdge::ClientService::ApiError)

      expect(recorded.size).to eq(1)
      payload = recorded.first
      expect(payload[:error_class]).to eq("SaltEdge::ClientService::ApiError")
      expect(payload[:error_message]).to eq("500")
      expect(payload[:status]).to be_nil
    end
  end

  describe "logger failure" do
    it "never breaks the API call when the logger raises" do
      noisy_logger = Class.new do
        def record(_payload) = raise "disk full"
      end.new
      expect(Rails.logger).to receive(:error).with(/LoggingClientService/)
      expect(inner).to receive(:get).and_return(result_ok)

      service = described_class.new(
        inner: inner,
        uri_builder: uri_builder,
        logger: noisy_logger
      )

      expect { service.get("accounts", headers: {}, data: {}) }.not_to raise_error
    end
  end
end
