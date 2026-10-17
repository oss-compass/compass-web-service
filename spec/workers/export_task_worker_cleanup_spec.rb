# frozen_string_literal: true

require 'csv'
require 'digest'
require 'fileutils'
require 'json'
require 'logger'
require 'pathname'
require 'stringio'
require 'tmpdir'
require 'active_support'
require 'active_support/cache'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'rspec/core'
require 'rspec/expectations'
require 'rspec/mocks'

# Isolated whole-worker regression: dispatch/ack, cache/root, record lookup,
# upload, attachment and callbacks are boundaries. CSV, files, IO and the
# complete production work method are real. No Rails app or broker is started.
RSpec.describe 'ExportTaskWorker temporary CSV cleanup' do
  let(:uuid) { Digest::SHA1.hexdigest('ExportTaskCleanupCallbacks:fixture-repo:repo') }
  let(:csv_path) { @directory.join("tmp/uploads/temp_#{uuid}.csv") }
  let(:cache_key) { "export-#{uuid}" }
  let(:message) do
    {
      label: 'fixture-repo', level: 'repo', uuid: uuid,
      query: nil, select: %w[name value],
      indexer: 'ExportTaskCleanupCallbacks',
      raw_data: [{ 'name' => 'first', 'value' => 1 }, { 'name' => 'second', 'value' => 2 }]
    }.to_json
  end
  let(:worker) { ExportTaskWorker.new }

  around do |example|
    Dir.mktmpdir('export-worker-cleanup-') do |directory|
      @directory = Pathname.new(directory)
      @upload_ios = []
      begin
        example.run
      ensure
        # Harness teardown only, after all example assertions: a failing
        # regression must not leave open handles that block Windows tmp cleanup.
        @upload_ios.each { |io| io.close unless io.closed? }
      end
    end
  end

  before do
    FileUtils.mkdir_p(@directory.join('tmp/uploads'))
    @sentinel = @directory.join('keep.txt')
    File.binwrite(@sentinel, "unrelated sentinel\n")
    @cache = ActiveSupport::Cache::MemoryStore.new
    @log_output = StringIO.new
    @logger = Logger.new(@log_output)
    @events = []

    queue_boundary = Module.new do
      def self.included(worker_class)
        worker_class.define_singleton_method(:from_queue) { |*_arguments| nil }
      end

      def ack!; end
    end
    stub_const('Sneakers', Module.new)
    stub_const('Sneakers::Worker', queue_boundary)
    logger = @logger
    Sneakers.define_singleton_method(:logger) { logger }

    stub_const('Rails', Module.new)
    directory, cache = @directory, @cache
    Rails.define_singleton_method(:root) { directory }
    Rails.define_singleton_method(:cache) { cache }

    subject_model = Class.new do
      def self.find_by(**_query); end
    end
    subject_model.const_set(:PROGRESS, 'progress')
    subject_model.const_set(:UNKNOWN, 'unknown')
    stub_const('Subject', subject_model)
    @attachments = double('subject exports')
    @subject = double('subject', short_name: 'fixture', exports: @attachments)
    allow(Subject).to receive(:find_by).with(label: 'fixture-repo', level: 'repo').and_return(@subject)

    stub_const('ActiveStorage', Module.new)
    blob_api = Class.new do
      def self.create_and_upload!(**_options); end
    end
    stub_const('ActiveStorage::Blob', blob_api)
    @blob = double('uploaded blob', id: 7, signed_id: 'signed-blob-7')
    allow(ActiveStorage::Blob).to receive(:create_and_upload!) do |io:, filename:, content_type:|
      expect(io).to be_a(File)
      expect(io).not_to be_closed
      @upload_ios << io
      @uploaded_csv = io.binmode.read
      @events << [:upload, filename, content_type]
      @blob
    end
    allow(@attachments).to receive(:attach) do |signed_id|
      @events << [:attach, signed_id, @upload_ios.all?(&:closed?)]
    end

    callbacks = Class.new do
      def self.on_each(args)
        args.fetch(:source)
      end

      def self.on_finish(_args); end
    end
    stub_const('ExportTaskCleanupCallbacks', callbacks)
    allow(ExportTaskCleanupCallbacks).to receive(:on_each).and_call_original
    allow(ExportTaskCleanupCallbacks).to receive(:on_finish) { |args| record_finish(args) }

    stub_const('ExportTaskWorker', Class.new)
    load File.expand_path('../../app/workers/export_task_worker.rb', __dir__)
    allow(worker).to receive(:ack!) { @events << [:ack] }
  end

  after do
    expect(File.binread(@sentinel)).to eq("unrelated sentinel\n")
  end

  def record_finish(args)
    @events << [:finish, args, File.exist?(csv_path), @upload_ios.all?(&:closed?)]
  end

  def expect_original_failure(error)
    expect { worker.work(message) }.to raise_error { |caught| expect(caught).to equal(error) }
    expect(@cache.read(cache_key)).to eq(status: Subject::UNKNOWN)
    expect(worker).not_to have_received(:ack!)
    expect(@upload_ios).to all(be_closed)
  end

  def replace_csv_with_directory
    # Real unlink failure, including as a privileged Unix user: File.delete
    # cannot unlink this nonempty directory. Do not stub production cleanup.
    File.delete(csv_path)
    Dir.mkdir(csv_path)
    File.binwrite(csv_path.join('keep.txt'), "keep directory child\n")
  end

  def expect_cleanup_directory_untouched
    expect(csv_path).to be_directory
    expect(Dir.children(csv_path)).to eq(['keep.txt'])
    expect(File.binread(csv_path.join('keep.txt'))).to eq("keep directory child\n")
  end

  it 'removes a partial CSV and rethrows the original row callback error without ack' do
    error = IOError.new('row transformation failed')
    rows = 0
    csv_existed = false
    allow(ExportTaskCleanupCallbacks).to receive(:on_each) do |args|
      rows += 1
      if rows == 2
        csv_existed = File.file?(csv_path)
        raise error
      end
      args.fetch(:source)
    end

    expect_original_failure(error)
    expect(rows).to eq(2)
    expect(csv_existed).to be(true)
    expect(File.exist?(csv_path)).to be(false)
    expect(@upload_ios).to be_empty
    expect(ActiveStorage::Blob).not_to have_received(:create_and_upload!)
    expect(ExportTaskCleanupCallbacks).not_to have_received(:on_finish)
  end

  it 'closes the upload IO and removes the CSV when upload raises' do
    error = IOError.new('upload service unavailable')
    allow(ActiveStorage::Blob).to receive(:create_and_upload!) do |io:, **_options|
      @upload_ios << io
      expect(io.binmode.read).to eq("name,value\nfirst,1\nsecond,2\n")
      raise error
    end

    expect_original_failure(error)
    expect(@upload_ios.size).to eq(1)
    expect(File.exist?(csv_path)).to be(false)
    expect(@attachments).not_to have_received(:attach)
    expect(ExportTaskCleanupCallbacks).not_to have_received(:on_finish)
  end

  it 'closes the upload IO before attachment and cleans up if attachment raises' do
    error = IOError.new('attachment write failed')
    closed_at_attach = false
    allow(@attachments).to receive(:attach) do |_signed_id|
      closed_at_attach = @upload_ios.all?(&:closed?)
      raise error
    end

    expect_original_failure(error)
    expect(@upload_ios.size).to eq(1)
    expect(closed_at_attach).to be(true)
    expect(File.exist?(csv_path)).to be(false)
    expect(ExportTaskCleanupCallbacks).not_to have_received(:on_finish)
  end

  it 'uploads the exact CSV, closes IO and deletes before finish and ack on success' do
    worker.work(message)

    expect(@uploaded_csv).to eq("name,value\nfirst,1\nsecond,2\n")
    expect(@upload_ios.size).to eq(1)
    expect(@upload_ios).to all(be_closed)
    expect(File.exist?(csv_path)).to be(false)
    expect(@events).to eq([
      [:upload, 'fixture.csv', 'text/csv'],
      [:attach, 'signed-blob-7', true],
      [:finish, { uuid: uuid, blob_id: 7 }, false, true],
      [:ack]
    ])
    # The controlled finish callback does not change cache status; the worker
    # itself writes PROGRESS on success and must not overwrite it with UNKNOWN.
    expect(@cache.read(cache_key)).to eq(status: Subject::PROGRESS)
    expect(worker).to have_received(:ack!).once
  end

  it 'keeps the file deleted and marks UNKNOWN if the finish callback raises' do
    error = IOError.new('finish callback failed')
    allow(ExportTaskCleanupCallbacks).to receive(:on_finish) do |args|
      record_finish(args)
      raise error
    end

    expect_original_failure(error)
    expect(File.exist?(csv_path)).to be(false)
    expect(@events.last).to eq([:finish, { uuid: uuid, blob_id: 7 }, false, true])
    expect(ExportTaskCleanupCallbacks).to have_received(:on_finish).once
  end

  it 'retains the no-subject path with no upload, deletion before finish and one ack' do
    allow(Subject).to receive(:find_by).and_return(nil)

    worker.work(message)

    expect(ActiveStorage::Blob).not_to have_received(:create_and_upload!)
    expect(@upload_ios).to be_empty
    expect(File.exist?(csv_path)).to be(false)
    expect(@events).to eq([[:finish, { uuid: uuid, blob_id: nil }, false, true], [:ack]])
    expect(@cache.read(cache_key)).to eq(status: Subject::PROGRESS)
    expect(worker).to have_received(:ack!).once
  end

  it 'preserves the business error when real filesystem cleanup also fails' do
    error = IOError.new('attachment write failed')
    allow(@attachments).to receive(:attach) do |_signed_id|
      replace_csv_with_directory
      raise error
    end

    expect_original_failure(error)
    expect(@upload_ios.size).to eq(1)
    expect_cleanup_directory_untouched
    expect(@log_output.string).to include('Failed to clean up export CSV, reason:')
    expect(ExportTaskCleanupCallbacks).not_to have_received(:on_finish)
  end

  it 'preserves the business error even when cleanup error logging fails' do
    error = IOError.new('attachment write failed')
    allow(@attachments).to receive(:attach) do |_signed_id|
      replace_csv_with_directory
      raise error
    end
    allow(@logger).to receive(:error).and_wrap_original do |original, text|
      raise IOError, 'cleanup log unavailable' if text.start_with?('Failed to clean up export CSV, reason:')

      original.call(text)
    end

    expect_original_failure(error)
    expect(@upload_ios.size).to eq(1)
    expect_cleanup_directory_untouched
    expect(ExportTaskCleanupCallbacks).not_to have_received(:on_finish)
  end
end
