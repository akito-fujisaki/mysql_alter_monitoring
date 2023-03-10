# frozen_string_literal: true

module MysqlAlterMonitoring
  # MysqlAlterMonitoring::PerformanceSchemaSetting
  class PerformanceSchemaSetting
    # @param client [MysqlAlterMonitoring::Client]
    # @param io [::IO]
    # @return [void]
    def initialize(client, io)
      @client = client
      @logger = JsonLogger.new(io)
    end

    # @return [void]
    def enable!
      client.query <<~SQL
        UPDATE performance_schema.setup_instruments SET ENABLED = 'YES'
        WHERE NAME LIKE 'stage/innodb/alter%'
      SQL

      client.query <<~SQL
        UPDATE performance_schema.setup_consumers SET ENABLED = 'YES'
        WHERE NAME LIKE '%stages%'
      SQL

      logger.info({ message: 'Enable monitoring settings for the performance schema' })
    end

    # @return [Boolean]
    def enable?
      disabled_instruments = client.query <<~SQL
        SELECT * FROM performance_schema.setup_instruments
        WHERE NAME LIKE 'stage/innodb/alter%' AND ENABLED = 'NO'
      SQL
      disabled_consumers = client.query <<~SQL
        SELECT * FROM performance_schema.setup_consumers
        WHERE NAME LIKE '%stages%' AND ENABLED = 'NO'
      SQL

      disabled_instruments.count.zero? && disabled_consumers.count.zero?
    end

    # @return [void]
    def disable!
      client.query <<~SQL
        UPDATE performance_schema.setup_instruments SET ENABLED = 'NO'
        WHERE NAME LIKE 'stage/innodb/alter%'
      SQL

      client.query <<~SQL
        UPDATE performance_schema.setup_consumers SET ENABLED = 'NO'
        WHERE NAME LIKE '%stages%'
      SQL

      logger.info({ message: 'Disable monitoring settings for the performance schema' })
    end

    private

    # @!attribute [r] client
    # @return [MysqlAlterMonitoring::Client]
    attr_reader :client
    # @!attribute [r] logger
    # @return [JsonLogger]
    attr_reader :logger
  end
end
