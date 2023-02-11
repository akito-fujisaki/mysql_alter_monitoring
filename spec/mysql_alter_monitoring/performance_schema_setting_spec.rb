# frozen_string_literal: true

RSpec.describe MysqlAlterMonitoring::PerformanceSchemaSetting do
  let(:performance_schema_setting) { described_class.new(build_client) }

  after { performance_schema_setting.enable! }

  it do
    performance_schema_setting.enable!

    expect(performance_schema_setting.enable?).to be true

    performance_schema_setting.disable!

    expect(performance_schema_setting.enable?).to be false
  end
end
