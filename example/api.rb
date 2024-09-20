require 'sinatra'
require 'json'
module OrderService
  class API < Sinatra::Base
    get '/order/user/:user_id' do
       “List of orders for user #{user_id}”
    end
  end
end