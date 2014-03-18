require 'sinatra'
require_relative './lib/grid'
require_relative './lib/cell'



def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Grid.new(seed.join)
  sudoku.solve
  sudoku.to_s.chars
end

get '/' do
  @current_solution = random_sudoku
  erb :index
end