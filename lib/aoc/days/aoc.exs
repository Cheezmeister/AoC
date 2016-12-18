defmodule Aoc do
  require Matrix
  require Integer
  require Bitwise

  defmodule Floor do
    defstruct [:fnum, :chips, :generators, :elevator?]
  end

  def main do
    dayeighteen
  end

  def dayeighteen do
    input = "^^.^..^.....^..^..^^...^^.^....^^^.^.^^....^.^^^...^^^^.^^^^.^..^^^^.^^.^.^.^.^.^^...^^..^^^..^.^^^^"
    row = input
    {sum, _} = (1..400000) |> Enum.reduce({0,row},fn(i,r) ->
      {s,row} =r
      if (rem(i,40) == 0) do
        IO.write "\r#{s} spaces | #{row} (#{i / 4000}%)" 
      end
      cur = s + (row |> String.to_charlist 
                    |> Enum.map(&(if (&1 == 46) do 1 else 0 end)) 
                    |> Enum.sum)
      {cur, nextrow(row)}
    end)
    output "Sum is #{sum}"
  end

  def nextrow(row) do
    mid = for i <- 1..(String.length(row)-2) do
      l = row |> String.at(i-1)
      c = row |> String.at(i)
      r = row |> String.at(i+1)
      trap_or_no_trap(l,c,r)
    end |> Enum.join("")
    left = trap_or_no_trap(".",String.at(row,0),String.at(row,1))
    right = trap_or_no_trap(String.at(row,-2),String.at(row,-1),".")
    left <> mid <> right
  end

  def is_trap(l,_,r) do
    case (l <> r) do
      "^." -> "^"
      ".^" -> "^"
      _ -> "."
    end
  end

  def dayseventeen do
    path = ""
    output bfs(
      "kglvqrro",
      [{0,0,path}],
      fn({x,y,_}) -> {x,y}=={3,3} end,
      fn(input, {x,y,path}) ->
        dirs = md5(input <> path) |> String.slice(0,4) |> String.to_charlist
        Enum.zip(1..4, dirs) |> Enum.map(fn({d,c}) ->
          # debug "c is #{inspect c}"
          case {d,c} do
            {1,c} when c in 'bcdef' -> {x  , y-1, path <> "U"}
            {2,c} when c in 'bcdef' -> {x  , y+1, path <> "D"}
            {3,c} when c in 'bcdef' -> {x-1, y  , path <> "L"}
            {4,c} when c in 'bcdef' -> {x+1, y  , path <> "R"}
            _ -> nil
          end
        end) |> Enum.filter(&nonnil/1)
      end
    )
  end

  def dayseventeenpart2 do
    path = ""
    output antibfs(
      "awrkjxxr",
      [{0,0,path}],
      fn({x,y,_}) -> {x,y}=={3,3} end,
      fn(input, {x,y,path}) ->
        dirs = md5(input <> path) |> String.slice(0,4) |> String.to_charlist
        Enum.zip(1..4, dirs) |> Enum.map(fn({d,c}) ->
          # debug "c is #{inspect c}"
          case {d,c} do
            {1,c} when c in 'bcdef' and (y>0) -> {x  , y-1, path <> "U"}
            {2,c} when c in 'bcdef' and (y<3) -> {x  , y+1, path <> "D"}
            {3,c} when c in 'bcdef' and (x>0) -> {x-1, y  , path <> "L"}
            {4,c} when c in 'bcdef' and (x<3) -> {x+1, y  , path <> "R"}
            _ -> nil
          end
        end) |> Enum.filter(&nonnil/1)
      end,
      ""
    ) |> String.length
  end

  def antibfs(_, [], _, _, longestpath) do
    longestpath
  end

  def antibfs(input, states, state_is_valid, explore_from, longestpath) do
    [state | rest] = states
    if (state_is_valid.(state)) do
      {_,_,path} = state
      antibfs(input, rest, state_is_valid, explore_from,
       if String.length(path) > String.length(longestpath) do
         path
       else
         longestpath
       end)
    else
      newstates = explore_from.(input, state)
      antibfs(input, Enum.concat(rest, newstates), state_is_valid, explore_from, longestpath)
    end
  end

  def bfs(_, [], _, _) do
    "Unsolvable"
  end

  def bfs(input, states, state_is_valid, explore_from) do
    [state | rest] = states
    {_,_,path} = state
    if (state_is_valid.(state)) do
      path
    else
      newstates = explore_from.(input, state)
      bfs(input, Enum.concat(rest, newstates), state_is_valid, explore_from)
    end
  end

  def daysixteen do
    str = "10010000000110000"
    str = str <> "0" <> (str |> String.reverse |> String.replace("1", "a") |> String.replace("0", "1")|> String.replace("a", "0"))
    str = str <> "0" <> (str |> String.reverse |> String.replace("1", "a") |> String.replace("0", "1")|> String.replace("a", "0"))
    str = str <> "0" <> (str |> String.reverse |> String.replace("1", "a") |> String.replace("0", "1")|> String.replace("a", "0"))
    str = str <> "0" <> (str |> String.reverse |> String.replace("1", "a") |> String.replace("0", "1")|> String.replace("a", "0"))
    s = str |> String.slice(0..35651583)
    checksum = checksum(s)
    output "Check is #{checksum}"
  end

  def checksum(str) do
    if Integer.is_odd(String.length(str)) do
      str
    else
      checksum(sum(str))
    end
  end
  def sum("") do
    ""
  end
  def sum(<< h ::binary-size(2), rest ::binary >>) do
    s = case h do
      "10" -> "0"
      "01" -> "0"
      "00" -> "1"
      "11" -> "1"
    end
    s <> sum(rest)
  end

  def dayeleven do
    states = [
      %{
        0 => %Floor{fnum: 0, elevator?: true, chips: "CRT", generators: "ATPRC"},
        1 => %Floor{fnum: 1, elevator?: false, chips: "AP"},
        2 => %Floor{fnum: 2, elevator?: false, chips: "", generators: ""},
        3 => %Floor{fnum: 3, elevator?: false, chips: "", generators: ""},
      }
    ]
    output solve(states, 0, [])
  end

  def solve(states, moves, seen) do
    # debug("." |> String.duplicate(Enum.count states))
    [state | rest] = states
    # debug "State, #{inspect state}"
    if ((state[3]).chips |> String.to_charlist |> Enum.sort) == 'ACPRT' do
      moves
    else
      newstates = moves(state) |> Enum.filter(&is_valid/1)
      solve(Enum.concat(rest, newstates), moves+1, seen)
    end
  end

  def moves(state) do
    {_,f} = state |> Enum.filter(fn({_,f}) -> f.elevator? end) |> Enum.at(0)
    from = f.fnum
    nums = case from do
      0 -> [1]
      1 -> [0,2]
      2 -> [1,3]
      3 -> [2]
    end
    retval = nums |> Enum.map(fn(n) -> moves(state, from, n) end) |> Enum.concat
    # debug "Moves: #{inspect retval}"
    retval
  end
  def moves(state, from, to) do
    floor = state[from]
    s = floor.chips |> String.to_charlist |> Enum.map(fn(c) ->
      tempstate = put_in(state[from].chips, state[from].chips |> String.replace(c |> to_string, ""))
      tempstate = put_in(state[to].chips, "#{state[to].chips}#{c}")
      tempstate
    end)
    g = floor.generators |> String.to_charlist |> Enum.map(fn(c) ->
      tempstate = put_in(state[from].generators, state[from].generators |> String.replace(c |> to_string, ""))
      tempstate = put_in(state[to].generators, "#{state[to].generators}#{c}")
      tempstate
    end)
    Enum.concat [g, s]
  end

  def is_valid(state) do
    0..3 |> Enum.map(fn(n) -> floorvalid(n, state) end) |> Enum.all?
  end

  def floorvalid(floor, state) do
    f = state[floor]
    result = cond do
      f.generators == "" -> true
      f.chips |> String.to_charlist |> Enum.map(fn(c) ->
        f.generators |> String.contains?(c)
      end) |> Enum.all?(fn(x) -> x end)
      true -> false
    end
    debug("#{inspect f} is #{result}")
    result
  end

  # def dayten do
  #   input = File.read!("input.10")
  #   bots = %{}
  #   input |> String.split |> Enum.map(fn(line) ->
  #       case line |> Regex.run ~r/(bot (\d+) gives low to bot (\d+) and high to bot (\d+)|value (\d+) goes to bot (\d+))/ do
  #         [_, _, src, low, hi] ->
  #         [_, _, val, dest] ->
  #       end
  #   end)
  # end

  def day9 do
    input = File.read!("input.9")
    output(decompress(String.trim(input), 0))
  end

  def decompress("", _) do
    ""
  end

  def decompress(<<c::binary-size(1)>>, _) do
    c
  end

  def decompress(<< c ::binary-size(1), rest ::binary >>, rec) do
    debug "#{" " |> String.duplicate(rec)}OKay c is #{c} and rest is #{rest}"
    case c do
      "(" -> handle_repeat(rest, rec)
      _ -> 
        wat = decompress(rest, rec+1)
        case wat do
          "" -> c
          _ -> debug "Catting #{c}/#{wat}"; << c, wat>>
        end
    end
  end

  def handle_repeat(input, rec) do
    re = ~r/(\d+)x(\d+)\)(.*)/
    [_, len, repeats, rest] = Regex.run re, input
    {section, remainder} = rest |> String.split_at(String.to_integer(len))
    debug "#{" " |> String.duplicate(rec)}Rem #{remainder}"
    case remainder do
      "" -> debug "#{" " |> String.duplicate(rec)}Uh. "; (section |> String.duplicate(String.to_integer repeats))
      _ -> debug "#{" " |> String.duplicate(rec)}wai"; (section |> String.duplicate(String.to_integer repeats))<> decompress(remainder, rec+1)
    end
  end

  # def day8 do
  # input = File.read!("input")
  #   rect = ~r/rect \d+x\d+/
  #   rotate = ~r/rotate (row|column) (x|y)=\d+ by \d+/
  #   input |> String.split("\n") |> Enum.map(fn(line) ->
  #     case Regex.run rect, line do
  #       [_, x, y] -> 
  #     end
  #   end)
  # end

  # def rotate(mat, rowcol, index, amount) do
  #   case rowcol do
  #     :row -> 
  #     :col ->
  #   end
  # end

  def day7 do
    input = File.read!("input")
    input |> String.trim |> String.split("\n") |> Enum.map(fn(line) ->
      re = ~r/(\w+)(\[\w+\])?/
      matches = re |> Regex.scan(line)
      results = matches |> Enum.map(fn(matchset) ->
        debug "Matchset: #{matchset}"
        case matchset do
          [_, nbzone, bracketed] -> {has_abba(nbzone), !has_abba(bracketed)}
          [_, nbzone] -> {has_abba(nbzone), true}
        end
      end) 

      {nb, br} = Enum.unzip results
      debug "#{inspect nb}"
      debug "#{inspect br}"
    
      success = nb |> Enum.reduce(false, fn(val, accum) -> val || accum end)
      success = success && br |> Enum.reduce(true, fn(val, accum) -> val && accum end)
      output("#{inspect success}: #{line}")
    end)
  end

  def has_abba(str) do
    found = has_abba_r(str)
    debug "#{str} has abba? #{found}"
    found
  end

  def has_abba_r(str) do
    if (String.length(str) < 4) do
      false
    else
      << abbaleft::binary-size(2), abbaright::binary-size(2), _ :: binary >> = str
      lhs = (abbaright |> String.reverse) == abbaleft
      rhs = (abbaright |> String.to_charlist |> Enum.at(0)) != (abbaright |> String.to_charlist |> Enum.at(1))
      if lhs && rhs do
        true
      else
        << _::binary-size(1), t::binary >> = str
        has_abba_r t
      end
    end
  end

  def day6 do
    input = File.read!("input")
    mat = matrix_from_input(input) |> Matrix.transpose

    ans = Enum.map mat, fn(str) ->
      str |> Enum.sort |> least_common_char
    end

    IO.puts ans
  end

  def least_common_char clist do
    {_, letters} = clist |> Enum.group_by(fn x -> x end) |> Enum.unzip
    letters |> Enum.min_by(&Enum.count/1) |> Enum.at(0)
  end
   
  def most_common_char clist do
    {_,_,char,_} = clist |> Enum.reduce({:a, 0, :a, 0}, fn(c, accum) ->
      {cur, curcount, max, maxcount} = accum
      {c,
       (if cur == c, do: curcount+1, else: 0),
       (if curcount > maxcount, do: cur, else: max),
       (if curcount > maxcount, do: curcount, else: maxcount),
      }
    end)
    char
  end
   
  def matrix_from_input(text) do
    lines = text |> String.trim |> String.split("\n")
    rows = Enum.count lines
    cols = lines |> Enum.at(0) |> String.to_charlist |> Enum.count
    Enum.reduce (0..rows-1), Matrix.new(rows, cols), fn(row, accum) ->
      Enum.reduce (0..cols-1), accum, fn(col, acc) ->
        <<val>> = lines |> Enum.at(row) |> String.codepoints |> Enum.at(col)
        Matrix.set acc, row, col, val
      end
    end
  end


  def debug str do
    IO.puts str
  end

  def output str do
    IO.puts str
  end

  def nonnil item do
    item != nil
  end

  def md5(string) do
    String.downcase(Base.encode16(:crypto.hash(:md5, string)))
  end

end

Aoc.main
