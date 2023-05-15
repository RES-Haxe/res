# RES

- [RES](#res)
  - [Overview](#overview)
  - [Installation](#installation)

## Overview

RES is a minimalist game engine designed for creating games with low-spec content. It is inspired by Pico-8 and other fantasy consoles.

RES is written in Haxe and extremely portable.

<img src="./readme/megatank.gif" height="250" />
<img src="./readme/motorun.gif" height="250" />
<img src="./readme/typingtrain.gif" height="250" />

## Installation

1. Install Haxe following the instructinos on the [official website](https://haxe.org/download/version/4.2.5/)
2. Using `haxelib` (library manager utility for haxe) install RES:
   ```
   haxelib install res
   ```

   or use git if you want the bleeding edge version :
   ```
   haxelib git res https://github.com/RES-Haxe/res.git
   ```
3. Now you can use RES cli:
   ```
   haxelib run res
   ```
4. To initialize a project use:
   ```
   haxelib run res init MyProject project/directory
   ```