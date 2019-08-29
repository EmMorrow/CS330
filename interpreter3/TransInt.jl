module TransInt

push!(LOAD_PATH, pwd())
using Revise
using Error
using Lexer

export parse, calc, analyze, NumVal, ClosureVal

#
# ==================================================
#

abstract type AE
end

struct NumNode <: AE
    n::Real
end

struct BinopNode <: AE
	op::Function
	lhs::AE
	rhs::AE
end

struct PlusNode <: AE
	exp::Array{AE}
end

struct UnopNode <: AE
    op::Function
    oper::AE
end

struct If0Node <: AE
    cond::AE
    zerobranch::AE
    nzerobranch::AE
end

struct SubNode <: AE
	sym::Symbol
	binding_expr::AE
end

struct WithNode <: AE
    sub_nodes::Array{SubNode}
    body::AE
end

struct AndNode <: AE
	op::Array{AE}
end

struct VarRefNode <: AE
    sym::Symbol
end

struct FuncDefNode <: AE
    formals::Array{Symbol}
    body::AE
end

struct FuncAppNode <: AE
    fun_expr::AE
    arg_exprs::Array{AE}
end

#
# ==================================================
#

abstract type RetVal
end

abstract type Environment
end

struct NumVal <: RetVal
    n::Real
end

struct ClosureVal <: RetVal
    formals::Array{Symbol}
    body::AE
    env::Environment
end

#
# ==================================================
#

struct EmptyEnv <: Environment
end

struct ExtendedEnv <: Environment
    sym::Symbol
    val::RetVal
    parent::Environment
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

bin_operators = Dict([(:+ => +), (:- => -), (:* => *), (:/ => /), (:mod => mod)])
un_operators = Dict([(:collatz => collatz), (:- => -)])

function isReservedVar( var::Any )
	return (var == :+ || var == :- || var == :* || var == :/ || var == :mod || var == :collatz || var == :with || var == :if0 || var == :lambda || var == :and)
end



#
# ==================================================
#

function parse( expr::Number )
    return NumNode( expr )
end

function parse( expr::Symbol )
	if isReservedVar(expr)
		throw(LispError("can't use key word as ID"))
	end
    return VarRefNode( expr )
end

function parse( expr::Array{Any} )
	if length(expr) == 0
		throw(LispError("invalid"))
	end

	if haskey(bin_operators,expr[1])
		if length(expr) == 3
			return BinopNode(bin_operators[expr[1]], parse(expr[2]), parse(expr[3]))
		elseif length(expr) == 2 && haskey(un_operators,expr[1])
			return UnopNode(un_operators[expr[1]], parse(expr[2]))
		elseif length(expr) >= 3 && expr[1] == :+
			exprs1 = AE[]
			for i in 2:size(expr,1)
				push!(exprs1, parse(expr[i]))
			end
			return PlusNode(exprs1)
		else
			throw(LispError("wrong num args"))
		end
	elseif haskey(un_operators,expr[1])
		if length(expr) == 2
			return UnopNode(un_operators[expr[1]], parse(expr[2]))
		else
			throw(LispError("wrong num args"))
		end
	elseif expr[1] == :and
		if length(expr) >= 3
			nums = AE[]
			for i in 2:size(expr,1)
				push!(nums, parse(expr[i]))
			end
			return AndNode(nums)
		else
			throw(LispError("nah"))
		end
	elseif expr[1] == :if0
		if length(expr) == 4
			return If0Node(parse(expr[2]),parse(expr[3]),parse(expr[4]))
		else
			throw(LispError("wrong num args"))
		end
	elseif expr[1] == :with
		if length(expr) == 3
			return WithNode(parseWith(expr[2]),parse(expr[3]))
		else
			throw(LispError("wrong num args"))
		end
    elseif expr[1] == :lambda
		if length(expr) == 3
			if !isa(expr[2], Array{Any})
				throw(LispError("invalid"))
			else
				check = Any[]
				for element in expr[2]
					if element in check || isReservedVar(element)
						throw(LispError("can't use param more than once"))
					end
					push!(check, element)
				end
			end
	    	return FuncDefNode(expr[2], parse(expr[3]))
		else
			throw(LispError("wrong num args"))
		end

    else
		elements = AE[]
		if length(expr) > 1
			for element in expr[2:end]
				push!(elements, parse(element))
			end
		end
        return FuncAppNode(parse(expr[1]) , elements)
	end

    throw(LispError("Unknown operator!"))
end

function parse( expr::Any )
  throw( LispError("Invalid type") )
end

function parseWith(expr::Array{Any})
	sub_nodes = SubNode[]

	for element in expr
		if isa(element, Array{Any}) && length(element) == 2
			if isReservedVar(element[1])
				throw(LispError("can't use key word for binding name"))
			end
			for sub in sub_nodes
				if element[1] == sub.sym
					throw(LispError("can't have duplicate bindings"))
				end
			end
			sn = SubNode( element[1], parse( element[2] ) )
			push!( sub_nodes, sn )

		else
			throw(LispError("bad"))
		end
	end

	return sub_nodes
end
#
# ==================================================
#

function analyze(ast::NumNode)
	return ast
end

function analyze(ast::PlusNode)
	if length(ast.exp) == 2
		return BinopNode(+, analyze(ast.exp[1]), analyze(ast.exp[2]))
	else
		return BinopNode(+, analyze(ast.exp[1]), analyze(PlusNode(ast.exp[2:end])))
	end
end

function analyze(ast::BinopNode)
	return BinopNode(ast.op, analyze(ast.lhs), analyze(ast.rhs))
end

function analyze(ast::UnopNode)
	return UnopNode(ast.op, analyze(ast.oper))
end

# function analyze(ast::If0Node)
# 	return If0Node(analyze(owl.cond), analyze(ast.zerobranch), analyze(ast.nzerobranch))
# end

function analyze( ast::VarRefNode )
    return ast
end

function analyze( ast::WithNode )
    syms = Symbol[]
	exprs = AE[]
	for i in 1:size(ast.sub_nodes,1)
		push!(syms, ast.sub_nodes[i].sym)
		push!(exprs, ast.sub_nodes[i].binding_expr)
	end

	node = FuncDefNode(syms, analyze(ast.body))
	return FuncAppNode(node, exprs)
end

function analyze( ast::If0Node )
    condition = analyze(ast.cond)

    if typeof(condition) == NumNode
        if condition.n == 0
            return analyze(ast.zerobranch)
        else
            return analyze(ast.nzerobranch)
        end
    end

    analyzezb = analyze(ast.zerobranch)
    analyzenz = analyze(ast.nzerobranch)
    return If0Node(condition, analyzezb, analyzenz)
end

function analyze( ast::FuncDefNode )
    return FuncDefNode( ast.formals, analyze( ast.body ) )
end

function analyze( ast::FuncAppNode )
	items = AE[]
	for x in ast.arg_exprs
		push!(items,analyze(x))
	end
    return FuncAppNode( analyze( ast.fun_expr), items)
end

function analyze(ast::AndNode)
	if length(ast.op) == 1
		return If0Node(analyze(ast.op[1]), NumNode(0), NumNode(1))
	else
		return If0Node(analyze(ast.op[1]), NumNode(0), analyze(AndNode(ast.op[2:end])))
	end
end

function analyze(ast::AE)
	throw(ListError("idk"))
end



#
# ==================================================
#

function calc( ast::NumNode, env::Environment )
    return NumVal( ast.n )
end

function calc( ast::BinopNode, env::Environment  )
	rhs = calc(ast.rhs, env)
	lhs = calc(ast.lhs, env)

	if (ast.op== /) && rhs.n == 0
		throw(LispError("not allowed to divide by 0"))
	end

	if !isa(rhs, NumVal) || !isa(lhs, NumVal)
		throw(LispError("argument has to be a num"))
	end
	return NumVal(ast.op(lhs.n,rhs.n))
end

function calc(ast::UnopNode, env::Environment )
	oper = calc(ast.oper, env)

	if !isa(oper, NumVal)
		throw(LispError("argument has to be a num"))
	end

	if ast.op== collatz && oper.n < 0
		throw(LispError("no collatz w negative"))
	end
	return NumVal(ast.op(oper.n))
end

function calc( ast::If0Node, env::Environment )
    cond = calc(ast.cond, env)

	if !isa(cond, NumVal)
		throw(LispError("argument has to be a num"))
	end

    if cond.n == 0
        return calc(ast.zerobranch, env)
    else
        return calc(ast.nzerobranch, env)
    end
end

function calc( ast::WithNode, env::Environment )
	curr = env
	for sub in ast.sub_nodes
		bind_val = calc(sub.binding_expr, env)
	    ext = ExtendedEnv( sub.sym, bind_val, curr )
		curr = ext
	end
    return calc( ast.body, curr )
end

function calc( ast::VarRefNode, env::EmptyEnv )
    throw( Error.LispError("Undefined variable " * string( ast.sym )) )
end

function calc( ast::VarRefNode, env::ExtendedEnv )
    if ast.sym == env.sym
        return env.val
    else
        return calc( ast, env.parent )
    end
end

function calc( ast::FuncDefNode, env::Environment )
    return ClosureVal( ast.formals, ast.body, env )
end

function calc( ast::FuncAppNode, env::Environment )
	clos = calc( ast.fun_expr, env )
	if length(ast.arg_exprs) != length(clos.formals)
		throw(LispError("arity mismatch"))
	end
	if !isa(clos, ClosureVal)
		throw(LispError("needs closure"))
	end

	curr = env
	i = 1
	for element in ast.arg_exprs
		param = calc(element, curr)
		ext = ExtendedEnv(clos.formals[i], param, curr)

		curr = ext
		i += 1
	end

    return calc(clos.body, curr)
end

function calc( ast::AE )
    return calc( ast, EmptyEnv() )
end

function calc(ast::Any)
	throw(LispError("bad"))
end

function calc(ast::Any, env::Environment)
	throw(LispError("Unknown type"))
end


#
# ==================================================
#

function interp( cs::AbstractString )
    lxd = Lexer.lex( cs )
    ast = parse( lxd )
    return calc( ast, EmptyEnv() )
end

# evaluate a series of tests in a file
function interpf( fn::AbstractString )
  f = open( fn )

  cur_prog = ""
  for ln in eachline(f)
      ln = chomp( ln )
      if length(ln) == 0 && length(cur_prog) > 0
          println( "" )
          println( "--------- Evaluating ----------" )
          println( cur_prog )
          println( "---------- Returned -----------" )
          try
              println( interp( cur_prog ) )
          catch errobj
              println( ">> ERROR: lxd" )
              lxd = Lexer.lex( cur_prog )
              println( lxd )
              println( ">> ERROR: ast" )
              ast = parse( lxd )
              println( ast )
              println( ">> ERROR: rethrowing error" )
              throw( errobj )
          end
          println( "------------ done -------------" )
          println( "" )
          cur_prog = ""
      else
          cur_prog *= ln
      end
  end

  close( f )
end

end #module
