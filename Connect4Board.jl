module Connect4Board

export Board
export newboard, copyboard, playmove!, iswin!
export printboard

mutable struct Board
    board::Int64
    lastplayerboard::Int64
    lastplayer::Int8
    remainingmoves::Array{Int8,1}
    validmoves::Array{Int8,1}
    iswin::Bool
    isfull::Bool
end

function newboard()::Board
    return Board(0, 0, 2, [6,6,6,6,6,6,6], [1,2,3,4,5,6,7], false, false)
end

@inline function copyboard(oldboard::Board)::Board
    return Board(oldboard.board,
                 oldboard.lastplayerboard,
                 oldboard.lastplayer,
                 copy(oldboard.remainingmoves),
                 copy(oldboard.validmoves),
                 oldboard.iswin,
                 oldboard.isfull)
end

@inline function playmove!(board::Board, move::Int8)
    board.board |= board.board + 1 << 7(move - 1)
    board.lastplayerboard ⊻= board.board
    board.lastplayer ⊻= 3
    board.remainingmoves[move] -= 1
    if board.remainingmoves[move] == 0
        for (i, arrmove) in enumerate(board.validmoves)
            if arrmove == move
                deleteat!(board.validmoves, i)
                break
            end
        end
    end
    iswin!(board)
    board.isfull = board.board == 279258638311359
end

@inline function iswin!(board::Board)
    check::Int64 = board.lastplayerboard & board.lastplayerboard >>> 1
    if check & check >>> 2 != 0
        board.iswin = true
        return
    end
    check = board.lastplayerboard & board.lastplayerboard >>> 6
    if check & check >>> 12 != 0
        board.iswin = true
        return
    end
    check = board.lastplayerboard & board.lastplayerboard >>> 7
    if check & check >>> 14 != 0
        board.iswin = true
        return
    end
    check = board.lastplayerboard & board.lastplayerboard >>> 8
    if check & check >>> 16 != 0
        board.iswin = true
        return
    end
end


# Testing Purposes
function printboard(board::Board)
    boards::Array{Int64,1} = Array{Int64}(undef, 2)
    boards[board.lastplayer] = board.lastplayerboard
    boards[3 ⊻ board.lastplayer] = board.board ⊻ board.lastplayerboard
    println("1  2  3  4  5  6  7\n")
    for i = 1:6
        for j = 1:7
            if 1 & boards[1] >>> (7j - i - 1) != 0
                printstyled("O  ", color=:red)
            elseif 1 & boards[2] >>> (7j - i - 1) != 0
                printstyled("O  ", color=:yellow)
            else
                printstyled(".  ", color=:normal)
            end
        end
        println()
    end
end

end
