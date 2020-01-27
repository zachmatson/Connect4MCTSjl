module MCTSdistributed

using Distributed

if length(procs()) < Threads.nthreads()
    addprocs(Threads.nthreads()-length(procs()))
end

@everywhere if pwd() ∉ LOAD_PATH
    push!(LOAD_PATH, pwd())
end

using Connect4Board

using Random
GLOBAL_RNG = MersenneTwister()

export TreeNode
export nodeexpand!, update_childrenUCT!, backpropogate!
export MCTSpickmove, simulate!, rollout!


mutable struct TreeNode
    state::Board
    parent::Union{TreeNode,Nothing}
    childID::Int8
    n::Int32
    expanded::Bool
    children::Array{TreeNode,1}
    childrenUCT::Array{Float32,1}
    children_n::Array{Int32,1}
    children_w::Array{Float32,1}
end


@inline function rootnode(board::Board)::TreeNode
    return TreeNode(board, nothing, 0, 0, false, [], [], [], [])
end


@inline function nodeexpand!(node::TreeNode)
    nummoves = length(node.state.validmoves)::Int64
    node.children = Array{TreeNode,1}(undef, nummoves)
    node.childrenUCT = zeros(Float32, nummoves)
    node.children_n = zeros(Int32, nummoves)
    node.children_w = zeros(Float32, nummoves)
    for (i, move::Int8) in enumerate(node.state.validmoves)
        tempboard::Board = Board(node.state)
        playmove!(tempboard, move)
        node.children[i] = TreeNode(tempboard, node, i, 0, false, [], [], [], [])
    end
    node.expanded = true
end


@inline function update_childrenUCT!(node::TreeNode)
    node.childrenUCT = @fastmath node.children_w ./ node.children_n .+ .√(2log(node.n) ./ node.children_n)
end


@inline function backpropogate!(node::TreeNode, outcome::Float32)
    while node.parent != nothing
        node.n += 1
        node.parent.children_n[node.childID] += 1
        node.parent.children_w[node.childID] += outcome
        node.parent.n += 1
        node = node.parent
        outcome = 1 - outcome
    end
end


function MCTSpickmove(board::Board, runcount::Int64 = 20_000)
    runs_per_thread::Int64 = Int64(ceil(runcount/Threads.nthreads()))
    n_array::Array{Int32,1} = @distributed (+) for i = 1:Threads.nthreads()
        let root::TreeNode = rootnode(board)
            nodeexpand!(root)
            for child in root.children
                rollout!(child)
            end
            while root.n < runs_per_thread
                update_childrenUCT!(root)
                simulate!(root.children[argmax(root.childrenUCT)])
            end
            root.children_n
        end
    end
    return board.validmoves[argmax(n_array)]
end


function simulate!(node::TreeNode)
    if node.state.iswin
        backpropogate!(node, Float32(1.0))
        return
    elseif node.state.isfull
        backpropogate!(node, Float32(0.5))
        return
    end
    if !(node.expanded)
        nodeexpand!(node)
        for child in node.children
            rollout!(child)
        end
    else
        update_childrenUCT!(node)
        simulate!(node.children[argmax(node.childrenUCT)])
    end
end


function rollout!(node::TreeNode)
    tempboard::Board = Board(node.state)
    while true
        if tempboard.iswin
            backpropogate!(node, Float32(node.state.lastplayer == tempboard.lastplayer))
            break
        elseif tempboard.isfull
            backpropogate!(node, Float32(0.5))
            break
        end
        nextmove::Int8 = tempboard.validmoves[rand(1:length(tempboard.validmoves))]
        playmove!(tempboard, nextmove)
    end
end

end
