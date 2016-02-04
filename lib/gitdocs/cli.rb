# -*- encoding : utf-8 -*-

require 'thor'
require 'table_print'
require 'dante'
require 'guard'

# rubocop:disable LineLength, ClassLength

module Gitdocs
  class Cli < Thor
    include Thor::Actions

    def self.source_root
      File.expand_path('../../', __FILE__)
    end

    desc 'start', 'Starts a daemonized gitdocs process'
    method_option :foreground, type: :boolean, aliases: '-fg'
    method_option :verbose,    type: :boolean, aliases: '-v'
    method_option :port,       type: :string,  aliases: '-p'
    method_option :pid,        type: :string,  aliases: '-P'
    def start
      unless stopped?
        say 'Gitdocs is already running, please use restart', :red
        return
      end

      Gitdocs::Initializer.verbose = options[:verbose]

      if options[:foreground]
        say 'Run in the foreground', :yellow
        Gitdocs::Initializer.foreground = true
        Gitdocs.start(options[:port])
      else
        # Clear the arguments so that they will not be processed by the
        # Dante execution.
        ARGV.clear
        runner.execute { Gitdocs.start(options[:port]) }

        if running?
          say 'Started gitdocs', :green
        else
          say 'Failed to start gitdocs', :red
        end
      end
    end

    method_option :pid, type: :string, aliases: '-P'
    desc 'stop', 'Stops the gitdocs process'
    def stop
      unless running?
        say 'Gitdocs is not running', :red
        return
      end

      runner.execute(kill: true)
      say 'Stopped gitdocs', :red
    end

    method_option :pid, type: :string, aliases: '-P'
    desc 'restart', 'Restarts the gitdocs process'
    def restart
      stop
      start
    end

    method_option :pid, type: :string, aliases: '-P'
    desc 'add PATH', 'Adds a path to gitdocs'
    def add(path)
      Share.create_by_path!(normalize_path(path))
      say "Added path #{path} to doc list"
      restart if running?
    end

    method_option :pid, type: :string, aliases: '-P'
    desc 'rm PATH', 'Removes a path from gitdocs'
    def rm(path)
      Share.remove_by_path(path)
      say "Removed path #{path} from doc list"
      restart if running?
    end

    desc 'clear', 'Clears all paths from gitdocs'
    def clear
      Share.destroy_all
      say 'Cleared paths from gitdocs'
    end

    method_option :pid, type: :string, aliases: '-P'
    desc 'create PATH REMOTE', 'Creates a new gitdoc root based on an existing remote'
    def create(path, remote)
      Repository.clone(path, remote)
      add(path)
      say "Created #{path} path for gitdoc"
    end

    method_option :pid, type: :string, aliases: '-P'
    desc 'status', 'Retrieve gitdocs status'
    def status
      say "GitDoc v#{VERSION}"
      say "Running: #{running?}"
      say "File System Watch Method: #{file_system_watch_method}"
      say 'Watched repositories:'
      tp.set(:max_width, 100)
      status_display = lambda do |share|
        repository = Repository.new(share)

        status = ''
        status += '*' if repository.dirty?
        status += '!' if repository.need_sync?

        status = 'ok' if status.empty?
        status
      end
      tp(
        Share.all,
        { sync: { display_method: :sync_type } },
        { s: status_display },
        :path
      )
      say "\n(Legend: ok everything synced, * change to commit, ! needs sync)"
    end

    desc 'open', 'Open the Web UI'
    method_option :port, type: :string, aliases: '-p'
    def open
      unless running?
        say 'Gitdocs is not running, cannot open the UI', :red
        return
      end

      web_port = options[:port]
      web_port ||= Configuration.web_frontend_port
      Launchy.open("http://localhost:#{web_port}/")
    end

    # TODO: make this work
    # desc 'config', 'Configuration options for gitdocs'
    # def config
    # end

    desc 'help', 'Prints out the help'
    def help(task = nil, subcommand = false)
      say "\nGitdocs: Collaborate with ease.\n\n"
      task ? self.class.task_help(shell, task) : self.class.help(shell, subcommand)
    end

    # Helpers for thor
    no_tasks do
      def runner
        Dante::Runner.new(
          'gitdocs',
          debug:     false,
          daemonize: true,
          pid_path:  pid_path,
          log_path:  Gitdocs.log_path
        )
      end

      def running?
        runner.daemon_running?
      end

      def stopped?
        runner.daemon_stopped?
      end

      def pid_path
        options[:pid] || '/tmp/gitdocs.pid'
      end

      # @param [String] path
      # @return [String]
      def normalize_path(path)
        File.expand_path(path, Dir.pwd)
      end

      # @return [Symbol] to indicate how the file system is being watched
      def file_system_watch_method # rubocop:disable CyclomaticComplexity
        if Guard::Listener.mac? && Guard::Darwin.usable?
          :notification
        elsif Guard::Listener.linux? && Guard::Linux.usable?
          :notification
        elsif Guard::Listener.windows? && Guard::Windows.usable?
          :notification
        else
          :polling
        end
      end
    end
  end
end
