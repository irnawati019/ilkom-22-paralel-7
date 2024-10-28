require 'sinatra'
require 'json'
module Mahasiswa
  class API < Sinatra::Base
    get '/'do
    'selamat anda kena prank'
  end
    get '/mahasiswa/:nim' do
       "list your nim #{nim}"
    end
  end
end