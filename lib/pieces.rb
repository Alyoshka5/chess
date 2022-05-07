class Empty
    attr_reader :name, :symbol
    def initialize
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
        @name = 'bishop'
        @symbol = color == 'black' ? '♔' : '♚'
    end
end


symbols = '♔♕♗♘♙♖♚♛♝♞♟♜'