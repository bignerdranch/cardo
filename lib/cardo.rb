require "peaty"
require "chronic"

require_relative "cardo/version"
require_relative "cardo/exceptions"
require_relative "cardo/user"
require_relative "cardo/dsl"

module Cardo
  RETRY_INTERVAL = 10

  def self.describe(&block)
    dsl = Cardo::DSL.new
    dsl.instance_eval(&block)

    dsl.finish!
  end

  def self.run_with_retry
    begin
      yield
    rescue Exception => e
      notice_error(e)

      sleep RETRY_INTERVAL
      retry
    end
  end

  def self.notice_error(e)
    $stderr.puts "OH NOES, AN ERROR OCCURED"
    $stderr.puts "#{e.message} (#{e.class})"
    $stderr.puts "#{e.backtrace.join("\n").gsub(/^/, "  ")}"
    $stderr.puts
    $stderr.puts "RETRYING IN 10 SECONDS"
  end

  def self.randomize_pairings(users)
    # TODO: Cleanup from original code
    pairings = []
    while pairings == [] do
      code_reviewees = users.shuffle
      users.each do |reviewer|
        reviewee = reviewer

        # Try again if we got to the end and someone is stuck reviewing themself
        if code_reviewees.count == 1 && code_reviewees.first == reviewer
          pairings = []
          break
        end

        while reviewer == reviewee do
          code_reviewees << code_reviewees.shift
          reviewee = code_reviewees.last
          pairings << [reviewer, code_reviewees.pop] unless reviewer == code_reviewees.last
        end
      end
    end
    pairings
  end
end
