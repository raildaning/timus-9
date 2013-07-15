class Land
  PASSABLE = '.'
  IMPASSABLE = '#'
  KATH = '$'
  JELU = '!'
  SANDRO = '*'
  PORT = /[A-Z]/
  IMPOSSIBLE = 'Impossible'

  def initialize(rows, cols, configuration)
    @rows = rows
    @cols = cols
    @configuration = configuration
    @ports = {}
    init_positions
  end

  def result
    raise 'bad configuration' unless @kath && @jelu && @sandro
    kath_ways = search_paths_to_sandro_surroundings @kath
    return IMPOSSIBLE if kath_ways.empty?
    jelu_ways = search_paths_to_sandro_surroundings @jelu
    return IMPOSSIBLE if jelu_ways.empty?
    common_ways = kath_ways.keys & jelu_ways.keys
    return IMPOSSIBLE if common_ways.empty?
    common_ways.map{|w| [kath_ways[w], jelu_ways[w]].max }.min + 1
  end

  private

  def init_positions
    @rows.times do |row|
      @cols.times do |col|
        r = region(row, col)
        case r
        when KATH
          @kath = [row, col]
        when JELU
          @jelu = [row, col]
        when SANDRO
          @sandro = [row, col]
        when PORT
          (@ports[r] ||= []) << [row, col]
        end
      end
    end
  end

  def region(row, col)
    if row >= 0 && row < @rows && col >= 0 && col < @cols
      @configuration[row][col]
    else
      IMPASSABLE
    end
  end

  def passable?(row, col)
    region(row, col) != IMPASSABLE
  end

  SURROUNDINGS = [[-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0], [1,1]]

  def search_paths_to_sandro_surroundings(from)
    map = Array.new(@rows){ Array.new @cols }
    map[from[0]][from[1]] = 0
    visited = [from]
    while passable_sandro_surroundings.any?{|s| map[s[0]][s[1]].nil? } && !visited.empty?
      current = visited.shift
      SURROUNDINGS.each do |d_row, d_col|
        row = current[0] + d_row
        col = current[1] + d_col
        if map[row] && map[row][col].nil? && passable?(row, col) && !(row == @sandro[0] && col == @sandro[1])
          d = map[current[0]][current[1]] + 1
          map[row][col] = d
          visited << [row, col]
          r = region(row, col)
          if r =~ PORT
            @ports[r].each do |pt|
              unless pt == current
                map[pt[0]][pt[1]] = d
                visited << pt
              end
            end
          end
        end
      end
    end
    res = {}
    passable_sandro_surroundings.each do |reg|
      d = map[reg[0]][reg[1]]
      res[reg] = d if d
    end
    res
  end

  def passable_sandro_surroundings
    @passable_sandro_surroundings ||= begin
      s = []
      SURROUNDINGS.each do |d_row, d_col|
        row = @sandro[0] + d_row
        col = @sandro[1] + d_col
        s << [row,col] if passable?(row, col)
      end
      s
    end
  end

end

n,m = gets.split.map(&:to_i)
configuration = Array.new(n)
n.times{|i| configuration[i] = gets }

puts Land.new(n,m,configuration).result