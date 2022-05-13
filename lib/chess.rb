require 'json'
require_relative 'pieces'

class Chess
    def initialize(board = nil, turn = nil, loaded_game = false)
        @board = board ? board : generate_board()
        @turn = turn ? turn : 'black'
        @loaded_game = loaded_game
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
        row_count = 9
        display = @board.map do |row|
            row_count -= 1
            symbol_row = row.map {|square| square.piece.symbol}
            "\n #{row_count}  " + symbol_row.join(" ") + "  #{row_count}"
        end
        col_line = "\n    a b c d e f g h \n"
        puts "\n#{col_line}" + display.join() + "\n#{col_line}"
    end

    def play_game
        if !@loaded_game
            return if load_or_delete()
        end
        puts "Enter starting and ending coordinates, seperate coordinates by a space"
        puts "Ex: e2 e4"
        until game_end?() do
            @turn = @turn == 'black' ? 'white' : 'black'
            display_board()
            puts "\n#{@turn}'s move: "
            
            move = get_move()
            return if move.nil?
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
            move = gets
            if move.downcase.chomp == 'save'
                save_game()
                return nil
            end

            move = move.split
            if move.length == 2 && move[0].length == 2 && move[1].length == 2
                move = [move[0][0], move[0][1], move[1][0], move[1][1]]
                valid = false if !(('a'..'h').include?(move[0].downcase)) || !(Float(move[1]) != nil rescue false) || !(('a'..'h').include?(move[2].downcase)) || !(Float(move[3]) != nil rescue false)
                move[0].downcase!
                move[1] = move[1].to_i
                move[2].downcase!
                move[3] = move[3].to_i
                valid = false if move[1] < 1 || move[1] > 8 || move[3] < 1 || move[3] > 8
                move = [8 - move[1], move[0].ord - 97, 8 - move[3], move[2].ord - 97]
            else
                valid = false
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
        display_board()
        if check?(enemy_color)
            puts "\nCHECKMATE"
            puts "#{@turn.capitalize} wins!"
        else
            puts "\nSTALEMATE"
        end
        delete_game(@loaded_game) if @loaded_game
        true
    end
    
    def to_json
        @board.each_with_index do |row, r|
            row.each_with_index do |square, c|
                piece = square.piece
                piece_hash = {
                    :color => piece.color,
                    :name => piece.name
                }
                piece_hash[:move_count] = piece.move_count if piece.instance_of?(King) || piece.instance_of?(Rook)
                square.piece = piece_hash

                square_hash = {
                    :coordinates => square.coordinates,
                    :piece => square.piece
                }
                @board[r][c] = square_hash
            end
        end

        JSON.dump ({
            :board => @board,
            :turn => @turn
        })
    end

    def from_json(game_string, game_name)
        data = JSON.load game_string

        board = data['board']
        board.each_with_index do |row, r|
            row.each_with_index do |square_hash, c|
                piece_hash = square_hash['piece']
                piece = Empty.new if !piece_hash['name']
                piece = Pawn.new(piece_hash['color']) if piece_hash['name'] == 'pawn'
                piece = Rook.new(piece_hash['color'], piece_hash['move_count']) if piece_hash['name'] == 'rook'
                piece = Knight.new(piece_hash['color']) if piece_hash['name'] == 'knight'
                piece = Bishop.new(piece_hash['color']) if piece_hash['name'] == 'bishop'
                piece = Queen.new(piece_hash['color']) if piece_hash['name'] == 'queen'
                piece = King.new(piece_hash['color'], piece_hash['move_count']) if piece_hash['name'] == 'king'
                
                square = Square.new(r, c, piece)
                board[r][c] = square
            end
        end

        turn = data['turn'] == 'white' ? 'black' : 'white'
        Chess.new(board, turn, game_name)
    end

    def save_game
        game_name = ''
        if @loaded_game
            game_name = @loaded_game  # @loaded_game contains the name of the game
        else
            puts "\nGame name (no spaces): "
            loop do
                game_name = gets.chomp
                break if game_name.split.length == 1
                puts "Invalid name"
            end
        end

        begin
            Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
            filename = "saved_games/#{game_name}.json"
            File.open(filename, 'w') {|file| file.puts to_json()}
            puts "Game saved as #{game_name}"
        rescue
            puts "Failed to save game."
        end
    end

    def load_or_delete
        puts "Load game by entering: load game_name / Delete a saved game by entering: delete game_name"
        puts "To see all currently saved games enter: list"
        puts "Press enter with inputing anything to load a new game"
        loop do
            puts "\nEnter command: "
            command = gets.downcase.chomp
            if command.length == 0
                return false
            elsif command == "list"
                list_games()
            elsif command[0..4] == "load "
                return true if load_game(command[5..-1])
            elsif command[0..6] == "delete "
                delete_game(command[7..-1])
            end
        end
    end

    def list_games
        puts "\nCurrently saved games: "
        saved_games = Dir.entries("saved_games")
        saved_games.each {|game| puts game[0...-5] if game.include?('.json')}
    end

    def load_game(game_name)
        filename = "saved_games/#{game_name}.json"
        if File.file?(filename)
            game = from_json(File.read(filename).chomp, game_name)
            game.play_game
            return true
        else
            puts "This game does not exist"
        end
    end

    def delete_game(game_name)
        filename = "saved_games/#{game_name}.json"
        if File.file?(filename)
            File.delete(filename)
            puts "#{game_name} game deleted"
        else
            puts "This game does not exist"
        end
    end

end
