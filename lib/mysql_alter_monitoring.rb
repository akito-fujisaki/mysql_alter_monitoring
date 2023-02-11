# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'json'
require 'logger'
require 'uri'
require 'mysql2'
require_relative 'mysql_alter_monitoring/version'
require_relative 'mysql_alter_monitoring/config'
require_relative 'mysql_alter_monitoring/performance_schema_setting'
require_relative 'mysql_alter_monitoring/json_logger'
require_relative 'mysql_alter_monitoring/client'
require_relative 'mysql_alter_monitoring/monitor'

# MysqlAlterMonitoring
module MysqlAlterMonitoring
  # MysqlAlterMonitoring::Error
  class Error < StandardError; end
end
