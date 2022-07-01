require_relative '../lib/tic_tac_toe'
include Symbols

describe Board do
  subject(:my_board) { described_class.new }

  describe '#reset_board' do
    let(:random_position) do
      %w[a1 a2 a3
         b1 b2 b3
         c1 c2 c3].sample
    end

    it 'resets the positions' do
      # fill random postion
      my_board.positions[random_position] = 'X'
      my_board.empty_positions.delete(random_position)

      my_board.reset_board
      expect(my_board.positions[random_position]).to eq(' ')
    end
  end

  describe '#insert' do
    it 'inserts given symbol at given position' do
      my_board.insert('a1', 'X')
      my_board.insert('c2', 'P')
      expect(my_board.positions['a1']).to eq('X')
      expect(my_board.positions['c2']).to eq('P')
    end

    it 'displays error when given invalid position' do
      error_message = 'Invalid position'
      expect(my_board).to receive(:puts).with(error_message).once
      my_board.insert('165', 'X')
    end

    it 'displays error when given a position that is not empty' do
      my_board.insert('b2', 'X')
      error_message = 'Enter empty position'
      expect(my_board).to receive(:puts).with(error_message)
      my_board.insert('b2', '+')
    end
  end

  describe '#fetch' do
    before do
      my_board.insert('a2', 'x')
      my_board.insert('c3', '+')
    end

    it 'fetches the value at given position' do
      expect(my_board.fetch('a2')).to eq('x')
      expect(my_board.fetch('b1')).to eq(' ')
      expect(my_board.fetch('c3')).to eq('+')
    end
  end

  describe '#empty_positions' do
    it 'returns empty positions in the board' do
      # fill some positions
      my_board.positions['a1'] = 'x'
      my_board.positions['a2'] = 'y'
      my_board.positions['b1'] = 'x'

      expect(my_board.empty_positions).to eq(%w[a3 b2 b3 c1 c2 c3])
    end
  end
end

describe Game do
  subject(:my_game) { described_class.new }

  describe '#register' do
    it 'adds player to the game' do
      player = 'Player 1'
      my_game.register(player)
      expect(my_game.players).to include(player)
    end

    it 'assigns a symbol to the player' do
      player = 'Player 2'
      my_game.register(player)
      expect(my_game.players[player]).to eq(CIRCLE).or eq(CROSS)
    end
  end

  describe '#symbol' do
    it 'returns the symbol assigned to the registered player' do
      player = 'Player 1'
      my_game.register(player)
      expect(my_game.symbol(player)).to eq(CIRCLE).or eq(CROSS)
    end
  end

  describe '#insert' do
    it 'sends :insert message to the game' do
      my_board = my_game.board
      expect(my_board).to receive(:insert).once
      my_game.insert('Player1', 'a2')
    end
  end

  describe '#check_endgame' do
    context 'when game is not finished' do
      before do
        my_board = my_game.board
        board_setup = { 'a1' => ' ', 'a2' => ' ', 'a3' => 'O',
                        'b1' => ' ', 'b2' => 'O', 'b3' => ' ',
                        'c1' => 'X', 'c2' => ' ', 'c3' => 'X' }
        board_setup.each do |key, value|
          my_board.insert(key, value)
        end
      end

      it 'returns false' do
        expect(my_game.check_endgame).to be_falsy
      end
    end

    context 'when game ends with a "row" win' do
      before do
        allow(my_game).to receive(:declare_winner)
        my_board = my_game.board
        board_setup = { 'a1' => 'X', 'a2' => 'X', 'a3' => 'X',
                        'b1' => 'O', 'b2' => 'O', 'b3' => ' ',
                        'c1' => ' ', 'c2' => ' ', 'c3' => ' ' }
        board_setup.each do |key, value|
          my_board.insert(key, value)
        end
      end

      it 'returns true' do
        expect(my_game.check_endgame).to be_truthy
      end

      it 'sends :declare_winner to the game' do
        expect(my_game).to receive(:declare_winner).with('X').once
        my_game.check_endgame
      end
    end

    context 'when game ends with a "column" win' do
      before do
        allow(my_game).to receive(:declare_winner)
        my_board = my_game.board
        board_setup = { 'a1' => 'X', 'a2' => 'X', 'a3' => '@',
                        'b1' => ' ', 'b2' => '@', 'b3' => '@',
                        'c1' => 'X', 'c2' => ' ', 'c3' => '@' }
        board_setup.each do |key, value|
          my_board.insert(key, value)
        end
      end

      it 'returns true' do
        expect(my_game.check_endgame).to be_truthy
      end

      it 'sends :declare_winner to the game' do
        expect(my_game).to receive(:declare_winner).with('@').once
        my_game.check_endgame
      end
    end

    context 'when game ends with a "diagonal" win' do
      before do
        allow(my_game).to receive(:declare_winner)

        my_board = my_game.board
        board_setup = { 'a1' => '&', 'a2' => ' ', 'a3' => '&',
                        'b1' => '$', 'b2' => '&', 'b3' => ' ',
                        'c1' => '&', 'c2' => '$', 'c3' => '$' }
        board_setup.each do |key, value|
          my_board.insert(key, value)
        end
      end

      it 'returns true' do
        expect(my_game.check_endgame).to be_truthy
      end

      it 'sends :declare_winner to the game' do
        expect(my_game).to receive(:declare_winner).with('&').once
        my_game.check_endgame
      end
    end

    context 'when game ends with a draw' do
      before do
        allow(my_game).to receive(:declare_draw)
        my_board = my_game.board
        board_setup = { 'a1' => '&', 'a2' => '$', 'a3' => '&',
                        'b1' => '$', 'b2' => '&', 'b3' => '&',
                        'c1' => '$', 'c2' => '&', 'c3' => '$' }
        board_setup.each do |key, value|
          my_board.insert(key, value)
        end
      end

      it 'returns true' do
        expect(my_game.check_endgame).to be_truthy
      end

      it 'sends :declare_draw to the game' do
        expect(my_game).to receive(:declare_draw)
        my_game.check_endgame
      end
    end
  end

  describe '#same_elements?' do
    it 'returns true when an array of same elements are given' do
      my_array = %w[a a a a]
      expect(my_game.same_elements?(my_array)).to be_truthy
    end

    it 'returns false when an array of same elements are not given' do
      my_array = ['a', 'a', 'a', 'a', ' ', 'a']
      expect(my_game.same_elements?(my_array)).to be_falsy
    end
  end

  describe '#empty_positions' do
    it 'sends :empty_positions to the board' do
      my_board = my_game.board
      expect(my_board).to receive(:empty_positions)
      my_game.empty_positions
    end
  end

  describe '#reset' do
    it 'sends :reset_board to the board' do
      my_board = my_game.board
      expect(my_board).to receive(:reset_board)
      my_game.reset
    end
  end

  describe '#draw_board' do
    it 'sends :draw to the board' do
      my_board = my_game.board
      expect(my_board).to receive(:draw)
      my_game.draw_board
    end
  end

  describe '#declare_winner' do
    it 'declares the winner when winner symbol is passed' do
      # setup
      player = double(Player, name: 'Player1')
      my_game.register(player)
      player_symbol = my_game.symbol(player)
      winner_statement = 'Player1 WINS'

      expect(my_game).to receive(:puts).with(winner_statement).once
      my_game.declare_winner(player_symbol)
    end
  end
end

describe Player do
  subject(:my_player) { described_class.new }
  let(:my_game) { double(Game, register: nil) }

  describe '#join' do
    it 'sends :register to the passed game' do
      expect(my_game).to receive(:register).with(my_player).once
      my_player.join(my_game)
    end
  end

  describe '#place' do
    it 'sends :insert to the game' do
      expect(my_game).to receive(:insert).with(my_player, 'position')
      my_player.join(my_game)
      my_player.place('position')
    end
  end

  describe '#symbol' do
    it 'sends :symbol to the game' do
      expect(my_game).to receive(:symbol).with(my_player).once
      my_player.join(my_game)
      my_player.symbol
    end
  end
end

describe Bot do
  subject(:my_bot) { described_class.new }
  let(:my_game) { double(Game, empty_positions: ['a1'], register: nil) }

  before do
    my_bot.join(my_game)
    allow(my_bot).to receive(:print)
    allow(my_bot).to receive(:puts)
    allow(my_bot).to receive(:sleep)
  end

  describe '#place' do
    it 'sends :insert to the game with random empty position' do
      expect(my_game).to receive(:insert).with(my_bot, 'a1')
      my_bot.place
    end
  end
end

describe TicTacToe do
  subject(:ttt) { described_class.new }
  let(:fake_player) { double(Player, name: 'fake') }

  describe '#add_players' do
    before do
      allow(ttt).to receive(:puts)
      allow(ttt).to receive(:gets).and_return('Player1', 'Player2')
      allow(ttt).to receive(:p1).and_return(fake_player)
      allow(ttt).to receive(:p2).and_return(fake_player)
    end

    it 'sends :join to the game' do
      expect(fake_player).to receive(:join).twice
      ttt.add_players
    end
  end

  describe '#toggle_player' do
    before do
      allow(ttt).to receive(:p1).and_return('Player1')
      allow(ttt).to receive(:p2).and_return('Player2')
    end

    it 'toggles player turn' do
      ttt.player = 'Player1'
      ttt.toggle_player
      expect(ttt.player).to eq('Player2')
    end
  end

  describe '#reset' do
    it 'sends :reset to the game' do
      my_game = ttt.game
      expect(my_game).to receive(:reset).once
      ttt.reset
    end
  end

  describe '#start' do
    before do
      allow(ttt).to receive(:puts)
      allow(ttt).to receive(:print)
      allow(ttt.game.board).to receive(:print)
      allow(ttt).to receive(:add_players)
      allow(ttt).to receive(:player).and_return(fake_player)
      allow(ttt).to receive(:toggle_player)
    end

    context 'when valid input is given' do
      before do
        allow(ttt).to receive(:gets).and_return('a1', 'b2', 'end')
        allow(fake_player).to receive(:place).and_return(true)
      end

      it 'sends :place to the player' do
        expect(fake_player).to receive(:place).twice
        ttt.start
      end

      it 'sends :draw_board to the game after receiving input' do
        expect(ttt.game).to receive(:draw_board).twice
        ttt.start
      end

      it 'sends :check_endgame to the game' do
        expect(ttt.game).to receive(:check_endgame).twice
        ttt.start
      end

      it 'calls toggle method' do
        expect(ttt).to receive(:toggle_player).twice
        ttt.start
      end

      it 'ends the game when when user inputs "end"' do
        # if 'end' wasn't passed the test would be stuck in infinite loop
        # the test runs completely indicates that 'end' ends the game
      end
    end

    context 'when invalid input is given' do
      before do
        allow(ttt).to receive(:gets).and_return('x1', 'y2', 'end')
        allow(fake_player).to receive(:place).and_return(false, false)
      end

      it 'it rejects input and repeats the loop' do
        expect(fake_player).to receive(:place).twice
        expect(ttt).not_to receive(:toggle_player)
        ttt.start
      end
    end
  end

  describe '#help' do
    # Only contains puts statements
  end

  describe '#do_move' do
    # Private Method
  end
end
