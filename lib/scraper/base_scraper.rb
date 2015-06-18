module Scraper

  #
  # This is the Base scraper class.
  # All Scraper should inherit from it.
  #
  class BaseScraper

    #
    # @!attribute agent
    #   @return [Mechanize] the scraper's agent.
    #
    # @!attribute response_code
    #   @return [String] the last request's HTTP response code.
    #
    attr_accessor :agent, :response_code

    #
    # How many times the scraper will retry, if retrying
    # is active.
    #
    MAX_ATTEMPTS = 2

    #
    # Creates a new instance of the BaseScraper class.
    #
    # @param [Hash] opts a hash of options used to initialize the Scraper.
    #
    # @return [BaseScraper] a new instance of `BaseScraper`.
    #
    def initialize(opts = {})
      opts = {
        agent:  Mechanize.new
      }.merge!(opts)

      initialize_agent agent

    end

    #
    # Makes a GET request to the given URL.
    #
    # @param [String] url the URL to make the GET request to.
    # @param [Hash] args a hash that is merged with the URL params.
    #
    # @return [String] the body of the downloaded page.
    #
    def get(args)
      check_request(args)
    end

    #
    # Makes a POST request to the given URL.
    #
    # @param [String] url the URL to make the POST request to.
    # @param [Hash] args a hash that is merged with the URL params.
    #
    # @return [String] the body of the downloaded page.
    #
    def post(args)
      check_request(args)
    end

    #
    # Protected methods.
    #
    protected

    #
    # Initializes the Mechanize agent.
    #
    # @param [Mechanize] agent the scraper's agent.
    #
    def initialize_agent(agent = Mechanize.new)
      @agent = Mechanize.new do |agent|
        agent.user_agent_alias    = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).sample
        agent.follow_meta_refresh = true
        agent.keep_alive          = false
        agent.history.max_size    = 10
        agent.verify_mode         = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def check_request(args)
      raise Exception.new("Unsupported HTTP method.") unless [:get, :post]

      process_params(args)

      begin

        # This timeout logic is the same as the one in TimeoutableRequest.
        # Please refer to that file to understand why we're using a new
        # thread.
        thread = nil
        begin
          Timeout.timeout(10) do
            thread = Thread.new { @agent.send(args) }
            thread.join
          end
        ensure
          thread.kill
        end

        # Expires outdated cache entries.
        expire_cache_keys :page, :body, :parser

        @response_code = @agent.page.code.to_i
        return @agent.page.body

      rescue Mechanize::ResponseCodeError => exc
        log_exception(exc, args: args)


        @response_code = exc.response_code.to_i
        @error_page = exc.page
      rescue Timeout::Error => exc
        log_exception(exc, args: args)
      rescue Exception => exc
        log_exception(exc, args: args)
      ensure
        return
      end
    end

    def process_params(args = {})
      args ||= ''
    end

     def log_exception(exception, opts = {})
      opts = {
        args:   'unknown args'
      }.merge(opts)

      @logger.debug("\nFailed to download #{opts[:args]}")
      @logger.debug("Agent: #{@agent.inspect}")
      @logger.debug(exception)
      @logger.debug(exception.backtrace.join("\n"))
    end

  end

end
