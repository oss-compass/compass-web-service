require 'rails_helper'

RSpec.describe CollectionServer, type: :service do
  describe '#execute' do
    it 'passes the proxy as an environment variable instead of shell source' do
      proxy = 'http://proxy.example:8080; touch /tmp/collection-server-pwned'
      status = instance_double(Process::Status, success?: false)
      logger = instance_double(Logger)
      server = described_class.new

      stub_const('Common::PROXY', proxy)
      allow(server).to receive(:job_logger).and_return(logger)
      allow(logger).to receive(:error)

      expect(Open3).to receive(:capture2).with(
        { 'https_proxy' => proxy },
        'git',
        'pull',
        chdir: Rails.root + Common::META_REPO
      ).and_return(['git pull failed', status])

      server.execute('collections')
    end
  end
end
