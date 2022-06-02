$circle = 'O'
$cross = 'X'

class Board
  attr_reader :positions

  def initialize
    @positions = {
      'a1' => ' ',
      'a2' => ' ',
      'a3' => ' ',
      'b1' => ' ',
      'b2' => ' ',
      'b3' => ' ',
      'c1' => ' ',
      'c2' => ' ',
      'c3' => ' '
    }
  end

  def insert(position, symbol)
    unless positions.keys.include?(position)
      puts 'Invalid position'
      return false
    end
    @positions[position] = symbol
    draw
    return true
  end

  def fetch(position)
    value = @positions[position]
  end

  def draw
    print fetch('a1'), '|', fetch('a2'), '|', fetch('a3')
    # print "\n", '------'
    print "\n", fetch('b1'), '|', fetch('b2'), '|', fetch('b3')
    # print "\n", '------'
    print "\n", fetch('c1'), '|', fetch('c2'), '|', fetch('c3')
    print "\n", "\n"
  end

end


class Game
  
  def initialize
    @players = {}
    @moves = []
    @board = Board.new
  end

  def register(player)
    if @players.length >= 2
      puts 'Failed to join game. Party full!'
      return false
    elsif @players.length == 0
      @players[player] = $circle
    else
      @players[player] = $cross
    end
  end

  def symbol(player)
    @players[player]
  end

  def insert(player, position)
    @board.insert(position, symbol(player))
  end

end

class Player
  attr_reader :name
  
  def initialize(name = 'Player1')
    @name = name
  end

  def join(game)
    game.register(self)
    @game = game
  end

  def place(position)
    @game.insert(self, position)
  end

  def my_symbol
    @game.symbol(self)
  end

end

new_game = Game.new
p1 = Player.new
p2 = Player.new('Player2')
p1.join(new_game)
p2.join(new_game)
player = p1
loop do
  print player.name + '>> '
  input = gets.chomp
  break if input == 'end'
  next unless player.place(input)
  if player == p1
    player = p2
  else
    player = p1
  end
end

# require('pry-byebug'); binding.pry
puts 'ok'