require 'yaml'

class Board
  NEIGHBOR_OFFSETS = [ [1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1], [0,1] ]
  attr_reader :grid, :bomb_locations, :neighbors
  
  def initialize(boardsize = 9)
    @grid = Array.new(boardsize) { |x| Array.new(boardsize) { |y| Tile.new(x,y) }}
    @boardsize = boardsize
    @bomb_locations = []
    @neighbors = []

    create_bombs
    fill_bomb_numbers
  end
  
  def [](pos)
    x, y = pos[0], pos[1]
    @grid[x][y]
  end
  
  def all_bombs_revealed?
    @grid.each do |row|
      row.each do |tile|
        return false if (tile.revealed == false && tile.has_bomb == false)
      end
    end
    
    true
  end

  def off_the_board?(x, y)
    (x < 0 || x >= @boardsize) || (y < 0 || y >= @boardsize)
  end
  
  def print_board
    p @bomb_locations.sort
    @grid.each do |row|
      row.each do |tile|
        format_tile( tile )
      end
      puts
    end
  end
    
  def reveal_tiles(coords)
    x, y = coords.first, coords.last
    
    self[[x, y]].revealed = true
    return if self[[x, y]].count != 0

    neighbors(coords).each { |neighbor| reveal_tiles(neighbor.coords) unless neighbor.revealed  }
  end

  private

    def create_bombs
      bomb_count = rand(5..15)
      
      until bomb_count == 0
        x, y = rand(@boardsize), rand(@boardsize)
        @bomb_locations << [x, y] unless @bomb_locations.include?([x, y])
        bomb_count -= 1
      end
      
      @bomb_locations.each do |coords|
        x, y = coords.first, coords.last
        @grid[x][y].has_bomb = true
      end
    end

    def format_tile(tile)
      if tile.flagged
        print 'F'
      elsif tile.revealed && tile.count == 0
        print '_'
      elsif tile.revealed
        print tile.count
      else
        print "*"
      end
    end
    
    def fill_bomb_numbers
      @bomb_locations.each do |coords|
        x, y = coords.first, coords.last
        
        NEIGHBOR_OFFSETS.each do |offset|
          new_x, new_y = x + offset.first, y + offset.last
          @grid[new_x][new_y].count += 1 unless off_the_board?(new_x, new_y)
        end
      end
    end

    def neighbors(coords)
      new_neighbors = []
      x, y = coords.first, coords.last

      NEIGHBOR_OFFSETS.each do |offset|
        new_x, new_y = x + offset.first, y + offset.last
        new_neighbors << @grid[new_x][new_y] unless off_the_board?(new_x, new_y)
      end

      new_neighbors
    end

end


class Tile
  
  attr_accessor :count, :flagged, :has_bomb, :revealed
  attr_reader :coords
  
  def initialize(x,y)
    @coords = [x,y]
    @count = 0
    @flagged = false
    @has_bomb = false
    @revealed = false
  end
  
end


class Player
  
  def initialize(boardsize = 9)
    @move = []
    @grid = Board.new(boardsize)
  end
  
  def menu
    p "Load a saved game (l) or start a new game (n)?"
    choice = gets.chomp.downcase
    if choice == 'l'
      @grid = YAML::load_file('saved_minesweeper.yml')
      play_game
    else
      new_player = Player.new
      play_game
    end
  end
  
  def play_game
    game_over = false
    
    until game_over
      @grid.print_board
      get_move
      game_over = check_game_over
    end
  end

  private
  
    def check_game_over

      if @grid.bomb_locations.include?(@move) && !@grid[@move].flagged
        print "You hit a bomb! You lose. \n"
        return true 
      elsif @grid.all_bombs_revealed?
        print "You win! You found all the bombs. \n"
        return true
      end
      
      false
    end

    def flagged_move
      p "which space? x, y"
      flag_move = gets.chomp.split(",").map(&:to_i)
      cur_flag = @grid[flag_move].flagged
      @grid[flag_move].flagged = (cur_flag == false ? true : false)
    end
    
    def get_move
      puts "Flag (f)?, save (s)?, or input the coordinates."
      input = gets.chomp
      
      if input == 'f'
        flagged_move
      elsif input == 's'
        saved_game = @grid.to_yaml
        File.open('saved_minesweeper.yml', 'w') {|f| f.write saved_game}
        p 'Goodbye!'
      else
        reveal_move(input)
      end
    end
    
    def reveal_move(input)
      @move = input.split(",").map(&:to_i)

      if @grid.off_the_board?(@move.first, @move.last)
        p "You're totes off the wall! Er, off the board.  Try again."
      else
        @grid.reveal_tiles(@move)
      end
    end
  
end

player = Player.new(10)
player.menu