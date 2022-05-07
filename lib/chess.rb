require_relative 'pieces'

class Chess
    def initialize
        @board = generate_board()
        #p @board
    end

    def generate_board
        board = []
        for r in 8.downto(1) do
            row = []
            for c in (1..8) do
                row << Square.new(r, c)
            end
            board << row
        end
        board
    end

    def display_board
        row_count = 9
        display = @board.map do |row|
            row_count -= 1
            row.map! {|square| square.piece.symbol}
            " #{row_count} | " + row.join(" | ") + " |"
        end
        num_line = "     1   2   3   4   5   6   7   8 \n"
        row_line = "\n   —————————————————————————————————\n"
        puts row_line + display.join(row_line) + row_line + num_line
            
    end
end

class Square
    attr_accessor :piece
    attr_reader :coordinates
    def initialize(row, col)
        @coordinates = [row, col]
        @piece = get_piece(row, col)
    end

    def get_piece(row, col)
        return Pawn.new('black') if row == 7
        return Pawn.new('white') if row == 2
        return Empty.new if row >= 3 && row <= 6
        if row == 8
            if col == 1 || col == 8
                return Rook.new('black')
            elsif col == 2 || col == 7
                return Knight.new('black')
            elsif col == 3 || col == 6
                return Bishop.new('black')
            elsif col == 4
                return Queen.new('black')
            else
                return King.new('black')
            end
        else
            if col == 1 || col == 8
                return Rook.new('white')
            elsif col == 2 || col == 7
                return Knight.new('white')
            elsif col == 3 || col == 6
                return Bishop.new('white')
            elsif col == 4
                return Queen.new('white')
            else
                return King.new('white')
            end
        end
    end
end



game = Chess.new
game.display_board