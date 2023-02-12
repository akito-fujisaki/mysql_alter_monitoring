# frozen_string_literal: true

RSpec.describe MysqlAlterMonitoring::CLI do
  let(:cli) { described_class.new(args, io: io) }
  let(:io) { StringIO.new }
  let(:logs) { io.tap(&:rewind).readlines.map(&:chomp) }

  context 'when a non-existent option is specified' do
    let(:args) { ['run', '--foo', 'bar'] }
    let(:expected_logs) { ['invalid option: --foo'] + cli.help.split("\n") }

    it do
      cli.run
      expect(logs).to eq expected_logs
    end
  end

  context 'when a non-existent command is specified' do
    let(:args) { ['foo', '--url', ENV.fetch('DATABASE_URL')] }
    let(:expected_logs) { ['Invalid command: foo'] + cli.help.split("\n") }

    it do
      cli.run
      expect(logs).to eq expected_logs
    end
  end

  context 'when --url is invalid' do
    let(:args) { ['run', '--url', 'invalid'] }
    let(:expected_logs) { ['URL scheme must be mysql2'] + cli.help.split("\n") }

    it do
      cli.run
      expect(logs).to eq expected_logs
    end
  end

  context 'when --help is specified' do
    let(:args) { ['run', '--help'] }
    let(:expected_logs) { cli.help.split("\n") }

    it do
      cli.run
      expect(logs).to eq expected_logs
    end
  end

  context 'when --version is specified' do
    let(:args) { ['run', '--version'] }
    let(:expected_logs) { ["MysqlAlterMonitoring #{MysqlAlterMonitoring::VERSION}"] }

    it do
      cli.run
      expect(logs).to eq expected_logs
    end
  end

  context 'when command is enable' do
    let(:performance_schema_setting) { instance_double(MysqlAlterMonitoring::PerformanceSchemaSetting) }
    let(:args) { ['enable', '--url', ENV.fetch('DATABASE_URL')] }

    before do
      allow(performance_schema_setting).to receive(:enable!)
      allow(MysqlAlterMonitoring::PerformanceSchemaSetting).to receive(:new).and_return(performance_schema_setting)
    end

    it do
      cli.run
      expect(performance_schema_setting).to have_received(:enable!)
    end
  end

  context 'when command is disable' do
    let(:performance_schema_setting) { instance_double(MysqlAlterMonitoring::PerformanceSchemaSetting) }
    let(:args) { ['disable', '--url', ENV.fetch('DATABASE_URL')] }

    before do
      allow(performance_schema_setting).to receive(:disable!)
      allow(MysqlAlterMonitoring::PerformanceSchemaSetting).to receive(:new).and_return(performance_schema_setting)
    end

    it do
      cli.run
      expect(performance_schema_setting).to have_received(:disable!)
    end
  end

  context 'when command is run' do
    let(:monitor) { instance_double(MysqlAlterMonitoring::Monitor) }
    let(:args) { ['run', '--url', ENV.fetch('DATABASE_URL')] }

    before do
      allow(monitor).to receive(:run_until_empty_event)
      allow(MysqlAlterMonitoring::Monitor).to receive(:new).and_return(monitor)
    end

    it do
      cli.run
      expect(monitor).to have_received(:run_until_empty_event)
    end
  end

  context 'when command is run-forever' do
    let(:monitor) { instance_double(MysqlAlterMonitoring::Monitor) }
    let(:args) { ['run-forever', '--url', ENV.fetch('DATABASE_URL')] }

    before do
      allow(monitor).to receive(:run_forever)
      allow(MysqlAlterMonitoring::Monitor).to receive(:new).and_return(monitor)
    end

    it do
      cli.run
      expect(monitor).to have_received(:run_forever)
    end
  end
end
