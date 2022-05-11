require_relative 'pieces'

class Chess
    def initialize
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
            end
            board << row
        end
        board
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

    def play_game
        checkmate = false
        puts "Enter starting and ending coordinates (from 0 - 7), each seperated by a space (ex: 1 7 3 6)"
        puts "First input row (y-axis) and then column (x-axis)"
        until game_end?() do
            @turn = @turn == 'black' ? 'white' : 'black'
            display_board()
            puts "\n#{@turn}'s move: "
            
            move = get_move()
            place_move(move)
        end
    end

    def testing
        @turn = 'white'
        rook = Bishop.new('white')
        @board[3][4].piece = rook
        display_board()
        moves = filter_moves(rook.valid_moves(3, 4, 'white', @board), @turn)
        p moves
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
        
        if start_piece.instance_of?(King)
            valid_moves = start_piece.valid_moves(move[0], move[1], @turn, @board, check?(@turn))
        else
            valid_moves = start_piece.valid_moves(move[0], move[1], @turn, @board)
        end
        valid_moves = filter_moves(valid_moves, @turn)
        return false if !valid_moves.include?([move[2], move[3]])
        
        taken_piece = @board[move[2]][move[3]].piece
        @board[move[2]][move[3]].piece = start_piece
        @board[move[0]][move[1]].piece = Empty.new
        
        is_check = check?(@turn)
        @board[move[0]][move[1]].piece = start_piece
        @board[move[2]][move[3]].piece = taken_piece
        puts "\nKING IN CHECK" if is_check
        return !is_check
    end
    
    def filter_moves(moves, turn)
        moves.filter! {|move| move[0] >= 0 && move[0] <= 7 && move[1] >= 0 && move[1] <= 7}
        moves.filter {|move| @board[move[0]][move[1]].piece.color != turn}
    end
    
    def place_move(move)
        # king castling
        if @board[move[0]][move[1]].piece.instance_of?(King)
            if @turn == 'white'
                if move[0] == 7 && move[1] == 4 && move[2] == 7 && move[3] == 6
                    king = @board[7][4].piece
                    rook = @board[7][7].piece
                    @board[7][6].piece = king
                    @board[7][5].piece = rook
                    @board[7][4].piece = Empty.new
                    @board[7][7].piece = Empty.new
                    return
                elsif move[0] == 7 && move[1] == 4 && move[2] == 7 && move[3] == 2
                    king = @board[7][4].piece
                    rook = @board[7][0].piece
                    @board[7][2].piece = king
                    @board[7][3].piece = rook
                    @board[7][4].piece = Empty.new
                    @board[7][0].piece = Empty.new
                    return
                end
            else
                if move[0] == 0 && move[1] == 4 && move[2] == 0 && move[3] == 6
                    king = @board[0][4].piece
                    rook = @board[0][7].piece
                    @board[0][6].piece = king
                    @board[0][5].piece = rook
                    @board[0][4].piece = Empty.new
                    @board[0][7].piece = Empty.new
                    return
                elsif move[0] == 0 && move[1] == 4 && move[2] == 0 && move[3] == 2
                    king = @board[0][4].piece
                    rook = @board[0][0].piece
                    @board[0][2].piece = king
                    @board[0][3].piece = rook
                    @board[0][4].piece = Empty.new
                    @board[0][0].piece = Empty.new
                    return
                end
            end
        end
        
        # replace pawn with new piece if it reaches the end of the board
        if @board[move[0]][move[1]].piece.instance_of?(Pawn) && move[2] == (@turn == 'white' ? 0 : 7)
            puts "Enter piece to replace pawn (queen, rook, knight, bishop):"
            replacement = ''
            loop do
                replacement = gets.downcase.chomp
                break if ['queen', 'rook', 'knight', 'bishop'].include?(replacement)
                puts "Invalid choice"
            end
            new_piece = Queen.new(@turn) if replacement == 'queen'
            new_piece = Rook.new(@turn) if replacement == 'rook'
            new_piece = Knight.new(@turn) if replacement == 'knight'
            new_piece = Bishop.new(@turn) if replacement == 'bishop'
            @board[move[0]][move[1]].piece = new_piece
        end
        
        piece = @board[move[0]][move[1]].piece
        piece.move_count += 1 if piece.instance_of?(King) || piece.instance_of?(Rook)
        
        # make move
        @board[move[2]][move[3]].piece = @board[move[0]][move[1]].piece
        @board[move[0]][move[1]].piece = Empty.new
    end
    
    
    def check?(turn)
        king_coords = @board.flatten.find {|square| square.piece.name == 'king' && square.piece.color == turn}.coordinates
        
        @board.flatten.each do |square|
            piece = square.piece
            next if piece.instance_of?(Empty) || piece.color == turn
            enemy_turn = (turn == 'white' ? 'black' : 'white')
            if piece.instance_of?(King)
                piece_moves = piece.valid_moves(square.coordinates[0], square.coordinates[1], enemy_turn, @board, true)
            else
                piece_moves = piece.valid_moves(square.coordinates[0], square.coordinates[1], enemy_turn, @board)
            end
            return true if piece_moves.include?(king_coords)
        end
        false
    end
    
    def game_end?
        enemy_color = @turn == 'white' ? 'black' : 'white'
        @board.flatten.each do |square|
            piece = square.piece
            next if piece.color != enemy_color
            coordinate = square.coordinates
            if piece.instance_of?(King)
                piece_moves = filter_moves(piece.valid_moves(coordinate[0], coordinate[1], enemy_color, @board, check?(@turn)), enemy_color)
            else
                piece_moves = filter_moves(piece.valid_moves(coordinate[0], coordinate[1], enemy_color, @board), enemy_color)
            end
            
            piece_moves.each do |move_to|
                taken_piece = @board[move_to[0]][move_to[1]].piece
                @board[move_to[0]][move_to[1]].piece = piece
                @board[coordinate[0]][coordinate[1]].piece = Empty.new
                
                game_ending = check?(enemy_color)
                @board[coordinate[0]][coordinate[1]].piece = piece
                @board[move_to[0]][move_to[1]].piece = taken_piece
                return false if !game_ending
            end
        end
        if check?(enemy_color)
            puts "\nCHECKMATE"
            puts "#{@turn.capitalize} wins!"
        else
            puts "\nSTALEMATE"
        end
        true
    end

end

game = Chess.new
game.play_game
