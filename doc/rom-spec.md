# ROM Format Specification

- [ROM Format Specification](#rom-format-specification)
  - [Reference](#reference)
  - [Header](#header)
  - [Chunks](#chunks)
    - [Palette (`0x00`)](#palette-0x00)
    - [Tileset (`0x01`)](#tileset-0x01)
    - [Tilemap (`0x02`)](#tilemap-0x02)
    - [Sprite (`0x03`)](#sprite-0x03)
    - [Font (`0x04`)](#font-0x04)
    - [Data (`0x05`)](#data-0x05)
    - [Audio (`0x06`)](#audio-0x06)

## Reference

- `BYTE`/`CHAR`: An 8-bit unsigned integer value
- `DWORD`: A 32-bit unsigned integer value
- `LONG`: A 32-bit signed integer value
- `SHORT`: A 16-bit signed integer value
- `WORD`: A 16-bit unsigned integer value
- `STRING`: UTF8 string

## Header

```
LONG        Magic Number `0x52524f4d` (`'RROM'` string)
```

## Chunks

The remaining data consist of Chunks

```
BYTE        Chunk type
BYTE        Length of chunk's name (n)
CHAR[n]     String representing chunk name
DWORD       Chunk data length (l)
BYTE[l]     Chunk data
```

Depending on chunk's type its data can have one of the following formats.

The first chunk the data **must** be `Palette` chunk (`0x00`):

### Palette (`0x00`)

```
BYTE        Number of colors in the Palette
+ For each color
  BYTE      BLUE color component
  BYTE      GREEN color component
  BYTE      RED color component
```

### Tileset (`0x01`)

```
BYTE        Tile width (w)
BYTE        Tile height (h)
DWORD       Number of tiles (n)
BYTE[w*h*n] Tiles' pixels
```

### Tilemap (`0x02`)

```
BYTE        Length of the string (n)
CHAR[n]     Name of a Tileset to use for this tilemap
DWORD       X position
DWORD       Y position
DWORD       Number of tiles horizontally (h)
DWORD       Number of tiles vertically (v)
+ For each LINE of tiles (0...v)
  + For each COL of tiles (0...h)
    WORD    Tile index
    BYTE    (boolean) whether the tile is flipped horizontally
    BYTE    (boolean) whether the tile is flipped vertically
    BYTE    (boolean) whether the tile is rotated 90 degrees clockwise 
```

### Sprite (`0x03`)

```
BYTE         Width
BYTE         Height
DWORD        Number of frames
+ For each frame
  DWORD      Frame duration in milliseconds
  BYTE[w*h]  Frame pixels
WORD         Number of animations
+ For each animation
  WORD       Length of the string representing animation name (n)
  BYTE[n]    Animation name
  DWORD      From frame
  DWORD      To frame
  SHORT      Animation direction 
               0 = Forward
               1 = Backwards
               2 = Ping Pong
```

### Font (`0x04`)

```
BYTE         Font type
               0 = Variable character size
               1 = Fixed character size 
```

If font type is `0`:

```
BYTE         Base
BYTE         Line height
WORD         Number of characters (n)
+ For each character (0...n)
  WORD       Character code
  WORD       X position in the sprite
  WORD       Y position in the sprite
  SHORT      X offset
  SHORT      Y offset
  BYTE       X advance
  BYTE       Character width
  BYTE       Character height
```

If font type is `1`:

```
BYTE         Character width
BYTE         Character height
BYTE         Spacing between characters
WORD         Number of characters [n]
STRING[n]    Characters
```

### Data (`0x05`)

Raw bytes, arbitrary format

### Audio (`0x06`)

```
BYTE         Number of channels
DWORD        Sample rate
BYTE         Bits per sample
DWORD        PCM data length (l)
BYTE[n]      PCM data

```
