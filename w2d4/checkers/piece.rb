require 'debugger'
# encoding: utf-8
require_relative 'errors'

class Piece
  
  attr_accessor :icon, :pos
  attr_reader :board, :color
  
  def initialize(board, pos, color)
    @board, @color, @pos = board, color, pos
    @icon = (color == :white ? ' ⚪' : ' ⚫')
    promoted = false
  end
  
  def perform_slide
    
  end
  
  def perform_jump
    
  end
  
end