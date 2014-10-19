require_relative 'board'

class Player
  attr_reader :color, :name
  
  def initialize(name, color)
    @name = name
    @color = color
  end
  
end

class Game
  attr_reader :board
  
  def initialize(name1, name2)
    @player1 = Player.new(name1, :white)
    @player2 = Player.new(name2, :black)
    @board = Board.new()
  end
  
  def play
    cur_player = @player1
    
    until game_over?
      @board.display
      take_turn(cur_player)
      cur_player = toggle_player(cur_player)
    end
  
    display_outcome
  end
  
  def take_turn(player)
    begin
      puts "#{player.name}, it's your move."
      moves = to_arr(gets.chomp)
      # p moves
      @board[moves.first].perform_moves(moves)
    rescue InvalidMove => e
      puts e.message
      retry
    end
  end
  
  private
  
    def to_arr(str)
      str.split(' ').map do |s|
        s.chars.map(&:to_i)
      end
    end
  
    def game_over?
      false
    end
  
    def display_outcome
      puts "someone won!"
    end
  
    def toggle_player(player)
      player = (player == @player1 ? @player2 : @player1)
    end
  
end

game = Game.new('justin', 'comp')
game.play