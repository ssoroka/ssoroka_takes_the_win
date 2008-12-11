require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require 'ssoroka_takes_the_win/ssoroka_takes_the_win'

describe SsorokaTakesTheWin::SsorokaTakesTheWin do
  
  before(:each) do
    @game = SsorokaTakesTheWin::SsorokaTakesTheWin.new
    @grid = @game.instance_variable_get("@grid")
  end
  
  def run_scores
    @game.send :score_grid
    @grid_score = @game.instance_variable_get("@grid_score")
  end

  it "should be instantiable with no paramters" do

    lambda { SsorokaTakesTheWin::SsorokaTakesTheWin.new }.should_not raise_error

  end

  it "should score cell 0, 0 poorly (-10) if the cell right of it is a miss" do
    @grid = @game.instance_variable_get("@grid")
    @grid.set(0, 1, :miss)
    run_scores
    @grid_score.get(0, 0).should == -10
  end
  
  it "should score cell 0, 0 poorly (-20) if the cells right and below it are a miss" do
    @grid.set(0, 1, :miss)
    @grid.set(1, 0, :miss)
    run_scores
    @grid_score.get(0, 0).should == -20
  end
  
  it "should not pick cells that you've previously shot at" do
    (0..99).to_a.each{|i|
      if i != 50
        @grid.set(i / 10, i % 10, :miss)
      end
    }
    run_scores
    best = @game.send :pick_best
    best.should == [5, 0]
  end
  
  it "should guess next to a hit" do
    @grid.set(0, 1, :hit)
    @grid.set(1, 0, :hit)
    @grid.set(1, 1, :miss)
    run_scores
    best = @game.send :pick_best
    best.should == [0, 0]
  end
  
end