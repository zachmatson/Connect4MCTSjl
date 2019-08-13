if !("D:/Users/Zachary/Julia Projects/Connect4Solver" in LOAD_PATH)
    push!(LOAD_PATH, "D:/Users/Zachary/Julia Projects/Connect4Solver")
end
using Connect4Board
using MCTSdistributed

board = newboard()
MCTSpickmove(board)

println("\n\n\n\n")

for i = 1:5
    @time MCTSpickmove(board,500_000)
    if MCTSpickmove(board) != 4
        error("Incorrect move choice")
    end
end
