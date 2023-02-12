# frozen_string_literal: true

module MysqlAlterMonitoring
  # MysqlAlterMonitoring::Client
  class Client
    extend Forwardable

    class << self
      # @param url [String]
      # @return [MysqlAlterMonitoring::Client]
      def build_by_url(url)
        Config.build_by_url(url).then { new(_1) }
      end
    end

    # @!method query
    #   @return [Object]
    delegate query: :mysql2_client

    # @param config [MysqlAlterMonitoring::Config]
    # @return [void]
    def initialize(config)
      @mysql2_client = Mysql2::Client.new(
        host: config.host,
        port: config.port,
        username: config.user,
        password: config.password
      )
    end

    private

    # @!attribute [r] mysql2_client
    # @return [Mysql2::Client]
    attr_reader :mysql2_client
  end
end
