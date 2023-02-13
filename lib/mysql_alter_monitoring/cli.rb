# frozen_string_literal: true

require 'optparse'

module MysqlAlterMonitoring
  # MysqlAlterMonitoring::CLI
  class CLI
    # @param args [Array<String>]
    # @param io [::IO]
    # @return [void]
    def initialize(args, io: $stdout)
      @args = args
      @io = io
      @options = {}
    end

    # @return [void]
    # @raise [MysqlAlterMonitoring::Error]
    def run # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
      parse!

      return if help? || version?

      client = Client.new(build_config)

      case options[:command]
      when 'enable'
        PerformanceSchemaSetting.new(client, io).enable!
      when 'disable'
        PerformanceSchemaSetting.new(client, io).disable!
      when 'run'
        Monitor.new(client, io).run_until_empty_event
      when 'run-forever'
        Monitor.new(client, io).run_forever
      else
        raise ArgumentError, "Invalid command: #{options[:command]}"
      end
    rescue OptionParser::InvalidOption, ArgumentError => e
      io.puts e.message
      io.puts help
    rescue Interrupt
      io.puts 'Bye!'
    end

    # @return [String]
    def help
      parser.help
    end

    private

    # @!attribute [r] args
    # @return [Array<String>]
    attr_reader :args
    # @!attribute [r] options
    # @return [Hash]
    attr_reader :options
    # @!attribute [r] io
    # @return [::IO]
    attr_reader :io

    # @return [OptionParser]
    def parser # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      @parser ||= OptionParser.new do |opts|
        opts.banner = 'Usage: mysql-alter-monitoring [command] [options]'
        opts.separator <<~COMMANDS
          Commands:
                  enable      Enable monitoring settings for the performance schema
                  disable     Disable monitoring settings for the performance schema
                  run         Start monitoring until event empty
                  run-forever Start monitoring forever
        COMMANDS
        opts.separator('Options:')
        opts.on('--url VALUE', String, 'example: mysql2://root:pass@localhost:3306') { @options[:url] = _1 }
        opts.on('--host VALUE', String) { @options[:host] = _1 }
        opts.on('--port VALUE', Integer, "default: #{Config::DEFAULT_PORT}") { @options[:port] = _1 }
        opts.on('--user VALUE', String) { @options[:user] = _1 }
        opts.on('--password VALUE', String) { @options[:password] = _1 }
        opts.on_tail('-h', '--help', 'Show help') { @options[:help] = true }
        opts.on_tail('--version', 'Show version') { @options[:version] = true }
      end
    end

    # @return [Boolean]
    def help?
      options.key?(:help).tap { io.puts help if _1 }
    end

    # @return [Boolean]
    def version?
      options.key?(:version).tap { io.puts "MysqlAlterMonitoring #{MysqlAlterMonitoring::VERSION}" if _1 }
    end

    # @return [MysqlAlterMonitoring::Config]
    def build_config
      return Config.build_by_url(options[:url] || '') if options.key?(:url)

      Config.new(
        host: options[:host] || '',
        port: options[:port] || 0,
        user: options[:user] || '',
        password: options[:password] || ''
      )
    end

    # @return [Hash]
    # @raise OptionParser::InvalidOption
    def parse!
      command = parser.parse(args).first || ''
      @options.merge!(command: command)
    end
  end
end
