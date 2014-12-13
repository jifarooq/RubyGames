class Board
  attr_reader :black_sq, :board

  def initialize(setup = true)
    @board = Array.new(8) { Array.new(8) }
    @black_sq = "\u25A0"
    board_setup if setup
  end

  def [](pos)
    x, y = pos
    @board[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @board[x][y] = piece
  end

  def dup
    dup_board = Board.new(false)

    dup_board.board.each_with_index do |row, x|
      row.each_index do |y|
        piece = self[[x, y]]
        dup_board[[x, y]] = piece.class.new(dup_board, [x, y], piece.color) unless piece.nil?
      end
    end

    dup_board
  end

  def checkmate?(color)
    in_check?(color) && pieces_array(color).all? { |p| p.valid_moves.empty? }
  end
  
  def in_check?(color)
    opp_color = (color == :white ? :black : :white)
    all_moves = []
    pieces_array(opp_color).each { |piece| all_moves += piece.moves }
    all_moves.any? { |pos| self[pos].class == King && self[pos].color == color }
  end
  
  def move(start_pos, end_pos, color)
    piece = self[start_pos]
    raise StartPositionEmpty.new 'Your starting position is empty.' if piece.nil?
    raise InvalidMove.new "That's not your piece!" unless piece.color == color
    raise InvalidMove.new "Piece can't move there." unless piece.moves.include?(end_pos)
    raise InvalidMove.new 'That move puts you in check.' if piece.move_into_check?(end_pos)
    move!(start_pos, end_pos)
  end
  
  def move!(start_pos, end_pos)
    self[start_pos], self[end_pos] = nil, self[start_pos]
    self[end_pos].pos = end_pos
  end

  def pieces_array(color)
    @board.flatten.compact.select { |piece| piece.color == color }
  end

  def display(player_color)
    system('clear') # check warnings about string literals for unicode
    
    row_labels, col_labels, temp_board = format_layout(player_color)
    output = format_board(row_labels, col_labels, temp_board)

    puts output
  end
  
  private 
  
    def format_layout(player_color)
      white_move = (player_color == :white)
    
      row_nums = (white_move ? [*'1'..'8'].reverse : [*'1'..'8'])
      col_letters = (white_move ? [*'a'..'h'] : [*'a'..'h'].reverse)
      temp_board = (white_move ? @board.reverse.map(&:reverse) : @board)
      
      [row_nums, col_letters, temp_board]
    end
    
    def format_board(row_labels, col_labels, board)
      output = ""
    
      board.each_with_index do |row, x|
        output += row_labels[x]
        row.each_with_index do |item, y|          
          output += (item.nil? ? '  ' : (item.icon + ' ')).colorize(background: sq_color(x, y))
        end
        output += "\n"
      end
    
      output += ' '.white + col_labels.join(' ')      
    end

    def board_setup
      setup_pawns
      setup_back_rows
    end

    def setup_pawns
      8.times do |col|
        [1, 6].each do |row|
          piece_color = (row <= 1 ? :white : :black)
          Pawn.new(self, [row, col], piece_color)
        end
      end
    end

    def setup_back_rows
      [[0, :white], [7, :black]].each do |(x, color)|
        pieces = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook]
        pieces.each_with_index do |klass, y|
          pos = x, y
          klass.new(self, pos, color)
        end
      end
    end
    
    def sq_color(idx1, idx2)
      (idx1.even? && idx2.even?) || (idx1.odd? && idx2.odd?) ? :light_green : :green
    end
  
end