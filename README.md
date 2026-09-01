The repository is migrated to Codeberg: https://codeberg.org/ilivi/tusa

# tusa

Tidal Unit for Sonic Activities.

The framework functions as a tmux workflow with different panes of a terminal performing different parts of the program.
It features an interpreter for Tidal Cycles, a snippets window for fast copying of precomposed material, a reference window that represents [the official reference](https://tidalcycles.org/docs/reference/cycles) in a brief format, and a SuperCollider server.
The system can be extended and now includes modular system for spatialisation (IKO is supported) and additional functionality.

## Features
- Stable performance
- Installation script
- Fast boot-up
- Automatic saving of the session (memory of last 10, but could be increased modifying /config-util/finish.sh)
- Syntax highlighting in snippets window
- Reference as a cheat sheet (yet not full)
- No need to press Cmd+C to copy; copying is automatic while selecting
- For devs: all settings for dependencies are local and don't affect global .rc files
- Theoretically should work in any modern Bash terminal (tested only on MacOS)

## Architecture
The bash script `tusa` is running a tmux workflow, that everytime you boot it asks you few questions to configure the session. It asks
- If you want to include reference with the snippets in your session.
- If you play with some advanced spatialisation (so it loads a corresponding spatialisation script)
- If you play with Machine Learning (it asks it separately, because it has a feature of plotting the dataset as a separate pane, currently in rethinking)
- If you want to load any additional module of your choice.

All the values are stored as variables and then are accessed as arguments for the rest of the utilities. The necessary module files are loaded in the SuperCollider Boot File via Require UGen.

## Installation

```sh
cd path-to-directory
git clone https://github.com/IliaViazov/tusa
./installation-macos.sh
```

The following script assumes that you have installed `git` and `homebrew`. The installation process is as follows:
- Haskell
- Python
- Tidal package for Haskell
- Nano Editor
- Glow Markdown Reader
- tmux
- SuperCollider, SC3-Plugins, Dirt-Samples, SuperDirt, Require.

## Usage

### Start

```sh
cd path-to-directory
./tusa
```
or via `tusa` in the Terminal window directly. The installation script creates a symlink in the root of your user, so the executable should be found by default.

After start the script will ask you for the modules you would like to use during the session, separating it into 3 categories:
- Spatialisation
- Machine Learning (originally because my module uses additional GUI for plotting the dataset)
- Other Modules.

P.s. Treating the machine learning as a separate kind of module feels for me redundant, and I'm currently working on modifying it.

To each module, a supplementary folder can be assigned (look examples with IKO and Serge synthesizer), that can be read by the script or used for additional files that are processed by `.scd` file.

### Finish

In the interpreter window, type:
```haskell
:finish
```
and then close the window. The command `:finish` is an alliance of `hush`, `:quit` and saving script in `shell` that is written inside of `BootTidal.hs`

The session will be saved in the folder `/sessions` as `.hs` file

### Multi-line

Multi-line can be used in the standard Haskell manner:
```haskell
:{
d1 $ "bd sn bd sn"
# gain rand
# octer 0.5
# room 1
:}
```

## FAQ

### SuperCollider crashed during performance

`Cmd + .` to kill.  
`↑` then `Enter` to start again.

### How do I add my samples?

Adjust this part of the code inside the SuperCollider bootloader, adding your unique path or just put it into the Dirt Samples folder.
```supercollider
~dirt.loadSoundFiles("/Users/myUserName/Dirt-Samples/samples/*");
```
The path may differ from the example.

### How do I add my synths?

Adjust this part of the code inside the SuperCollider bootloader, adding your unique path or just put it into the Dirt Samples folder.
```supercollider
~dirt.loadSynthDefs("/Users/myUserName/SuperDirt/synthdefs/*");
```
The path may differ from the example.

### How do I add my modules?

All modules shall be located in the `/config-util/modules` folder. The startup script every time asks you if you would like to load any additional module into the Boot-Loader. Each module can have its additional folder for all the utilities, files which are necessary for the work of the module.

### Don't like autocopying?

Adjust `.tmux.conf` inside the repository's folder.

## Future Plans

- Full support on Linux and Windows
- Additional sample library and SuperCollider library
- Support of advanced spatialisation via Ambisonics Toolkit
- Direct Communication SynthDefs: OSC, MIDI, Serial, and G-Code
- Easy multiplayer via tmux remote feature


## References to the used resources, repos, and inspirations

- [Tidal Cycles](https://tidalcycles.org/)
- [SuperCollider](https://supercollider.github.io/)
- [Nano](https://www.nano-editor.org/)
- [Syntax Highlighting for Nano](https://github.com/scopatz/nanorc.git)
- [vim-tidal](https://github.com/tidalcycles/vim-tidal)
- [Glow](https://www.nano-editor.org/)
- [tmux](https://github.com/tmux/tmux/wiki)
- [Haskell](https://www.haskell.org/ghcup/)
- [Colored GHCI](https://github.com/rhysd/ghci-color/tree/master)
- [Python](https://www.python.org/)

The project is done and maintained with a great support of the [SACMT](https://www.instagram.com/mhl.sacmt/) at Musikhochschule Lübeck.
