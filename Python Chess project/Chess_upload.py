CHESS_FIGURES = {"pawn", "rook", "knight", "bishop", "queen", "king"}
BLACK_ALLOWED = CHESS_FIGURES
WHITE_ALLOWED = {"pawn", "rook"}  # white can be only these two


def is_valid_position(position: str) -> bool:
    square = position.strip().lower()
    return len(square) == 2 and 'a' <= square[0] <= 'h' and '1' <= square[1] <= '8'  #  a–h, 1–8

def is_valid_piece(piece: str, allowed: set[str]) -> bool:
    return piece.strip().lower() in allowed


def convert_to_xy(square: str) -> tuple[int, int]:
    square = square.strip().lower()
    return ord(square[0]) - ord('a'), int(square[1]) - 1

def validate_white_input(line: str) -> tuple[str, str]:
    parts = line.strip().lower().split()
    match parts:
        case [piece, square] if is_valid_position(square):
            if not is_valid_piece(piece, WHITE_ALLOWED):
                allowed = ", ".join(sorted(WHITE_ALLOWED))
                raise ValueError(f"White piece must be one of: {allowed}")
            return piece, square
        case [_, _]:
            raise ValueError("Square must be a-h followed by 1-8 (e.g., a1, d4, h8)")
        case _:
            raise ValueError("Use e.g., 'rook a5'")

def validate_black_input(line: str) -> tuple[str, str]:
    parts = line.strip().lower().split()
    match parts:
        case [piece, square] if is_valid_position(square):
            if not is_valid_piece(piece, BLACK_ALLOWED):
                allowed = ", ".join(sorted(BLACK_ALLOWED))
                raise ValueError(f"Black piece must be one of: {allowed}")
            return piece, square
        case [_, _]:
            raise ValueError("Square must be a-h followed by 1-8 (e.g., a1, d4, h8)")
        case _:
            raise ValueError("Use e.g., 'bishop d6'")

def collect_black_pieces(white_square: str) -> list[dict]:
    print(" Add BLACK pieces (1 to 16). Example: 'bishop d6'. Type 'done' when finished. ")
    blacks: list[dict] = []
    occupied = {white_square.strip().lower()}
    while True:
        line = input("Black piece (or 'done'): ").strip()
        if line.lower() == "done":
            if len(blacks) == 0:
                print("Error: add at least one BLACK piece before typing 'done'.")
                continue
            break

        if len(blacks) >= 16:
            print("Error: you cannot add more than 16 BLACK pieces. Type 'done' to finish.")
            continue

        try:
            piece_b, square_b = validate_black_input(line)
            sq_norm = square_b.strip().lower()

            if sq_norm in occupied:
                print("Error: that square is already occupied. Choose another square.")
                continue

            blacks.append({"piece": piece_b, "square": square_b})
            occupied.add(sq_norm)
            print(f"Added BLACK {piece_b} at {square_b}.")
        except ValueError as e:
            print(f"Error: {e}")

    return blacks


def pawn_can_capture(
        white_xy: tuple[int,int],
        target_xy: tuple[int,int]
) -> bool:
    """White pawn captures diagonally forward one: (x±1, y+1)."""
    wx, wy = white_xy
    tx, ty = target_xy
    return ty == wy + 1 and (tx == wx - 1 or tx == wx + 1)

def rook_can_capture(
    white_xy: tuple[int,int],
    target_xy: tuple[int,int],
    black_occupied: set[tuple[int,int]],
) -> bool:
    """Rook captures along board with no blockers (black pieces block)."""
    wx, wy = white_xy
    tx, ty = target_xy

    if wx == tx:
        step = 1 if ty > wy else -1
        for y in range(wy + step, ty, step):
            if (wx, y) in black_occupied:
                return False
        return True

    if wy == ty:
        step = 1 if tx > wx else -1
        for x in range(wx + step, tx, step):
            if (x, wy) in black_occupied:
                return False
        return True

    return False

CAPTURE_RULES = {
    "pawn":  pawn_can_capture,
    "rook":  rook_can_capture,
}
_missing = WHITE_ALLOWED - CAPTURE_RULES.keys()
if _missing:
    raise NotImplementedError(f"No capture rules implemented for: {sorted(_missing)}")

def main():
    #  white piece
    allowed = ", ".join(sorted(WHITE_ALLOWED))
    print(f"Set the WHITE piece (allowed: {allowed}). Example: 'rook a5' ")
    while True:
        try:
            piece_w, square_w = validate_white_input(input("White piece and position: "))
            print(f"Added WHITE {piece_w} at {square_w}.")
            break
        except ValueError as e:
            print(f"Error: {e}")

    black_pieces = collect_black_pieces(square_w)

    white_xy = convert_to_xy(square_w)

    capturable: list[dict] = []

    for black_piece in black_pieces:
        target_xy = convert_to_xy(black_piece["square"])
        if piece_w == "pawn":
            if pawn_can_capture(white_xy, target_xy):
                capturable.append(black_piece)
        elif piece_w == "rook":
            black_coords = {convert_to_xy(black_piece["square"]) for black_piece in black_pieces}
            if rook_can_capture(white_xy, target_xy, black_coords):
                capturable.append(black_piece)



    print("Result")
    print(f"The WHITE {piece_w} at {square_w} can capture:")
    if capturable:
        for black_piece in capturable:
            print(f" - BLACK {black_piece['piece']} at {black_piece['square']} (move {square_w} → {black_piece['square']})")
    else:
        print("No captures available.")

if __name__ == "__main__":
    main()