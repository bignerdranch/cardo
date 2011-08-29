require "spec_helper"
require "date"
require "uri"
require "active_support/core_ext/hash/except"

describe "basic weekly feature" do
  before do
    Timecop.freeze(Date.civil(2011, 8, 27))
  end

  after do
    Timecop.return
  end

  def run_cardo
    Cardo.describe do
      api_key "abc123"
      project_id 269443

      weekly do
        feature "Weekly Review", estimate: 1,
                                 labels: "weekly-review",
                                 owned_by: "Andy Lindeman"
      end
    end
  end

  context "with no stories" do
    use_vcr_cassette "basic_with_no_stories"

    it "creates the weekly review story" do
      run_cardo

      a_request(:post, "https://www.pivotaltracker.com/services/v3/projects/269443/stories").
        with do |req|
          Hash[URI.decode_www_form(req.body)] == {"story[project_id]" => "269443",
                                                  "story[story_type]" => "feature",
                                                  "story[name]"       => "Weekly Review",
                                                  "story[estimate]"   => "1",
                                                  "story[labels]"     => "weekly-review",
                                                  "story[owned_by]"   => "Andy Lindeman"}
        end.should have_been_made
    end

    it "creates the weekly release" do
      run_cardo

      a_request(:post, "https://www.pivotaltracker.com/services/v3/projects/269443/stories").
        with do |req|
          body_params = Hash[URI.decode_www_form(req.body)]

          success = body_params.except("story[deadline]") == {"story[project_id]" => "269443",
                                                              "story[story_type]" => "release",
                                                              "story[name]"       => "Wednesday, September 07 2011",
                                                              "story[labels]"     => "weekly-release"}

          success &= body_params["story[deadline]"] &&
                     body_params["story[deadline]"].start_with?("2011-09-07")
        end.should have_been_made
    end
  end

  context "with existing stories" do
    use_vcr_cassette "basic_with_existing_stories"

    it "does not create stories" do
      run_cardo

      a_request(:post, "https://www.pivotaltracker.com/services/v3/projects/269443/stories").
        should_not have_been_made
    end
  end
end
