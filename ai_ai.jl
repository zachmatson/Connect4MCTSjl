if !("D:/Users/Zachary/Julia Projects/Connect4Solver" in LOAD_PATH)
    push!(LOAD_PATH, "D:/Users/Zachary/Julia Projects/Connect4Solver")
end
using Connect4Board
import MCTSdistributed
import MCTS

let wins::Array{Int,1} = [0,0]
    for i = 1:100
        board = newboard()
        player = 2
        while !(board.iswin||board.isfull)
            player ⊻= 3
            playmove!(board, [MCTS.MCTSpickmove(board, 5_000), MCTSdistributed.MCTSpickmove(board,20_000)][player])
            # printboard(board)
            # println()
        end
        wins[player] += 1
    end
    println(wins)
end
