# -*- encoding : utf-8 -*-

require File.expand_path('../test_helper', __FILE__)

describe 'gitdocs runner' do
  let(:runner) { Gitdocs::Runner.new(share) }

  let(:share)      { stub(polling_interval: 1, notification: true) }
  let(:repository) { stub(root: 'root_path') }
  before do
    Gitdocs::Repository.stubs(:new).with(share).returns(repository)
  end

  describe '#root' do
    subject { runner.root }
    it { subject.must_equal 'root_path' }
  end

  describe '#sync_changes' do
    subject { runner.sync_changes }

    let(:syncronizer) { stub }
    before do
      repository.expects(:valid?).returns(valid)
      share.stubs(:sync_type).returns(sync_type)
      Gitdocs::Repository::Syncronizer.stubs(:new)
        .with(share)
        .returns(syncronizer)
    end

    describe 'invalid repository' do
      let(:valid)     { false }
      let(:sync_type) { nil }
      it { subject.must_be_nil }
    end

    describe 'exception' do
      let(:valid)     { true }
      let(:sync_type) { 'other' }
      before do
        exception = StandardError.new
        syncronizer.expects(:sync).raises(exception)
        Gitdocs::Notifier.expects(:error).with(
          'Unexpected error syncing changes in root_path', exception.to_s, true
        )
      end
      it { subject.must_be_nil }
    end

    describe 'run' do
      let(:valid) { true }
      before do
        syncronizer.expects(:sync).returns([:merge_result, :push_result])
        Gitdocs::Notifier.expects(:sync_result)
          .with(:merge_result, :push_result, 'root_path', true)
      end

      describe 'with fetch' do
        let(:sync_type) { 'full' }
        before { repository.expects(:commit) }
        it { subject.must_be_nil }
      end

      describe 'without fetch' do
        let(:sync_type) { 'other' }
        it { subject.must_be_nil }
      end
    end
  end
end
