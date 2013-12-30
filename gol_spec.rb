require 'rspec'
require '/Users/wls/code/gol/ruby-gol/gol.rb'
require 'pry'

describe 'game of life' do

  context "game" do

    let(:game) { Game.new }

    before do
      game.row_count = 10
      game.column_count = 10
    end

    it "is not nil when initiated" do
      expect(game).not_to eq(nil)
    end

    it "creates a board with a default(50) width when given a zero/neg width" do
      game.column_count = -10
      board = game.create_board
      expect(board.columns).to eq(150)
    end

    it "creates a board with a default(150) height when given a zero/neg height" do
      game.row_count = -10
      board = game.create_board
      expect(board.rows).to eq(50)
    end

    it "creates a 50x150 board when given two negative dimensions" do
      game.row_count = -10
      board = game.create_board
      expect([board.rows, board.columns]).to eq([50, 150])
    end
  end

  context "board", focus: true do

    context "setup" do

      let(:board) { Board.new(50, 150, 0.5) }

      it "creates the number of live cells according the density given" do
        alive_cells =  board.cells.select { |key, cell| cell.alive? }.size
        expect(board.live_cell_count).to eq(alive_cells)
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


