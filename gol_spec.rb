require 'rspec'
require '/Users/wls/code/gol/ruby-gol/gol.rb'

describe 'game of life' do

  context "game" do

    it "is not nil" do
      game = Game.new
      expect(game).not_to eq(nil)
    end

    it "does not create a board with a zero or negative width" do
    end

    it "does not create a board with a zero or negative height" do

    end
  end

  context "board" do


    context "setup" do

      it "creates the number of live cells according the density given" do
      end

      it "correctly assigns each cell a count of its neighbors" do
      end
    end

    context "game mechanics" do
    end

    context "runs the game taking into account the previous board" do
    end
  end

  context "cell" do

    context "when living" do

      before do
      end

      it "live cell with fewer than two live neighbours dies, as if caused by under-population." do
      end

      it "live cell with two or three live neighbours lives on to the next generation." do
      end

      it "cell with more than three live neighbours dies, as if by overcrowding." do
      end
    end

    context  "when dead" do

      it "cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
      end

      it "cell with something other than three live neighbors dies" do
      end
    end
  end
end


