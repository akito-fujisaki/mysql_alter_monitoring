# frozen_string_literal: true

require 'securerandom'

# TestDatabaseSetupClient
class TestDatabaseSetupClient
  # @return [String]
  TEST_DATABASES_NAME = 'test'
  private_constant :TEST_DATABASES_NAME
  # @return [String]
  TEST_TABLE_NAME = 'sample'
  private_constant :TEST_TABLE_NAME
  # @return [Integer]
  INITIAL_DATA_SIZE = 500_000
  private_constant :INITIAL_DATA_SIZE
  INSERT_BULK_SIZE = 100_000
  private_constant :INSERT_BULK_SIZE

  # @param client [MysqlAlterMonitoring::Client]
  # @return [void]
  def initialize(client)
    @client = client
  end

  # @return [void]
  def create_database
    client.query("CREATE DATABASE IF NOT EXISTS #{TEST_DATABASES_NAME}")
  end

  # @return [void]
  def create_table
    client.query <<~SQL
      CREATE TABLE IF NOT EXISTS #{TEST_DATABASES_NAME}.#{TEST_TABLE_NAME} (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        col1 VARCHAR(255) DEFAULT '' NOT NULL
      )
    SQL
  end

  # @return [void]
  def insert_initial_data
    (1..INITIAL_DATA_SIZE).each_slice(INSERT_BULK_SIZE) do |list|
      list.map { "('#{SecureRandom.hex(50)}')" }
          .join(',')
          .then { "INSERT INTO #{TEST_DATABASES_NAME}.#{TEST_TABLE_NAME} (col1) VALUES #{_1}" }
          .then { client.query(_1) }
    end
  end

  # @return [void]
  def alter_table
    client.query(
      "ALTER TABLE #{TEST_DATABASES_NAME}.#{TEST_TABLE_NAME} ADD INDEX col1_index(col1)"
    )
  end

  # @return [void]
  def drop_database
    client.query("DROP DATABASE IF EXISTS #{TEST_DATABASES_NAME}")
  end

  private

  # @!attribute [r] client
  # @return [MysqlAlterMonitoring::Client]
  attr_reader :client
end
