require 'pry'


class Game
  attr_accessor :row_count, :column_count

  def initialize
    get_dimensions
    create_board
  end

  def get_dimensions
    puts "Enter number of rows(20-50 is best)"
    @row_count = gets.chomp.to_i
    puts "Enter number of columns(20-100 is best)"
    @column_count = gets.chomp.to_i
  end

  def create_board
    if @row_count > 50 || @column_count > 150 || (@row_count <= 0 || @column_count <= 0)
      puts "Please choose a non-negative value of a sensible size"
      sleep 2.0
      board = Board.new(50, 150, 0.5)
    else
      board = Board.new(@row_count, @column_count, 0.5)
    end

    board.start
  end
end


class Board


  attr_reader :rows, :columns, :density, :cells
  attr_accessor :live_cell_count

  def initialize(rows, columns, density)
    @rows = rows
    @columns = columns
    @density = density
    @cells = {}
  end

  def start
    initialize_board
    print_board
    run_game_loop
  end

  def run_game_loop
    turn_number = 1
    loop do
      draw_next_board
      draw_game_state_information(turn_number)
      turn_number += 1
      sleep 0.1
    end
  end

  def initialize_board
    initial_live_cells = place_initial_live_cells
    (0...@rows).each do |row|
      (0...@columns).each do |column|
        hash_position = Board.hash_position_helper([column.to_s, row.to_s])

        cell_state = initial_live_cells.has_key?(hash_position)  ? 'alive' : 'dead'
        @cells[hash_position] = Cell.new({:x => column, :y => row}, cell_state, self)
      end
    end
  end

  def place_initial_live_cells
    live_cells = {}
    starting_cells_count = (total_cells * @density).to_i
    self.live_cell_count = starting_cells_count

    while live_cells.size < starting_cells_count
      coords = [Random.rand(0...@columns), Random.rand(0...@rows)]
      live_cells[Board.hash_position_helper(coords)] = 'alive'
    end
    return live_cells
  end

  def get_next_cell_state
    get_live_cell_neighbor_count
    @cells.each do |key, cell|
      cell.determine_next_state
    end
  end

  def assign_next_state_to_cells
    @cells.each do |key, cell|
      cell.assign_next_state
    end
  end

  def build_board
    board = cells.map { |key, cell| cell = cell.alive? ? 'x' : '.' }
    new_line_positions = (1..@rows).map.with_index { |x, i| (x * @columns) + i }
    new_line_positions.map { |pos| board.insert(pos, "\n") }
    board.join
  end

  def draw_next_board
    get_next_cell_state
    assign_next_state_to_cells
    print_board
  end

  def draw_game_state_information(turn_number)
    turn_number_str = turn_number.to_s + " "
    turn_number_str += turn_number > 1 ? 'turns' : 'turn'
    puts "\n #{turn_number_str} /  #{live_cell_count} live cells"
  end

  def print_board
    # Clears the terminal -- hacky
    board = build_board
    puts "\e[H\e[2J"
    print board
  end

  def get_live_cell_neighbor_count
    @cells.each do |key, cell|
      cell.live_neighbors_count = cell.neighbors.select { |cell_position|
          @cells[cell_position].state == 'alive'
        }.count
    end
  end

  def total_cells
    @rows * @columns
  end

  def self.hash_position_helper(coords)
    coords.join("-").to_sym
  end
end

class Cell

  attr_reader :x_coord, :y_coord, :board, :neighbors

  attr_accessor :live_neighbors_count, :state, :next_state

  def initialize(coords, state, board)
    @x_coord = coords[:x]
    @y_coord = coords[:y]
    @state = state
    @board = board
    @neighbors = find_and_store_neighbors
  end

  def assign_next_state
    self.state = self.next_state
  end

  def determine_next_state
    if self.alive?
      possibly_change_live_cell_state
    else
      possibly_change_dead_cell_state
    end
  end

  def possibly_change_live_cell_state
    if @live_neighbors_count < 2 || @live_neighbors_count > 3
      self.next_state = 'dead'
      self.board.live_cell_count -= 1
    else
      self.next_state = self.state
    end
  end

  def possibly_change_dead_cell_state
    if @live_neighbors_count == 3
      self.next_state = 'alive'
      self.board.live_cell_count += 1
    else
      self.next_state = self.state
    end
  end

  def find_and_store_neighbors
    possible_neighbors = [[x_coord - 1, y_coord + 1], [x_coord, y_coord + 1], [x_coord + 1, y_coord + 1],
                          [x_coord - 1, y_coord],                             [x_coord + 1, y_coord],
                          [x_coord - 1, y_coord - 1], [x_coord, y_coord - 1], [x_coord + 1, y_coord - 1]]

    possible_neighbors
      .select { |x, y|
        x >= 0 && (x < board.columns) &&
        y >= 0 && (y < board.rows)
      }.map { |coords|
        Board.hash_position_helper(coords)
      }

  end

  def alive?
    state == 'alive'
  end

  def dead?
    !self.alive?
  end
end


Game.new()

require 'rspec'

describe 'game of life' do

  context "game" do
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


