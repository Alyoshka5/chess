class Square
    attr_accessor :piece
    attr_reader :coordinates
    def initialize(row, col)
        @coordinates = [row, col]
        @piece = get_piece(row, col)
    end

    def get_piece(row, col)
        return Pawn.new('white') if row == 6
        return Pawn.new('black') if row == 1
        return Empty.new if row >= 2 && row <= 5
        if row == 7
            if col == 0 || col == 7
                return Rook.new('white')
            elsif col == 1 || col == 6
                return Knight.new('white')
            elsif col == 2 || col == 5
                return Bishop.new('white')
            elsif col == 3
                return Queen.new('white')
            else
                return King.new('white')
            end
        else
            if col == 0 || col == 7
                return Rook.new('black')
            elsif col == 1 || col == 6
                return Knight.new('black')
            elsif col == 2 || col == 5
                return Bishop.new('black')
            elsif col == 3
                return Queen.new('black')
            else
                return King.new('black')
            end
        end
    end
end

class Empty
    attr_reader :color, :name, :symbol
    def initialize
        @color = nil
        @name = nil
        @symbol = ' '
    end
end

class Pawn
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'pawn'
        @symbol = color == 'black' ? '♙' : '♟'
    end

    def valid_moves(row, col, turn, board, opponent_pieces)
        moves = []
        if turn == 'white'
            moves << [row-1, col] if board[row-1][col].piece.instance_of?(Empty)
            moves << [row-2, col] if board[row-2][col].piece.instance_of?(Empty) && row == 6
            moves << [row-1, col+1] if board[row-1][col+1].piece.color == 'black'
            moves << [row-1, col-1] if board[row-1][col-1].piece.color == 'black'
        else
            moves << [row+1, col] if board[row+1][col].piece.instance_of?(Empty)
            moves << [row+2, col] if board[row+2][col].piece.instance_of?(Empty) && row == 1
            moves << [row+1, col+1] if board[row+1][col+1].piece.color == 'white'
            moves << [row+1, col-1] if board[row+1][col-1].piece.color == 'white'
        end
        moves
    end
end

class Rook
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'rook'
        @symbol = color == 'black' ? '♖' : '♜'
    end
end

class Knight
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'knight'
        @symbol = color == 'black' ? '♘' : '♞'
    end

    def valid_moves(row, col, turn, board, opponent_pieces)
        moves = []
        directions = [1, 2, -1, -2]
        for i in directions
            for j in directions
                new_row = row + i
                new_col = col + j
                next if i.abs == j.abs
                moves << [row + i, col + j]
            end
        end
        moves
    end
end

class Bishop
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'bishop'
        @symbol = color == 'black' ? '♗' : '♝'
    end
end

class Queen
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'queen'
        @symbol = color == 'black' ? '♕' : '♛'
    end
end

class King
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'king'
        @symbol = color == 'black' ? '♔' : '♚'
    end

    def valid_moves(row, col, turn, board, opponent_pieces)
        
    end
end


symbols = '♔♕♗♘♙♖♚♛♝♞♟♜'