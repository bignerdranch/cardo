module Cardo
  class DSL
    class IterationDefinition
      def initialize(dsl, release_date)
        @dsl          = dsl
        @release_date = release_date

        @stories      = []
      end

      def feature(name, options)
        @stories << {story_type: :feature,
                     name:       name}.merge(options)
      end

      def random_pairing(name, users, options)
        Cardo.randomize_pairings(users).each do |pairee, pairer|
          feature name % [pairee, pairer],
                  options.merge(owned_by: pairer)
        end
      end

      def random(name, users, options)
        user = users.sample
        feature name % user,
                options.merge(owned_by: user)
      end

      def finish!
        # TODO: Move after previous release
        release_name  = @release_date.strftime('%A, %B %d %Y')
        release_story = @dsl.create_story(story_type: :release,
                                          name:       release_name,
                                          deadline:   @release_date,
                                          labels:     "weekly-release")
        Cardo.run_with_retry do
          release_story.save
        end

        @stories.each do |options|
          story = @dsl.create_story(options)

          Cardo.run_with_retry do
            story.save
          end

          Cardo.run_with_retry do
            story.move(:before => release_story)
          end
        end
      end
    end
  end
end
