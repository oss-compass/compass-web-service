require 'rails_helper'

RSpec.describe 'Integration enable flags' do
  around do |example|
    keys = %w[CENSORING_ENABLE THIRD_PARTY_CALLBACK_ENABLE]
    previous = keys.to_h { |key| [key, ENV[key]] }
    keys.each { |key| flag.nil? ? ENV.delete(key) : ENV[key] = flag }
    example.run
  ensure
    previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  let(:namespace) { Module.new }
  let(:censoring) do
    path = Rails.root.join('app/models/concerns/censoring.rb')
    namespace.module_eval(File.read(path), path.to_s)
    namespace.const_get(:Censoring)
  end
  let(:record) do
    concern = censoring
    Class.new do
      include concern
      attr_accessor :name
      censoring only: [:name]

      def previous_changes
        { 'name' => [nil, name] }
      end
    end.new.tap { |item| item.name = 'Example model' }
  end
  let(:worker_class) do
    path = Rails.root.join('app/workers/third_party_callback_worker.rb')
    namespace.module_eval(File.read(path), path.to_s)
    namespace.const_get(:ThirdPartyCallbackWorker)
  end
  let(:message) do
    { status: Subject::PENDING, label: 'https://gitee.com/example/repo', level: 'repo',
      origin: 'gitee' }.to_json
  end

  after do
    if namespace.const_defined?(:ThirdPartyCallbackWorker, false)
      Sneakers::Worker::Classes.delete(namespace.const_get(:ThirdPartyCallbackWorker))
    end
  end

  [nil, 'false', '0', 'off'].each do |value|
    context "when the flag is #{value.inspect}" do
      let(:flag) { value }

      it 'returns content without requesting moderation or reading moderation results' do
        expect(record).not_to receive(:processing_censoring)
        expect(record).not_to receive(:censoring_result)

        record.censoring_update

        expect(record.name_after_reviewed).to eq('Example model')
      end

      it 'acknowledges the callback message without querying data or sending a request' do
        allow(Sneakers).to receive(:logger).and_return(instance_double(Logger, info: nil))
        expect(Subject).not_to receive(:find_by)
        expect(Faraday).not_to receive(:post)

        expect(worker_class.allocate.work(message)).to eq(:ack)
      end
    end
  end

  context 'when the flag is true' do
    let(:flag) { 'true' }

    it 'still submits changed content for moderation' do
      allow(record).to receive(:processing_censoring)

      record.censoring_update

      expect(record).to have_received(:processing_censoring).with('name')
    end

    it 'still sends callbacks for allowed origins' do
      allow(Sneakers).to receive(:logger).and_return(instance_double(Logger, info: nil))
      allow(ActiveRecord::Base.connection_pool).to receive(:with_connection).and_yield
      allow(Subject).to receive(:find_by).and_return(nil)
      allow(Faraday).to receive(:post).and_return(double(body: 'ok'))

      expect(worker_class.allocate.work(message)).to eq(:ack)
      expect(Faraday).to have_received(:post).with(
        worker_class::CallbackUrl,
        { action: :sync_subject, data: {} }.to_json,
        hash_including('Content-Type' => 'application/json')
      )
    end
  end
end
