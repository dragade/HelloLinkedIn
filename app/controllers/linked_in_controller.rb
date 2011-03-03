class LinkedInController < ApplicationController

  # TODO: Go to https://www.linkedin.com/secure/developer, request a developer key and fill it in here!
  CONSUMER_KEY = ""
  CONSUMER_SECRET = ""

  def authenticate

    # TODO: by default, rails uses cookie based sessions. Although the cookie can be encrypted, storing the access_token and access_token_secret in a cookie
    # is generally not a good idea. If this is an app that will go to production, you may want to use Active Record Session Store, memcached, etc.

    if CONSUMER_KEY && CONSUMER_SECRET
      @client = LinkedIn::Client.new(CONSUMER_KEY, CONSUMER_SECRET)
      if is_logged_in
        @client.authorize_from_access(session[:access_token], session[:access_token_secret])
      elsif has_request_token
        session[:access_token], session[:access_token_secret] = @client.authorize_from_request(session[:request_token], session[:request_token_secret], params[:oauth_verifier])
      else
        request_token = @client.request_token({:oauth_callback => request.url})
        session[:request_token] = request_token.token
        session[:request_token_secret] = request_token.secret
        redirect_to request_token.authorize_url
      end
    else
      raise "You must specify a consumer key and consumer secret in linkedin_controller.rb!"
    end
  end

  def has_request_token
    session[:request_token] && session[:request_token_secret]
  end

  def is_logged_in
    session[:access_token] && session[:access_token_secret]
  end

  def intro

  end

  def profile
    authenticate
    @profile = @client.profile(:fields => [:first_name, :last_name, :picture_url, :headline])
  end

  # This shows how to use the client from the linkedin gem to make REST calls since it's already set up
  # the method calls the people search API
  def apicall
    authenticate
    # Make a request for the data in JSON format
    @rest_url = "/v1/people-search:(people:(id,first-name,last-name,headline),num-results)"
    json_txt = @client.access_token.get(@rest_url, 'x-li-format' => 'json').body

    @results = []
    @parsed_data = JSON.parse(json_txt)
    if @parsed_data['people'] && @parsed_data['people']['values'] then
      @parsed_data['people']['values'].each do |p|
        result = p['firstName'] + " " + p['lastName'] + " (" + p['headline'] + ")"
        @results << result
      end

    end

    @pretty_data = JSON.pretty_generate(@parsed_data)
  end

end
