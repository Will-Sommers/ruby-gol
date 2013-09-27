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
    assign_cells
    board = place_cells_on_board
    puts board
    draw_board(board)
  end

  def make_blank_board
    (0..@rows).each do |row|
      (0..@columns).each do |column|
        @cells << Cell.new(row, column)
      end
    end
  end

  def assign_cells
    inc = 0
    initial_cells = (area * @density).to_i

    while inc < initial_cells do
      x_coord = (0..columns).to_a.sample
      y_coord = (0..rows).to_a.sample
      cell = Board.find_cell_by_coords([x_coord, y_coord])
      unless cell.alive?
        @cells.delete(cell)
        cell.state = 'alive'
        @cells << cell
        inc += 1
      end
    end
  end

  def place_cells_on_board
    cells_coords = @cells.map { |cell| [cell.x_coord, cell.y_coord] }
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

      cell.neighbors_count = (@cells.map { |cell| [cell.x_coord, cell.y_coord]} & adjacent_cells).count
    end
  end

  def area
    rows * columns
  end

  def find_cell_by_coords(coords)
    @cells.select { |cell| [cell.x_coord, cell.y_coord] & [coords] }
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
        self.state = 'live'
      when @neighbors_count > 3
        self.state = 'dead'
      end
    elsif self.dead?
      if @neighbors_count == 3
        self.state = 'live'
      else
        self.state = 'dead'
      end
    end
  end

  def alive?
    self.state == 'live'
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

      it "creates the number of starting cells according the density given" do
        initial_cells = subject.area * subject.density
        subject.assign_cells
        expect(subject.cells.count).to eql(initial_cells.to_i)
      end

      it "correctly assigns each cell a count of its neighbors" do
        subject.cells = []
        cell_positions = [[0, 0], [0, 1]]
        cell_positions.each { |x, y| subject.cells << Cell.new(x, y) }
        subject.assign_neighbors_to_cells
        expect(subject.cells.first.neighbors_count).to eql(1)
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

