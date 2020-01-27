if !(pwd() in LOAD_PATH)
    push!(LOAD_PATH, pwd())
end
using Connect4Board
using MCTSdistributed

board = Board()
MCTSpickmove(board)

println("\n\n\n\n")

for i = 1:5
    @time MCTSpickmove(board,500_000)
    if MCTSpickmove(board) != 4
        error("Incorrect move choice")
    end
end
