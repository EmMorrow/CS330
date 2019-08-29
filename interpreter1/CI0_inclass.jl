module CI0_inclass

push!(LOAD_PATH,pwd())

using Lexer
using Error

export interp


abstract type AE


struct NumNode <: AE
	n::Real
end

struct MinusNode <: AE
	lhs::AE
	rhs::AE
end

struct PlusNode <: AE
	lhs::AE
	rhs::AE
end

function parse( expr::Number )
	return NumNode( expr )
end

function parse( expre::Array{Any})
	if expr[1] == :+
		return PlusNode( parse(expr[2]), parse(expr[3]) )
	elseif expr[]

function parse( expr::Any )
	throw(LispError("whoa: unkown expresion!"))
end

function calc( node::NumNode )
	return node.n
end

function calc( node::PlusNode )
	lhs = calc( node.lhs )
	rhs = calc( node.rhs )
	return lhs + rhs
end

function calc( node::MinusNode )
	lhs = calc( node.lhs )
	rhs = calc( node.rhs )
	return lhs - rhs
end

function interp(cs::AbstractString)
	lxd = Lexer.lex( cs )
	ast = parse( lxd )
	return calc( ast )
