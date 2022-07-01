require_relative './lib/tic_tac_toe'

def run
  tic_tac_toe = TicTacToe.new
  loop do
    tic_tac_toe.start
    print 'Play again(y/n): '
    break unless gets.chomp.downcase == 'y'

    tic_tac_toe.reset
  end

  puts 'Thank you for playing!'
end

run