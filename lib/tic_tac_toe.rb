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
    reset_board
  end

  def reset_board
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
    unless empty_positions.include?(position)
      puts 'Enter empty position'
      return false
    end
    @positions[position] = symbol
    true
  end

  def fetch(position)
    @positions[position]
  end

  def empty_positions
    empty = []
    positions.each do |key, value|
      empty.push(key) if value == ' '
    end
    empty
  end

  def draw
    print fetch('a1'), '|', fetch('a2'), '|', fetch('a3')
    print "\n", fetch('b1'), '|', fetch('b2'), '|', fetch('b3')
    print "\n", fetch('c1'), '|', fetch('c2'), '|', fetch('c3')
    print "\n", "\n"
  end
end

# Top level Game Class Definition
class Game
  include Symbols

  attr_reader :players, :board

  def initialize
    @players = {}
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
    board.insert(position, symbol(player))
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
        values << board.fetch(position)
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
        values << board.fetch(position)
      end
      if same_elements?(values)
        declare_winner(values[0])
        return true
      end
    end

    # check for draw
    if empty_positions.empty?
      declare_draw
      return true
    end

    false
  end

  def same_elements?(array)
    array[0] != ' ' && array.uniq.length == 1
  end

  def empty_positions
    board.empty_positions
  end

  def reset
    board.reset_board
  end

  def draw_board
    board.draw
  end

  def declare_winner(symbol)
    @players.each do |player, player_symbol|
      if player_symbol == symbol
        puts "#{player.name} WINS"
        break
      end
    end
  end

  def declare_draw
    puts 'DRAW GAME'
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

  def symbol
    @game.symbol(self)
  end
end

# Bot subclass of Player
class Bot < Player
  def place
    empty_positions = @game.empty_positions
    3.times do
      print '.'
      sleep(0.3)
    end
    random_position = empty_positions.sample
    puts random_position
    @game.insert(self, random_position)
  end
end

# Main Game Class For Flow Control
class TicTacToe
  attr_reader :game, :p1, :p2
  attr_accessor :player

  def initialize
    @game = Game.new
  end
  
  def add_players
    help
    puts 'Enter name of player 1: '
    @p1 = Player.new(gets.chomp)
    puts "Enter name of player 2(Try 'bot'): "
    p2_name = gets.chomp
    @p2 = if p2_name.downcase == 'bot'
            Bot.new(p2_name)
          else
            Player.new(p2_name)
          end

    p1.join(game)
    p2.join(game)
  end

  def toggle_player
    @player = player == p1 ? p2 : p1
  end

  def reset
    game.reset
  end

  def start
    add_players unless p1
    @player = [p1, p2].sample
    loop do
      print "#{player.name}>> "

      case do_move
      when 'end'
        break
      when 'repeat'
        next
      end

      game.draw_board

      break if game.check_endgame

      toggle_player
    end
  end

  def help
    puts "Tic-Tac-Toe:
    Conquer a row, a column or a diagonal to win.
    Input: a,b,c are rows and 1,2,3 are columns. Example: enter b3 for inserting at second row third column
    Enter 'end' anytime to quit the game in between"
  end

  private

  def do_move
    # if player is bot, just do a random move
    if player.instance_of?(Bot)
      player.place
    else
      input = gets.chomp
      return 'end' if input == 'end'
      return 'repeat' unless player.place(input)
    end
  end
end
