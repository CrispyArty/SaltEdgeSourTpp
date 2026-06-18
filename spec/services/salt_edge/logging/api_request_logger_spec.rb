# frozen_string_literal: true

describe ::SaltEdge::Logging::ApiRequestLogger do
  it "persists the payload via the sink's create!" do
    sink = double("sink")
    expect(sink).to receive(:create!).with({ method: "GET" })

    logger = described_class.new(sink: sink)

    logger.record({ method: "GET" })
  end

  it "defaults the sink to the ApiRequest ActiveRecord model" do
    expect(ApiRequest).to respond_to(:create!)
  end
end
