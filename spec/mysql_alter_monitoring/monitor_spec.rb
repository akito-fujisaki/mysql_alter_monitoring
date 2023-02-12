# frozen_string_literal: true

RSpec.describe MysqlAlterMonitoring::Monitor do
  let(:io) { StringIO.new }
  let(:monitor) { described_class.new(build_client, io, logging_interval: 0.1) }
  let(:performance_schema_setting) { MysqlAlterMonitoring::PerformanceSchemaSetting.new(build_client, StringIO.new) }

  describe '#run_until_empty_event' do
    subject(:logs) { io.tap(&:rewind).readlines.map { JSON.parse(_1, symbolize_names: true) } }

    context 'when performance schema monitoring setting is not enabled' do
      before do
        freeze_time
        performance_schema_setting.disable!
      end

      after { performance_schema_setting.enable! }

      let(:expected_logs) do
        [
          {
            level: 'ERROR',
            error_class: 'MysqlAlterMonitoring::Error',
            error_message: 'performance schema monitoring setting is not enabled',
            timestamp: Time.now.to_s
          },
          {
            level: 'INFO',
            message: 'Finish monitoring',
            timestamp: Time.now.to_s
          }
        ]
      end

      it do
        monitor.run_until_empty_event
        expect(logs).to eq expected_logs
      end
    end

    context 'when fetch_event_stages_current raise error' do
      before do
        freeze_time
        allow(monitor).to receive(:fetch_event_stages_current).and_raise(StandardError, 'error')
      end

      let(:expected_logs) do
        [
          {
            level: 'ERROR',
            error_class: 'StandardError',
            error_message: 'error',
            timestamp: Time.now.to_s
          },
          {
            level: 'INFO',
            message: 'Finish monitoring',
            timestamp: Time.now.to_s
          }
        ]
      end

      it do
        monitor.run_until_empty_event
        expect(logs).to eq expected_logs
      end
    end

    context 'when ALTER TABLE is not running' do
      before { freeze_time }

      around do |example|
        performance_schema_setting.enable!
        test_database_setup do |setup_client|
          setup_client.create_database
          setup_client.create_table
        end

        example.run

        test_database_setup(&:drop_database)
      end

      let(:expected_logs) do
        Array.new(
          described_class::EMPTY_EVENT_MAX_COUNT,
          { level: 'INFO', message: 'Event is empty', timestamp: Time.now.to_s }
        ) + [{ level: 'INFO', message: 'Finish monitoring', timestamp: Time.now.to_s }]
      end

      it do
        monitor.run_until_empty_event
        expect(logs).to eq expected_logs
      end
    end

    # Takes about 10 seconds to not mock.
    # Logs are output under spec/snapshots, so check them visually.
    context 'when ALTER TABLE is running' do
      around do |example|
        performance_schema_setting.enable!
        test_database_setup do |setup_client|
          setup_client.create_database
          setup_client.create_table
          setup_client.insert_initial_data
        end

        alter_table_thead = Thread.new { test_database_setup(&:alter_table) } # rubocop:disable ThreadSafety/NewThread

        example.run

        alter_table_thead.join
        test_database_setup(&:drop_database)
      end

      it do
        expect { monitor.run_until_empty_event }.not_to raise_error
        write_snapshot('monitor#run_until_empty_event.jsonl', io.tap(&:rewind).read)
      end
    end
  end

  describe '#run_forever' do
    # Takes about 10 seconds to not mock.
    # Logs are output under spec/snapshots, so check them visually.
    context 'when use thread' do
      around do |example|
        performance_schema_setting.enable!
        test_database_setup do |setup_client|
          setup_client.create_database
          setup_client.create_table
          setup_client.insert_initial_data
        end

        alter_table_thead = Thread.new { test_database_setup(&:alter_table) } # rubocop:disable ThreadSafety/NewThread

        example.run

        alter_table_thead.join
        test_database_setup(&:drop_database)
      end

      it do
        expect { Thread.new { monitor.run_forever }.tap { sleep(2) }.kill }.not_to raise_error  # rubocop:disable ThreadSafety/NewThread
        write_snapshot('monitor#run_forever.jsonl', io.tap(&:rewind).read)
      end
    end
  end
end
