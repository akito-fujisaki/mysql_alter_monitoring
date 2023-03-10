# frozen_string_literal: true

RSpec.describe MysqlAlterMonitoring::Config do
  describe '.build_by_url' do
    subject(:build_by_url) { described_class.build_by_url(url) }

    context 'when url is valid' do
      let(:url) { 'mysql2://root:pass@0.0.0.0:9999/foo?pool=5' }
      let(:expected_attributes) do
        {
          host: '0.0.0.0',
          port: 9999,
          user: 'root',
          password: 'pass'
        }
      end

      it { is_expected.to have_attributes expected_attributes }
    end

    context 'when url does not include port' do
      let(:url) { 'mysql2://root:pass@0.0.0.0/foo?pool=5' }
      let(:expected_attributes) do
        {
          host: '0.0.0.0',
          port: 3306,
          user: 'root',
          password: 'pass'
        }
      end

      it { is_expected.to have_attributes expected_attributes }
    end

    context 'when url schema is not mysql2' do
      let(:url) { 'postgresql://root:pass@0.0.0.0:9999/foo?pool=5' }

      it { expect { build_by_url }.to raise_error ArgumentError }
    end

    context 'when url is empty string' do
      let(:url) { '' }

      it { expect { build_by_url }.to raise_error ArgumentError }
    end
  end

  describe '#new' do
    subject(:new) do
      described_class.new(
        host: host,
        port: port,
        user: user,
        password: password
      )
    end

    let(:host) { '0.0.0.0' }
    let(:port) { 3_306 }
    let(:user) { 'root' }
    let(:password) { 'pass' }

    context 'when args are valid' do
      it { is_expected.to be_an_instance_of described_class }
    end

    context 'when host is empty string' do
      let(:host) { '' }

      it { expect { new }.to raise_error ArgumentError }
    end

    context 'when port is 0' do
      let(:port) { 0 }

      it { expect { new }.to raise_error ArgumentError }
    end

    context 'when user is empty string' do
      let(:user) { '' }

      it { expect { new }.to raise_error ArgumentError }
    end

    context 'when password is empty string' do
      let(:password) { '' }

      it { expect { new }.to raise_error ArgumentError }
    end
  end
end
