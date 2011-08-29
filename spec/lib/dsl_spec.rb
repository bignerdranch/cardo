require "spec_helper"

describe Cardo::DSL do
  describe "#pivot_day" do
    it "determines the pivot day based on the project information from the Tracker API" do
      dsl = Cardo::DSL.new
      dsl.stub(:_project).and_return(double(:week_start_day => "Monday"))

      dsl.pivot_day.should == "Monday"
    end
  end
end
