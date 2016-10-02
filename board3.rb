require 'pry'

BOARD_SIZE = 3
BOARD_AREA = BOARD_SIZE**2

def prompt(message)
  puts "==> #{message}"
end

def empty_squares(board)
  board.each_index.select { |i| board[i] == " " }
end

def alter_turn(turn)
  turn == "computer" ? "player" : "computer"
end

def game_nodes(brd, n, turn, brd_state)
  brd_state[n][brd] = Hash.new { |h, k| h[k] = [] }
  empty_squares(brd).each do |square|
    board = brd.dup
    board[square] = turn == "computer" ? "O" : "X"
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

def node_states(turn, node, brd_state)
  brd_state[node] = {}
  value_count = brd_state[node - 1].values.size
  (0..(value_count - 1)).each do |size|
    brd_state[node - 1].values[size]['state'].each do |board|
      brd_state = game_nodes(board, node, turn, brd_state) unless winner(board)
    end
  end
  brd_state
end

def brd_node(turn, brd_state)
  n = brd_state.keys.size
  brd_state = node_states(turn, n, brd_state)
  turn = alter_turn(turn)
  brd_empty = brd_state[n].values[0]['state'].last.flatten.include?(" ")
  brd_node(turn, brd_state) if brd_empty
  brd_state
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

def min_max(min_max, brd_state)
  n = brd_state.keys.last
  n.step(2, -1) do |node|
    brd_state = calculate_minmax_score(node, min_max, brd_state)
    min_max = alter_minmax_state(min_max)
  end
  computer_choice(brd_state, min_max)
end

def computer_choice(brd_state, min_max)
  selected_score = brd_state[1].values.last['score'].send(min_max)
  brd_index = brd_state[1].values.last['score'].index(selected_score)
  brd_state[1].values.last['state'][brd_index]
end

def alter_minmax_state(mm_state)
  mm_state == 'min' ? 'max' : 'min'
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
  BOARD_SIZE.times do |line|
    display_line(board, line)
  end
end

continue_play = true
brd_state = {}

while continue_play
  board = Array.new(BOARD_SIZE**2, " ")
  while board.include?(" ") && winner(board).nil?
    puts "Select Square to mark"
    square = gets.chomp.to_i
    board[square - 1] = "X"
    brd_state[0] = { board => {} }
    brd_state[0][board.dup]['state'] = [board.dup]
    brd_state[0][board.dup]['score'] = [nil]
    display_board(board)
    break if winner(board) || !board.include?(" ")
    brd_node('computer', brd_state)
    board = min_max('min', brd_state)
    display_board(board)
    brd_state.clear
  end
  puts "would you like to play again (y/n)"
  answer = gets.chomp
  continue_play = false if answer == 'n'
end
