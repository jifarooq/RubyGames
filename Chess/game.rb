#if you include a module to another class, those methods become instance methods
#if you extend a module, those methods become class methods


require_relative 'board'
require_relative 'errors'
require_relative 'pieces'
require 'colorize'

class Player
  attr_reader :color, :name
  attr_accessor :game_time
  
  def initialize(name, color)
    @name = name
    @color = color
    @game_time = 900  #15 min in seconds
  end
  
end

class Game
  attr_reader :board
  
  def initialize(name1, name2)
    @player1 = Player.new(name1, :white)
    @player2 = Player.new(name2, :black)
    @board = Board.new()
    @taken_by_white = []
    @taken_by_black = []
  end

  def play_game
    cur_player = @player1

    until game_over?
      @board.display(cur_player.color)
      show_check_status(cur_player)
      show_stats
      take_turn(cur_player)
      cur_player = toggle_player(cur_player)
    end

    display_outcome
  end

  def display_outcome
    if checkmated?
      winner = (@board.checkmate?(:white) ? @player2 : @player1)
    elsif stalemate?
      winner = @player1
      puts "Stalemate.  Everybody wins!"
      return
    else #ran out of time
      winner = (@player1.game_time < 0 ? @player2 : @player1)
    end
    
    @board.display(winner.color)
    puts "#{ winner.name } won the game!"
  end
  
  def take_turn(player)
    start_time = current_time(player)
    
    # begin
      print ":".blink
      start_pos, end_pos = convert_coordinates(gets.chomp)
      piece_at_end_pos = @board[end_pos]
      @board.move(start_pos, end_pos, player.color)
    rescue StandardError => e
      puts "#{e.message}"
      retry
    end
    
    player.game_time -= (Time.now - start_time).round
    add_to_pieces_taken(player.color, piece_at_end_pos)
  end
  
  private
  
    def checkmated?
      @board.checkmate?(:white) || @board.checkmate?(:black)
    end
    
    def game_over?
      @board.checkmate?(:white) || @board.checkmate?(:black) || 
      @player1.game_time <= 0 || @player2.game_time <= 0 || stalemate?
    end
    
    def stalemate?
      white_cant_move = @board.pieces_array(:white).all?{ |p| p.valid_moves.empty? }
      black_cant_move = @board.pieces_array(:black).all?{ |p| p.valid_moves.empty? }
      (!@board.in_check?(:white) && white_cant_move) || (!@board.in_check?(:black) && black_cant_move)
    end
    
    def add_to_pieces_taken(color, piece)
      @taken_by_white << piece unless (piece.nil? || color == :black)
      @taken_by_black << piece unless (piece.nil? || color == :white)
    end
  
    def current_time(player)
      puts "#{player.name}'s move. Time Remaining: #{player.game_time/60}m#{player.game_time%60}s"
      Time.now
    end

    def convert_coordinates(user_input)
      letter_map = Hash[[*'a'..'h'].reverse.zip([*0..7])]
      move1, move2 = user_input.split
      [move1, move2].map do |coord|
        chars = coord.split('')
        chars[0] = letter_map[chars.first]
        [chars.last.to_i - 1, chars.first]
      end
    end
    
    def show_check_status(player)
      puts "Oh shit, you're in check!" if @board.in_check?(player.color)
    end
    
    def show_stats
      white_points, black_points = total_points(@taken_by_white), total_points(@taken_by_black)
    
      unless @taken_by_white.empty? && @taken_by_black.empty?
        taken_by_white, taken_by_black = sort_pieces(@taken_by_white), sort_pieces(@taken_by_black)
        puts "White: #{white_points} points #{taken_by_white.join(' ')}"
        puts "Black: #{black_points} points #{taken_by_black.join(' ')}"
      end
    end

    def sort_pieces(pieces_taken)
      pieces_taken.sort_by{ |p| p.value }.map{ |p| p.icon }.reverse
    end
    
    def toggle_player(player)
      player = (player == @player1 ? @player2 : @player1)
    end
    
    def total_points(pieces_taken)
      pieces_taken.reduce(0){ |total, piece| total + piece.value}
    end
  
end

game = Game.new('Justin', 'David')
game.play_game