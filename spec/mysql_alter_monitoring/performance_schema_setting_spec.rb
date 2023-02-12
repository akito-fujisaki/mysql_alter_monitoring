# frozen_string_literal: true

RSpec.describe MysqlAlterMonitoring::PerformanceSchemaSetting do
  let(:performance_schema_setting) { described_class.new(build_client, io) }
  let(:io) { StringIO.new }
  let(:logs) { io.tap(&:rewind).readlines.map { JSON.parse(_1, symbolize_names: true) } }

  before { freeze_time }

  after { performance_schema_setting.enable! }

  it 'can be toggled enable and disable' do
    performance_schema_setting.enable!

    expect(performance_schema_setting.enable?).to be true

    performance_schema_setting.disable!

    expect(performance_schema_setting.enable?).to be false

    expected_logs = [
      { level: 'INFO', message: 'Enable monitoring settings for the performance schema', timestamp: Time.now.to_s },
      { level: 'INFO', message: 'Disable monitoring settings for the performance schema', timestamp: Time.now.to_s }
    ]
    expect(logs).to eq expected_logs
  end
end
