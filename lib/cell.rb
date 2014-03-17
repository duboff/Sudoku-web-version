class Cell
  attr_accessor :value, :neighbours


  def initialize(val)
    @value = val
    @candidates = []
    @neighbours = [] # array of cells
  end

  def solve
    @value = @candidates.first if candidates.size == 1
  end

  def solved?
    value != 0
  end

  def candidates
    @candidates = (1..9).to_a - neighbours
  end

end