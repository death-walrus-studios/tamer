# Tamer

## The vision

Tamer helps a Hunter on World of Warcraft: Forever know what their pet should learn next, how to unlock it, and which beast teaches it. You open one small window and see your next step, without digging through a database of beasts, abilities, ranks and locations.

If you're working on this project, whether you're a person or an AI, these are the goals that decide what to do:

- **Show what matters right now, not everything that exists.** The next useful upgrade beats a full list of beasts.
- **Answer three questions on every screen.** What does my pet already know? What can I teach it right now? What should I go learn next?
- **Explain the difference.** Never leave the player to work out "known by the Hunter", "trained on the pet" and "available from a wild beast" on their own.
- **Keep up by itself.** Find missing ranks from the pet's family and update as the pet levels, without the player tracking anything.
- **One main screen.** A new feature has to earn its place, and it shouldn't make the dashboard harder to read.

The full plan is in [docs/plan.md](docs/plan.md).

## What it is

One small window for the pet you have out. Open it with the minimap icon or `/tamer`.

![The Tamer window](docs/screenshots/curseforge/01-window.png)

- **Green card:** ranks you know that your pet can learn right now, as big icons with their training point cost. The Teach button opens Beast Training.
- **Gold card:** ranks waiting on a pet level or more training points.
- **Blue card:** the next rank of each ability you don't know yet, with the nearest beast that teaches it, or the Pet Trainer. Hover a row for up to three beasts with their level and zone.

When your pet levels into a rank you can teach it, Tamer prints one line in chat. That's the only time it speaks up.

The game only shows which ranks you know while Beast Training is open, so cast Beast Training once with each kind of pet out. Tamer remembers them for each character.

The beast list is built in, from public Classic Era data. It's in `addon/Tamer/Data.lua`.

[Join us on Discord](https://discord.gg/GyrhmXnQTW) to ask questions, report bugs and suggest ideas.

## Setup

1. Close the game and extract the zip into your AddOns folder, so its files end up in `AddOns/Tamer/`:

   - **Windows:** `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\`
   - **macOS:** `/Applications/World of Warcraft/_forever_/Interface/AddOns/`

   Create the `AddOns` folder if it isn't there. Your game may be installed somewhere else.

2. Start the game. If addons load individually, turn on Tamer at the character screen.

## Commands

| Command | What it does |
| --- | --- |
| `/tamer` | Open or close the window |
| `/tamer minimap` | Show or hide the minimap icon |
| `/tamer status` | Print what Tamer can read about you and your pet |
| `/tamer debug` | Print what the game returns, for bug reports |
| `/tamer help` | List the commands |

## Working on the addon

These commands need [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell), which also runs on macOS. To link the project into the game so edits load directly, run:

```powershell
./install-addon.ps1
```

Pass `-WowPath` if the game isn't in the default location. Restart the game after linking.

The addon is in `addon/Tamer/`. Edits load with `/reload`. A brand-new file needs a game restart and an entry in `Tamer.toc`.

- `Data.lua`: the abilities, their ranks, and the beasts that teach them. Note the source above each section, copy facts only, and never take another addon's data.
- `Core.lua`: saved data, the slash command, and shared helpers.
- `Knowledge.lua`: reads the pet, its spellbook, its training points, and Beast Training.
- `Advisor.lua`: works out each rank's status. It makes no game calls, so the harness tests it fully.
- `Dashboard.lua` and `MinimapButton.lua`: the window and the minimap icon.

The artist's PNGs are in `art/`. After replacing `icon.png` or `minimap.png`, rebuild the in-game textures on a Mac:

```sh
python3 tools/make-textures.py
```

To test the addon outside the game, run the harness with [LuaJIT](https://luajit.org/). See [tools/harness/README.md](tools/harness/README.md).

```sh
luajit tools/harness/harness.lua
```

### Releasing

Pushing a version tag publishes to CurseForge and GitHub. See [docs/RELEASING.md](docs/RELEASING.md).

### Building the zip

This builds `dist/Tamer-<version>.zip` with the addon:

```powershell
./tools/build-release.ps1
```

To update, replace the whole `Tamer` folder with the new one. Saved data isn't stored there, so it stays.
