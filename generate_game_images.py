import os
import math
from PIL import Image, ImageDraw, ImageFont

output_dir = os.path.join(os.getcwd(), 'assets', 'images', 'games')
os.makedirs(output_dir, exist_ok=True)

font_path = "C:/Windows/Fonts/segoeuib.ttf"
if not os.path.exists(font_path):
    font_path = "C:/Windows/Fonts/arialbd.ttf"

def make_font(size):
    try:
        return ImageFont.truetype(font_path, size)
    except:
        return ImageFont.load_default()

games_data = [
    (1, "game_1_hash_cracker.png", "HASH CRACKER", "01", "PUZZLE", (213, 0, 249), (35, 12, 55), "padlock"),
    (2, "game_2_coin_catcher.png", "BITCOIN CATCHER", "02", "ACTION", (0, 255, 136), (10, 42, 28), "coin"),
    (3, "game_3_precision_drill.png", "PRECISION DRILL", "03", "REFLEX", (0, 240, 255), (10, 38, 52), "crosshair"),
    (4, "game_4_lucky_wheel.png", "LUCKY WHEEL", "04", "CASINO", (255, 179, 0), (55, 38, 10), "wheel"),
    (5, "game_5_flappy_miner.png", "FLAPPY DRONE", "05", "ACTION", (0, 240, 255), (12, 35, 50), "drone"),
    (6, "game_6_block_slicer.png", "BLOCK SLICER", "06", "ACTION", (255, 30, 86), (50, 10, 22), "sword"),
    (7, "game_7_whack_a_bug.png", "WHACK-A-BUG", "07", "REFLEX", (255, 109, 0), (52, 25, 8), "bug"),
    (8, "game_8_crypto_snake.png", "CRYPTO SNAKE", "08", "RETRO", (0, 255, 136), (12, 45, 26), "snake"),
    (9, "game_9_cyber_pong.png", "CYBER PONG", "09", "RETRO", (0, 210, 255), (12, 34, 52), "pong"),
    (10, "game_10_memory_match.png", "MEMORY MATRIX", "10", "PUZZLE", (213, 0, 249), (42, 14, 55), "cards"),
    (11, "game_11_brick_breaker.png", "BRICK BREAKER", "11", "RETRO", (255, 179, 0), (48, 32, 10), "bricks"),
    (12, "game_12_matrix_decoder.png", "MATRIX DECODER", "12", "PUZZLE", (0, 255, 102), (8, 44, 22), "terminal"),
    (13, "game_13_crypto_jump.png", "CRYPTO JUMP", "13", "ACTION", (0, 240, 255), (12, 36, 54), "rocket"),
    (14, "game_14_laser_defense.png", "LASER DEFENSE", "14", "ACTION", (255, 30, 86), (52, 12, 24), "turret"),
    (15, "game_15_pipe_connection.png", "PIPE MATRIX", "15", "PUZZLE", (0, 240, 255), (14, 38, 52), "pipes"),
    (16, "game_16_color_switch.png", "COLOR ORBIT", "16", "REFLEX", (213, 0, 249), (40, 16, 52), "orbit"),
    (17, "game_17_simon_tap.png", "SIMON HASH", "17", "PUZZLE", (255, 179, 0), (45, 30, 12), "simon"),
    (18, "game_18_balance_rig.png", "BALANCE THE RIG", "18", "PHYSICS", (255, 160, 0), (48, 28, 8), "seesaw"),
    (19, "game_19_minecart_rush.png", "MINECART RUSH", "19", "ACTION", (255, 213, 79), (48, 38, 14), "cart"),
    (20, "game_20_tic_tac_toe.png", "TIC-TAC-TOE PRO", "20", "PUZZLE", (0, 240, 255), (12, 36, 52), "tictactoe"),
    (21, "game_21_space_invaders.png", "SPACE INVADERS", "21", "RETRO", (255, 45, 85), (50, 12, 25), "alien"),
    (22, "game_22_reaction_speed.png", "REACTION SPEED", "22", "REFLEX", (0, 255, 136), (10, 44, 25), "stopwatch"),
    (23, "game_23_higher_lower.png", "HIGHER OR LOWER", "23", "CASINO", (255, 179, 0), (48, 32, 10), "chart"),
    (24, "game_24_merge_2048.png", "2048 SAT MERGE", "24", "PUZZLE", (124, 77, 255), (32, 18, 55), "merge"),
    (25, "game_25_rope_grapple.png", "ROPE GRAPPLE", "25", "PHYSICS", (0, 240, 255), (14, 38, 52), "grapple"),
    (26, "game_26_rps_bot.png", "RPS SHOWDOWN", "26", "REFLEX", (255, 109, 0), (52, 24, 10), "rps"),
    (27, "game_27_target_archery.png", "TARGET ARCHERY", "27", "REFLEX", (255, 179, 0), (48, 32, 10), "archery"),
    (28, "game_28_cyber_runner.png", "CYBER RUNNER", "28", "ACTION", (0, 229, 255), (10, 36, 52), "runner"),
    (29, "game_29_quantum_slots.png", "QUANTUM SLOTS", "29", "CASINO", (255, 179, 0), (52, 34, 12), "slots"),
    (30, "game_30_circuit_crosser.png", "CIRCUIT CROSSER", "30", "ACTION", (0, 255, 136), (10, 44, 26), "crosser"),
]

W, H = 480, 260
font_title = make_font(26)
font_num = make_font(20)
font_badge = make_font(13)
font_small = make_font(12)

def draw_icon(draw, icon_type, color, cx, cy):
    # Draw vector cyber glyphs based on icon_type
    if icon_type == "coin":
        draw.ellipse([cx-40, cy-40, cx+40, cy+40], fill=(20, 25, 40), outline=color, width=4)
        draw.text((cx-14, cy-22), "B", font=make_font(36), fill=color)
    elif icon_type == "padlock":
        draw.rounded_rectangle([cx-32, cy-15, cx+32, cy+35], radius=8, fill=(20, 25, 40), outline=color, width=4)
        draw.arc([cx-22, cy-45, cx+22, cy-5], 180, 0, fill=color, width=5)
        draw.ellipse([cx-8, cy+2, cx+8, cy+18], fill=color)
    elif icon_type == "crosshair":
        draw.ellipse([cx-42, cy-42, cx+42, cy+42], outline=color, width=3)
        draw.ellipse([cx-24, cy-24, cx+24, cy+24], outline=color, width=2)
        draw.ellipse([cx-6, cy-6, cx+6, cy+6], fill=color)
        draw.line([cx-50, cy, cx+50, cy], fill=color, width=2)
        draw.line([cx, cy-50, cx, cy+50], fill=color, width=2)
    elif icon_type == "wheel":
        draw.ellipse([cx-42, cy-42, cx+42, cy+42], outline=color, width=4)
        for ang in range(0, 360, 45):
            rad = math.radians(ang)
            draw.line([cx, cy, cx + int(42*math.cos(rad)), cy + int(42*math.sin(rad))], fill=color, width=2)
        draw.ellipse([cx-12, cy-12, cx+12, cy+12], fill=color)
    elif icon_type == "drone" or icon_type == "rocket":
        pts = [(cx, cy-42), (cx+36, cy+32), (cx, cy+16), (cx-36, cy+32)]
        draw.polygon(pts, fill=(20, 25, 40), outline=color)
        draw.ellipse([cx-8, cy-8, cx+8, cy+8], fill=color)
    elif icon_type == "sword":
        draw.line([cx-36, cy+36, cx+36, cy-36], fill=color, width=6)
        draw.line([cx-24, cy+12, cx-12, cy+24], fill=(255, 255, 255), width=4)
        draw.line([cx-44, cy+44, cx-30, cy+30], fill=(255, 200, 200), width=8)
    elif icon_type == "bug" or icon_type == "alien":
        draw.rounded_rectangle([cx-32, cy-24, cx+32, cy+28], radius=14, fill=(20, 25, 40), outline=color, width=4)
        draw.ellipse([cx-18, cy-10, cx-6, cy+2], fill=color)
        draw.ellipse([cx+6, cy-10, cx+18, cy+2], fill=color)
        draw.line([cx-24, cy-24, cx-36, cy-40], fill=color, width=3)
        draw.line([cx+24, cy-24, cx+36, cy-40], fill=color, width=3)
        draw.line([cx-32, cy, cx-46, cy], fill=color, width=3)
        draw.line([cx+32, cy, cx+46, cy], fill=color, width=3)
    elif icon_type == "snake":
        draw.arc([cx-34, cy-34, cx+10, cy+10], 0, 180, fill=color, width=5)
        draw.arc([cx-10, cy-10, cx+34, cy+34], 180, 360, fill=color, width=5)
        draw.ellipse([cx+26, cy-6, cx+42, cy+10], fill=color)
    elif icon_type == "pong":
        draw.rounded_rectangle([cx-40, cy-32, cx-28, cy+32], radius=4, fill=(0, 240, 255))
        draw.rounded_rectangle([cx+28, cy-22, cx+40, cy+42], radius=4, fill=(255, 30, 86))
        draw.ellipse([cx-6, cy-6, cx+6, cy+6], fill=(255, 255, 255))
    elif icon_type == "cards":
        draw.rounded_rectangle([cx-38, cy-32, cx+8, cy+32], radius=8, fill=(20, 25, 40), outline=color, width=3)
        draw.rounded_rectangle([cx-8, cy-22, cx+38, cy+42], radius=8, fill=(30, 15, 48), outline=(255, 255, 255), width=3)
    elif icon_type == "bricks":
        for r in range(3):
            for c in range(3):
                bx = cx - 36 + c * 25
                by = cy - 24 + r * 18
                draw.rectangle([bx, by, bx+20, by+13], fill=(20, 25, 40), outline=color, width=2)
    elif icon_type == "terminal":
        draw.rounded_rectangle([cx-42, cy-32, cx+42, cy+32], radius=8, fill=(10, 25, 15), outline=color, width=3)
        draw.text((cx-30, cy-24), "> 0x7F", font=make_font(20), fill=color)
    elif icon_type == "turret":
        draw.polygon([(cx-36, cy+30), (cx+36, cy+30), (cx+18, cy-10), (cx-18, cy-10)], fill=(20, 25, 40), outline=color)
        draw.line([cx-6, cy-10, cx-6, cy-40], fill=color, width=4)
        draw.line([cx+6, cy-10, cx+6, cy-40], fill=color, width=4)
    elif icon_type == "pipes":
        draw.line([cx-40, cy, cx, cy], fill=color, width=8)
        draw.line([cx, cy, cx, cy-40], fill=color, width=8)
        draw.ellipse([cx-12, cy-12, cx+12, cy+12], fill=(255, 255, 255))
    elif icon_type == "orbit":
        draw.ellipse([cx-42, cy-42, cx+42, cy+42], outline=(0, 240, 255), width=5)
        draw.ellipse([cx-24, cy-24, cx+24, cy+24], outline=(255, 179, 0), width=4)
        draw.ellipse([cx-8, cy-8, cx+8, cy+8], fill=(255, 30, 86))
    elif icon_type == "simon":
        draw.rectangle([cx-36, cy-36, cx-4, cy-4], fill=(0, 255, 136))
        draw.rectangle([cx+4, cy-36, cx+36, cy-4], fill=(255, 30, 86))
        draw.rectangle([cx-36, cy+4, cx-4, cy+36], fill=(255, 179, 0))
        draw.rectangle([cx+4, cy+4, cx+36, cy+36], fill=(0, 240, 255))
    elif icon_type == "seesaw":
        draw.line([cx-42, cy-10, cx+42, cy+10], fill=color, width=6)
        draw.polygon([(cx, cy+8), (cx-18, cy+35), (cx+18, cy+35)], fill=(20, 25, 40), outline=color)
    elif icon_type == "cart":
        draw.rounded_rectangle([cx-36, cy-16, cx+36, cy+20], radius=6, fill=(20, 25, 40), outline=color, width=4)
        draw.ellipse([cx-26, cy+20, cx-10, cy+36], fill=color)
        draw.ellipse([cx+10, cy+20, cx+26, cy+36], fill=color)
        draw.ellipse([cx-8, cy-28, cx+8, cy-12], fill=(255, 215, 0))
    elif icon_type == "tictactoe":
        draw.line([cx-14, cy-36, cx-14, cy+36], fill=color, width=2)
        draw.line([cx+14, cy-36, cx+14, cy+36], fill=color, width=2)
        draw.line([cx-36, cy-14, cx+36, cy-14], fill=color, width=2)
        draw.line([cx-36, cy+14, cx+36, cy+14], fill=color, width=2)
        draw.text((cx-32, cy-32), "B", font=make_font(18), fill=(255, 179, 0))
        draw.text((cx-4, cy-4), "X", font=make_font(18), fill=(0, 240, 255))
    elif icon_type == "stopwatch":
        draw.ellipse([cx-38, cy-32, cx+38, cy+44], outline=color, width=4)
        draw.line([cx, cy+6, cx+18, cy-14], fill=color, width=3)
        draw.rectangle([cx-8, cy-42, cx+8, cy-32], fill=color)
    elif icon_type == "chart":
        pts = [(cx-40, cy+24), (cx-15, cy-8), (cx+10, cy+12), (cx+40, cy-32)]
        for i in range(len(pts)-1):
            draw.line([pts[i], pts[i+1]], fill=color, width=4)
        draw.polygon([(cx+40, cy-32), (cx+28, cy-30), (cx+36, cy-18)], fill=color)
    elif icon_type == "merge":
        draw.rounded_rectangle([cx-36, cy-36, cx+36, cy+36], radius=10, fill=(35, 20, 60), outline=color, width=3)
        draw.text((cx-28, cy-14), "2048", font=make_font(20), fill=color)
    elif icon_type == "grapple":
        draw.arc([cx-30, cy-30, cx+30, cy+30], 45, 225, fill=color, width=5)
        draw.line([cx, cy-45, cx+40, cy+40], fill=(255, 255, 255), width=2)
    elif icon_type == "rps":
        draw.ellipse([cx-30, cy-10, cx-6, cy+14], fill=(255, 109, 0))
        draw.rectangle([cx+6, cy-22, cx+30, cy+6], fill=(0, 240, 255))
        draw.line([cx-10, cy+15, cx+10, cy+35], fill=(255, 255, 255), width=3)
    elif icon_type == "archery":
        draw.ellipse([cx-40, cy-40, cx+40, cy+40], outline=(255, 30, 86), width=4)
        draw.ellipse([cx-24, cy-24, cx+24, cy+24], outline=(255, 179, 0), width=4)
        draw.ellipse([cx-10, cy-10, cx+10, cy+10], fill=(0, 240, 255))
    elif icon_type == "runner":
        draw.ellipse([cx, cy-32, cx+16, cy-16], fill=color)
        draw.line([cx+8, cy-16, cx+2, cy+8], fill=color, width=4)
        draw.line([cx+2, cy+8, cx-18, cy+32], fill=color, width=4)
        draw.line([cx+2, cy+8, cx+22, cy+28], fill=color, width=4)
    elif icon_type == "slots":
        draw.rounded_rectangle([cx-44, cy-32, cx+44, cy+32], radius=8, fill=(20, 25, 40), outline=color, width=3)
        draw.text((cx-36, cy-18), "7 7 7", font=make_font(24), fill=color)
    elif icon_type == "crosser":
        draw.rounded_rectangle([cx-30, cy-20, cx+30, cy+20], radius=8, fill=(20, 25, 40), outline=color, width=3)
        draw.line([cx-44, cy, cx+44, cy], fill=color, width=2)
        draw.ellipse([cx-8, cy-8, cx+8, cy+8], fill=color)
    else:
        draw.ellipse([cx-32, cy-32, cx+32, cy+32], fill=(20, 25, 40), outline=color, width=3)

for num, fname, title, badge_num, cat, color, bg_tint, icon in games_data:
    img = Image.new("RGB", (W, H), (11, 16, 33))
    draw = ImageDraw.Draw(img)

    # Gradient background tint
    for y in range(H):
        ratio = y / H
        r = int(11 * (1 - ratio) + bg_tint[0] * ratio)
        g = int(16 * (1 - ratio) + bg_tint[1] * ratio)
        b = int(33 * (1 - ratio) + bg_tint[2] * ratio)
        draw.line([(0, y), (W, y)], fill=(r, g, b))

    # Cyber grid lines
    grid_color = (25, 38, 65)
    for x in range(0, W, 32):
        draw.line([(x, 0), (x, H)], fill=grid_color, width=1)
    for y in range(0, H, 32):
        draw.line([(0, y), (W, y)], fill=grid_color, width=1)

    # Ambient glow ring around center
    cx, cy = W // 2, 105
    for rad in range(75, 45, -5):
        alpha_tint = (int(color[0] * 0.15), int(color[1] * 0.15), int(color[2] * 0.15))
        draw.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], outline=alpha_tint, width=3)

    # Draw specific game vector glyph
    draw_icon(draw, icon, color, cx, cy)

    # Category Pill (Top Left)
    draw.rounded_rectangle([18, 16, 120, 42], radius=6, fill=(18, 26, 48), outline=color, width=1)
    draw.text((30, 22), cat, font=font_badge, fill=color)

    # Game Number Pill (Top Right)
    draw.rounded_rectangle([W - 74, 16, W - 18, 42], radius=6, fill=(18, 26, 48), outline=(60, 80, 120), width=1)
    draw.text((W - 60, 20), f"#{badge_num}", font=font_num, fill=(255, 255, 255))

    # Title Banner Bar (Bottom)
    draw.rectangle([0, H - 65, W, H], fill=(12, 17, 30))
    draw.line([(0, H - 65), (W, H - 65)], fill=color, width=2)

    # Title Text
    bbox = draw.textbbox((0, 0), title, font=font_title)
    tw = bbox[2] - bbox[0]
    draw.text(((W - tw) // 2, H - 54), title, font=font_title, fill=(255, 255, 255))

    # Outer Neon Border
    draw.rectangle([0, 0, W - 1, H - 1], outline=color, width=3)

    out_path = os.path.join(output_dir, fname)
    img.save(out_path, "PNG")
    print(f"Generated {fname}")

print("All 30 images generated successfully!")

