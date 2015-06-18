module Scraper

  module StatusCodeScraper
    SUCCESS                       = "200 - Succeessful action."
    INTERNAL_ERROR                = "400 - Internal error"
    PARAMETERS_BLANK              = "401 - At least one mandatory parameter is blank."
    INVALID_PARAMETERS            = "402 - Invalid parameters were sent."
    SITE_UNAVAILABLE              = "403 - The source site is temporarily unavailable."
    BLOCKED_REQUEST               = "404 - The source site has blocked the request."
    NON_EXISTENT                  = "405 - The data does not exist in the source site's database."
    UNEXPECTED_INCORRECT_RESPONSE = "406 - Error Unexpected"
  end

end
