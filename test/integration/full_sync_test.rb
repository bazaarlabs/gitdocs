# -*- encoding : utf-8 -*-

require File.expand_path('../test_helper', __FILE__)

describe 'fully synchronizing repositories' do
  before do
    git_clone_and_gitdocs_add(git_init_remote, 'clone1', 'clone2', 'clone3')
    start_daemon
  end

  it 'should sync new files' do
    write_file('clone1/newfile', 'testing')
    wait_for_clean_workdir('clone1')

    wait_for_exact_file_content('clone1/newfile', 'testing')
    wait_for_exact_file_content('clone2/newfile', 'testing')
    wait_for_exact_file_content('clone3/newfile', 'testing')
  end

  it 'should sync changes to an existing file' do
    write_file('clone1/file', 'testing')
    wait_for_clean_workdir('clone1')

    wait_for_exact_file_content('clone3/file', 'testing')
    append_to_file('clone3/file', "\nfoobar")
    wait_for_clean_workdir('clone3')

    wait_for_exact_file_content('clone1/file', "testing\nfoobar")
    wait_for_exact_file_content('clone2/file', "testing\nfoobar")
    wait_for_exact_file_content('clone3/file', "testing\nfoobar")
  end

  it 'should mark unresolvable conflicts' do
    write_file('clone1/file', 'testing')
    wait_for_clean_workdir('clone1')

    append_to_file('clone2/file', 'foobar')
    append_to_file('clone3/file', 'deadbeef')
    wait_for_clean_workdir('clone2')
    wait_for_clean_workdir('clone3')

    # HACK: Leaving in the sleep and standard checks.
    # Trying to wait for the conflicts to be resolved does not seem to
    # be working consistently when run on TravisCI. Hopefully this will.
    sleep(6)
    in_current_dir do
      # Remember expected file counts include '.', '..', and '.git'
      assert_includes(5..6, Dir.entries('clone1').count)
      assert_includes(5..6, Dir.entries('clone2').count)
      assert_includes(5..6, Dir.entries('clone3').count)
    end
    # TODO: Want to convert to these methods in the future
    # wait_for_conflict_markers('clone1/file')
    # wait_for_conflict_markers('clone2/file')
    # wait_for_conflict_markers('clone3/file')
  end
end
