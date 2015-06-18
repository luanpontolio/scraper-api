#
# Scraper
#
module Scraper

  #
  # Returns the default logger that is used if the scraper does not define
  # its own logger.
  #
  # @return [Logger] a logger that points to a default log file.
  #
  def self.default_logger
    Scraper.define_logger('default')
  end

  #
  # Defines a logger in the proper location.
  #
  # @param [String] file_name the name of the log file.
  #
  # @return [Logger] the logger that points to the given log file.
  #
  def self.define_logger(file_name)
    path = "#{Rails.root}/log/scraper"

    # Creates the scrapers folder inside the log folder if necessary.
    FileUtils.mkdir_p path

    logger = Logger.new("#{path}/#{file_name}.log")
    # logger.formatter = "UTF-8"
    logger
  end

  def self.robot(args = {})
    Scraper::Robot.new.run(args)
  end

end

require 'scraper/robot.rb'
