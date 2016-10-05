require 'pry'

BOARD_SIZE = 3
BOARD_AREA = BOARD_SIZE**2
MARKER = { "player" => "X", "computer" => "O" }.freeze

def prompt(message)
  puts "==> #{message}"
end

def empty_squares(board)
  board.each_index.select { |square| board[square] == " " }
end

def alter_turn(turn)
  turn == "computer" ? "player" : "computer"
end

def valid_input?(position)
  return false unless position.to_i.to_s == position
  (1..BOARD_AREA).cover?(position.to_i) ? true : false
end

def empty_squares_string(board)
  empty_squares(board).map { |index| (index + 1) }.join(", ")
end

def validate_input(board, input)
  loop do
    return input.to_f if valid_input?(input) && board[input.to_i - 1] == " "
    if valid_input?(input)
      prompt("Square #{input} is taken.")
    else
      prompt("Invalid input")
    end
    prompt("Choose a square from #{empty_squares_string(board)}")
    input = gets.chomp
  end
end

def display_line(board, line)
  puts "|" + ("     |" * BOARD_SIZE)
  BOARD_SIZE.times do |square|
    print "|" + "  #{board[(square + (BOARD_SIZE * line))]}  "
  end
  print "|\n"
  puts "|" + ("_____|" * BOARD_SIZE) unless line == BOARD_SIZE
end

def display_board(board)
  system "clear"
  puts " " + ("_____ " * BOARD_SIZE)
  BOARD_SIZE.times do |line|
    display_line(board, line)
  end
  puts
end

def generate_game_tree(turn, brd_state)
  n = brd_state.keys.last + 1
  brd_state = game_nodes(turn, n, brd_state)
  turn = alter_turn(turn)
  brd_empty = brd_state[n].values[0]['state'].last.flatten.include?(" ")
  generate_game_tree(turn, brd_state) if brd_empty
  brd_state
end

def game_nodes(turn, node, brd_state)
  brd_state[node] = Hash.new
  value_count = brd_state[node - 1].values.size
  (0..(value_count - 1)).each do |size|
    brd_state[node - 1].values[size]['state'].each do |board|
      continue = winner(board) && !board.include?(" ")
      brd_state = game_sub_nodes(board, node, turn, brd_state) unless continue
    end
  end
  brd_state
end

def game_sub_nodes(brd, n, turn, brd_state)
  brd_state[n][brd] = Hash.new { |h, k| h[k] = [] }
  empty_squares(brd).each do |square|
    board = brd.dup
    board[square] = MARKER[turn]
    (brd_state[n][brd]['state'] << board.dup).flatten
    brd_state[n][brd]['score'] << calc_score(board)
  end
  brd_state
end

def calc_score(brd)
  winner = winner(brd)
  return -1 if winner == 'X'
  return 1 if winner == 'O'
  return nil if brd.include?(" ")
  0
end

def winner?(line)
  line.uniq.size == 1 && line.uniq != [" "]
end

def horizontal_winner(board)
  0.step(BOARD_AREA - 1, BOARD_SIZE) do |start|
    line = board.slice(start, BOARD_SIZE)
    return line[0] if winner?(line)
  end
  nil
end

def vertical_winner(board)
  (0..2).each do |index|
    line = index.step((BOARD_AREA - 1), BOARD_SIZE).map { |i| board[i] }
    return board[index] if winner?(line)
  end
  nil
end

def diagonal_winner(board)
  diagonal1 = 0.step((BOARD_AREA - 1), (BOARD_SIZE + 1)).map { |i| board[i] }
  return board[0] if winner?(diagonal1)
  diagonal2 = (BOARD_SIZE - 1).step((BOARD_SIZE * 2), (BOARD_SIZE - 1))
                              .map { |i| board[i] }
  return board[BOARD_SIZE - 1] if winner?(diagonal2)
  nil
end

def winner(board)
  horizontal_winner(board)   ||
    vertical_winner(board)   ||
    diagonal_winner(board)
end

def calculate_minmax_score(node, min_max, brd_state)
  brd_state[node - 1].each do |k, v|
    v['state'].each_with_index do |board, index|
      unless v['score'][index]
        score = brd_state[node][board]['score'].send(min_max)
        brd_state[node - 1][k]['score'][index] = score
      end
    end
  end
  brd_state
end

def computer_choice(brd_state, min_max)
  selected_score = brd_state[1].values.last['score'].send(min_max)
  brd_index = brd_state[1].values.last['score'].index(selected_score)
  brd_state[1].values.last['state'][brd_index]
end

def alter_minmax_state(mm_state)
  mm_state == 'min' ? 'max' : 'min'
end

def computer_marks_board(min_max, brd_state)
  n = brd_state.keys.last
  n.step(2, -1) do |node|
    brd_state = calculate_minmax_score(node, min_max, brd_state)
    min_max = alter_minmax_state(min_max)
  end
  computer_choice(brd_state, min_max)
end

def computer_move(brd_state)
  brd_state = generate_game_tree('computer', brd_state)
  computer_marks_board('min', brd_state)
end

def track_score(winner, game_score)
  if winner == " "
    game_score["tie"] += 1
  else
    game_score[winner] += 1
  end
  game_score
end

continue_play = true
game_score = Hash.new(0)

while continue_play
  board = Array.new(BOARD_SIZE**2, " ")
  brd_state = Hash.new
  winner = " "

  while board.include?(" ") && winner == " "
    display_board(board)
    prompt "Select Square to mark"
    square = validate_input(board, gets.chomp)
    board[square - 1] = MARKER["player"]
    display_board(board)

    brd_state[0] = { board => {} }
    brd_state[0][board]['state'] = [board]
    brd_state[0][board]['score'] = [nil]

    if winner(board)
      winner = "Player"
    elsif board.include?(" ")
      board = computer_move(brd_state)
      display_board(board)
      brd_state.clear
    end
    winner = "Computer" if winner(board)
  end

  puts winner == " " ? "Tie Game \n\n" : "#{winner} wins !!!\n\n"
  game_score = track_score(winner, game_score)
  puts "Computer: #{game_score['Computer']}, Player: #{game_score['Player']},"\
        " Tie:  #{game_score['tie']}\n\n"

  prompt "Enter y to play again or any other key to exit game."
  answer = gets.chomp.downcase
  continue_play = false unless answer.start_with?('y')
end
prompt "Good Bye!"
