class Board

  attr_accessor :rows, :columns, :density, :cells

  def initialize(rows, columns, density)
    @rows = rows - 1
    @columns = columns - 1
    @density = density
    @cells = []
    make_blank_board
  end

  def start
    i = 0
    assign_cells
    board = place_cells_on_board
    draw_board(board)
    loop do
      board = place_cells_on_board
      draw_board(board)
      assign_neighbors_to_cells
      get_new_board
      puts "#{i/5} seconds, #{live_cells.count} live cells"
      i += 1
      sleep 0.2
    end
  end

  def make_blank_board
    (0..@rows).each do |row|
      (0..@columns).each do |column|
        cell = Cell.new(row, column)
        @cells << cell
      end
    end
  end

  def get_new_board
    new_cells = []
    @cells.each do |c|
       new_state = c.determine_next_state
       c.state = new_state
       new_cells << c
    end
    @cells = new_cells
  end

  def assign_cells
    inc = 0
    while inc < initial_live_cells do
      x_coord = (0..@columns).to_a.sample
      y_coord = (0..@rows).to_a.sample
      cell = Board.find_cell_by_coords([x_coord, y_coord], @cells)
      unless cell.alive?
        @cells.delete(cell)
        cell.state = 'alive'
        @cells << cell
        inc += 1
      end
    end
  end

  def place_cells_on_board
    cells_coords = live_cells.map { |cell| [cell.x_coord, cell.y_coord] }
    board = []
    (0..@rows).each do |row|
      (0..@columns).each do |column|
        cell =  cells_coords.include?([column, row]) ? 'x' : '.'
        board << cell
      end
      board << "\n"
    end
    board.join
  end

  def draw_board(board)
    # Clears the terminal -- hacky
    puts "\e[H\e[2J"
    print board
  end

  def assign_neighbors_to_cells
    @cells.each do |cell|

      adjacent_cells = [[cell.x_coord - 1, cell.y_coord + 1], [cell.x_coord, cell.y_coord + 1], [cell.x_coord + 1, cell.y_coord + 1],
                       [cell.x_coord - 1, cell.y_coord],                                       [cell.x_coord + 1, cell.y_coord],
                       [cell.x_coord - 1, cell.y_coord - 1], [cell.x_coord, cell.y_coord - 1], [cell.x_coord + 1, cell.y_coord - 1]]
      cell.neighbors_count = (live_cells.map { |cell| [cell.x_coord, cell.y_coord]} & adjacent_cells).count

    end
  end

  def total_cells
    @cells.count
  end

  def initial_live_cells
    (total_cells * @density).to_i
  end

  def live_cells
    @cells.select { |c| c.state == 'alive' }
  end

  def dead_cells
    @cells.select { |c| c.state == 'dead' }
  end

  def self.find_cell_by_coords(coords, cells)
    cells.select { |cell| [cell.x_coord, cell.y_coord] == coords }.first
  end
end

class Cell

  attr_accessor :x_coord, :y_coord, :state, :neighbors_count

  def initialize(x_coord, y_coord, state='dead' )
    @x_coord = x_coord
    @y_coord = y_coord
    @state = state
  end


  def determine_next_state
    if self.alive?
      case
      when @neighbors_count < 2
        self.state = 'dead'
      when @neighbors_count == (2 || 3)
        self.state = 'alive'
      when @neighbors_count > 3
        self.state = 'dead'
      end
    elsif self.dead?
      if @neighbors_count == 3
        self.state = 'alive'
      else
        self.state = 'dead'
      end
    end
    self.state
  end

  def alive?
    self.state == 'alive'
  end

  def dead?
    self.state == 'dead'
  end
end


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

b = Board.new(40,40, 0.15)
b.start
