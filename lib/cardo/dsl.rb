require_relative "dsl/weekly"

module Cardo
  class DSL
    def initialize
      @recurring_dsls = []
    end

    # Getter/setter DSL methods
    # If an argument is provided, it's a setter
    # If not, it's a getter
    [:api_key, :project_id, :pivot_day].each do |method|
      class_eval <<-EOE
        def #{method}(arg = nil)
          if arg
            @#{method} = arg
          else
            @#{method}
          end
        end
      EOE
    end

    def weekly(options = {}, &block)
      _needed_release_dates.each do |date|
        dsl = Cardo::DSL::Weekly.new(self, date, options)
        dsl.instance_eval(&block)

        @recurring_dsls << dsl
      end
    end

    def finish!
      _validate_config!
      @recurring_dsls.each(&:finish!)
    end

    def create_story(options)
      _project.stories.build(options)
    end

    private

    def _validate_config!
      messages = []
      messages << "api_key must be provided"    if api_key.nil?
      messages << "project_id must be provided" if project_id.nil?
      messages << "pivot_day must be provided"  if pivot_day.nil?
      raise Cardo::ConfigurationError, messages.join(", ") unless messages.empty?
    end

    def _project
      @project ||= _user.pivotal_tracker_projects.find(project_id)
    end

    def _user
      @user ||= User.new(api_key)
    end

    def _releases
      @releases ||= _project.releases.all
    end

    def _release_exists?(deadline)
      _releases.any? do |release|
        if release.attributes.key?("deadline") && release.attributes.key?("labels")
          release.labels.split(",").include?("weekly-release") && Time.parse(release.deadline) == deadline
        else
          false
        end
      end
    end

    def _needed_release_dates
      # See: https://github.com/highgroove/office-tools/blob/master/ptup2date.rb#L74-79
      # TODO: Cleanup

      if @needed_release_dates
        @needed_release_dates
      else
        @needed_release_dates = [].tap do |needed_release_dates|
          tmp_release_date = Chronic.parse("next #{pivot_day}")
          # TODO: Multiple weeks
          1.times do
            tmp_release_date = release_date = Chronic.parse("next #{pivot_day}", :now => tmp_release_date)

            needed_release_dates << release_date unless _release_exists?(release_date)
          end
        end
      end
    end
  end
end