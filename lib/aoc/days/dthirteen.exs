
require Integer
require Bitwise
use Bitwise

# def rows(range) do
# end

# def squares(y, range) do
#     range |> Enum.map fn(x) ->
#       find(x, y)
#     end
# end

# def find(x,y) do
#   x == y
# end

IO.puts 1..40 |> Enum.map(fn(y) ->
  1..40 |> Enum.map(fn(x) ->
    num = x*x + 3*x + 2*x*y + y + y*y + 1350
    weight = for(<<bit::1 <- :binary.encode_unsigned num>>, do: bit) |> Enum.sum
    cond do
      ({x,y}=={31,39}) -> "G" 
      ((weight &&& 1) == 0) -> "." 
      true -> "#" 
    end
  end) |> Enum.join
end) |> Enum.join("\n")

