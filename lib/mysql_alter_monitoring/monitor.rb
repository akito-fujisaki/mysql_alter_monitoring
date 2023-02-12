# frozen_string_literal: true

module MysqlAlterMonitoring
  # MysqlAlterMonitoring::Monitor
  class Monitor
    # @return [Integer]
    EMPTY_EVENT_MAX_COUNT = 10
    public_constant :EMPTY_EVENT_MAX_COUNT

    # @param client [MysqlAlterMonitoring::Client]
    # @param io [::IO]
    # @param logging_interval [Numeric]
    # @return [void]
    def initialize(client, io, logging_interval: 10)
      @client = client
      @logger = JsonLogger.new(io)
      @logging_interval = logging_interval
      @performance_schema_setting = PerformanceSchemaSetting.new(client)
    end

    # Fetch ALTER TABLE events at specified intervals and output in JSON format to specified IO.
    # Exit when a total of 10 empty ALTER TABLE events are fetched.
    #
    # @return [void]
    def run_until_empty_event
      empty_event_count = 0

      run do |event|
        empty_event_count += 1 if event.empty?
        empty_event_count > EMPTY_EVENT_MAX_COUNT
      end

      logger.info({ message: 'Finish monitoring' })
    end

    # @return [void]
    def run_forever
      run { false }
    end

    private

    # @!attribute [r] client
    # @return [MysqlAlterMonitoring::Client]
    attr_reader :client
    # @!attribute [r] logger
    # @return [JsonLogger]
    attr_reader :logger
    # @!attribute [r] logging_interval
    # @return [Numeric]
    attr_reader :logging_interval
    # @!attribute [r] performance_schema_setting
    # @return [MysqlAlterMonitoring::PerformanceSchemaSetting]
    attr_reader :performance_schema_setting

    # Must specify finish condition in block
    #
    # @yieldparam event [Hash]
    # @yieldreturn [Boolean]
    # @return [void]
    def run # rubocop:todo Metrics/AbcSize
      raise Error, 'performance schema monitoring setting is not enabled' unless performance_schema_setting.enable?

      Enumerator.produce { fetch_event_stages_current }.each do |event|
        raise StopIteration if yield(event)

        build_log_hash(event).then { logger.info(_1) }
        sleep(logging_interval)
      end
    rescue StandardError => e
      logger.error(e)
    end

    # @return [Hash]
    def fetch_event_stages_current
      client.query('SELECT * FROM performance_schema.events_stages_current').to_a.first || {}
    end

    # @param event [Hash]
    # f@return [Hash]
    def build_log_hash(event)
      return { message: 'Event is empty' } if event.empty?

      { progress: calculate_progress(event), raw: event }
    end

    # @param event [Hash]
    # @return [String]
    def calculate_progress(event)
      (BigDecimal(event['WORK_COMPLETED']) / BigDecimal(event['WORK_ESTIMATED']))
        .then { _1 * 100 }
        .then { _1.round(3) }
        .then { format('%<progress>3.3f(%%)', progress: _1) }
    end
  end
end
