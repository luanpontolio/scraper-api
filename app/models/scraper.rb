class Scraper < ActiveRecord::Base

  attr_accessor :url, :elements

  validates_presence_of :url, :elements

end
