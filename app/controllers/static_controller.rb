class StaticController < ApplicationController

  # No authentication required
  skip_before_filter :require_login
  skip_authorization_check only: [:index, :content, :login]

  def dashboard
    render layout: nil
  end

  # def content
  #   # A simple anonymous proxy - pass through to one-domain only - GET requests only!
  #   base_url = params[:url]
  #   base_url += '/' if base_url.include?('health-wellbeing') or base_url.include?('training-and-performance')
  #   resp = Net::HTTP.get_response(URI("http://champtracker.wpengine.com/#{base_url}"))
  #   unless resp.body.present?
  #     head resp.code
  #     return
  #   end
  #
  #   # Re-write any URLs
  #   rewritten = resp.body.to_s.split("\n").collect { |x|
  #     x.gsub(/http:\/\/champtracker.wpengine.com\//, 'https://app.champtracker.com/content/')
  #   }.join("\n")
  #
  #   # Ignore JS cross-resource
  #   @marked_for_same_origin_verification = false if resp['Content-Type'].include?('javascript')
  #
  #   # Render it straight out to the browser
  #   render content_type: resp['Content-Type'], body: rewritten.html_safe, status: resp.code
  # end
end
