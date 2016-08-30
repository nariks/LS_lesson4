require 'pry'

BOARD_SIZE = 9
MARKER = { 'P' => 'X', 'C' => 'O' }.freeze


def prompt(message)
  puts "==> #{message}"
end

def initialize_board
  Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, " ") }
end

def display_board(board)
  system "clear"
  puts " _______________________"
  (0..(BOARD_SIZE - 1)).each do |row|
    (1..4).each do |count|
      print "|"
      if count == 3
        (0..(BOARD_SIZE - 1)).each { |col| print "   #{board[row][col]}   |" }
      else
        (0..(BOARD_SIZE - 1)).each { print "       |" }
      end
      puts
    end
    print "|"
    (0..(BOARD_SIZE - 1)).each { print "_______|" }
    puts
 end
end

def valid_input?(position)
  /^[1-9]$/.match(position)
end

def convert_1d_to_2d(position)
  col = (position % 3).to_i
  row = (position / 3).ceil.to_i
  return row - 1, col - 1
end

def position_unmarked?(board, position)
  row, col = convert_1d_to_2d(position)
  board[row][col] == ' '
end

def obtain_valid_input(board)
  prompt("Please enter a valid unmarked position number from 1-9")
  loop do
    input = gets.chomp
    if valid_input?(input)
      if position_unmarked?(board, input.to_f)
        return input.to_f
      else
        prompt("Please select an unmarked square.")
      end
    else
      prompt("Invalid square number. Try again...")
    end
  end
end

def player_marks_board(board, position)
  row, col = convert_1d_to_2d(position)
  board[row][col] = 'X'
  board
end

def empty_squares(board)
  empty_squares_index = []
  board.flatten.each_with_index do |value, index|
    empty_squares_index << (index + 1) if value == " "
  end
  empty_squares_index
end

def computer_marks_board(board)
  empty_squares_position = empty_squares(board)
  row, col = convert_1d_to_2d(empty_squares_position.sample.to_f)
  board[row][col] = "O"
  board
end

def board_not_empty?(board)
  board.flatten.include?(" ")
end

def transpose(board)
  transposed = [[], [], []]
  (0..2).each do |row|
    (0..2).each do |column|
      transposed[row][column] = board[column][row]
    end
  end
  transposed
end

def diagonal(board)
  [[board[0][0], board[1][1], board[2][2]],
   [board[0][2], board[1][1], board[2][0]]]
end

def winning_line?(line)
  (line.uniq.size == 1 && line.uniq != [" "]) ? true : false
end

def no_winner?(board)
  board.each { |line| return false if winning_line?(line) }
  transpose(board).each { |line| return false if winning_line?(line) }
  diagonal(board).each { |line| return false if winning_line?(line) }
  true
end

winner = " "
board = initialize_board
display_board(board)

prompt("Enter board position to mark")
while board_not_empty?(board) && winner == " "
  player_input = obtain_valid_input(board)
  board = player_marks_board(board, player_input)
  display_board(board)
  if no_winner?(board)
    board = computer_marks_board(board)
    display_board(board)
    winner = "Computer" unless no_winner?(board)
  else
    winner = "Player"
  end
end
p(winner == " " ? " Tie Game" : "#{winner} wins !!!")
