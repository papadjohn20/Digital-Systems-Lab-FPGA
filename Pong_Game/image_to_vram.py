from PIL import Image
import numpy as np

WIDTH  = 128
HEIGHT = 96
BRAM_BITS = 16384        # 16K bits ανά bitplane
INIT_BLOCK_BITS = 256    # 256 bits ανά INIT_xx
THRESH = 128             # threshold για κάθε κανάλι

def image_to_bitplanes(image_path):
    """
    Φορτώνει την εικόνα, την κάνει 128x96, και επιστρέφει
    3 λίστες bits (R, G, B), καθεμία μήκους BRAM_BITS.
    """
    img = Image.open(image_path).convert("RGB")
    img = img.resize((WIDTH, HEIGHT), Image.NEAREST)

    bits_r, bits_g, bits_b = [], [], []

    for y in range(HEIGHT):
        for x in range(WIDTH):
            r, g, b = img.getpixel((x, y))

            bit_r = 1 if r >= THRESH else 0
            bit_g = 1 if g >= THRESH else 0
            bit_b = 1 if b >= THRESH else 0

            bits_r.append(bit_r)
            bits_g.append(bit_g)
            bits_b.append(bit_b)

    # pad / truncate σε ακριβώς 16K bits
    def fix_len(bits):
        if len(bits) < BRAM_BITS:
            bits = bits + [0] * (BRAM_BITS - len(bits))
        return bits[:BRAM_BITS]

    return fix_len(bits_r), fix_len(bits_g), fix_len(bits_b)


def bits_to_init_blocks(bits):
    """
    Παίρνει μια λίστα από bits και τη σπάει σε blocks των 256 bits.
    Επιστρέφει λίστα strings τύπου "256'h....".
    """
    bits = np.array(bits).astype(int)
    hex_blocks = []

    for i in range(0, len(bits), INIT_BLOCK_BITS):
        block_bits = bits[i:i+INIT_BLOCK_BITS]
        if len(block_bits) < INIT_BLOCK_BITS:
            block_bits = np.pad(block_bits, (0, INIT_BLOCK_BITS - len(block_bits)))
        bit_str = "".join(map(str, block_bits))
        hex_val = hex(int(bit_str, 2))[2:].upper()
        hex_val = hex_val.zfill(64)  # 256 bits = 64 hex chars
        hex_blocks.append(f"256'h{hex_val}")

    return hex_blocks


def save_preview_image(bits_r, bits_g, bits_b, base_name="vram"):
    """
    Φτιάχνει μια preview εικόνα από τα quantized bits.
    """
    preview = Image.new("RGB", (WIDTH, HEIGHT))
    for y in range(HEIGHT):
        for x in range(WIDTH):
            idx = y * WIDTH + x
            r = 255 * (bits_r[idx] & 1)
            g = 255 * (bits_g[idx] & 1)
            b = 255 * (bits_b[idx] & 1)
            preview.putpixel((x, y), (r, g, b))

    preview_filename = f"{base_name}_preview.png"
    preview.save(preview_filename)
    print(f"Preview image saved as: {preview_filename}")


if __name__ == "__main__":
    image_path = "right_wins.png"
    base_name = "vram"

    bits_r, bits_g, bits_b = image_to_bitplanes(image_path)

    # --- Τυπώνει INIT_xx για κάθε κανάλι, όπως στο δεύτερο script ---
    for plane_name, bits in [("R", bits_r), ("G", bits_g), ("B", bits_b)]:
        print(f"\n// {plane_name} PLANE INIT VALUES")
        inits = bits_to_init_blocks(bits)
        for idx, val in enumerate(inits):
            print(f".INIT_{idx:02X}({val}),")

save_preview_image(bits_r, bits_g, bits_b, base_name=base_name)