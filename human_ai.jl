if !(pwd() ∈ LOAD_PATH)
    push!(LOAD_PATH, pwd())
end
using Connect4Board
using MCTSdistributed

AI_SIM_COUNT = 150_000

function human_vs_ai()
    board = newboard()
    player = 2

    print("Do you want to play first or second? (1/2): ")
    humanplayer = parse(Int, chomp(readline(stdin)))
    println()

    humanmove::Int8 = 0

    printboard(board)

    while !(board.iswin || board.isfull)

        player ⊻= 3
        if player == humanplayer
            while true
                print("Please select a move (1-7): ")
                move = parse(Int8, chomp(readline(stdin)))

                if move ∈ board.validmoves
                    break
                end
            end
        else
            move = MCTSpickmove(board, AI_SIM_COUNT)
            # println("AI Playing $ai_move\n")
        end
        playmove!(board, move)
        println("\n"*" "^(3*(move-1))*"∨")
        printboard(board)
    end
    println(["You Lose.", "You Win!"][Int(player == humanplayer) + 1])
end
