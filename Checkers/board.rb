# encoding: utf-8

# require_relative 'piece'
require_relative 'piece.rb'
require 'colorize'

class Board
  
  attr_reader :grid
  
  def initialize(setup = true)
    @grid = Array.new (8) { Array.new(8) }
    setup_board if setup
  end
  
  def[](pos)
    x, y = pos
    @grid[x][y]
  end

  def[]=(pos, piece)
    x, y = pos
    @grid[x][y] = piece
  end
  
  def display
    system('clear')
    labels = [*0..7].map(&:to_s)
    
    output = ""
    
    @grid.each_with_index do |row, x|
      output += labels[x]
      row.each_with_index do |item, y|
        display_icon = ( item.nil? ? '   ' : item.icon + ' ' ).colorize(background: bg_color(x, y) )
        # p display_icon
        output += display_icon
      end
      output += "\n"
    end
    
    output += '  ' + labels.join('  ')
    puts output
  end
  
  # def dup
  #   dup_board = Board.new(false)
  #
  #   @grid.each_with_index do |row, x|
  #     row.each_index do |y|
  #       piece = self[[x, y]]
  #       dup_board[[x, y]] = piece.class.new(dup_board, [x, y], piece.color) unless piece.nil?
  #     end
  #   end
  #
  #   dup_board
  # end
  
  def dup
    dup_board = Board.new(false)
    
    @grid.flatten.compact.each do |piece|
      piece.dup(dup_board)
    end
    
    dup_board
  end
  
  def setup_board
    @grid.each_with_index do |row, x|
      row.each_index do |y|
        pos = [x, y]
        #needed to use self here, not @grid
        color = (x < 3 ? :black : :white)
        self[pos] = Piece.new(@grid, pos, color) if dark_square?(x, y) && in_range?(x)
      end
    end
  end
  
  def in_range?(x)
    !x.between?(3, 4)
  end
  
  def dark_square?(x, y)    #pieces start on dark squares
    (x.even? && y.odd?) || (x.odd? && y.even?)
  end
  
  def bg_color(x, y)
    dark_square?(x, y) ? :green : :light_green
  end
  
end

# board = Board.new
# board[[1,4]] = nil
# board[[4,1]] = Piece.new(board, [4,1], :brown)
# # board[[5,0]].perform_jump([5,0], [3,2])
# board[[5,0]].perform_moves([[5,0], [3,2], [1,4]])
# # p board[[5,0]].valid_move_seq?([[5,0], [3,2], [1,4]])
# board.display

# board[[5,0]].perform_slide([5,0], [4,1])
# board[[2,3]].perform_slide([2,3], [3,2])
# board[[4,1]].perform_moves!([[4,1], [2,3]])

# board[[2,1]].perform_slide([2,1], [3,2])
# board[[5,2]].perform_jump([5,2], [3,0])
# board[[1,2]].perform_slide([1,2], [2,1])
# board[[3,0]].perform_jump([3,0], [1,2])
# board[[1,2]].perform_slide([1,2], [0,1])
# board.display
