# Tamer: development plan

WoW Forever Hunter pet training addon.

## 1. Product vision

Tamer helps Hunters know exactly what their pet needs to learn next, how to unlock it, and where to find the beast that teaches it.

The goal is to remove the confusion of leveling a pet like Behr in Loch Modan: instead of digging through a big database of beasts, abilities, ranks and locations, you open one small window and see what to do.

**Core design principle:** show the player what matters right now, not everything that exists.

### How Tamer is different

Several Forever addons already cover pet training: Beastfinder, Hunter's Handbook, HunterPetFinder, and the recently updated HunterPetJournal. Some already flag missing ranks and nearby beasts. Tamer should stand out by being simpler, not by having a bigger database.

| Existing addons | Tamer |
| --- | --- |
| Browse hundreds of beasts | Show the next useful upgrade |
| Search and filter abilities | Find missing ranks automatically |
| Move between several tabs | One main screen |
| Look up beast spawn locations | Give a clear next step |
| Track pet progress by hand | Update as the pet levels |

## 2. Main user experience

`/tamer` opens a small dashboard for the currently summoned pet.

Concept layout (illustrative, using Behr's earlier state, not live data):

```
Behr
Bear · Level 15 · 4 trained
[pet XP bar]

Ready to train
  Swipe · Rank 1 · Available
  You've learned this. Train it through Beast Training if Behr doesn't know it yet.

Next upgrade
  Claw · Rank 3 · Level 16
  Already learned by your Hunter. Behr needs one more level.

Missing abilities
  Next unlearned rank, found from your pet's family.
  Select an ability to see which beasts teach it.
```

### Every screen answers three questions

1. What does my pet already know?
2. What can I teach my pet right now?
3. What should I go learn next?

The player should never need to understand the difference between "known by the Hunter", "trained on the pet" and "available from a wild beast" without the addon explaining it.

### What each ability's status means

Every ability rank on the dashboard is in exactly one of these states, always written out in plain words:

| Status | What it means | What the dashboard tells you |
| --- | --- | --- |
| Known | Your pet has this rank. | Nothing to do. |
| Ready to train | You know the rank, your pet is high enough level, and it has the training points. | Cast Beast Training and teach it. |
| Needs level | You know the rank, but your pet is too low. | "Behr needs level 16." |
| Needs training points | You know the rank and the level is fine, but there aren't enough points. | How many points it costs and how many are left. |
| Go learn it | You don't know this rank yet. | Tame one of these beasts, with their level and zone. |

"You" always means the Hunter and "your pet" always means the pet, so the difference between the two is never left to the player to work out.

## 3. First release (MVP)

### In

- **One small window** for the summoned pet, opened with `/tamer` or a minimap button.
- **Header:** the pet's name, family, level, experience bar, and training points left.
- **Ready to train:** ranks you can teach right now, with their training point cost.
- **Next upgrade:** the next rank your pet will be able to learn by leveling, and at what level.
- **Go learn it:** ranks your pet's family can learn that you don't know yet. Click one to see up to three beasts that teach it, closest to your level first, with each one's level and zone.
- **One chat line on level-up**, only when a rank becomes ready to train: "Behr can now learn Claw (Rank 3). Cast Beast Training to teach it."
- **A built-in beast list**, put together from public game data.
- **Minimap button:** click to open, drag to move, `/tamer minimap` to hide or show it.

### Out, for now

- Map pins and waypoints.
- Sharing discoveries with guild or group.
- Stabled pets. With no pet out, the window says to call one.
- Pop-ups for zones or targets, and any alert besides the level-up line.
- Feeding, happiness and loyalty.
- Learning new beasts while you play. The built-in list is the only source.

### Commands

| Command | What it does |
| --- | --- |
| `/tamer` | Open or close the dashboard |
| `/tamer minimap` | Show or hide the minimap button |
| `/tamer status` | Print what Tamer can read about you and your pet |
| `/tamer help` | List the commands |

## 4. Game data

### What the game tells us

These are what Classic-era clients provide. Each one has to be confirmed on WoW Forever before we build on it (see milestone 2).

| What we need | Where it comes from | Notes |
| --- | --- | --- |
| Pet's name, level, family | `UnitName("pet")`, `UnitLevel("pet")`, `UnitCreatureFamily("pet")` | Available whenever a pet is out. |
| Pet's experience | `GetPetExperience()` | |
| Training points left | `C_PetInfo.GetPetTrainingPoints()` on Forever, `GetPetTrainingPoints()` on Classic | Returns total and spent. |
| Ranks the pet knows | The pet's spellbook (`C_SpellBook` on Forever) | Read when the pet is called and when it learns something. |
| Ranks the Hunter knows | The Beast Training window. On Forever it's a trainer window (`TRAINER_SHOW`, `GetTrainerServiceInfo`, which returns name, category, icon, level, rank). Classic uses the craft API. | Only readable while the window is open, so Tamer saves what it saw for each character. Also updated from "You have learned" chat messages. |
| Each rank's level and training point cost | The Beast Training window | Saved alongside the ranks above. Tamer's data comes first when it has the rank. |

Training a higher rank refunds the points spent on the pet's current rank, so an upgrade costs the difference, as in Classic. Checked on Forever: Claw 3 showed 6 points with Claw 1 known (7 minus 1).

Until you've opened Beast Training once, Tamer can't know which ranks you have, so the dashboard asks you to open it.

### What we ship and maintain

`Data.lua` holds what the game never tells an addon:

- **Abilities:** each ability, its ranks, the level each rank needs, and which pet families can learn it.
- **Beasts:** each beast that teaches something: name, family, level range, zone, and the ranks it teaches.

### Where the list comes from

The list is built from public game data that already exists, such as the Classic sections of [Wowhead](https://www.wowhead.com/classic) and [warcraft.wiki.gg](https://warcraft.wiki.gg/), and Classic-era hunter pet references.

- **Facts only:** names, families, levels, zones and ranks. No descriptions or other text are copied.
- **No other addon's data files.** Other Forever pet addons ship their own lists. Tamer's comes from the public sources, not from them.
- **Sources noted:** a comment above each section of `Data.lua` says where its entries came from, so they can be checked again.
- **Within each site's terms:** look things up by hand rather than scraping a site whose terms forbid it.

Public data describes Classic Era, and Forever may differ in places, such as a beast's level, zone, or what it teaches. When a player reports a difference, Forever wins and the entry is fixed in `Data.lua`.

## 5. How the addon is built

Same layout as Fireside Tales. Files load in this order:

| File | Job |
| --- | --- |
| `Data.lua` | Abilities and beasts. Data only, no code. |
| `Core.lua` | Saved data, events, the slash command, shared helpers. |
| `Knowledge.lua` | Reads the game: the pet, its spellbook, training points, the Beast Training window, and chat messages. Saves what the Hunter knows. |
| `Advisor.lua` | Works out each rank's status and builds the three lists. Takes plain tables in and gives plain tables back, with no game calls, so the harness can test it fully. |
| `Dashboard.lua` | The window. Only draws what `Advisor.lua` returns. |
| `MinimapButton.lua` | The minimap button, as in Fireside Tales, with the hand-and-snout icon. |

Saved data, in `TamerDB`:

- Per character: ranks the Hunter knows, with each rank's level and cost.
- Account-wide: the minimap button's position and visibility.

Art lives in `art/` as the artist's PNGs (`logo.png`, `icon.png`, `minimap.png`, `banner.png`). The in-game icon and minimap icon are converted to TGA in `addon/Tamer/Textures/`, and the TOC's `## IconTexture` points at the new icon instead of the game's Beast Training icon.

## 6. Artwork and the CurseForge page

Both follow Fireside Tales.

- **Artwork:** [artwork-brief.md](artwork-brief.md) is the request for our artist: a logo, in-game icon, minimap icon and banner, built around the moment of taming: a Hunter's open hand and a wild beast lowering its head to sniff it. Send it at the start, so the art is ready by release.
- **CurseForge page:** [curseforge-listing.md](curseforge-listing.md) has every field the project form asks for and a draft description, with the same shape as Fireside Tales': a banner, what it does, a short how-to, commands, and a "Good to know" section. The gallery gets four real screenshots, listed in the artwork brief.
- **Changelog:** the same style as Fireside Tales. One `## X.Y.Z` section per release, newest first, with short, plain bullets. Each release posts the whole changelog to CurseForge and GitHub. There's no "Unreleased" section. Test versions before 1.0.0 upload as a Beta and get a section too.

## 7. Milestones

1. **Request the artwork.** Send the artwork brief to the artist.
2. **Read the game.** `/tamer status` prints the pet, its level, family, training points, known ranks, and the Hunter's known ranks after opening Beast Training. Try it on Forever and correct the table in section 4.
3. **The advisor.** `Advisor.lua` and its harness checks, using a test pet like Behr.
4. **The dashboard.** The window, the minimap button, and the level-up line.
5. **Data.** Abilities for every family, then beasts for levels 10 to 30 first, then the rest.
6. **Art and listing.** Add the artist's icons to the addon, take the screenshots, and finish the CurseForge description against what the addon really does.
7. **Release 1.0.**

## 8. Testing

### The harness

`tools/harness/harness.lua` stands in for the game and checks:

- Each status in section 2 with a test pet: known, ready, needs level, needs points, go learn it.
- No pet out, a pet out before Beast Training was ever opened, and a family with no data.
- The level-up line appears once, only for a newly ready rank, and not on login.
- Every entry in `Data.lua` is well formed: real families, ranks in order, levels in range, and every rank a beast teaches exists in the ability list.

### In the game

- A fresh Hunter who has never opened Beast Training.
- Call, dismiss, and swap pets while the window is open.
- Level a pet past a rank and check the chat line.
- Spot-check a few beasts from "Go learn it" in their zones: right level, right place, and they teach what the list says.
- Hide and show the minimap button, `/reload`, and check everything is remembered.

## 9. Release checklist

- The harness passes with 0 failures.
- Every in-game check above done on Forever.
- The artist's logo, icons and banner are in `art/`, and the icons are in the game.
- `## Version` set to `1.0.0` in `Tamer.toc`.
- A `## 1.0.0` section in `CHANGELOG.md`, in the usual short style, shown to you for approval before tagging.
- The public GitHub repository exists, so the banner loads on CurseForge.
- The CurseForge project is created from [curseforge-listing.md](curseforge-listing.md), with the artist credited in "Good to know" and four real screenshots in the gallery.
- `CF_API_TOKEN` and `CF_PROJECT_ID` set in GitHub.
- Tag and push, as in [RELEASING.md](RELEASING.md).

## 10. Open questions

- About half the beast-taught ranks still have no teacher in `Data.lua`. Wowhead's Forever "Taught by" tabs list none for them: Charge 4-6, Cower 5, Dive, Lightning Breath (except rank 2), Scorpid Poison, Shell Shield, Thunderstomp 2-4, Furious Howl 4, Savage Rend 4, Screech 4, Web 2-5, and all of Sonic Blast, Pinch, Tendon Rip, Dismember and Dust Cloud. A few more are only in zones Wowhead didn't name, such as Mount Hyjal.
- Wowhead's Forever pages list Pet Trainers as also teaching Bite 1-6, Claw 1-6, Dash 1-2, Prowl 1 and Swipe 2. If a Pet Trainer's window shows them in the game, those ranks can point to the trainer too.
- Training point costs for Forever's new abilities, and for Thunderstomp 4, aren't published. Beast Training shows them.
- Does `UnitCreatureFamily` return "Owl" or "Bird of Prey" on Forever? Tamer accepts both.
