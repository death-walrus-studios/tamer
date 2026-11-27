-- Tamer's built-in data: Hunter pet abilities and the beasts that teach them.
-- Classic Era (1.12) values from public sources, noted above each section.
-- Forever may differ in places; when it does, Forever wins and the entry is fixed here.
local _, ns = ...

ns.Data = {}

-- Pet families, exactly as UnitCreatureFamily("pet") returns them on an English client.
-- Fox is new in Forever.
ns.Data.Families = { "Bat", "Bear", "Boar", "Carrion Bird", "Cat", "Crab", "Crocolisk", "Fox", "Gorilla", "Hyena", "Owl", "Raptor", "Scorpid", "Spider", "Tallstrider", "Turtle", "Wind Serpent", "Wolf" }

-- Other names the game may use for a family. Wowhead's Forever data calls owls "Bird of
-- Prey", so either name gets the Owl abilities until the game shows which it uses.
ns.Data.FamilyAliases = { ["Bird of Prey"] = "Owl" }

-- Other names the game may use for an ability. ForeverChanges calls the Carrion Bird's
-- Screech "Demoralizing Screech".
ns.Data.AbilityAliases = { ["Demoralizing Screech"] = "Screech" }

-- Each ability's icon in Classic. Tamer prefers the icon the game shows in the pet's
-- spellbook or in Beast Training, and falls back to these.
ns.Data.Icons = {
	["Bite"] = "Interface\\Icons\\Ability_Racial_Cannibalize",
	["Charge"] = "Interface\\Icons\\Ability_Hunter_Pet_Boar",
	["Claw"] = "Interface\\Icons\\Ability_Druid_Rake",
	["Cower"] = "Interface\\Icons\\Ability_Druid_Cower",
	["Dash"] = "Interface\\Icons\\Ability_Druid_Dash",
	["Dive"] = "Interface\\Icons\\Spell_Shadow_BurningSpirit",
	["Furious Howl"] = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
	["Growl"] = "Interface\\Icons\\Ability_Physical_Taunt",
	["Lightning Breath"] = "Interface\\Icons\\Spell_Nature_Lightning",
	["Prowl"] = "Interface\\Icons\\Ability_Druid_SupriseAttack",
	["Scorpid Poison"] = "Interface\\Icons\\Ability_PoisonSting",
	["Screech"] = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
	["Shell Shield"] = "Interface\\Icons\\Ability_Hunter_Pet_Turtle",
	["Thunderstomp"] = "Interface\\Icons\\Ability_Hunter_Pet_Gorilla",
	["Great Stamina"] = "Interface\\Icons\\Spell_Nature_UnyeildingStamina",
	["Natural Armor"] = "Interface\\Icons\\Spell_Nature_SpiritArmor",
	["Arcane Resistance"] = "Interface\\Icons\\Spell_Nature_StarFall",
	["Fire Resistance"] = "Interface\\Icons\\Spell_Fire_FireArmor",
	["Frost Resistance"] = "Interface\\Icons\\Spell_Frost_FrostWard",
	["Nature Resistance"] = "Interface\\Icons\\Spell_Nature_ResistNature",
	["Shadow Resistance"] = "Interface\\Icons\\Spell_Shadow_AntiShadow",
}

-- forever = true marks an ability that's new in Forever, whose training point costs
-- aren't known yet.
--
-- Each ability: where the Hunter learns it ("beast" = tame a wild beast that knows it,
-- "trainer" = a Pet Trainer), which families can learn it ("all" or a list), and its ranks
-- in order, each with the pet level it needs and its training point cost.
--
-- Sources:
--   Rank levels: Wowhead Classic, "Classic Hunter Pet Abilities" list
--     (wowhead.com/classic/spells/pet-abilities/hunter) and the individual spell pages.
--   Training point costs and which families learn what: Wowhead Classic "Hunter Pet Training"
--     calculator (wowhead.com/classic/hunter-pet-training), checked family by family.
--   Beast vs. trainer: warcraft.wiki.gg "Beast Training" (Growl, Great Stamina, Natural Armor and
--     the five resistances come from Pet Trainers; everything else from tamed beasts).
--   Family lists cross-checked against warcraft.wiki.gg "Pet abilities (Classic)".
-- Disagreements:
--   Dive: warcraft.wiki.gg "Pet abilities (Classic)" lists Bat, Carrion Bird, Owl. Wowhead Classic
--     (Dive spell page "Used by Pet" tab and the training calculator) also lists Wind Serpent.
--     Wowhead is used here, so Wind Serpent is included.
--   Shadow Resistance rank 4: Wowhead Classic gives it a required level of 40 (the same as rank 3),
--     while the other four resistances put rank 4 at 50. Kept at 40 as Wowhead shows it; check in game.
--   Growl: warcraft.wiki.gg "Beast Training" says pets know ranks 1-2 by default; ranks 3+ are bought
--     from a Pet Trainer. Every rank costs 0 training points.
-- Most of Forever's new family abilities share these rank levels.
local FAMILY_RANKS = { { level = 12 }, { level = 24 }, { level = 36 }, { level = 48 }, { level = 60 } }

ns.Data.Abilities = {
	-- Beast-taught -----------------------------------------------------------------------
	["Bite"] = {
		source = "beast",
		families = { "Bat", "Bear", "Boar", "Carrion Bird", "Cat", "Crocolisk", "Gorilla", "Hyena", "Raptor", "Spider", "Tallstrider", "Turtle", "Wind Serpent", "Wolf" },
		ranks = {
			{ level = 1, cost = 1 },
			{ level = 8, cost = 4 },
			{ level = 16, cost = 7 },
			{ level = 24, cost = 10 },
			{ level = 32, cost = 13 },
			{ level = 40, cost = 17 },
			{ level = 48, cost = 21 },
			{ level = 56, cost = 25 },
		},
	},
	["Charge"] = {
		source = "beast",
		families = { "Boar" },
		ranks = {
			{ level = 1, cost = 5 },
			{ level = 12, cost = 9 },
			{ level = 24, cost = 13 },
			{ level = 36, cost = 17 },
			{ level = 48, cost = 21 },
			{ level = 60, cost = 25 },
		},
	},
	["Claw"] = {
		source = "beast",
		families = { "Bear", "Carrion Bird", "Cat", "Crab", "Owl", "Raptor", "Scorpid" },
		ranks = {
			{ level = 1, cost = 1 },
			{ level = 8, cost = 4 },
			{ level = 16, cost = 7 },
			{ level = 24, cost = 10 },
			{ level = 32, cost = 13 },
			{ level = 40, cost = 17 },
			{ level = 48, cost = 21 },
			{ level = 56, cost = 25 },
		},
	},
	["Cower"] = {
		source = "beast",
		families = "all",
		ranks = {
			{ level = 5, cost = 8 },
			{ level = 15, cost = 10 },
			{ level = 25, cost = 12 },
			{ level = 35, cost = 14 },
			{ level = 45, cost = 16 },
			{ level = 55, cost = 18 },
		},
	},
	["Dash"] = {
		source = "beast",
		-- Forever adds Bear, Crab, Crocolisk, Gorilla, Raptor, Scorpid, Spider and Turtle.
		families = { "Bear", "Boar", "Cat", "Crab", "Crocolisk", "Gorilla", "Hyena", "Raptor", "Scorpid",
			"Spider", "Tallstrider", "Turtle", "Wolf" },
		ranks = {
			{ level = 30, cost = 15 },
			{ level = 40, cost = 20 },
			{ level = 50, cost = 25 },
		},
	},
	["Dive"] = {
		source = "beast",
		families = { "Bat", "Carrion Bird", "Owl", "Wind Serpent" },
		ranks = {
			{ level = 30, cost = 15 },
			{ level = 40, cost = 20 },
			{ level = 50, cost = 25 },
		},
	},
	["Furious Howl"] = {
		source = "beast",
		families = { "Wolf" },
		ranks = {
			{ level = 10, cost = 10 },
			{ level = 24, cost = 15 },
			{ level = 40, cost = 20 },
			{ level = 56, cost = 25 },
		},
	},
	["Lightning Breath"] = {
		source = "beast",
		families = { "Wind Serpent" },
		ranks = {
			{ level = 1, cost = 1 },
			{ level = 12, cost = 5 },
			{ level = 24, cost = 10 },
			{ level = 36, cost = 15 },
			{ level = 48, cost = 20 },
			{ level = 60, cost = 25 },
		},
	},
	["Prowl"] = {
		source = "beast",
		families = { "Cat" },
		ranks = {
			{ level = 30, cost = 15 },
			{ level = 40, cost = 20 },
			{ level = 50, cost = 25 },
		},
	},
	["Scorpid Poison"] = {
		source = "beast",
		families = { "Scorpid" },
		ranks = {
			{ level = 8, cost = 10 },
			{ level = 24, cost = 15 },
			{ level = 40, cost = 20 },
			{ level = 56, cost = 25 },
		},
	},
	-- Forever took Screech away from bats and owls.
	["Screech"] = {
		source = "beast",
		families = { "Carrion Bird" },
		ranks = {
			{ level = 8, cost = 10 },
			{ level = 24, cost = 15 },
			{ level = 48, cost = 20 },
			{ level = 56, cost = 25 },
		},
	},
	["Shell Shield"] = {
		source = "beast",
		families = { "Turtle" },
		ranks = {
			{ level = 20, cost = 15 },
		},
	},
	["Thunderstomp"] = {
		source = "beast",
		families = { "Gorilla" },
		ranks = {
			{ level = 30, cost = 15 },
			{ level = 40, cost = 20 },
			{ level = 50, cost = 25 },
			-- New in Forever (Wowhead's Forever database). Its cost isn't known yet.
			{ level = 60, newInForever = true },
		},
	},

	-- New in Forever -----------------------------------------------------------------------
	-- Each family below got one ability of its own. Sources: ForeverChanges
	-- (foreverchanges.pro/hunter-pets, build 1.60.1.70938) for families and first and last rank
	-- levels, and Leprestore's Forever rank table for the levels in between. Neither lists
	-- training point costs, so they're left out; Tamer reads them from Beast Training instead.
	-- No beasts that teach them are listed yet.
	["Sonic Blast"] = { source = "beast", families = { "Bat" }, ranks = FAMILY_RANKS, forever = true },
	["Swipe"] = { source = "beast", families = { "Bear" }, ranks = FAMILY_RANKS, forever = true },
	["Pinch"] = { source = "beast", families = { "Crab" }, ranks = FAMILY_RANKS, forever = true },
	["Dismember"] = { source = "beast", families = { "Crocolisk" }, ranks = FAMILY_RANKS, forever = true },
	["Tendon Rip"] = { source = "beast", families = { "Hyena" }, ranks = FAMILY_RANKS, forever = true },
	["Savage Rend"] = { source = "beast", families = { "Raptor" }, ranks = FAMILY_RANKS, forever = true },
	["Web"] = { source = "beast", families = { "Spider" }, ranks = FAMILY_RANKS, forever = true },
	["Dust Cloud"] = { source = "beast", families = { "Tallstrider" }, ranks = FAMILY_RANKS, forever = true },
	["Mine!"] = {
		source = "beast", families = { "Owl" }, forever = true,
		ranks = { { level = 10 }, { level = 20 }, { level = 30 }, { level = 40 }, { level = 50 } },
	},
	["Trickster's Dance"] = { source = "beast", families = { "Fox" }, ranks = { { level = 20 } }, forever = true },

	-- Trainer-taught ---------------------------------------------------------------------
	["Growl"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 1, cost = 0 },
			{ level = 10, cost = 0 },
			{ level = 20, cost = 0 },
			{ level = 30, cost = 0 },
			{ level = 40, cost = 0 },
			{ level = 50, cost = 0 },
			{ level = 60, cost = 0 },
		},
	},
	["Great Stamina"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 1, cost = 5 },
			{ level = 12, cost = 10 },
			{ level = 18, cost = 15 },
			{ level = 24, cost = 25 },
			{ level = 30, cost = 50 },
			{ level = 36, cost = 75 },
			{ level = 42, cost = 100 },
			{ level = 48, cost = 125 },
			{ level = 54, cost = 150 },
			{ level = 60, cost = 185 },
		},
	},
	["Natural Armor"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 1, cost = 1 },
			{ level = 12, cost = 5 },
			{ level = 18, cost = 10 },
			{ level = 24, cost = 15 },
			{ level = 30, cost = 25 },
			{ level = 36, cost = 50 },
			{ level = 42, cost = 75 },
			{ level = 48, cost = 100 },
			{ level = 54, cost = 125 },
			{ level = 60, cost = 150 },
		},
	},
	["Arcane Resistance"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 20, cost = 5 },
			{ level = 30, cost = 15 },
			{ level = 40, cost = 45 },
			{ level = 50, cost = 90 },
		},
	},
	["Fire Resistance"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 20, cost = 5 },
			{ level = 30, cost = 15 },
			{ level = 40, cost = 45 },
			{ level = 50, cost = 90 },
		},
	},
	["Frost Resistance"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 20, cost = 5 },
			{ level = 30, cost = 15 },
			{ level = 40, cost = 45 },
			{ level = 50, cost = 90 },
		},
	},
	["Nature Resistance"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 20, cost = 5 },
			{ level = 30, cost = 15 },
			{ level = 40, cost = 45 },
			{ level = 50, cost = 90 },
		},
	},
	["Shadow Resistance"] = {
		source = "trainer",
		families = "all",
		ranks = {
			{ level = 20, cost = 5 },
			{ level = 30, cost = 15 },
			{ level = 40, cost = 45 },
			{ level = 40, cost = 90 }, -- Wowhead Classic says 40; the other resistances use 50 here
		},
	},
}

-- Wild beasts that teach a rank. level = { min, max }. teaches = { { "Ability", rank }, ... }
--
-- Sources:
--   Which beast teaches which rank: the "Taught by" tab on Wowhead's spell page for each rank
--     (wowhead.com/forever/spell=<id>; Wowhead Classic's spell pages don't have this tab, the
--     Forever ones do). Only beasts that also exist in Classic Era were kept.
--   Name, level and zone: Wowhead Classic hunter pet family pages (wowhead.com/classic/pet=<id>,
--     e.g. "Boar - Hunter Pet"). Where a beast spans more than one zone, the first one is used.
--   Where Wowhead's Forever level range differs from Classic, the Classic range is used and the
--     Forever range is noted on the line.
ns.Data.Beasts = {
	-- Bite
	{ name = "Gray Forest Wolf", family = "Wolf", level = { 7, 8 }, zone = "Elwynn Forest", teaches = { { "Bite", 1 } } },
	{ name = "Webwood Venomfang", family = "Spider", level = { 7, 8 }, zone = "Teldrassil", teaches = { { "Bite", 1 } } },
	{ name = "Prairie Stalker", family = "Wolf", level = { 7, 8 }, zone = "Mulgore", teaches = { { "Bite", 1 } } },
	{ name = "Dreadmaw Crocolisk", family = "Crocolisk", level = { 9, 11 }, zone = "Durotar", teaches = { { "Bite", 1 } } },
	{ name = "Coyote", family = "Wolf", level = { 10, 11 }, zone = "Westfall", teaches = { { "Bite", 2 } } },
	{ name = "Giant Webwood Spider", family = "Spider", level = { 10, 11 }, zone = "Teldrassil", teaches = { { "Bite", 2 } } },
	{ name = "Worg", family = "Wolf", level = { 10, 11 }, zone = "Silverpine Forest", teaches = { { "Bite", 2 }, { "Furious Howl", 1 } } },
	{ name = "Oasis Snapjaw", family = "Turtle", level = { 15, 16 }, zone = "The Barrens", teaches = { { "Bite", 2 } } },
	{ name = "Wood Lurker", family = "Spider", level = { 17, 18 }, zone = "Loch Modan", teaches = { { "Bite", 3 } } },
	{ name = "Greater Tarantula", family = "Spider", level = { 19, 20 }, zone = "Redridge Mountains", teaches = { { "Bite", 3 } } },
	{ name = "Bloodsnout Worg", family = "Wolf", level = { 16, 17 }, zone = "Silverpine Forest", teaches = { { "Bite", 3 } } },
	{ name = "Deepmoss Creeper", family = "Spider", level = { 16, 17 }, zone = "Stonetalon Mountains", teaches = { { "Bite", 3 } } },
	{ name = "Black Ravager", family = "Wolf", level = { 24, 25 }, zone = "Duskwood", teaches = { { "Bite", 4 } } },
	{ name = "Giant Wetlands Crocolisk", family = "Crocolisk", level = { 25, 26 }, zone = "Wetlands", teaches = { { "Bite", 4 } } },
	{ name = "Giant Moss Creeper", family = "Spider", level = { 24, 25 }, zone = "Hillsbrad Foothills", teaches = { { "Bite", 4 } } },
	{ name = "Ghostpaw Alpha", family = "Wolf", level = { 27, 28 }, zone = "Ashenvale", teaches = { { "Bite", 4 }, { "Furious Howl", 2 } } },
	{ name = "Plains Creeper", family = "Spider", level = { 32, 33 }, zone = "Arathi Highlands", teaches = { { "Bite", 5 } } },
	{ name = "Sparkleshell Snapper", family = "Turtle", level = { 34, 35 }, zone = "Thousand Needles", teaches = { { "Bite", 5 } } },
	{ name = "Drywallow Crocolisk", family = "Crocolisk", level = { 35, 36 }, zone = "Dustwallow Marsh", teaches = { { "Bite", 5 } } },
	{ name = "Deathstrike Tarantula", family = "Spider", level = { 40, 41 }, zone = "Swamp of Sorrows", teaches = { { "Bite", 6 } } },
	{ name = "Drywallow Daggermaw", family = "Crocolisk", level = { 40, 41 }, zone = "Dustwallow Marsh", teaches = { { "Bite", 6 } } },
	{ name = "Longtooth Runner", family = "Wolf", level = { 40, 41 }, zone = "Feralas", teaches = { { "Bite", 6 }, { "Dash", 2 }, { "Furious Howl", 3 } } },
	{ name = "Saltwater Snapjaw", family = "Turtle", level = { 49, 50 }, zone = "The Hinterlands", teaches = { { "Bite", 7 } } },
	{ name = "Felpaw Ravager", family = "Wolf", level = { 51, 52 }, zone = "Felwood", teaches = { { "Bite", 7 } } },

	-- Claw
	{ name = "Ice Claw Bear", family = "Bear", level = { 7, 8 }, zone = "Dun Morogh", teaches = { { "Claw", 1 } } },
	{ name = "Strigid Owl", family = "Owl", level = { 5, 6 }, zone = "Teldrassil", teaches = { { "Claw", 1 } } },
	{ name = "Swoop", family = "Carrion Bird", level = { 7, 9 }, zone = "Mulgore", teaches = { { "Claw", 1 } } },
	{ name = "Pygmy Surf Crawler", family = "Crab", level = { 5, 6 }, zone = "Durotar", teaches = { { "Claw", 1 } } },
	{ name = "Young Forest Bear", family = "Bear", level = { 8, 9 }, zone = "Elwynn Forest", teaches = { { "Claw", 2 } } },
	{ name = "Thistle Bear", family = "Bear", level = { 11, 12 }, zone = "Darkshore", teaches = { { "Claw", 2 } } },
	{ name = "Ferocious Grizzled Bear", family = "Bear", level = { 11, 12 }, zone = "Silverpine Forest", teaches = { { "Claw", 2 } } },
	{ name = "Venomtail Scorpid", family = "Scorpid", level = { 9, 10 }, zone = "Durotar", teaches = { { "Claw", 2 } } },
	{ name = "Black Bear Patriarch", family = "Bear", level = { 16, 17 }, zone = "Loch Modan", teaches = { { "Claw", 3 } } },
	{ name = "Shore Crawler", family = "Crab", level = { 17, 18 }, zone = "Westfall", teaches = { { "Claw", 3 } } },
	{ name = "Ashenvale Bear", family = "Bear", level = { 21, 22 }, zone = "Ashenvale", teaches = { { "Claw", 3 } } },
	{ name = "Gray Bear", family = "Bear", level = { 21, 22 }, zone = "Hillsbrad Foothills", teaches = { { "Claw", 3 } } },
	{ name = "Elder Ashenvale Bear", family = "Bear", level = { 25, 26 }, zone = "Ashenvale", teaches = { { "Claw", 4 } } },
	{ name = "Scorpashi Snapper", family = "Scorpid", level = { 30, 31 }, zone = "Desolace", teaches = { { "Claw", 4 } } },
	{ name = "Scorpid Reaver", family = "Scorpid", level = { 31, 32 }, zone = "Thousand Needles", teaches = { { "Claw", 4 } } },
	{ name = "Scorpashi Lasher", family = "Scorpid", level = { 34, 35 }, zone = "Desolace", teaches = { { "Claw", 5 } } },
	{ name = "Ironfur Bear", family = "Bear", level = { 41, 42 }, zone = "Feralas", teaches = { { "Claw", 6 }, { "Swipe", 3 } } },
	{ name = "Scorpid Hunter", family = "Scorpid", level = { 40, 41 }, zone = "Tanaris", teaches = { { "Claw", 6 } } },
	{ name = "Silt Crawler", family = "Crab", level = { 40, 41 }, zone = "Swamp of Sorrows", teaches = { { "Claw", 6 } } },
	{ name = "Ironfur Patriarch", family = "Bear", level = { 48, 49 }, zone = "Feralas", teaches = { { "Claw", 7 } } },
	{ name = "Angerclaw Mauler", family = "Bear", level = { 49, 50 }, zone = "Felwood", teaches = { { "Claw", 7 }, { "Swipe", 4 } } },
	{ name = "Ironbeak Hunter", family = "Owl", level = { 50, 51 }, zone = "Felwood", teaches = { { "Claw", 7 } } },
	{ name = "Elder Shardtooth", family = "Bear", level = { 57, 58 }, zone = "Winterspring", teaches = { { "Claw", 8 } } },
	{ name = "Winterspring Screecher", family = "Owl", level = { 57, 59 }, zone = "Winterspring", teaches = { { "Claw", 8 }, { "Mine!", 5 } } }, -- Forever: 57-60

	-- Charge
	{ name = "Longsnout", family = "Boar", level = { 10, 11 }, zone = "Elwynn Forest", teaches = { { "Charge", 1 } } },
	{ name = "Mountain Boar", family = "Boar", level = { 10, 11 }, zone = "Loch Modan", teaches = { { "Charge", 1 } } },
	{ name = "Elder Mottled Boar", family = "Boar", level = { 8, 9 }, zone = "Durotar", teaches = { { "Charge", 1 } } },
	{ name = "Battleboar", family = "Boar", level = { 3, 4 }, zone = "Mulgore", teaches = { { "Charge", 1 } } },
	{ name = "Young Goretusk", family = "Boar", level = { 12, 13 }, zone = "Westfall", teaches = { { "Charge", 2 } } },
	{ name = "Goretusk", family = "Boar", level = { 14, 15 }, zone = "Westfall", teaches = { { "Charge", 2 } } },
	{ name = "Mangy Mountain Boar", family = "Boar", level = { 14, 15 }, zone = "Loch Modan", teaches = { { "Charge", 2 } } },
	{ name = "Great Goretusk", family = "Boar", level = { 16, 17 }, zone = "Redridge Mountains", teaches = { { "Charge", 2 } } },
	{ name = "Bellygrub", family = "Boar", level = { 24, 24 }, zone = "Redridge Mountains", teaches = { { "Charge", 3 } } },

	-- Cower
	{ name = "Foreststrider Fledgling", family = "Tallstrider", level = { 11, 13 }, zone = "Darkshore", teaches = { { "Cower", 1 } } },
	{ name = "Fleeting Plainstrider", family = "Tallstrider", level = { 12, 13 }, zone = "The Barrens", teaches = { { "Cower", 1 } } },
	{ name = "Juvenile Snow Leopard", family = "Cat", level = { 5, 6 }, zone = "Dun Morogh", teaches = { { "Cower", 1 } } },
	{ name = "Durotar Tiger", family = "Cat", level = { 7, 8 }, zone = "Durotar", teaches = { { "Cower", 1 } } }, -- Forever: 4-8
	{ name = "Moonstalker Sire", family = "Cat", level = { 17, 18 }, zone = "Darkshore", teaches = { { "Cower", 2 } } },
	{ name = "Ornery Plainstrider", family = "Tallstrider", level = { 16, 17 }, zone = "The Barrens", teaches = { { "Cower", 2 } } },
	{ name = "Starving Mountain Lion", family = "Cat", level = { 23, 24 }, zone = "Hillsbrad Foothills", teaches = { { "Cower", 2 } } },
	{ name = "Twilight Runner", family = "Cat", level = { 23, 24 }, zone = "Stonetalon Mountains", teaches = { { "Cower", 2 } } },
	{ name = "Crag Stalker", family = "Cat", level = { 25, 26 }, zone = "Thousand Needles", teaches = { { "Cower", 3 } } },
	{ name = "Feral Mountain Lion", family = "Cat", level = { 27, 28 }, zone = "Hillsbrad Foothills", teaches = { { "Cower", 3 } } },
	{ name = "Young Stranglethorn Tiger", family = "Cat", level = { 30, 31 }, zone = "Stranglethorn Vale", teaches = { { "Cower", 3 } } },
	{ name = "Young Panther", family = "Cat", level = { 30, 31 }, zone = "Stranglethorn Vale", teaches = { { "Cower", 3 } } },
	{ name = "Ridge Stalker", family = "Cat", level = { 36, 37 }, zone = "Badlands", teaches = { { "Cower", 4 }, { "Prowl", 1 } } },
	{ name = "Ridge Huntress", family = "Cat", level = { 38, 39 }, zone = "Badlands", teaches = { { "Cower", 4 } } },
	{ name = "Frostsaber Cub", family = "Cat", level = { 55, 56 }, zone = "Winterspring", teaches = { { "Cower", 6 } } },

	-- Dash
	{ name = "Stranglethorn Tiger", family = "Cat", level = { 32, 33 }, zone = "Stranglethorn Vale", teaches = { { "Dash", 1 } } },
	{ name = "Kurzen War Tiger", family = "Cat", level = { 32, 33 }, zone = "Stranglethorn Vale", teaches = { { "Dash", 1 } } },
	{ name = "Bonepaw Hyena", family = "Hyena", level = { 33, 35 }, zone = "Desolace", teaches = { { "Dash", 1 } } },
	{ name = "Crag Coyote", family = "Wolf", level = { 35, 36 }, zone = "Badlands", teaches = { { "Dash", 1 }, { "Bite", 5 } } },
	{ name = "Ridge Stalker Patriarch", family = "Cat", level = { 40, 41 }, zone = "Badlands", teaches = { { "Dash", 2 }, { "Prowl", 2 } } },
	{ name = "Starving Blisterpaw", family = "Hyena", level = { 41, 42 }, zone = "Tanaris", teaches = { { "Dash", 2 } } },
	{ name = "Elder Shadowmaw Panther", family = "Cat", level = { 42, 43 }, zone = "Stranglethorn Vale", teaches = { { "Dash", 2 }, { "Prowl", 2 } } },
	{ name = "Frostsaber Huntress", family = "Cat", level = { 58, 59 }, zone = "Winterspring", teaches = { { "Dash", 3 } } },
	{ name = "Frostsaber Stalker", family = "Cat", level = { 59, 60 }, zone = "Winterspring", teaches = { { "Dash", 3 }, { "Prowl", 3 } } },

	-- Lightning Breath and Thunderstomp
	-- Which rank each teaches comes from the beasts' own warcraft.wiki.gg pages ("Deviate Venomwing",
	-- "Deviate Dreadfang", "Jungle Thunderer"); level and zone from the Wowhead Classic family pages.
	-- warcraft.wiki.gg gives Deviate Venomwing as level 19; Wowhead Classic says 20-21 (used here).
	{ name = "Deviate Venomwing", family = "Wind Serpent", level = { 20, 21 }, zone = "Wailing Caverns", teaches = { { "Lightning Breath", 2 } } },
	{ name = "Deviate Dreadfang", family = "Wind Serpent", level = { 20, 21 }, zone = "Wailing Caverns", teaches = { { "Lightning Breath", 2 } } },
	{ name = "Jungle Thunderer", family = "Gorilla", level = { 37, 38 }, zone = "Stranglethorn Vale", teaches = { { "Thunderstomp", 1 } } },

	-- Forever ---------------------------------------------------------------------------
	-- Teachers for ranks the list above had none for, including Forever's new family
	-- abilities. Source: the "Taught by" tab of each rank's spell page on Wowhead's Forever
	-- database (wowhead.com/forever/spell=<id>), read 2026-11-27, with Forever's levels and
	-- zones. Up to four per rank, normal beasts before rare ones, lowest level first. Beasts
	-- only in zones Wowhead didn't name (such as Mount Hyjal) are left out.
	{ name = "Rabid Shardtooth", family = "Bear", level = { 59, 60 }, zone = "Winterspring", teaches = { { "Bite", 8 }, { "Swipe", 5 } } },
	{ name = "Giant Moonstrider", family = "Tallstrider", level = { 60, 60 }, zone = "Moonglade", teaches = { { "Bite", 8 } } },
	{ name = "Coyote Packleader", family = "Wolf", level = { 11, 12 }, zone = "Westfall", teaches = { { "Furious Howl", 1 } } },
	{ name = "Coldrasp", family = "Wolf", level = { 12, 12 }, zone = "Tirisfal Glades", teaches = { { "Furious Howl", 1 } } }, -- rare
	{ name = "Gorefang", family = "Wolf", level = { 13, 13 }, zone = "Silverpine Forest", teaches = { { "Furious Howl", 1 } } }, -- rare
	{ name = "Black Ravager Mastiff", family = "Wolf", level = { 25, 26 }, zone = "Duskwood", teaches = { { "Furious Howl", 2 } } },
	{ name = "Elder Crag Coyote", family = "Wolf", level = { 39, 40 }, zone = "Badlands", teaches = { { "Furious Howl", 2 } } },
	{ name = "Longtooth Howler", family = "Wolf", level = { 43, 44 }, zone = "Feralas", teaches = { { "Furious Howl", 2 } } },
	{ name = "Silvermane Wolf", family = "Wolf", level = { 43, 44 }, zone = "The Hinterlands", teaches = { { "Furious Howl", 3 } } },
	{ name = "Felpaw Wolf", family = "Wolf", level = { 47, 48 }, zone = "Felwood", teaches = { { "Furious Howl", 3 } } },
	{ name = "Child of Jai'vhanel", family = "Owl", level = { 10, 12 }, zone = "Darkshore", teaches = { { "Mine!", 1 } } },
	{ name = "Jai'vhanel", family = "Owl", level = { 12, 12 }, zone = "Darkshore", teaches = { { "Mine!", 1 } } },
	{ name = "Nightscreech", family = "Owl", level = { 10, 10 }, zone = "Teldrassil", teaches = { { "Mine!", 1 } } }, -- rare
	{ name = "Carrodin", family = "Owl", level = { 25, 25 }, zone = "Wetlands", teaches = { { "Mine!", 2 } } }, -- rare
	{ name = "Marsh Owl", family = "Owl", level = { 34, 36 }, zone = "Alterac Mountains", teaches = { { "Mine!", 3 } } },
	{ name = "Ironbeak Owl", family = "Owl", level = { 48, 49 }, zone = "Felwood", teaches = { { "Mine!", 4 } } },
	{ name = "Winterspring Owl", family = "Owl", level = { 54, 56 }, zone = "Winterspring", teaches = { { "Mine!", 4 } } },
	{ name = "Mountain Lion", family = "Cat", level = { 32, 33 }, zone = "Alterac Mountains", teaches = { { "Prowl", 1 } } },
	{ name = "Shadowmaw Panther", family = "Cat", level = { 37, 38 }, zone = "Stranglethorn Vale", teaches = { { "Prowl", 1 } } },
	{ name = "Shadow Panther", family = "Cat", level = { 39, 40 }, zone = "Swamp of Sorrows", teaches = { { "Prowl", 1 } } },
	{ name = "King Bangalash", family = "Cat", level = { 43, 43 }, zone = "Stranglethorn Vale", teaches = { { "Prowl", 2 } } }, -- rare
	{ name = "Jaguero Stalker", family = "Cat", level = { 50, 50 }, zone = "Stranglethorn Vale", teaches = { { "Prowl", 3 } } },
	{ name = "Sunscale Screecher", family = "Raptor", level = { 13, 15 }, zone = "The Barrens", teaches = { { "Savage Rend", 1 } } },
	{ name = "Highland Raptor", family = "Raptor", level = { 23, 24 }, zone = "Wetlands", teaches = { { "Savage Rend", 2 } } },
	{ name = "Highland Lashtail", family = "Raptor", level = { 24, 25 }, zone = "Wetlands", teaches = { { "Savage Rend", 2 } } },
	{ name = "Mottled Screecher", family = "Raptor", level = { 24, 25 }, zone = "Wetlands", teaches = { { "Savage Rend", 2 } } },
	{ name = "Highland Scytheclaw", family = "Raptor", level = { 25, 26 }, zone = "Wetlands", teaches = { { "Savage Rend", 2 } } },
	{ name = "Bloodfen Screecher", family = "Raptor", level = { 36, 37 }, zone = "Dustwallow Marsh", teaches = { { "Savage Rend", 3 } } },
	{ name = "Highland Fleshstalker", family = "Raptor", level = { 36, 37 }, zone = "Arathi Highlands", teaches = { { "Savage Rend", 3 } } },
	{ name = "Young Jungle Stalker", family = "Raptor", level = { 36, 37 }, zone = "Stranglethorn Vale", teaches = { { "Savage Rend", 3 } } },
	{ name = "Bloodfen Scytheclaw", family = "Raptor", level = { 37, 38 }, zone = "Dustwallow Marsh", teaches = { { "Savage Rend", 3 } } },
	{ name = "Venomhide Ravasaur", family = "Raptor", level = { 50, 51 }, zone = "Un'Goro Crater", teaches = { { "Savage Rend", 5 } } },
	{ name = "Taloned Swoop", family = "Carrion Bird", level = { 8, 10 }, zone = "Mulgore", teaches = { { "Screech", 1 } } },
	{ name = "Young Fleshripper", family = "Carrion Bird", level = { 10, 11 }, zone = "Westfall", teaches = { { "Screech", 1 } } },
	{ name = "Greater Fleshripper", family = "Carrion Bird", level = { 16, 17 }, zone = "Westfall", teaches = { { "Screech", 1 } } },
	{ name = "Lord Condar", family = "Carrion Bird", level = { 15, 16 }, zone = "Loch Modan", teaches = { { "Screech", 1 } } }, -- rare
	{ name = "Salt Flats Vulture", family = "Carrion Bird", level = { 32, 34 }, zone = "Thousand Needles", teaches = { { "Screech", 2 } } },
	{ name = "Dread Ripper", family = "Carrion Bird", level = { 39, 40 }, zone = "Desolace", teaches = { { "Screech", 2 } } },
	{ name = "Gharrik", family = "Carrion Bird", level = { 40, 40 }, zone = "Badlands", teaches = { { "Screech", 2 } } },
	{ name = "Zopilote", family = "Carrion Bird", level = { 43, 43 }, zone = "Tanaris", teaches = { { "Screech", 2 } } }, -- rare
	{ name = "Carrion Vulture", family = "Carrion Bird", level = { 50, 52 }, zone = "Western Plaguelands", teaches = { { "Screech", 3 } } },
	{ name = "Giant Grizzled Bear", family = "Bear", level = { 12, 13 }, zone = "Silverpine Forest", teaches = { { "Swipe", 1 } } },
	{ name = "Grizzled Black Bear", family = "Bear", level = { 13, 14 }, zone = "Loch Modan", teaches = { { "Swipe", 1 } } },
	{ name = "Old Vicejaw", family = "Bear", level = { 14, 14 }, zone = "Silverpine Forest", teaches = { { "Swipe", 1 } } }, -- rare
	{ name = "Elder Gray Bear", family = "Bear", level = { 25, 26 }, zone = "Hillsbrad Foothills", teaches = { { "Swipe", 2 } } },
	{ name = "Maddened Rotclaw", family = "Bear", level = { 25, 26 }, zone = "Wetlands", teaches = { { "Swipe", 2 } } },
	{ name = "Big Samras", family = "Bear", level = { 27, 27 }, zone = "Hillsbrad Foothills", teaches = { { "Swipe", 2 } } }, -- rare
	{ name = "Grizzled Ironfur Bear", family = "Bear", level = { 44, 45 }, zone = "Feralas", teaches = { { "Swipe", 3 } } },
	{ name = "Angerclaw Bear", family = "Bear", level = { 47, 48 }, zone = "Felwood", teaches = { { "Swipe", 3 } } },
	{ name = "Ursius", family = "Bear", level = { 56, 56 }, zone = "Winterspring", teaches = { { "Swipe", 5 } } }, -- rare
	{ name = "Gray Fox", family = "Fox", level = { 22, 23 }, zone = "Duskwood", teaches = { { "Trickster's Dance", 1 } } },
	{ name = "Moss Stalker", family = "Spider", level = { 12, 13 }, zone = "Silverpine Forest", teaches = { { "Web", 1 } } },
	{ name = "Cliff Lurker", family = "Spider", level = { 13, 14 }, zone = "Loch Modan", teaches = { { "Web", 1 } } },
	{ name = "Mist Creeper", family = "Spider", level = { 13, 14 }, zone = "Silverpine Forest", teaches = { { "Web", 1 } } },
	{ name = "Deepmoss Hatchling", family = "Spider", level = { 14, 14 }, zone = "Stonetalon Mountains", teaches = { { "Web", 1 } } },
}
