require 'rspec'
require '/Users/wls/code/gol/ruby-gol/gol.rb'
require 'pry'

describe 'game of life' do

  context "game" do

    let(:game) { Game.new(is_test=true) }

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

  context "board" do

    context "setup" do
      it "creates the number of live cells according the density given" do
        board = Board.new(50, 150, 0.5)
        alive_cells =  board.cells.select { |key, cell| cell.alive? }.size
        expect(board.live_cell_count).to eq(alive_cells)
      end

      it "correctly assigns each cell a count of its neighbors" do
        board = Board.new(10,10, 1)
        cell = board.cells.first[1] # get the cell not the hash key
        live_cells = cell.neighbors.select { |n| board.cells[n].alive? }.size
        expect(live_cells).to eq(cell.neighbors.size)
      end
    end

    context "game mechanics" do
      ## Add more here
    end
  end

  context "cell" do

    context "when living" do

      let(:board) { Board.new(3, 3, 0) }

      before do
        @cell = board.cells[:"1-1"] # has 9 neighbors
        @cell.state = "alive"
      end

      it "live cell with fewer than two live neighbours dies, as if caused by under-population." do
        board.get_live_cell_neighbor_count
        @cell.determine_next_state

        expect(@cell.next_state).to eq("dead")
      end

      it "live cell with two or three live neighbours lives on to the next generation." do
        @cell.neighbors.take(2).each do |key|
          board.cells[key].state = "alive"
        end

        board.get_live_cell_neighbor_count
        @cell.determine_next_state
        expect(@cell.next_state).to eq("alive")
      end

      it "cell with more than three live neighbours dies, as if by overcrowding." do
        @cell.neighbors.take(5).each do |key|
          board.cells[key].state = "alive"
        end

        board.get_live_cell_neighbor_count
        @cell.determine_next_state
        expect(@cell.next_state).to eq("dead")
      end
    end

    context  "when dead" do

      let(:board) { Board.new(3, 3, 0) }

      before do
        board.cells.each { |key, cell| cell.state = "alive" }
        @cell = board.cells[:"0-0"] # has exactly 3 live neighbors
        @cell.state = "dead"
      end

      it "cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
        board.get_live_cell_neighbor_count

        @cell.determine_next_state
        expect(@cell.next_state).to eq("alive")
      end

      it "cell with something other than three live neighbors remains dead" do
        board.cells[:"0-1"].state = "dead"
        board.get_live_cell_neighbor_count

        @cell.determine_next_state
        expect(@cell.next_state).to eq("dead")
      end
    end
  end
end


