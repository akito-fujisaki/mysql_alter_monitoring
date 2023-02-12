# frozen_string_literal: true

module MysqlAlterMonitoring
  # MysqlAlterMonitoring::JsonLogger
  class JsonLogger
    # @return [Proc]
    FORMATTER = (proc do |severity, timestamp, _progname, msg|
                   JSON.parse(String(msg), symbolized_name: true)
                       .merge(level: severity, timestamp: timestamp)
                       .then { "#{JSON.generate(_1)}\n" }
                 end).freeze
    private_constant :FORMATTER

    # @param io [::IO]
    # @return [void]
    def initialize(io)
      @logger = ::Logger.new(io, formatter: FORMATTER)
    end

    # @param hash [Hash]
    # @return [void]
    def info(hash)
      build_message(hash).then { logger.info(_1) }
    end

    # @param error [Exception]
    # @param hash [Hash]
    # @return [void]
    def error(error, hash = {})
      hash.merge(error_class: error.class.name, error_message: error.message)
          .then { build_message(_1) }
          .then { logger.error(_1) }
    end

    private

    # @!attribute [r] logger
    # @return [Logger]
    attr_reader :logger

    # @param hash [Hash]
    # @return [String]
    def build_message(hash)
      JSON.generate(hash)
    end
  end
end
