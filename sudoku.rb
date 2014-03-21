require 'sinatra'
require 'sinatra/partial'
require 'rack-flash'
set :partial_template_engine, :erb
use Rack::Flash
set :session_secret, "I'm the secre key to sign the cookie"

require_relative './lib/grid'
require_relative './lib/cell'

enable :sessions

helpers do
  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
    must_be_guessed = puzzle_value.to_i == 0
    tried_to_guess = current_solution_value.to_i != 0
    guessed_incorrectly = current_solution_value != solution_value
    if solution_to_check && tried_to_guess && guessed_incorrectly && must_be_guessed
      'incorrect'
    elsif !must_be_guessed
      'value-provided'
    end
  end

  def cell_value(value)
    value.to_i == 0 ? '' : value
  end

  def read_only(puzzle_value)
    'readonly' if puzzle_value.to_i != 0
  end

end
      
def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Grid.new(seed.join)
  sudoku.solve
  sudoku.to_s.chars
end

def puzzle(sudoku, difficulty)
  mult = 1 if difficulty == :easy
  mult = 2 if difficulty == :medium
  mult = 3 if difficulty == :hard
  threes = sudoku.each_slice(3).to_a
  mult.times { threes.each { |three| three[rand(3)] = 0} }
  threes.flatten
end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) do |memo, i| 
    first_box_index = i / 3 * 3
    three_boxes = boxes[first_box_index, 3]
    three_rows_of_three = three_boxes.map do |box|
      row_number_in_a_box = i % 3
      first_cell_in_the_row_index = row_number_in_a_box * 3
      box[first_cell_in_the_row_index, 3]
    end
    memo += three_rows_of_three.flatten
  end
end

def generate_new_puzzle_if_necessary(difficulty)
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku,difficulty)
  session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  if @check_solution
      flash[:notice] = "Incorrect values are highlighted in yellow"
  end
  session[:check_solution] = nil
end

def game_saved_warning
  flash[:notice] = "Game saved!" if params[:check] == 'false'
end


get '/' do
  session[:difficulty] ||= :easy
  game_saved_warning
  prepare_to_check_solution
  generate_new_puzzle_if_necessary(session[:difficulty])
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  # redirect to('/win') if @current_solution == @solution
  erb :index
end

post '/' do
  cells = box_order_to_row_order(params["cell"])
  session[:current_solution] = cells.map {|value| value.to_i }.join
  session[:check_solution] = params[:check] == 'true'
  session[:current_solution] = session[:puzzle] if params[:restart] == 'true'
  redirect to('/')
end


post '/newgame' do
  session[:current_solution] = nil
  session[:difficulty] = params[:difficulty].to_sym
  redirect to('/')
end

get '/last-visit' do
  "Previous visit to homepage: #{session[:last_visit]}"
end

get '/solution' do
  redirect to('/') if !session[:solution]
  @current_solution = session[:solution]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

get '/rules' do
  erb :rules
end

get '/win' do
  'Congrats! You won!'
end



