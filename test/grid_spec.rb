require 'grid'

describe Grid do
  let(:puzzle) { '015003002000100906270068430490002017501040380003905000900081040860070025037204600' }
  let(:grid) { Grid.new(puzzle) }


  context 'initialize' do

    it 'should have 81 cells' do
      expect(grid.cells.size).to eq 81
    end

    it 'should have an unsolved first cell' do
      expect(grid.cells.first).not_to be_solved
    end

    it 'should have a solved second cell with value 1' do
      expect(grid.cells[1].value).to eq 1 
    end
    it 'should have a solved fifteenth cell with value 9' do
      expect(grid.cells[15].value).to eq 9 
    end

    it 'knows when it is solved' do
      solved_grid = Grid.new('123')
      expect(solved_grid).to be_solved
    end
  end

  context 'Rows, cols and boxes' do
   
    it 'knows each row has 9 cells' do
      expect(grid.rows.first.size).to eq 9
    end

    it 'knows there are 9 rows' do
      expect(grid.rows.size).to eq 9
    end

    it 'knows first row' do
      expect(grid.rows[1][6].value).to eq 9
    end

    it 'knows each column has 9 cells' do
      expect(grid.cols.first.size).to eq 9
    end
    it 'knows there are 9 columns' do
      expect(grid.cols.size).to eq 9
    end
    it 'knows first column' do
      expect(grid.cols.first[3].value).to eq 4
    end

    it 'knows each box has 9 cells' do
      expect(grid.boxes.first.size).to eq 9
    end
    it 'knows there are 9 boxes' do
      expect(grid.boxes.size).to eq 9
    end
    it 'knows the right box' do
      expect(grid.boxes.first[7].value).to eq 7
      # expect(grid.boxes[1][0].value).to eq 
    end
  end

  context 'Solver' do
    it 'should correctly assign neighbours to a cell' do
      grid.generate_neigbours(grid.cells.first)
      expect(grid.cells.first.neighbours).to eq [1,5,0,3,2,4,9,8,7].sort
      # grid.generate_neigbours(grid.cells[27])
      # expect(grid.cells[27].neighbours).to eq [9,2,1,7,0,5,8,3].sort
    end

    it 'candidates should be generated correctly' do
      grid.generate_neigbours(grid.cells.first)
      expect(grid.cells.first.candidates).to eq [6]
    end

    it 'cell should be able to solve itself when there is 1 candidate' do
      grid.generate_neigbours(grid.cells.first)
      grid.cells.first.solve
      expect(grid.cells.first.value).to eq 6
      expect(grid.cells.first).to be_solved
    end
    it 'cell should not be able to solve itself when there is >1 candidate' do
      grid.generate_neigbours(grid.cells.last)
      grid.cells.last.solve
      expect(grid.cells.last.value).to eq 0
      expect(grid.cells.last).not_to be_solved
    end
    it 'can solve board when one iteration required' do
      another_grid = Grid.new('015493872308127956270568431496032517521706389783910264952681043864379105137254690')
      another_grid.try_to_solve
      expect(another_grid.to_s).to eq '615493872348127956279568431496832517521746389783915264952681743864379125137254698'
    end

    it 'can solve easy board' do
      grid.solve
      expect(grid).to be_solved
      expect(grid.to_s).to eq '615493872348127956279568431496832517521746389783915264952681743864379125137254698'
    end

  end
  context 'Hard Sudoku' do
    it 'can solve a hard board' do
      hard_grid = Grid.new("800000000003600000070090200050007000000045700000100030001000068008500010090000400")
      hard_grid.solve
      expect(hard_grid).to be_solved
    end
  end

end