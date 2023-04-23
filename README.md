# RES

RES is a minimalist game engine focused on low-resolution paletted raster graphics. RES is written in Haxe and extremely portable.

## Installation

### Easy (and preferred) way:

Download and install (or build from source) the [RES CLI](https://github.com/RES-Haxe/res-cli) tool and follow the instructions in the readme

### Haxe ecosystem way:

1. Install Haxe following the instructions on the [official website](https://haxe.org/)
2. Using `haxelib` (library manager utility for haxe) install the following libs:

   ```
   haxelib git res https://github.com/RES-Haxe/res-cli.git
   haxelib install ase
   haxelib install format
   ```

   For HashLink support also install these:
   ```
   haxelib git res-hl https://github.com/RES-Haxe/res-hl.git
   haxelib install hlsdl
   haxelib install hlopenal
   ```

   For HTML5 support install:
   ```
   haxelib git res-html5 https://github.com/RES-Haxe/res-html5.git
   ```
3. Create a directory for your project. Inside create `src` directory for your code and `rom` directory for your resources
4. Create `src/Main.hx` file with content similar to this:
   ```haxe
    #if hl
    final bios = new res.bios.hl.BIOS("RES", 4);
    #elseif js
    final bios = new res.bios.html5.BIOS();
    #end

    function main() {
        RES.boot(bios, {
            resolution: [128, 128],
            rom: Rom.embed(),
            main: (res) -> {
                update: (dt) -> {},
                render: (fb) -> {}
            }
        });
    }
   ```
5. For HashLink support
   1. Make sure [HashLink](https://hashlink.haxe.org/) is installed in your system
   2. Create `res.hl.hxml` file in the root of your project directory with the following content:
      ```hxml
      -cp ./src
      -main Main
      -lib res
      -lib ase
      -lib format
      -lib res-hl
      -lib hlsdl
      -lib hlopenal
      --hl hlboot.dat
      ```
   3. Build the project using `haxe res.hl.hxml` command
   4. Run the project using `hl` command
6. For HTML5 support
   1. Create `res.js.hxml` file in the root of your project directory with the following content:
      ```hxml
      -cp ./src
      -main Main
      -lib res
      -lib ase
      -lib format
      -lib res-html5
      --js ./js/game.js
      ```
   2. Create `js/index.html` file with the content similar to this:
      ```html
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8" />
          <meta http-equiv="X-UA-Compatible" content="IE=edge" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title></title>
      </head>
      <body>
          <script src="game.js"></script>
      </body>
      </html>
      ```
   3. Build the project using `haxe res.js.hxml` command
   4. Open `js/index.html` file using your web browser of choice