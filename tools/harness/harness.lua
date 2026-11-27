-- Headless smoke test for Tamer: stubs the WoW API, loads the addon the way the
-- client does (TOC order, missing files skipped), and drives its flows.
-- It proves the addon's Lua logic, NOT that the stubbed APIs exist in the client.
--
-- Run it with LuaJIT or any Lua 5.1:
--   luajit tools/harness/harness.lua [addon folder]
-- The addon folder defaults to addon/Tamer next to this tools folder.
local scriptDir = (arg and arg[0] or ""):match("^(.*)[/\\]") or "."
local ADDON_DIR = ADDON_DIR or (arg and arg[1]) or (scriptDir .. "/../../addon/Tamer")
local ADDON = "Tamer"
local realG = _G
local stdPrint = print

local passed, failed = 0, 0
local failures = {}
local function check(name, cond, detail)
	if cond then
		passed = passed + 1
	else
		failed = failed + 1
		failures[#failures + 1] = name .. (detail and (" -- " .. tostring(detail)) or "")
		stdPrint("  FAIL " .. name .. (detail and (" -- " .. tostring(detail)) or ""))
	end
end

local function section(name, fn)
	stdPrint(name)
	local ok, err = pcall(fn)
	check(name .. " runs without errors", ok, err)
end

-------------------------------------------------------------------------------
-- World state the stubs read from
-------------------------------------------------------------------------------

local W = {
	class = "HUNTER", playerName = "Testhunter", realm = "Forever", playerLevel = 15,
	pet = { name = "Behr", level = 15, family = "Bear", xp = 1200, xpMax = 3400, total = 14, spent = 2 },
	petSpells = { { "Claw", "Rank 2" }, { "Bite", "Rank 1" }, { "Growl", "Rank 1" }, { "Attack", "" } },
	crafts = {},
	time = 0,
}

local chatOut = {}
local unknownGlobals = {}

-------------------------------------------------------------------------------
-- Frames
-------------------------------------------------------------------------------

local eventFrames = {}
local allFrames = {}

local frameMethods = {}
frameMethods.__index = function(self, key)
	local method = rawget(frameMethods, key)
	if method then return method end
	-- Unmodelled API methods (always capitalized) are no-ops; data fields are nil.
	if type(key) == "string" and key:find("^%u") then
		return function() end
	end
	return nil
end

local function newObject(parent)
	local object = setmetatable({ _scripts = {}, _events = {}, _parent = parent, _width = 0, _height = 0 }, frameMethods)
	allFrames[#allFrames + 1] = object
	return object
end

function frameMethods:SetScript(what, fn) self._scripts[what] = fn end
function frameMethods:GetScript(what) return self._scripts[what] end
function frameMethods:HookScript(what, fn)
	local old = self._scripts[what]
	self._scripts[what] = function(...)
		if old then old(...) end
		fn(...)
	end
end
function frameMethods:RegisterEvent(event)
	self._events[event] = true
	eventFrames[#eventFrames + 1] = self
end
function frameMethods:Show()
	if self._hidden then
		self._hidden = false
		if self._scripts.OnShow then self._scripts.OnShow(self) end
	end
end
function frameMethods:Hide()
	if not self._hidden then
		self._hidden = true
		if self._scripts.OnHide then self._scripts.OnHide(self) end
	end
end
function frameMethods:SetShown(shown) if shown then self:Show() else self:Hide() end end
function frameMethods:IsShown() return not self._hidden end
function frameMethods:SetAlpha(a) self._alpha = a end
function frameMethods:GetAlpha() return self._alpha or 1 end
function frameMethods:SetAttribute(key, value) self._attributes = self._attributes or {}; self._attributes[key] = value end
function frameMethods:GetAttribute(key) return self._attributes and self._attributes[key] end
function frameMethods:SetSize(w, h) self._width, self._height = w, h end
function frameMethods:SetWidth(w) self._width = w end
function frameMethods:SetHeight(h) self._height = h end
function frameMethods:GetWidth() return self._width end
function frameMethods:GetHeight() return self._height end
function frameMethods:GetCenter() return 0, 0 end
function frameMethods:GetEffectiveScale() return 1 end
function frameMethods:GetPoint() return "CENTER", nil, "CENTER", 10, 20 end
function frameMethods:GetVerticalScroll() return 0 end
function frameMethods:GetVerticalScrollRange() return 0 end
function frameMethods:SetText(text) self._text = text ~= nil and tostring(text) or nil end
function frameMethods:GetText() return self._text end
function frameMethods:GetStringHeight()
	return 12 * math.max(1, math.ceil(#(self._text or "") / 50))
end
function frameMethods:CreateFontString()
	local fs = newObject(self)
	fs._isText = true
	return fs
end
function frameMethods:CreateTexture() return newObject(self) end

local function effectiveShown(f)
	while f do
		if f._hidden then return false end
		f = f._parent
	end
	return true
end

local function isInside(f, ancestor)
	while f do
		if f == ancestor then return true end
		f = f._parent
	end
	return false
end

local namedFrames = {}
local function createFrame(_, name, parent)
	local f = newObject(parent)
	if name then namedFrames[name] = f end
	return f
end

local function fire(event, ...)
	for _, f in ipairs(eventFrames) do
		if f._events[event] and f._scripts.OnEvent then
			f._scripts.OnEvent(f, event, ...)
		end
	end
end

-------------------------------------------------------------------------------
-- The game's globals
-------------------------------------------------------------------------------

local stubs = {
	CreateFrame = createFrame,
	print = function(...)
		local parts = {}
		for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
		chatOut[#chatOut + 1] = table.concat(parts, " ")
	end,
	C_AddOns = {
		GetAddOnMetadata = function(name, field)
			if name == ADDON and field == "Version" then return "0.0.0-test" end
		end,
	},
	SlashCmdList = {},
	UISpecialFrames = {},
	tinsert = table.insert,
	unpack = unpack,
	UIParent = newObject(nil),
	Minimap = newObject(nil),
	GameTooltip = (function()
		local tip = newObject(nil)
		tip._lines = {}
		tip.SetOwner = function(self) self._lines = {} end
		tip.SetText = function(self, text) self._lines = { text } end
		tip.AddLine = function(self, text) self._lines[#self._lines + 1] = text end
		return tip
	end)(),
	SOUNDKIT = {},
	PlaySound = function() end,
	GetCursorPosition = function() return 0, 0 end,
	BOOKTYPE_PET = "pet",
	ERR_LEARN_SPELL_S = "You have learned a new spell: %s.",
	ERR_LEARN_ABILITY_S = "You have learned a new ability: %s.",

	issecretvalue = function() return false end,
	GetTime = function() return W.time end,
	UnitClass = function(unit)
		if unit == "player" then return W.class, W.class end
	end,
	UnitName = function(unit)
		if unit == "player" then return W.playerName end
		if unit == "pet" and W.pet then return W.pet.name end
	end,
	UnitLevel = function(unit)
		if unit == "player" then return W.playerLevel end
		if unit == "pet" and W.pet then return W.pet.level end
	end,
	UnitExists = function(unit)
		if unit == "player" then return true end
		if unit == "pet" then return W.pet ~= nil end
	end,
	UnitCreatureFamily = function(unit)
		if unit == "pet" and W.pet then return W.pet.family end
	end,
	GetRealmName = function() return W.realm end,
	GetPetExperience = function()
		if W.pet then return W.pet.xp, W.pet.xpMax end
		return 0, 0
	end,
	GetPetTrainingPoints = function()
		if W.pet then return W.pet.total, W.pet.spent end
		return 0, 0
	end,
	HasPetSpells = function()
		if W.pet then return #W.petSpells, "PET" end
	end,
	GetSpellBookItemName = function(index, book)
		if book ~= "pet" then return nil end
		local spell = W.petSpells[index]
		if spell then return spell[1], spell[2] end
	end,
	GetNumCrafts = function() return #W.crafts end,
	GetCraftInfo = function(index)
		local c = W.crafts[index]
		if c then return c[1], c[2], c[3] or "optimal", 0, true, c[4], c[5] end
	end,
}

local env = setmetatable({}, {
	__index = function(_, key)
		local value = stubs[key]
		if value ~= nil then return value end
		value = namedFrames[key]
		if value ~= nil then return value end
		value = realG[key]
		if value == nil then unknownGlobals[key] = true end
		return value
	end,
})
for k, v in pairs(stubs) do env[k] = v end
env._G = env

-------------------------------------------------------------------------------
-- Loading
-------------------------------------------------------------------------------

local function tocFiles()
	local files = {}
	local toc = assert(io.open(ADDON_DIR .. "/" .. ADDON .. ".toc"), "no TOC in " .. ADDON_DIR)
	for line in toc:lines() do
		line = line:gsub("\r$", "")
		if line:match("%.lua$") and not line:match("^#") then files[#files + 1] = line end
	end
	toc:close()
	return files
end

local ns = {}
for _, file in ipairs(tocFiles()) do
	local chunk, err = loadfile(ADDON_DIR .. "/" .. file)
	check("finds and parses " .. file, chunk ~= nil, err)
	if chunk then
		setfenv(chunk, env)
		local ok, runErr = pcall(chunk, ADDON, ns)
		check("loads " .. file, ok, runErr)
	end
end

local realData = ns.Data

-- Small, fixed data for the flow checks, so they don't change when the real list does.
local TEST_DATA = {
	Families = { "Bear", "Cat", "Wolf" },
	Abilities = {
		Claw = { source = "beast", families = { "Bear", "Cat" }, ranks = {
			{ level = 1, cost = 1 }, { level = 8, cost = 5 }, { level = 16, cost = 10 }, { level = 24, cost = 15 },
		} },
		Bite = { source = "beast", families = { "Bear", "Wolf" }, ranks = {
			{ level = 1, cost = 1 }, { level = 8, cost = 4 }, { level = 16, cost = 8 },
		} },
		Dash = { source = "beast", families = { "Cat", "Wolf" }, ranks = {
			{ level = 30, cost = 5 }, { level = 40, cost = 10 },
		} },
		Growl = { source = "trainer", families = "all", ranks = {
			{ level = 1, cost = 1 }, { level = 10, cost = 3 }, { level = 20, cost = 5 },
		} },
	},
	Beasts = {
		{ name = "Test Bear A", family = "Bear", level = { 14, 15 }, zone = "Loch Modan", teaches = { { "Claw", 3 } } },
		{ name = "Test Bear B", family = "Bear", level = { 20, 21 }, zone = "Wetlands", teaches = { { "Claw", 3 } } },
		{ name = "Test Bear C", family = "Bear", level = { 18, 19 }, zone = "Redridge Mountains", teaches = { { "Claw", 3 } } },
		{ name = "Test Bear D", family = "Bear", level = { 12, 13 }, zone = "Dun Morogh", teaches = { { "Claw", 3 }, { "Bite", 2 } } },
		{ name = "Test Cat", family = "Cat", level = { 7, 8 }, zone = "Teldrassil", teaches = { { "Claw", 2 } } },
	},
}

local function hunterKnows(spec)
	local known = {}
	for ability, list in pairs(spec) do
		known[ability] = {}
		for _, rank in ipairs(list) do known[ability][rank] = {} end
	end
	return known
end

local function names(list)
	local out = {}
	for i, entry in ipairs(list) do out[i] = entry.ability .. " " .. entry.rank end
	return table.concat(out, ", ")
end

-------------------------------------------------------------------------------
-- The advisor
-------------------------------------------------------------------------------

section("The advisor", function()
	local A = ns.Advisor
	local behr = { name = "Behr", family = "Bear", level = 15, points = 12 }
	local input = {
		pet = behr,
		petRanks = { Claw = 2, Bite = 1, Growl = 1 },
		hunterRanks = hunterKnows({ Claw = { 1, 2 }, Bite = { 1, 2 }, Growl = { 1, 2, 3 } }),
		playerLevel = 15,
		data = TEST_DATA,
	}
	local advice = A.Build(input)

	check("lists the family's abilities only", table.concat(A.FamilyAbilities(TEST_DATA, "Bear"), ",") == "Bite,Claw,Growl")
	check("known: what the pet has", names(advice.known) == "Bite 1, Claw 2, Growl 1", names(advice.known))
	check("ready: ranks you know, at the pet's level, that it can afford", names(advice.ready) == "Bite 2, Growl 2", names(advice.ready))
	check("ready: costs only the difference from the pet's rank", advice.ready[1].cost == 3 and advice.ready[2].cost == 2,
		tostring(advice.ready[1].cost) .. "/" .. tostring(advice.ready[2].cost))
	check("needs points: nothing while points are plentiful", #advice.needsPoints == 0)
	check("next upgrade: a rank you know that needs a higher level", names(advice.nextUp) == "Growl 3" and advice.nextUp[1].level == 20, names(advice.nextUp))
	check("go learn it: the next rank you don't know, lowest level first", names(advice.goLearn) == "Bite 3, Claw 3", names(advice.goLearn))
	check("go learn it: never the family's abilities it can't learn", not names(advice.goLearn):find("Dash"))
	check("no Beast Training prompt once it's been seen", not advice.needsBeastTraining)

	local claw = advice.goLearn[2]
	local beastNames = {}
	for i, beast in ipairs(claw.beasts) do beastNames[i] = beast.name end
	check("teachers: at most three, tameable first, nearest your level first",
		table.concat(beastNames, ", ") == "Test Bear A, Test Bear D, Test Bear C", table.concat(beastNames, ", "))
	check("teachers: flags beasts above your level", claw.beasts[3].tooHigh and not claw.beasts[1].tooHigh)
	check("teachers: a rank with no beast gives an empty list", #advice.goLearn[1].beasts == 0)

	input.pet = { name = "Behr", family = "Bear", level = 15, points = 2 }
	advice = A.Build(input)
	check("needs points: a rank you could teach but can't afford", names(advice.needsPoints) == "Bite 2", names(advice.needsPoints))
	check("needs points: says what it costs", advice.needsPoints[1] and advice.needsPoints[1].cost == 3)
	check("needs points: the affordable rank is still ready", names(advice.ready) == "Growl 2", names(advice.ready))

	input.pet = behr
	input.hunterRanks = hunterKnows({ Growl = { 1 } })
	advice = A.Build(input)
	local growl
	for _, entry in ipairs(advice.trainer) do if entry.ability == "Growl" then growl = entry end end
	check("a trainer rank the pet is old enough for goes to the Pet Trainer list", growl and growl.rank == 2, names(advice.trainer))
	input.pet = { name = "Behr", family = "Bear", level = 25, points = 20 }
	advice = A.Build(input)
	check("the trainer list names the highest rank the pet is old enough for", names(advice.trainer) == "Growl 3", names(advice.trainer))
	input.pet = { name = "Behr", family = "Bear", level = 5, points = 20 }
	input.hunterRanks = hunterKnows({ Growl = { 1, 2 } })
	advice = A.Build(input)
	local later
	for _, entry in ipairs(advice.goLearn) do if entry.ability == "Growl" then later = entry end end
	check("a trainer rank the pet is too young for stays in go find", later and later.source == "trainer" and later.rank == 3
		and #advice.trainer == 0, names(advice.goLearn))

	input.hunterRanks = nil
	advice = A.Build(input)
	check("before Beast Training is seen, it asks for it", advice.needsBeastTraining)
	check("before Beast Training is seen, it still shows what the pet knows", #advice.known == 3)
	check("before Beast Training is seen, it doesn't guess the rest", #advice.ready == 0 and #advice.goLearn == 0)

	advice = A.Build({ pet = nil, data = TEST_DATA })
	check("no pet out", advice.noPet)
	advice = A.Build({ pet = { name = "Snap", family = "Ravager", level = 10 }, data = TEST_DATA, hunterRanks = {} })
	check("a family with no data", advice.noData)

	-- A pet that knows a higher rank than you do (it came that way when tamed).
	input.hunterRanks = hunterKnows({ Claw = { 1 } })
	input.petRanks = { Claw = 2 }
	advice = A.Build(input)
	local next
	for _, entry in ipairs(advice.goLearn) do if entry.ability == "Claw" then next = entry end end
	check("go learn it starts above whatever the pet already has", next and next.rank == 3)
	check("nothing to train when the pet's rank is higher than yours", names(advice.ready):find("Claw") == nil)
end)

-------------------------------------------------------------------------------
-- The addon in the game
-------------------------------------------------------------------------------

local function slash(input)
	env.SlashCmdList.TAMER(input)
	return chatOut[#chatOut]
end

local function printedSince(n, text)
	for i = n + 1, #chatOut do
		if chatOut[i]:find(text, 1, true) then return true end
	end
	return false
end

local function countSince(n, text)
	local count = 0
	for i = n + 1, #chatOut do
		if chatOut[i]:find(text, 1, true) then count = count + 1 end
	end
	return count
end

local function dashboardText()
	local window = namedFrames.TamerDashboard
	local parts = {}
	for _, f in ipairs(allFrames) do
		if f._isText and f._text and f._text ~= "" and isInside(f, window) and effectiveShown(f) then
			parts[#parts + 1] = f._text
		end
	end
	return table.concat(parts, "\n")
end

-- Hovers the row or tile showing this text and returns its tooltip as one string.
local function hover(text)
	local window = namedFrames.TamerDashboard
	for _, f in ipairs(allFrames) do
		if f._isText and f._text and f._text:find(text, 1, true) and effectiveShown(f) and isInside(f, window) then
			local owner = f._parent
			if owner._scripts.OnEnter then
				owner._scripts.OnEnter(owner)
				return table.concat(env.GameTooltip._lines, "\n")
			end
		end
	end
	return ""
end

local function clickRow(text)
	local window = namedFrames.TamerDashboard
	for _, f in ipairs(allFrames) do
		if f._isText and f._text and f._text:find(text, 1, true) and effectiveShown(f) and isInside(f, window) then
			local row = f._parent
			if row._scripts.OnClick then
				row._scripts.OnClick(row)
				return true
			end
		end
	end
	return false
end

section("Loading and login", function()
	check("reads its version from the TOC", ns.Version == "0.0.0-test", ns.Version)
	fire("ADDON_LOADED", "SomeOtherAddon")
	check("ignores other addons loading", env.TamerDB == nil)
	fire("ADDON_LOADED", ADDON)
	check("creates its saved data", type(env.TamerDB) == "table")
	ns.Data = TEST_DATA

	local n = #chatOut
	fire("PLAYER_LOGIN")
	fire("PLAYER_ENTERING_WORLD")
	check("keeps data for this character", ns.CharData() == env.TamerDB.chars["Testhunter-Forever"])
	check("makes the minimap button", namedFrames.TamerMinimapButton ~= nil)
	check("says nothing at login", #chatOut == n, chatOut[#chatOut])
	check("registers /tamer", env.SLASH_TAMER1 == "/tamer")
end)

section("The window before Beast Training", function()
	slash("")
	local window = namedFrames.TamerDashboard
	check("/tamer opens the window", window and window:IsShown())
	check("Escape closes it", env.UISpecialFrames[1] == "TamerDashboard")
	local text = dashboardText()
	check("shows the pet", text:find("Behr", 1, true) and text:find("Level 15 Bear", 1, true), text)
	check("shows training points left", text:find("\n12\npoints", 1, true), text)
	check("asks you to open Beast Training", text:find("Open Beast Training once", 1, true), text)
	check("doesn't guess what's ready", not text:find("can learn", 1, true), text)
	local teach = namedFrames.TamerTeachButton
	check("has a Teach button", teach ~= nil and teach:IsShown())
	check("which casts Beast Training", teach:GetAttribute("type") == "spell" and teach:GetAttribute("spell") == "Beast Training")
	check("and says what it does", teach:GetText() == "Open Beast Training", teach:GetText())
	check("the points have a tooltip", hover("points"):find("Training points", 1, true))
end)

section("After Beast Training", function()
	W.crafts = {
		{ "Beast Training", nil, "header" },
		{ "Claw", "Rank 1", "used", 1, 1 }, { "Claw", "Rank 2", "used", 5, 8 },
		{ "Bite", "Rank 1", "used", 1, 1 }, { "Bite", "Rank 2", "optimal", 3, 8 },
		{ "Growl", "Rank 1", "used", 1, 1 }, { "Growl", "Rank 2", "optimal", 2, 10 }, { "Growl", "Rank 3", "none", 4, 20 },
	}
	local before = #chatOut
	fire("CRAFT_SHOW")
	check("opening Beast Training doesn't print a level-up line", countSince(before, "can now learn") == 0)
	local char = ns.CharData()
	check("remembers the ranks you know", char.known.Growl and char.known.Growl[3] ~= nil)
	check("remembers the family it saw them with", char.seenFamilies.Bear)
	local text = dashboardText()
	check("the prompt goes away", not text:find("Open Beast Training once", 1, true), text)
	check("a green card says how many are ready", text:find("Behr can learn 2 things now", 1, true), text)
	check("with an icon tile for each", text:find("\nBite\n", 1, true) and text:find("\nGrowl\n", 1, true), text)
	check("the tile tooltip says the cost", hover("Bite"):find("Costs", 1, true), hover("Bite"))
	check("the Teach button names the pet", namedFrames.TamerTeachButton:GetText() == "Teach Behr", namedFrames.TamerTeachButton:GetText())
	check("coming soon, with its level", text:find("Coming soon", 1, true) and text:find("Growl (Rank 3)", 1, true)
		and text:find("Level 20", 1, true) and text:find("5 more levels", 1, true), text)
	check("go find these", text:find("Go find these", 1, true) and text:find("Claw (Rank 3)", 1, true), text)
	check("with the nearest beast on the row", text:find("Test Bear A, Loch Modan", 1, true), text)
	local tip = hover("Claw (Rank 3)")
	check("the tooltip lists the beasts", tip:find("Test Bear A, level 14-15, Loch Modan", 1, true), tip)
	check("and flags the ones too high to tame", tip:find("Test Bear C, level 18-19, Redridge Mountains (too high for you)", 1, true), tip)
	check("no long sentences in the window", not text:find("Click one to see", 1, true))
	local height = namedFrames.TamerDashboard:GetHeight()
	check("the window fits its cards", height >= 240 and height < 600, height)

	-- Another family's window adds to what you know, and never removes anything.
	W.crafts = { { "Dash", "Rank 1", "optimal", 5, 30 } }
	fire("CRAFT_UPDATE")
	check("adds ranks from another window", char.known.Dash and char.known.Dash[1])
	check("keeps the ranks it had", char.known.Claw and char.known.Claw[2])
end)

section("The level-up line", function()
	W.time = 100 -- Long after login.
	TEST_DATA.Abilities["Fire Resistance"] = { source = "trainer", families = "all", ranks = { { level = 20, cost = 5 } } }
	local n = #chatOut
	W.pet.level = 16
	fire("UNIT_LEVEL", "pet")
	check("quiet when no new rank is ready", countSince(n, "can now learn") == 0, chatOut[#chatOut])

	-- The level arrives first, and the training points a moment later.
	W.pet.level = 20
	W.pet.total = 5
	fire("UNIT_LEVEL", "pet")
	check("waits while the new rank isn't affordable yet", countSince(n, "can now learn") == 0, chatOut[#chatOut])
	check("but says a Pet Trainer has something new", printedSince(n, "Behr hit level 20. A Pet Trainer has 1 new rank for Behr."), chatOut[#chatOut])
	check("and the window has a Pet Trainer card", dashboardText():find("A Pet Trainer has 1 new thing", 1, true)
		and hover("Fire Resistance"):find("Buy it from a Pet Trainer", 1, true), dashboardText())
	W.pet.total = 14
	fire("UNIT_PET_TRAINING_POINTS", "player")
	check("one line when a rank becomes ready", countSince(n, "can now learn") == 1)
	check("names the pet and the rank", printedSince(n, "Behr can now learn Growl (Rank 3). Cast Beast Training to teach it."), chatOut[#chatOut])
	fire("UNIT_LEVEL", "pet")
	check("doesn't repeat itself", countSince(n, "can now learn") == 1)

	-- Right after a loading screen, the game can report 0 training points, then the real number.
	n = #chatOut
	local saved = W.pet.total
	W.pet.total = 0
	fire("PLAYER_ENTERING_WORLD")
	W.pet.total = saved
	fire("UNIT_PET_TRAINING_POINTS", "player")
	check("quiet while the game fills in the pet after loading", countSince(n, "can now learn") == 0, chatOut[#chatOut])
	W.time = 200

	-- After /reload the game can report the pet before its training points.
	n = #chatOut
	local total = W.pet.total
	W.pet.total = nil
	fire("UNIT_PET", "player")
	W.pet.total = total
	fire("UNIT_PET_TRAINING_POINTS", "player")
	check("quiet when training points arrive late after a reload", countSince(n, "can now learn") == 0, chatOut[#chatOut])

	n = #chatOut
	W.pet = { name = "Fang", level = 25, family = "Wolf", xp = 0, xpMax = 100, total = 20, spent = 0 }
	W.petSpells = { { "Bite", "Rank 1" } }
	fire("UNIT_PET", "player")
	check("quiet when you swap pets", countSince(n, "can now learn") == 0, chatOut[#chatOut])
	check("the window follows the new pet", dashboardText():find("Fang", 1, true))
	TEST_DATA.Abilities["Fire Resistance"] = nil
end)

section("Learning from chat", function()
	local char = ns.CharData()
	fire("CHAT_MSG_SYSTEM", "You have learned a new spell: Bite (Rank 3).")
	check("a learned rank is remembered", char.known.Bite and char.known.Bite[3] ~= nil)
	check("with its level from the data", char.known.Bite[3].level == 16)
	fire("CHAT_MSG_SYSTEM", "You have learned a new spell: Fireball (Rank 3).")
	check("other spells are ignored", char.known.Fireball == nil)
	fire("CHAT_MSG_SYSTEM", "Your pet has learned Dash (Rank 3).")
	check("other wording about learning a rank counts too", char.known.Dash and char.known.Dash[3] ~= nil)
	fire("CHAT_MSG_SYSTEM", "Fireball (Rank 3) is ready.")
	check("but only lines about learning", char.known.Fireball == nil)
end)

section("The Teach button in combat", function()
	local teach = namedFrames.TamerTeachButton
	check("starts open with the window", namedFrames.TamerDashboard:IsShown() and teach:IsShown())
	env.InCombatLockdown = function() return true end
	ns.Dashboard.Toggle()
	check("closing in combat leaves it alone but invisible", teach:IsShown() and teach:GetAlpha() == 0)
	env.InCombatLockdown = function() return false end
	fire("PLAYER_REGEN_ENABLED")
	check("and hides it once combat ends", not teach:IsShown() and teach:GetAlpha() == 1)
	ns.Dashboard.Toggle()
	check("opening again shows it", teach:IsShown())
	env.InCombatLockdown = nil
end)

section("Forever's newer APIs", function()
	local char = ns.CharData()
	char.seenFamilies.Wolf = nil
	local savedHas = env.HasPetSpells
	-- Forever's spellbook: C_SpellBook, the rank only from the spell ID, and no count.
	env.HasPetSpells = function() return nil end
	env.Enum = { SpellBookSpellBank = { Player = 0, Pet = 1 } }
	local book = { { "Bite", "", 17255 }, { "Dash (Rank 1)", nil, 23099 }, { "Growl", "Rank 2", 14916 } }
	env.C_SpellBook = {
		GetSpellBookItemName = function(index, bank)
			if bank ~= 1 then return nil end
			local spell = book[index]
			if spell then return spell[1], spell[2], spell[3] end
		end,
	}
	env.C_Spell = { GetSpellSubtext = function(id) if id == 17255 then return "Rank 4" end end }
	local ranks = ns.Knowledge.PetRanks()
	check("reads the pet's spellbook through C_SpellBook", ranks.Growl == 2, ranks.Growl)
	check("takes the rank from the spell ID", ranks.Bite == 4, ranks.Bite)
	check("takes the rank from the name", ranks.Dash == 1, ranks.Dash)

	-- An ability the data doesn't have, like Forever's Swipe, is learned from the spellbook.
	table.insert(book, { "Swipe", "Rank 2", 900 })
	table.insert(book, { "Aggressive", "Pet Stance", 901 })
	ranks = ns.Knowledge.PetRanks()
	check("learns a ranked ability the data doesn't have", ranks.Swipe == 2 and TEST_DATA.Abilities.Swipe
		and TEST_DATA.Abilities.Swipe.families[1] == "Wolf", ranks.Swipe)
	check("but not stances or commands", TEST_DATA.Abilities.Aggressive == nil)
	check("and saves it for next time", env.TamerDB.discovered and env.TamerDB.discovered.Swipe and env.TamerDB.discovered.Swipe.Wolf)
	TEST_DATA.Abilities.Swipe = nil
	ns.Knowledge.LoadDiscovered()
	check("it comes back after a reload", TEST_DATA.Abilities.Swipe and TEST_DATA.Abilities.Swipe.families[1] == "Wolf")
	table.remove(book) table.remove(book)
	TEST_DATA.Abilities.Swipe, env.TamerDB.discovered = nil, nil

	-- Forever's Beast Training: a trade skill window, not a craft window.
	W.crafts = {}
	local recipes = {
		[30] = { name = "Bite", learned = true }, [10] = { name = "Bite", learned = true },
		[20] = { name = "Bite", learned = true }, [40] = { name = "Dash (Rank 2)", learned = true },
		[50] = { name = "Furious Howl", learned = false }, [60] = { name = "Smelt Copper", learned = true },
	}
	env.C_TradeSkillUI = {
		GetAllRecipeIDs = function() return { 30, 10, 20, 40, 50, 60 } end,
		GetRecipeInfo = function(id) return recipes[id] end,
	}
	fire("TRADE_SKILL_SHOW")
	check("reads Beast Training from the trade skill window", char.seenFamilies.Wolf)
	check("numbers unranked ranks in order", char.known.Bite[1] and char.known.Bite[2] and char.known.Bite[3])
	check("reads a rank in the name", char.known.Dash[2] ~= nil)
	check("skips ranks you haven't learned", char.known["Furious Howl"] == nil)
	check("the window stops asking for Beast Training", not dashboardText():find("Open Beast Training once", 1, true), dashboardText())

	-- Or a trainer window, as Forever may use for Beast Training.
	local services = { { "Growl", "Rank 5", "available", 40 }, { "Claw (Rank 4)", "", "unavailable", 24 } }
	local npc = true
	env.GetNumTrainerServices = function() return #services end
	-- In the order Forever returns them: name, category, icon, level, rank.
	env.GetTrainerServiceInfo = function(i) local s = services[i]; return s[1], s[3], 132140, s[4], s[2], "" end
	env.GetTrainerServiceLevelReq = function(i) return services[i][4] end
	local savedExists = env.UnitExists
	env.UnitExists = function(unit) if unit == "npc" then return npc end return savedExists(unit) end
	fire("TRAINER_SHOW")
	check("a Pet Trainer NPC's ranks for sale aren't counted", not (char.known.Growl and char.known.Growl[5]))
	-- Buying a rank marks it as learned in the Pet Trainer's window.
	char.seenFamilies.Wolf = nil
	services[1][3] = "used"
	local tradeSkills = env.C_TradeSkillUI
	env.C_TradeSkillUI = nil
	fire("TRAINER_UPDATE")
	env.C_TradeSkillUI = tradeSkills
	check("a rank bought from a Pet Trainer counts", char.known.Growl and char.known.Growl[5] ~= nil)
	check("but a Pet Trainer doesn't stand in for Beast Training", not char.seenFamilies.Wolf)
	char.known.Growl[5] = nil
	services[1][3] = "available"
	npc = false
	fire("TRAINER_SHOW")
	check("reads Beast Training as a trainer window", char.known.Growl and char.known.Growl[5]
		and char.known.Growl[5].level == 40)
	check("with the rank in the name", char.known.Claw[4] ~= nil)

	-- Forever's training points.
	env.C_PetInfo = { GetPetTrainingPoints = function() return 90, 11 end }
	check("reads training points from C_PetInfo", ns.Knowledge.Pet().points == 79, ns.Knowledge.Pet().points)

	local n = #chatOut
	slash("debug")
	check("/tamer debug prints trainer services", printedSince(n, "service 1: Growl | available | 132140 | 40 | Rank 5"))
	env.GetNumTrainerServices, env.GetTrainerServiceInfo, env.GetTrainerServiceLevelReq, env.UnitExists, env.C_PetInfo = nil, nil, nil, savedExists, nil
	check("/tamer debug prints the pet's spellbook", printedSince(n, "pet 1: Bite"))
	check("and the recipes", printedSince(n, "recipe 30: learned=true, name=Bite"))

	env.HasPetSpells, env.Enum, env.C_SpellBook, env.C_Spell, env.C_TradeSkillUI = savedHas, nil, nil, nil, nil
end)

section("No pet, and not a Hunter", function()
	local saved = W.pet
	W.pet = nil
	fire("UNIT_PET", "player")
	check("asks you to call your pet", dashboardText():find("Call your pet", 1, true), dashboardText())
	local teach = namedFrames.TamerTeachButton
	check("and the button calls it", teach:GetAttribute("spell") == "Call Pet" and teach:GetText() == "Call Pet", teach:GetText())
	W.pet = saved
	W.class = "MAGE"
	ns.Dashboard.Refresh()
	check("says it's for Hunters", dashboardText():find("Tamer is for Hunters", 1, true), dashboardText())
	check("with no button", not namedFrames.TamerTeachButton:IsShown())
	W.class = "HUNTER"
	fire("UNIT_PET", "player")
end)

section("Commands", function()
	slash("")
	check("/tamer closes the window again", not namedFrames.TamerDashboard:IsShown())
	slash("minimap")
	check("/tamer minimap hides the icon", env.TamerDB.minimapHidden == true and not namedFrames.TamerMinimapButton:IsShown())
	slash("minimap")
	check("and shows it again", not env.TamerDB.minimapHidden and namedFrames.TamerMinimapButton:IsShown())
	local n = #chatOut
	slash("status")
	check("/tamer status prints the pet", printedSince(n, "Fang, level 25 Wolf"))
	check("/tamer status prints what it knows", printedSince(n, "Pet knows: Bite 1") and printedSince(n, "You know (highest ranks)"))
	n = #chatOut
	slash("help")
	check("/tamer help lists the commands", printedSince(n, "/tamer minimap"))
	check("an unknown command points to help", (slash("nonsense") or ""):find("/tamer help", 1, true))
end)

-------------------------------------------------------------------------------
-- The real data
-------------------------------------------------------------------------------

section("Data.lua", function()
	local data = realData
	check("Data.lua defines the data", type(data) == "table" and type(data.Abilities) == "table" and type(data.Beasts) == "table")
	if type(data) ~= "table" then return end
	local families = {}
	for _, family in ipairs(data.Families or {}) do families[family] = true end
	check("lists the pet families", next(families) ~= nil)

	local abilityCount = 0
	for name, info in pairs(data.Abilities) do
		abilityCount = abilityCount + 1
		check(name .. ": a beast or trainer source", info.source == "beast" or info.source == "trainer", info.source)
		if info.families ~= "all" then
			for _, family in ipairs(info.families or {}) do
				check(name .. ": " .. tostring(family) .. " is a real family", families[family])
			end
		end
		local lastLevel = 0
		for rank, entry in ipairs(info.ranks or {}) do
			check(("%s %d: has a level"):format(name, rank), type(entry.level) == "number")
			if not info.forever and not entry.newInForever then
				check(("%s %d: has a cost"):format(name, rank), type(entry.cost) == "number")
			end
			check(("%s %d: levels go up"):format(name, rank), (entry.level or 0) >= lastLevel)
			lastLevel = entry.level or lastLevel
		end
		check(name .. ": has ranks", #(info.ranks or {}) > 0)
	end
	check("has abilities", abilityCount > 0)
	for alias, family in pairs(data.FamilyAliases or {}) do
		check(alias .. " is another name for a real family", families[family], family)
		check(alias .. " gets the same abilities as " .. family,
			table.concat(ns.Advisor.FamilyAbilities(data, alias), ",") == table.concat(ns.Advisor.FamilyAbilities(data, family), ","))
	end

	for i, beast in ipairs(data.Beasts) do
		local label = ("beast %d (%s)"):format(i, tostring(beast.name))
		check(label .. ": has a name and zone", type(beast.name) == "string" and type(beast.zone) == "string")
		check(label .. ": a real family", families[beast.family], beast.family)
		local low, high = beast.level and beast.level[1], beast.level and (beast.level[2] or beast.level[1])
		check(label .. ": a level range", type(low) == "number" and type(high) == "number" and low <= high)
		for _, taught in ipairs(beast.teaches or {}) do
			local info = data.Abilities[taught[1]]
			check(label .. ": teaches a real ability", info ~= nil, taught[1])
			check(label .. ": each rank is just { ability, rank }", #taught == 2 and type(taught[2]) == "number", taught[1])
			if info then
				check(label .. ": teaches a real rank", info.ranks[taught[2]] ~= nil, taught[1] .. " " .. tostring(taught[2]))
				local allowed = info.families == "all"
				for _, family in ipairs(type(info.families) == "table" and info.families or {}) do
					if family == beast.family then allowed = true end
				end
				check(label .. ": its family can learn " .. taught[1], allowed)
				check(label .. ": teaches a beast ability", info.source == "beast", taught[1])
			end
		end
		check(label .. ": teaches something", #(beast.teaches or {}) > 0)
	end
end)

stdPrint("")
stdPrint(("RESULT: %d passed, %d failed"):format(passed, failed))
for _, f in ipairs(failures) do stdPrint("  - " .. f) end
local unknown = {}
for name in pairs(unknownGlobals) do unknown[#unknown + 1] = name end
table.sort(unknown)
stdPrint("Globals read but not stubbed: " .. (#unknown > 0 and table.concat(unknown, ", ") or "none"))
os.exit(failed == 0 and 0 or 1)
