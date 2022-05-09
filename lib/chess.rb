require_relative 'pieces'

class Chess
    def initialize
        @white_pieces = []
        @black_pieces = []
        @board = generate_board()
        @turn = 'black'
    end
        
    def generate_board
        board = []
        for r in (0..7) do
            row = []
            for c in (0..7) do
                square = Square.new(r, c)
                row << square
                @white_pieces << square.piece if r <= 1
                @black_pieces << square.piece if r >= 6  
            end
            board << row
        end
        board
    end

    def play_game
        checkmate = false
        puts "Enter starting and ending coordinates (from 0 - 7), each seperated by a space (ex: 1 7 3 6)"
        puts "First input row (y-axis) and then column (x-axis)"
        until checkmate do
            @turn = @turn == 'black' ? 'white' : 'black'
            display_board()
            puts "#{@turn}'s move: "

            move = get_move()
            #place_move(move)
        end
    end

    def testing
        display_board()
        @turn = 'white'
        square = @board[2][4]
        square2 = @board[1][4]
        square2.piece = Empty.new
        square.piece = Pawn.new('white')
        pawn = square.piece
        p pawn
        p pawn.valid_moves(2, 4, @turn, @board, @black_pieces)
    end

    def get_move
        loop do
            valid = true
            move = gets.split.map {|coord| coord.to_i}
            valid = false if move.length != 4
            move.each do |coord|
                if coord < 0 || coord > 7
                    valid = false
                end
            end
            return move if valid && valid_move?(move)
            puts "Invalid move"
        end
    end

    def valid_move?(move)
        start_piece = @board[move[0]][move[1]].piece
        finish_piece = @board[move[2]][move[3]].piece
        return false if start_piece.color != @turn

        opponent_pieces = @turn == 'white' ? @black_pieces : @white_pieces
        valid_moves = start_piece.valid_moves(move[0], move[1], @turn, @board, opponent_pieces)
        valid_moves = filter_moves(valid_moves)
        return false if !valid_moves.include?([move[2], move[3]])

        check_board = @board
        check_board[move[2]][move[3]].piece = start_piece
        check_board[move[0]][move[1]].piece = Empty.new
        @board = check_board
        
        #return false if check?(check_board)
        
        
        p start_piece
        p finish_piece
        p valid_moves
        true
    end

    def filter_moves(moves)
        moves.filter! {|move| move[0] >= 0 && move[0] <= 7 && move[1] >= 0 && move[1] <= 7}
        moves.filter {|move| @board[move[0]][move[1]].piece.color != (@turn == 'white' ? 'white' : 'black')}
    end

    def display_board
        row_count = -1
        display = @board.map do |row|
            row_count += 1
            symbol_row = row.map {|square| square.piece.symbol}
            " #{row_count} | " + symbol_row.join(" | ") + " |"
        end
        num_line = "     0   1   2   3   4   5   6   7 \n"
        row_line = "\n   —————————————————————————————————\n"
        puts row_line + display.join(row_line) + row_line + num_line
            
    end
end

game = Chess.new
game.play_game
