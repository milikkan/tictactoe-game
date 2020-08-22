# constant definitons
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[2, 5, 8], [1, 4, 7], [3, 6, 9]] + # columns
                [[1, 5, 9], [3, 5, 7]]              # diagonals
WINNING_SCORE = 5
MOVE_FIRST = "choose" # valid options: choose, computer, player

# method definitions
def prompt(msg)
  puts "=> #{msg}"
end

def clear_screen
  system("clear") || system("cls")
end

def spacer(lines=1)
  lines.times { puts }
end

def box(msg)
  len = msg.length + 2
  upper_left = "\u250C"
  upper_right = "\u2510"
  lower_left = "\u2514"
  lower_right = "\u2518"
  horizontal = "\u2500"
  vertical = "\u2502"

  puts upper_left + (horizontal * len) + upper_right
  puts vertical + " " + msg + " " + vertical
  puts lower_left + (horizontal * len) + lower_right
end

def integer?(input)
  /^\d+$/.match(input)
end

def display_welcome_message
  box "  WELCOME TO TIC-TAC-TOE GAME  "
  spacer
end

def display_score(scores)
  spacer
  prompt "SCORE (reach #{WINNING_SCORE} to win):"
  box "  PLAYER| #{scores[:player]}   -   #{scores[:computer]} |COMPUTER  "
  spacer
end

def display_marker_info
  prompt "You are a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
end

# rubocop: disable Metrics/AbcSize
def display_board(brd)
  puts "       |     |"
  puts "    #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "       |     |"
  puts "  -----+-----+-----"
  puts "       |     |"
  puts "    #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "       |     |"
  puts "  -----+-----+-----"
  puts "       |     |"
  puts "    #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "       |     |"
end
# rubocop: enable Metrics/AbcSize

def reset_screen
  clear_screen
  display_welcome_message
  display_marker_info
  spacer
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def joinor(arr, delimiter=', ', link_word='or')
  msg = ''

  if arr.size == 1
    msg = arr[0].to_s
  elsif arr.size == 2
    msg = "#{arr[0]} #{link_word} #{arr[1]}"
  else
    msg = arr[0...arr.size - 1].join(delimiter)
    msg += delimiter + link_word
    msg += " " + arr[-1].to_s
  end
  msg
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square #{joinor(empty_squares(brd))}:"
    square = gets.chomp
    break if integer?(square) && empty_squares(brd).include?(square.to_i)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square.to_i] = PLAYER_MARKER
end

def count_marker(brd, line, marker)
  brd.values_at(*line).count(marker)
end

def find_marker(brd, line, marker)
  line.each do |square|
    return square if brd[square] == marker
  end
  nil
end

def decide_computer_move(brd, marker)
  WINNING_LINES.each do |line|
    space_count = count_marker(brd, line, INITIAL_MARKER)
    move_count = count_marker(brd, line, marker)

    if (move_count == 2) && (space_count == 1)
      return find_marker(brd, line, INITIAL_MARKER)
    end
  end
  nil
end

def computer_places_piece!(brd)
  # offensive move
  square = decide_computer_move(brd, COMPUTER_MARKER)
  # defensive move
  square = decide_computer_move(brd, PLAYER_MARKER) if !square
  # pick square 5 if available
  square = 5 if (!square) && (brd[5] == INITIAL_MARKER)
  # random move
  square = empty_squares(brd).sample if !square

  brd[square] = COMPUTER_MARKER
end

def place_piece!(brd, player)
  if player == "computer"
    computer_places_piece!(brd)
  else
    player_places_piece!(brd)
  end
end

def alternate_player(player)
  player == "computer" ? "player" : "computer"
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def round_won?(brd)
  !!detect_round_winner(brd)
end

def detect_round_winner(brd)
  WINNING_LINES.each do |line|
    if count_marker(brd, line, PLAYER_MARKER) == 3
      return 'player'
    elsif count_marker(brd, line, COMPUTER_MARKER) == 3
      return 'computer'
    end
  end
  nil
end

def game_won?(scores)
  !!detect_game_winner(scores)
end

def update_score(scores, winner)
  scores[winner.to_sym] += 1
end

def detect_game_winner(scores)
  if scores[:player] == WINNING_SCORE
    return 'player'
  elsif scores[:computer] == WINNING_SCORE
    return 'computer'
  end
  nil
end

def display_round_result(winner)
  if winner == "tie"
    prompt "It's a tie!"
  else
    prompt "#{winner.capitalize} won the round!"
  end
end

def display_next_round
  prompt "Press enter for the next round..."
  gets
end

def display_game_result(winner)
  spacer
  prompt "Game over. #{winner.capitalize} won!"
end

def display_play_again
  prompt "Play again? (y or n)"
end

def retrieve_new_game_answer
  loop do
    answer = gets.chomp.downcase
    break answer if ['y', 'yes', 'n', 'no'].include?(answer)
    prompt "Invalid input, please enter either 'y', yes' or 'n', no'"
  end
end

def new_game?(answer)
  answer == 'y' || answer == 'yes'
end

def choose_first
  clear_screen
  prompt "Who will play first?"
  prompt "Hit 'p' for player, 'c' for computer"
  loop do
    answer = gets.chomp.downcase
    break answer if answer == 'p' || answer == 'c'
    prompt "Invalid choice! Try again..."
  end
end

def initialize_player
  if MOVE_FIRST == "choose"
    result = choose_first == 'p' ? "player" : "computer"
    spacer(2)
    prompt "#{result.upcase} will start playing."
    prompt "Press enter to begin the game..."
    gets
  else
    result = MOVE_FIRST
  end
  result
end

first_player = initialize_player

loop do # main game loop
  scores = { player: 0, computer: 0 }

  loop do
    board = initialize_board
    current_player = first_player
    loop do
      reset_screen
      display_board(board)
      display_score(scores)

      place_piece!(board, current_player)
      current_player = alternate_player(current_player)

      break if round_won?(board) || board_full?(board)
    end

    if round_won?(board)
      winner = detect_round_winner(board)
      update_score(scores, winner)
    else
      winner = "tie"
    end

    reset_screen
    display_board(board)
    display_score(scores)
    display_round_result(winner)

    break if game_won?(scores)
    display_next_round
  end

  game_winner = detect_game_winner(scores)
  display_game_result(game_winner)

  display_play_again
  answer = retrieve_new_game_answer
  break unless new_game?(answer)
end # end main loop

prompt "Thanks for playing Tic Tac Toe. Good bye!"
