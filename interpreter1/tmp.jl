#
# Class Interpreter 0
# Base interpreter with numbers, plus, and minus
#

module RudInt

push!(LOAD_PATH, pwd())

using Revise
using Error
using Lexer
export parse, calc, interp

#
# ==================================================
#

abstract type AE end


struct NumNode <: AE
    n::Real
end

struct BinopNode <: AE
    op::Function
    lhs::AE
    rhs::AE
end

struct UnopNode <: AE
    op::Function
    oper::AE
end



#
# ==================================================
#
function collatz( n::Real )
  return collatz_helper( n, 0 )
end

function collatz_helper( n::Real, num_iters::Int )
  if n == 1
    return num_iters
  end
  if mod(n,2)==0
    return collatz_helper( n/2, num_iters+1 )
  else
    return collatz_helper( 3*n+1, num_iters+1 )
  end
end
#
# ==================================================
#

bin_operators = Dict([(:+ => +), (:- => -), (:* => *), (:/ => /), (:mod => mod)])
un_operators = Dict([(:collatz => collatz), (:- => -)])

function parse( expr::Number )
    return NumNode( expr )
end

function parse( expr::Array{Any} )
    if length(expr) == 3
        if haskey(bin_operators,expr[1])
			if expr[1] == :/ && expr[3] == 0
				throw(LispError("Can't devide by 0"))
			else
            	return BinopNode(bin_operators[expr[1]],parse(expr[2]),parse(expr[3]))
			end
        else
            throw(LispError("Unknown operator"))
        end

    elseif length(expr) == 2
        if haskey(un_operators,expr[1])
            return UnopNode(un_operators[expr[1]],parse(expr[2]))
        else
            throw(LispError("Unknown operator!"))
        end
    else
        throw(LispError("Wrong number of arguments"))
    end
end

function parse( expr::Any )
  throw( LispError("Invalid type") )
end

#
# ==================================================
#
function calc(e::BinopNode)
    left = calc(e.lhs)
    right = calc(e.rhs)
    return e.op(left,right)
end

function calc(e::UnopNode)
    unary = calc(e.oper)
	if (e.op == collatz && unary <= 0) # Check to make sure collatz is a valid input.
		throw(LispError("Cannot perform collatz"))
	else
		return e.op(calc(e.oper))
	end
end

function calc( ast::NumNode )
    return ast.n
end


function calc(e::Any)
    throw(LispError("Whoa there! Unknown operation!"))
end

#
# ==================================================
#

function interp( cs::AbstractString )
    lxd = Lexer.lex( cs )
    ast = parse( lxd )
    return calc( ast )
end

end #module


push!(LOAD_PATH, pwd())

using Lexer
using Error

function lexParse(str)
  RudInt.parse(Lexer.lex(str))
end

function parseInter(str)
  RudInt.calc(lexParse(str))
end

function removeNL(str)
  replace(string(str), "
" => "")
end

function testerr(f, param)
  try
    return removeNL(f(param))
  catch Y
    return "Error"
  end
end

println(testerr(lexParse, "(+ 1 2)"))
println(testerr(lexParse, "(- 1 2)"))
println(testerr(lexParse, "+ 1 2"))
println(testerr(lexParse, "(a)"))

println(testerr(parseInter, "(- 1 2)"))
println(testerr(parseInter, "(* 1 2)"))
println(testerr(parseInter, "(collatz -1)"))
println(testerr(parseInter, "(/ 1 0)"))
