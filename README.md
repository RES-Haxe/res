# RES

- [RES](#res)
  - [Introduction](#introduction)
  - [Features](#features)
  - [Getting Started](#getting-started)
    - [Creating a project](#creating-a-project)
      - [Haxe Ecosystem (Recommended)](#haxe-ecosystem-recommended)
      - [Starter Kit](#starter-kit)

## Introduction

**RES** (*Restrictive Entertainment System? Or maybe Raster Engine Solution? Idk ¯\\_(ツ)_/¯*) is a framework dedicated to creation of low resolution raster/pixelart games that can run on anything (potentially).

RES is a platform-independed library meaning that you will need to bring your own implementations of things like frame buffer output to a screen, playing sounds, capturing user inputs, etc. In order to do that you will have to implement your own [Platform](documentation/platform.md) or user one of premade ones:

- HTML5: res-html5 (TBD)
- Heaps: res-heaps (TBD)
- Lime: res-lime (TBD)
- LincSDL: res-linksdl (TBD)

## Features

- ROM ("Where's all the data" file/embedded data)
- [Aseprite](https://www.aseprite.org/) files as sprites/tilesets/tilemaps
- Palettes and palette swapping
- Generative sounds
- Animated sprites
- Tilemaps
- Input abstractions

  Keyboard/Gamepad inputs mapped to virtual controllers
- Scanline interupts
- Basic collision detection and resolution

## Getting Started

### Creating a project

There are different ways of starting a project with RES:

#### Haxe Ecosystem (Recommended)

#### Starter Kit