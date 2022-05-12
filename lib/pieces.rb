class Square
    attr_accessor :piece
    attr_reader :coordinates
    def initialize(row, col, piece = nil)
        @coordinates = [row, col]
        @piece = piece ? piece : get_piece(row, col)
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

    def valid_moves(row, col, turn, board)
        # p "r #{row} ; c #{col} ; t #{turn} ; b #{board}\n"
        # p board[row+1]
        moves = []
        if turn == 'white'
            moves << [row-1, col] if board[row-1][col].piece.instance_of?(Empty)
            moves << [row-2, col] if row == 6 && board[row-2][col].piece.instance_of?(Empty)
            moves << [row-1, col+1] if col != 7 && board[row-1][col+1].piece.color == 'black'
            moves << [row-1, col-1] if col != 0 && board[row-1][col-1].piece.color == 'black'
        else
            moves << [row+1, col] if board[row+1][col].piece.instance_of?(Empty)
            moves << [row+2, col] if row == 1 && board[row+2][col].piece.instance_of?(Empty)
            moves << [row+1, col+1] if col != 7 && board[row+1][col+1].piece.color == 'white'
            moves << [row+1, col-1] if col != 0 && board[row+1][col-1].piece.color == 'white'
        end
        moves
    end
end

class Knight
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'knight'
        @symbol = color == 'black' ? '♘' : '♞'
    end

    def valid_moves(row, col, turn, board)
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

class Rook
    attr_reader :color, :name, :symbol
    attr_accessor :move_count
    def initialize(color, move_count = nil)
        @color = color
        @name = 'rook'
        @symbol = color == 'black' ? '♖' : '♜'
        @move_count = move_count ? move_count : 0
    end

    def valid_moves(row, col, turn, board)
        moves = []

        forward = 1
        loop do
            break if row == 7
            moves << [row+forward, col]
            break if row+forward >= 7 || !board[row+forward][col].piece.instance_of?(Empty)
            forward += 1
        end
        
        backward = 1
        loop do
            break if row == 0
            moves << [row-backward, col]
            break if row-backward == 0 || !board[row-backward][col].piece.instance_of?(Empty)
            backward += 1
        end
        
        right = 1
        loop do
            break if col == 7
            moves << [row, col+right]
            break if col+right == 7 || !board[row][col+right].piece.instance_of?(Empty)
            right += 1
        end
        
        left = 1
        loop do
            break if col == 0
            moves << [row, col-left]
            break if col-left == 0 || !board[row][col-left].piece.instance_of?(Empty)
            left += 1
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

    def valid_moves(row, col, turn, board)
        moves = []

        for_up = 1
        loop do
            break if row == 0 || col == 7
            moves << [row-for_up, col+for_up]
            break if row-for_up == 0 || col+for_up == 7 || !board[row-for_up][col+for_up].piece.instance_of?(Empty)
            for_up += 1
        end
        
        for_down = 1
        loop do
            break if row == 7 || col == 7
            moves << [row+for_down, col+for_down]
            break if row+for_down == 7 || col+for_down == 7 || !board[row+for_down][col+for_down].piece.instance_of?(Empty)
            for_down += 1
        end
        
        back_up = 1
        loop do
            break if row == 0 || col == 0
            moves << [row-back_up, col-back_up]
            break if row-back_up == 0 || col-back_up == 0 || !board[row-back_up][col-back_up].piece.instance_of?(Empty)
            back_up += 1
        end
        
        back_down = 1
        loop do
            break if row == 7 || col == 0
            moves << [row+back_down, col-back_down]
            break if row+back_down == 7 || col-back_down == 0 || !board[row+back_down][col-back_down].piece.instance_of?(Empty)
            back_down += 1
        end

        moves
    end
end

class Queen
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'queen'
        @symbol = color == 'black' ? '♕' : '♛'
    end

    def valid_moves(row, col, turn, board)
        moves = []

        forward = 1
        loop do
            break if row == 7
            moves << [row+forward, col]
            break if row+forward >= 7 || !board[row+forward][col].piece.instance_of?(Empty)
            forward += 1
        end
        
        backward = 1
        loop do
            break if row == 0
            moves << [row-backward, col]
            break if row-backward == 0 || !board[row-backward][col].piece.instance_of?(Empty)
            backward += 1
        end
        
        right = 1
        loop do
            break if col == 7
            moves << [row, col+right]
            break if col+right == 7 || !board[row][col+right].piece.instance_of?(Empty)
            right += 1
        end
        
        left = 1
        loop do
            break if col == 0
            moves << [row, col-left]
            break if col-left == 0 || !board[row][col-left].piece.instance_of?(Empty)
            left += 1
        end

        for_up = 1
        loop do
            break if row == 0 || col == 7
            moves << [row-for_up, col+for_up]
            break if row-for_up == 0 || col+for_up == 7 || !board[row-for_up][col+for_up].piece.instance_of?(Empty)
            for_up += 1
        end
        
        for_down = 1
        loop do
            break if row == 7 || col == 7
            moves << [row+for_down, col+for_down]
            break if row+for_down == 7 || col+for_down == 7 || !board[row+for_down][col+for_down].piece.instance_of?(Empty)
            for_down += 1
        end
        
        back_up = 1
        loop do
            break if row == 0 || col == 0
            moves << [row-back_up, col-back_up]
            break if row-back_up == 0 || col-back_up == 0 || !board[row-back_up][col-back_up].piece.instance_of?(Empty)
            back_up += 1
        end
        
        back_down = 1
        loop do
            break if row == 7 || col == 0
            moves << [row+back_down, col-back_down]
            break if row+back_down == 7 || col-back_down == 0 || !board[row+back_down][col-back_down].piece.instance_of?(Empty)
            back_down += 1
        end
        
        moves
    end
end

class King
    attr_reader :color, :name, :symbol
    attr_accessor :move_count
    def initialize(color, move_count = nil)
        @color = color
        @name = 'king'
        @symbol = color == 'black' ? '♔' : '♚'
        @move_count = move_count ? move_count : 0
    end

    def valid_moves(row, col, turn, board, check)
        directions = [-1, 0, 1]
        moves = []
        for i in directions
            for j in directions
                moves << [row+i, col+j] unless i == 0 && j == 0
            end
        end

        if !check
            if turn == 'white'
                if row == 7 && col == 4 && @move_count == 0 && board[7][7].piece.name == 'rook' && board[7][7].piece.move_count == 0 && board[7][5].piece.instance_of?(Empty) && board[7][6].piece.instance_of?(Empty)
                    moves << [7, 6]
                elsif row == 7 && col == 4 && @move_count == 0 && board[7][0].piece.name == 'rook' && board[7][0].piece.move_count == 0 && board[7][1].piece.instance_of?(Empty) && board[7][2].piece.instance_of?(Empty) && board[7][3].piece.instance_of?(Empty)
                    moves << [7, 1]
                end
            else
                if row == 0 && col == 4 && @move_count == 0 && board[0][7].piece.name == 'rook' && board[0][7].piece.move_count == 0 && board[0][5].piece.instance_of?(Empty) && board[0][6].piece.instance_of?(Empty)
                    moves << [0, 6]
                elsif row == 0 && col == 4 && @move_count == 0 && board[0][0].piece.name == 'rook' && board[0][0].piece.move_count == 0 && board[0][1].piece.instance_of?(Empty) && board[0][2].piece.instance_of?(Empty) && board[0][3].piece.instance_of?(Empty)
                    moves << [0, 2]
                end
            end
        end

        moves
    end
end


symbols = '♔♕♗♘♙♖♚♛♝♞♟♜'