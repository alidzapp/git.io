require "net/http"
require "uri"

module Gitio
  autoload :VERSION,    "gitio/version"
  autoload :Error,      "gitio/errors"
  autoload :CLI,        "gitio/cli"

  # Shorten the given <tt>url</tt> with git.io.
  #
  # If <tt>code</tt> is given, git.io will attempt
  # to use it in place of a random value for the
  # shortened URL.
  def self.shorten(url, code=nil)
    Net::HTTP.start "git.io", 443, :use_ssl => true do |http|
      request = Net::HTTP::Post.new "/"
      request.content_type = "application/x-www-form-urlencoded"

      query = Hash.new.tap do |h|
        h[:url] = url
        h[:code] = code if code
      end

      request.body = URI.encode_www_form(query)

      response = http.request(request)

      if response.key? "Location"
        return response["Location"]
      else
        raise Error, response.body
      end
    end
  end

  # Expand the given <tt>url</tt> to its original form.
  def self.lengthen(url)
    url = URI(url)

    Net::HTTP.start url.host, 443, :use_ssl => true do |http|
      request = Net::HTTP::Get.new url.path

      response = http.request(request)
      return response["Location"]
    end
  end

end
