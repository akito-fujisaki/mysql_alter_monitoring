# frozen_string_literal: true

# TestDatabaseHelper
module TestDatabaseHelper
  # @return [MysqlAlterMonitoring::Client]
  def build_client
    MysqlAlterMonitoring::Client.build_by_url(ENV.fetch('DATABASE_URL'))
  end

  # @yieldparam setup_client [TestDatabaseSetup]
  # @yieldreturn [void]
  # @return [TestDatabaseSetup]
  def test_database_setup
    yield(TestDatabaseSetupClient.new(build_client))
  end
end
