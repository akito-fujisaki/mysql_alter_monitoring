# frozen_string_literal: true

module MysqlAlterMonitoring
  # MysqlAlterMonitoring::Config
  class Config
    # @return [String]
    SUPPROTED_URI_SCHEME = 'mysql2'
    private_constant :SUPPROTED_URI_SCHEME
    # @return [Integer]
    DEFAULT_PORT = 3306
    public_constant :DEFAULT_PORT

    class << self
      # Build config in DATABSE_URL format used in Rails.
      # URI scheme must be mysql2.
      # Example: mysql2://root:pass@0.0.0.0:3306/foo?pool=5
      #
      # @param url [String]
      # @return [MysqlAlterMonitoring::Config]
      def build_by_url(url)
        uri = URI.parse(url)

        raise ArgumentError, 'URL scheme must be mysql2' if uri.scheme != SUPPROTED_URI_SCHEME

        new(
          host: uri.hostname,
          port: uri.port,
          user: uri.user,
          password: uri.password
        )
      end
    end

    # @!attribute [r] host
    # @return [String]
    attr_reader :host
    # @!attribute [r] port
    # @return [Integer]
    attr_reader :port
    # @!attribute [r] user
    # @return [String]
    attr_reader :user
    # @!attribute [r] password
    # @return [String]
    attr_reader :password

    # @param host [String]
    # @param port [Integer]
    # @param user [String]
    # @param password [String]
    # @return [void]
    # @raise [ArgumentError]
    def initialize(host:, port:, user:, password:)
      @host = host
      @port = port || DEFAULT_PORT
      @user = user
      @password = password
      validate!
    end

    private

    # @return [void]
    # @raise [ArgumentError]
    def validate!
      raise ArgumentError, 'host must be specified' if host.empty?
      raise ArgumentError, 'port must be positive' unless port.positive?
      raise ArgumentError, 'user must be specified' if user.empty?
      raise ArgumentError, 'password must be specified' if password.empty?
    end
  end
end
