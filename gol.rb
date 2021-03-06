require 'pry'

class Game
  attr_reader :is_test

  attr_accessor :row_count, :column_count, :board

  def initialize(is_test=false)
    @is_test = is_test
    ask_for_multiple_board_game
    get_dimensions
    @boards = @boards_count.times.map { create_board }
  end

  def ask_for_multiple_board_game
    puts "How many boards would you like to render?"
    @boards_count = gets.chomp.to_i
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
      sleep 2.0 if not @is_test
      Board.new(50, 150, 0.5)
    else
      Board.new(@row_count, @column_count, 0.5)
    end
  end

  def start_board
    @boards.each(&:print_board)

    turn_number = 1
    loop do
      @boards.each do |b|
        b.draw_next_board
        b.draw_game_state_information(turn_number)
        puts "\n\n"
      end
      turn_number += 1
      sleep 0.1
      puts "\e[H\e[2J"
    end
  end
end


class Board


  attr_reader :rows, :columns, :density, :cells
  attr_accessor :live_cell_count

  def initialize(rows, columns, density)
    @rows = rows
    @columns = columns
    @density = density
    @cells = initialize_board
  end

  def initialize_board
    initial_live_cells = place_initial_live_cells
    initial_board = {}

    (0...@rows).each do |row|
      (0...@columns).each do |column|
        hash_position = Board.hash_position_helper([column.to_s, row.to_s])

        cell_state = initial_live_cells.has_key?(hash_position)  ? 'alive' : 'dead'
        initial_board[hash_position] = Cell.new({:x => column, :y => row}, cell_state, self)
      end
    end

    return initial_board
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

def load_game
  game = Game.new()
  game.start_board
end

load_game
