require_relative "dsl/iteration_definition"

module Cardo
  class DSL
    def initialize
      @iteration_definitions = []
    end

    # Getter/setter DSL methods
    # If an argument is provided, it's a setter
    # If not, it's a getter
    [:api_key, :project_id].each do |method|
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

    def every_iteration(&block)
      _needed_release_dates.each do |date|
        dsl = IterationDefinition.new(self, date)
        dsl.instance_eval(&block)

        @iteration_definitions << dsl
      end
    end

    def finish!
      _validate_config!
      @iteration_definitions.each(&:finish!)
    end

    def create_story(options)
      _project.stories.build(options)
    end

    def pivot_day
      _project.week_start_day
    end

    def iteration_length_in_weeks
      _project.iteration_length
    end

    def current_iteration_number
      _project.current_iteration_number
    end

    def first_iteration_start_date
      Date.parse(_project.first_iteration_start_time)
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
          release.labels.split(",").include?("weekly-release") && Date.parse(release.deadline) == deadline.to_date
        else
          false
        end
      end
    end

    def _needed_release_dates
      # See: https://github.com/highgroove/office-tools/blob/master/ptup2date.rb#L74-79
      @needed_release_dates ||= [].tap do |needed_release_dates|
        first_iteration_end   = Chronic.parse(pivot_day, :now => first_iteration_start_date)
        current_iteration_end = Chronic.parse("#{current_iteration_number * iteration_length_in_weeks} weeks hence",
                                              :now => first_iteration_end)

        # TODO: Support multiple weeks?
        possible_needed_release_date = Chronic.parse("#{iteration_length_in_weeks} weeks hence",
                                                     :now => current_iteration_end)

        unless _release_exists?(possible_needed_release_date)
          needed_release_dates << possible_needed_release_date
        end
      end
    end
  end
end
