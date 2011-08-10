module Cardo
  class User < Struct.new(:pt_api_key)
    pivotal_tracker_for :pt_api_key
  end
end
