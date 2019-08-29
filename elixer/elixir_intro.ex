defmodule Elixir_Intro do
  def fib(n) when n == 1 do
    1
  end

  def fib(n) when n == 2 do
    1
  end

  def fib(n) do
    fib(n-1) + fib(n-2)
  end

  def area(shape, shape_info) do
    case shape do
      :rectangle ->
        {length,height} = shape_info
        length * height
      :square ->
        sidelen = shape_info
        sidelen * sidelen
      :circle ->
        radius = shape_info
        radius * radius * :math.pi
      :triangle ->
        {base, height} = shape_info
        base * height * 0.5
    end
  end


# Elixir_Intro.calcTotals([{"dog",2,10},{"cat",5,2}])
  def sqrList(nums) do
    Enum.map(nums, fn(x) -> x * x end)
  end

  def calcTotals(inventory) do
    Enum.map(inventory, fn(x) ->
      {item, quant, price} = x
      obj = {item, quant*price}
      obj
     end)
  end

  def map(function, vals) do
    if length(vals) > 0 do
      [function.(hd(vals))] ++ map(function, tl(vals))
    else
      []
    end
  end

  def qsort([]) do [] end
  def qsort(list) do
		pivotpos = :rand.uniform(1)-1
		pivot = Enum.at(list,pivotpos)
		rest = List.delete_at(list, pivotpos)

			smaller = for n <- rest, n < pivot do n end
			larger = for n <- rest, n >= pivot do n end
	    qsort(smaller) ++ [pivot] ++ qsort(larger)
  end

  def quickSortServer() do
    receive do
      {message, pid} ->
        send(pid, {qsort(message), self()})
    end
    quickSortServer()
  end

	# def callServer(pid,nums) do
	# 		send(pid, {nums, self()})
	# 		listen()
	# end
	#
	# def listen do
	# 		receive do
	# 			{sorted, pid} ->
	# 				sorted
	# 		end
	# end


end

#
# Elixir_Intro.fib(3)
# Elixir_Intro.calcTotals([{"dog",2,10},{"cat",5,2}])
# # pid = spawn &Elixir_Intro.quickSortServer/0
# Elixir_Intro.callServer(pid,[3,5,1,2])
