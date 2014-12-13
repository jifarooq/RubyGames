require 'debugger'
# encoding: utf-8
require_relative 'errors'

class Piece
  
  MOVE_DELTAS = [ [1, -1], [1, 1] ]
  
  attr_accessor :icon, :pos
  attr_reader :board, :color
  
  def initialize(board, pos, color)
    @board, @color, @pos = board, color, pos
    @promoted = false
    @icon = choose_icon
    
    board[pos.first][pos.last] = self
  end
  
  def dup(new_board)
    Piece.new(new_board, pos, color)
  end
  
  def choose_icon
    unless @promoted
      @icon = (color == :white ? ' ⚪' : ' ⚫')
    else
      @icon = (color == :white ? '♕' : '♛')
    end
  end

  def move_deltas
    if @color == :white
      MOVE_DELTAS.map { |delta| [delta.first * -1, delta.last * -1] }
    else
      MOVE_DELTAS
    end
  end
  
  def maybe_promote
    row, col = @pos
    promotable = (@color == :white && row == 0) || (@color == :black && row == 7)
    @promoted = true && @icon = '⚪⚪' if promotable
  end
  
  def perform_slide(start_pos, end_pos, board)
    row, col = start_pos
    row2, col2 = end_pos
    piece = board[row][col]
    p row, col
    p row2, col2
    # debugger
    
    if piece.poss_slides(board, start_pos).include?(end_pos)
      board[row][col], board[row2][col2] = nil, piece
      piece.pos = end_pos
      piece.maybe_promote
      true
    else
      false
    end
    
    # p piece.class, piece.poss_slides
  end
  
  # def perform_slide(move_pos)
  #   # row, col = start_pos
  #   # row2, col2 = end_pos
  #   # piece = @board[row][col]
  #
  #   if self.poss_slides.include?(end_pos)
  #     board[pos.first][pos.last] = nil
  #     self.pos = move_pos
  #     board[move_pos] = self
  #
  #     # @board[row][col], @board[row2][col2] = nil, piece
  #     # piece.pos = end_pos
  #     maybe_promote
  #
  #     true
  #   else
  #     false
  #   end
  #
  #   # p piece.class, piece.poss_slides
  # end
  
  def poss_slides(board, pos)
    # debugger
    x, y = pos
    slides = []
    
    move_deltas.each do |delta|
      temp_slide = [x + delta.first, y + delta.last]
      slides << temp_slide if board[ temp_slide[0] ][ temp_slide[1] ].nil?
    end
    
    # p slides
    slides
  end
  
  def perform_jump(start_pos, end_pos, board)
    row, col = start_pos
    row2, col2 = mid_pos(start_pos, end_pos)
    row3, col3 = end_pos
    jump_piece = board[row][col]
    
    if jump_piece.poss_jumps(board).include?(end_pos)
      board[row][col], board[row3][col3] = nil, jump_piece
      jump_piece.pos = end_pos
      board[row2][col2] = nil
      jump_piece.maybe_promote
    else
      false
    end
  end
  
  #piece eaten by jump
  def mid_pos(start_pos, end_pos)
    [(start_pos[0] + end_pos[0]) / 2, (start_pos[1] + end_pos[1]) / 2]
  end
  
  def poss_jumps(board)
    jumps = []
    
    move_deltas.each do |delta|
      temp_slide = [@pos.first + delta.first, @pos.last + delta.last]
      temp_jump = [@pos.first + delta.first * 2, @pos.last + delta.last * 2]
      jumps << temp_jump unless board[temp_slide[0]][temp_slide[1]].nil?
    end
    
    jumps
  end
  
  def slidable_move?(seq)
    # debugger
    start_pos, end_pos = seq
    # p start_pos, end_pos
    [1, 1] == [(end_pos[0] - start_pos[0]).abs, (end_pos[1] - start_pos[1]).abs]
  end
  
  def perform_moves!(move_seq, board)
    # debugger
    if move_seq.size <= 2
      # slide = slidable_move?(move_seq)
      if slidable_move?(move_seq)
        perform_slide(move_seq.first, move_seq.last, board)
      else
        perform_jump(move_seq.first, move_seq.last, board)
      end
    else
      while move_seq.size < 2
        perform_jump(move_seq[0], move_seq[1], board)
        move_seq.shift
      end
    end
  end
  
  def perform_moves(move_seq)
    # debugger
    if valid_move_seq?(move_seq)
      perform_moves!(move_seq, @board)
    else
      raise InvalidMove.new "cant move there"
    end
  end
  
  def valid_move_seq?(move_seq)
    # debugger
    board_copy = board.dup
    x, y = @pos
    # true #unless board_copy[x][y].perform_moves!(move_seq)
    
    begin
      board_copy[x][y].perform_moves!(move_seq, board_copy)
    rescue InvalidMove => e
      puts e.message
      false
    else
      true
    end
  end
  
end