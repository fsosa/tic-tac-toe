#! /usr/bin/env ruby

class Board
	attr_accessor :grid
	attr_accessor :winner

	def initialize
		reset_grid
	end

	def print_grid
		@grid.each_with_index do |row, i|
			marker = row.nil? ? "" : row > 0 ? "X" : "O"
			print " #{marker} "

			print "|" unless i % 3 == 2

			if i % 3 == 2
				puts ""
				puts "-"*10

			end
		end
	end

	def reset_grid
		@winner = 0
		self.grid = Array.new(9)
	end

	def legalMoves
		legalMoves = []

		@grid.each_index do |index|
			if @grid[index].nil?
				legalMoves.push(index)
			end
		end

		return legalMoves
	end

	def makeMove (marker, loc)
		if (loc < 0 || loc > 8)
			p "INVALID MOVE: CAN'T MOVE THERE"
			return
		end

		grid_pos = @grid[loc]


		if grid_pos.nil?
			@grid[loc] = marker			
		else
			puts
			p "INVALID MOVE: MARKER ALREADY THERE"
			puts
			return
		end
	end

	def game_complete?
		return winning_column? || winning_row? || winning_diagonal? || legalMoves.empty?
	end

	def winning_row?
		row_sum = 0
		@grid.each_with_index do |sq, i|

			if i % 3 == 0
				row_sum = 0
			end

			if sq.nil?
				next
			end

			row_sum += sq

			if row_sum == 3 || row_sum == -3
				@winner = row_sum / 3
				return true
			end
		end

		@winner = 0
		return false
	end

	def winning_column?
		3.times do |i|
			col_sum = 0

			next if @grid[i].nil?

			col_sum += @grid[i]

			col_index = i
			2.times do |j|
				col_index += 3

				break if @grid[col_index].nil?

				col_sum += @grid[col_index]
			end

			if col_sum == 3 || col_sum == -3
				@winner = col_sum / 3
				return true
			end
		end

		@winner = 0
		return false
	end

	def winning_diagonal?
		diagonals = [[0, 4, 8], [2, 4, 6]]
		diagonals.each do |diag|
			diag_sum = 0

			diag.each do |index|
				if @grid[index].nil?
					break
				end

				diag_sum += @grid[index]
			end

			if diag_sum == 3 || diag_sum == -3
				@winner = diag_sum / 3
				return true
			end

		end

		@winner = 0

		return false
	end

end

class AI

	def move (player, board)
		# move = find_best_move(player, board)
		move = negamaxx(1, board)
		board.makeMove(player, move)
	end

	def negamaxx (player, board, alpha=-10000, beta=10000)
		best_move = 0
		best_alpha = -10000
		opponent = player * -1

		if board.game_complete?
			return score(player, board)
		end

		board.legalMoves.each do |move|
			child_board = Board.new
			child_board.grid = Array.new(board.grid)
			child_board.makeMove(player, move)

			score = -negamax(opponent, child_board, -beta, -alpha)

			if score > alpha
				alpha = score
			end

			if alpha >= beta
				break
			end

			if alpha > best_alpha
				best_alpha = alpha
				best_move = move
			end

		end

		return best_move

	end


	def find_best_move (player, board)
		best_move = 0
		best_alpha = -10000
		opponent = 1

		board.legalMoves.each do |move|
			child_board = Board.new
			child_board.grid = Array.new(board.grid)
			child_board.makeMove(player, move)


			alpha = -negamax(opponent, child_board, -10000, 10000)

			if alpha > best_alpha
				best_alpha = alpha
				best_move = move
			end
		end

		return best_move
	end


	def negamax (player, board, alpha, beta)
		opponent = -player

		if board.game_complete?
			return score(player, board)
		end

		board.legalMoves.each do |move|
			child_board = Board.new
			child_board.grid = Array.new(board.grid)
			child_board.makeMove(player, move)

			score = -negamax(opponent, child_board, -beta, -alpha)

			if score > alpha
				alpha = score
			end

			if alpha >= beta
				break
			end

		end

		return alpha

	end


	def score (player, board)
		return 1 if board.winner == player
		return -1 if board.winner == -player
		return 0
	end

end





def playgame
	board = Board.new
	ai = AI.new

	turn = 1

	while true
		if (turn == 1)
			ai.move(turn, board)
		else
			loc = gets.chomp

			if loc == "r"
				board.reset_grid
				turn = -turn
				next
			else
				loc = loc.to_i
			end

			board.makeMove(turn, loc)
		end

		board.print_grid

		if board.game_complete?
			board.reset_grid
			puts 
			puts "#{turn > 0 ? "X" : "O"} WINS"
			puts
			turn = 1
			next
		end

		turn = -turn
	end
end



playgame
