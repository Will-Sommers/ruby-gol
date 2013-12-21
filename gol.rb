require 'pry'
class Board

  attr_accessor :rows, :columns, :density, :cells

  def initialize(rows, columns, density)
    @rows = rows
    @columns = columns
    @density = density
    @cells = {}
  end

  def start
    make_board
    print_board
    run_game_loop
  end

  def run_game_loop
    i = 1
    loop do
      draw_next_board
      draw_game_state_information(i)
      i += 1
      sleep 0.2
    end
  end

  def make_board
    cell_arr = []
    while cell_arr.size < initial_live_cells
      x_coord = Random.rand(0...@columns)
      y_coord = Random.rand(0...@rows)
      cell_arr << [x_coord, y_coord] unless cell_arr.include?([x_coord, y_coord])
    end
    (0...@rows).each do |row|
      (0...@columns).each do |column|
        state = cell_arr.include?([column, row]) ? 'alive' : 'dead'
        cell = Cell.new(column, row, state)
        pos = (column.to_s + "-" + row.to_s).to_sym
        @cells[pos] = cell
      end
    end
  end

  def get_new_board
    @cells.each do |c|
      cell = c[1]
      cell.determine_next_state
    end
    @cells.each do |c|
      cell = c[1]
      cell.assign_next_state
    end
  end

  def place_cells_on_board
    board = []
    starting_row = 0
    cells.each do |c|
      cell = c[1]
      if cell.y_coord == starting_row + 1
        starting_row += 1
        board << "\n"
      end
      cell = cell.alive? ? 'x' : '.'
      board << cell
    end
    board.join
  end

  def draw_next_board
    print_board
    assign_neighbors_to_cells
    get_new_board
  end

  def draw_game_state_information(i)
    i_str = i.to_s + " "
    i_str = i > 1 ? i_str + 'turns' : i_str + 'turn'
    puts "\n #{i_str} /  #{live_cells.count} live cells"
  end

  def print_board
    # Clears the terminal -- hacky
    board = place_cells_on_board
    puts "\e[H\e[2J"
    print board
  end

  def assign_neighbors_to_cells
    @cells.each do |cell|
      cell = cell[1]

      adjacent_cells = cell.adjacent_cell_coords(@cells)
      adjacent_cells = adjacent_cells.select { |x, y| x >= 0 && (x < self.columns) && y >= 0 && (y < self.rows) }

      cell.neighbors_count = adjacent_cells.select { |c|
          hash_position = c.join("-").to_sym
          @cells[hash_position].state == 'alive'
        }.count
    end
  end

  def total_cells
    @rows * @columns
  end

  def initial_live_cells
    (total_cells * @density).to_i
  end

  def live_cells
    @cells.select { |c| @cells[c].alive? }
  end
end

class Cell

  attr_accessor :x_coord, :y_coord, :state, :neighbors_count, :next_state

  def initialize(x_coord, y_coord, state)
    @x_coord = x_coord
    @y_coord = y_coord
    @state = state
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
    if @neighbors_count < 2 || @neighbors_count > 3
      self.next_state = 'dead'
    else
      self.next_state = self.state
    end
  end

  def possibly_change_dead_cell_state
    if @neighbors_count == 3
      self.next_state = 'alive'
    else
      self.next_state = self.state
    end
  end

  def adjacent_cell_coords(cells)
    cells = [[x_coord - 1, y_coord + 1], [x_coord, y_coord + 1], [x_coord + 1, y_coord + 1],
            [x_coord - 1, y_coord],                             [x_coord + 1, y_coord],
            [x_coord - 1, y_coord - 1], [x_coord, y_coord - 1], [x_coord + 1, y_coord - 1]]
    return cells
  end

  def alive?
    state == 'alive'
  end

  def dead?
    !self.alive?
  end
end



board = Board.new(30,80, 0.5)
board.start

require 'rspec'

describe 'game of life' do

  context "board" do

    let(:rows) { 10 }
    let(:columns) { 10  }
    subject { Board.new(rows, columns, 0.5) }

    context "setup" do

      it "creates the number of live cells according the density given" do
        initial_cells = subject.total_cells * subject.density
        subject.assign_cells
        expect(subject.live_cells.count).to eql(initial_cells.to_i)
      end

      it "correctly assigns each cell a count of its neighbors" do
        subject.cells = []
        cell_positions = [[0, 0], [0, 1]]
        cell_positions.each { |x, y| subject.cells << Cell.new(x, y) }
        subject.assign_neighbors_to_cells
        expect(subject.cells.first.neighbors_count).to eql(1)
      end
    end

    context "game mechanics" do
      it "requires the number of live cells and dead cells to add up to total cells" do
        expect(subject.dead_cells + subject.live_cells).to eql(subject.total_cellscount)
      end
    end

    context "runs the game taking into account the previous board" do
    end
  end

  context "cell" do

    subject { Cell.new(1, 1) }

    context "when living" do

      before do
        subject.state = 'live'
      end

      it "live cell with fewer than two live neighbours dies, as if caused by under-population." do
        subject.neighbors_count = 0
        subject.determine_next_state
        expect(subject.state).to eql('dead')
      end

      it "live cell with two or three live neighbours lives on to the next generation." do
        subject.neighbors_count = 2
        subject.determine_next_state
        expect(subject.state).to eql('live')
      end

      it "cell with more than three live neighbours dies, as if by overcrowding." do
        subject.neighbors_count = 4
        subject.determine_next_state
        expect(subject.state).to eql('dead')
      end
    end

    context  "when dead" do
      before do
        subject.state = 'dead'
      end

      it "cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
        subject.neighbors_count = 3
        subject.determine_next_state
        expect(subject.state).to eql('live')
      end

      it "cell with something other than three live neighbors dies" do
        subject.neighbors_count = 1
        subject.determine_next_state
        expect(subject.state).to eql('dead')
      end
    end
  end
end


