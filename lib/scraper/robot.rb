# encoding utf-8

module Scraper

  #
  # class Robot
  # return output Hash
  #
  class Robot < BaseScraper


    def initialize
      super(logger: Scraper.define_logger('robot'))
    end

    #
    # Returns the default logger that is used if the scraper does not define
    # its own logger.
    #
    # @return [Logger] a logger that points to a default log file.
    #
    def self.default_logger
      Scraper.define_logger('robot')
    end

    #
    # Parameters of args is blank if yes, returns message error,
    # case no, @args receives args.
    #
    def verify_args(args = {})
      if args.blank?
        return { message: Scraper::StatusCodeScraper::PARAMETERS_BLANK }
      elsif args[:url].blank?
        return { message: Scraper::StatusCodeScraper::INVALID_PARAMETERS }
      elsif args[:elements].blank?
        return { message: Scraper::StatusCodeScraper::INVALID_PARAMETERS }
      else
        initialize_agent
        @args = args
      end
    end

    def run(args = {})
      verify_args(args)

      @agent.get @args[:url]

      if(hsh = request_response)
        return hsh
      end

      output = {}
      output[:time]     = Time.zone.now
      output[:elements] = { url: @args[:url], elements: @args[:elements] }
      output[:data]     = parse_result(@agent.page.parser)
      output[:message]  = Scraper::StatusCodeScraper::SUCCESS

      output
    end

    def split_elements
      @args[:elements].split(',').join(' ')
    end

    def parse_result(doc)
      elements = split_elements

      values = doc.css("#{elements}").map { |element| element.text.gsub(/[[:space:]]+/, ' ').strip }
      data   = verify_data(values)

      data
    end

    def verify_data(data = [])
      return { message: Scraper::StatusCodeScraper::NON_EXISTENT } if data.blank?

      data.reject(&:empty?)
    end

    def request_response
      if @agent.page.body == "Este host"
        return { message: Scraper::StatusCodeScraper::UNEXPECTED_INCORRECT_RESPONSE }
      end
    end

  end

end
