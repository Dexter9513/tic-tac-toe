# frozen_string_literal: true

# Store symbols
module Symbols
  CIRCLE = 'O'
  CROSS = 'X'
end

# Top level Board Class Definition
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
    unless fetch(position) == ' '
      puts 'Enter empty position'
      return false
    end
    @positions[position] = symbol
    draw
    true
  end

  def fetch(position)
    @positions[position]
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

# Top level Game Class Definition
class Game
  include Symbols
  def initialize
    @players = {}
    @moves = []
    @board = Board.new
  end

  def register(player)
    if @players.length >= 2
      puts 'Failed to join game. Party full!'
      false
    elsif @players.length.zero?
      @players[player] = CIRCLE
    else
      @players[player] = CROSS
    end
  end

  def symbol(player)
    @players[player]
  end

  def insert(player, position)
    @moves.append(position)
    @board.insert(position, symbol(player))
  end

  def check_endgame
    # check for rows
    'a'.upto('c') do |row|
      values = []
      '1'.upto('3') do |column|
        position = row + column
        values << @board.fetch(position)
      end
      if same_elements?(values)
        declare_winner(values[0])
        return true
      end
    end

    # check for columns
    '1'.upto('3') do |column|
      values = []
      'a'.upto('c') do |row|
        position = row + column
        values << @board.fetch(position)
      end
      if same_elements?(values)
        declare_winner(values[0])
        return true
      end
    end

    # check for diagonals
    diagonals = [
      %w[a1 b2 c3],
      %w[a3 b2 c1]
    ]
    diagonals.each do |diagonal|
      values = []
      diagonal.each do |position|
        values << @board.fetch(position)
      end
      if same_elements?(values)
        declare_winner(values[0])
        return true
      end
    end
    false
  end

  def declare_winner(symbol)
    @players.each do |player, player_symbol|
      if player_symbol == symbol
        puts "#{player.name} wins"
        break
      end
    end
  end

  def same_elements?(array)
    array[0] != ' ' && array[0] == array[1] && array[1] == array[2]
  end
end

# Top level Player Class Definition
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

# Flow Control
my_game = Game.new
p1 = Player.new
p2 = Player.new('Player2')
p1.join(my_game)
p2.join(my_game)
player = p1
loop do
  print "#{player.name}>> "
  input = gets.chomp
  break if input == 'end'
  next unless player.place(input)

  break if my_game.check_endgame

  player = player == p1 ? p2 : p1
end

# require('pry-byebug'); binding.pry
puts 'Thank you for playing!'
