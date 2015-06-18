class Api::V1::ScraperController < ActionController::Base
  respond_to :json, :xml, :html

  before_filter :to_params

  def index
  	result = robot
  	render :json => result
  end

  private

  def robot
  	args = to_params
  	Scraper::Robot.new.run(args)
  end

  def to_params
    JSON.parse(params.to_json).symbolize_keys
  end

end
