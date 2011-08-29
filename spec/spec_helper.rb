require "rubygems"
require "bundler"
Bundler.require(:default, :development)

ENV["TEST"] = "yes"

unless ENV["CI"]
  require "ruby-debug"
  Debugger.start
end

require "webmock/rspec"

require_relative "../lib/cardo"

VCR.config do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.stub_with :webmock
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end

# VCR reponses encoded with gzip are not useful to edit
# Make sure they are not compressed
module RestClient
  class Request
    def default_headers_with_no_accept_encoding
      default_headers_without_no_accept_encoding.tap do |defaults|
        defaults.delete(:accept_encoding)
      end
    end
    alias_method :default_headers_without_no_accept_encoding, :default_headers
    alias_method :default_headers, :default_headers_with_no_accept_encoding
  end
end
