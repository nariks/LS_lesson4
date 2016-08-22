require 'pry'
def prompt(message)
  puts "==> #{message}"
end

def initialize_board
  board = {}
  (1..3).each { |board_row| board[board_row] = [' ', ' ', ' '] }
  board
end

def display_board(board)
  system "clear"
  (1..3).each do |row_count|
    (1..4).each do |count|
      if count == 3 
        puts "  #{board[row_count][0]}  |  #{board[row_count][1]}  |" \
             "  #{board[row_count][2]}  "
      else
        puts "     |     |     "
      end
    end
    puts "_____|_____|_____" unless row_count == 3
  end
end

def valid_input?(position)
  #/#{position}/.match(/^[1-9]$/)
  /^[1-9]$/.match(position)
end

def convert_1d_to_2d(position)
  col = position % 3
  row = (position / 3).ceil
  return row, col
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
        prompt("Please select an unmarked position.")
      end
    else
      prompt("Invalid position number. Try again...")
    end
  end
end

def player_marks_board(board, position)
  row, col = convert_1d_to_2d(position)
  board[row][col - 1] = 'X'
  board
end

def computer_marks_board(board)
  board.each do |k,v|
    v.each_with_index do |value, index|
      if value == ' '
        board[k][index] = "O"
        return board
      end
    end
  end
end

def board_not_empty?(board)
  board.values.flatten.include?(" ")
end

def transpose(board)

end

def diagonal(board)

end

def no_winner?(board)
  board.values.each do |line|
    return true if line[0] == line [1] && line[1] == line[2]
  end
  transpose(board.values).each do |line|
    return true if line[0] == line [1] && line[1] == line[2]
  end
  diagonal(board.values).each do |line|
    return true if line[0] == line[1] && line[1] == line[3]
  end
end


board = initialize_board
display_board(board)

prompt("Enter board position to mark")
loop do
  if board_not_empty?(board) && no_winner?(board)
    player_input = obtain_valid_input(board)
    board = player_marks_board(board, player_input)
    display_board(board)
    board = computer_marks_board(board)
    display_board(board)
  else
    puts detect_winner
  end
end
