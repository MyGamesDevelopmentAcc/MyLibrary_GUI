local addonName, AddonNS = ...

local NS = AddonNS.WowListExamples
NS.SharedData = NS.SharedData or {}

local SharedData = NS.SharedData

local names = {
    "Arden", "Belia", "Cairn", "Dorian", "Elyn", "Faelyn", "Gavin", "Helia", "Ivar", "Jaina",
    "Kael", "Lyria", "Mira", "Nolan", "Orin", "Pyria", "Quinn", "Rhea", "Sylas", "Talia",
    "Ulric", "Vera", "Wren", "Xara", "Yorin", "Zane",
}

local roles = { "Tank", "Healer", "DPS", "Support" }
local classes = { "Warrior", "Paladin", "Priest", "Mage", "Rogue", "Druid", "Shaman", "Warlock", "Monk", "Evoker" }
local channels = { "Trade", "General", "Guild", "Party" }
local statuses = { "Stable", "Hot", "Critical", "Offline", "Review" }
local categories = { "Alchemy", "Crafting", "Dungeon", "PvP", "Raid", "Social", "Services", "Sales" }

local function deterministicValue(seed, mult, add, mod)
    return ((seed * mult) + add) % mod
end

function SharedData.GetBasicRows()
    return {
        { "Thrall", "Shaman", 489 },
        { "Jaina", "Mage", 503 },
        { "Anduin", "Priest", 476 },
        { "Valeera", "Rogue", 498 },
        { "Malfurion", "Druid", 500 },
        { "Muradin", "Warrior", 482 },
        { "Uther", "Paladin", 495 },
        { "Liadrin", "Paladin", 491 },
        { "Alleria", "Hunter", 502 },
        { "Khadgar", "Mage", 497 },
    }
end

function SharedData.GetSortingRows()
    local rows = {}
    for i = 1, 120 do
        local name = names[(i % #names) + 1] .. "-" .. i
        local className = classes[(i % #classes) + 1]
        local level = 10 + deterministicValue(i, 17, 9, 61)
        local score = deterministicValue(i, 97, 111, 10000)
        local rank = statuses[(i % #statuses) + 1]
        table.insert(rows, { name, className, level, score, rank })
    end
    return rows
end

function SharedData.GetTradeLikeRows()
    local rows = {}
    for i = 1, 250 do
        local topic = categories[(i % #categories) + 1]
        local channel = channels[(i % #channels) + 1]
        local quality = statuses[(i % #statuses) + 1]
        local msg = string.format("[%s] WTS service pack #%03d | quality=%s | pst", topic, i, quality)
        table.insert(rows, { "#" .. i, msg, channel, topic, quality })
    end
    return rows
end

function SharedData.GetCallbackRows()
    local rows = {}
    for i = 1, 180 do
        local role = roles[(i % #roles) + 1]
        local className = classes[(i % #classes) + 1]
        local prio = deterministicValue(i, 31, 7, 100) + 1
        table.insert(rows, { i, names[(i % #names) + 1], role, className, prio })
    end
    return rows
end

function SharedData.GetHealthStatusRows()
    local rows = {}
    local maxHp = 1000000
    for i = 1, 180 do
        local currentHp = 150000 + deterministicValue(i, 431, 9000, 850000)
        local damage = deterministicValue(i, 193, 17, 170000)
        local heal = deterministicValue(i, 157, 13, 140000)
        local absorb = deterministicValue(i, 223, 29, 120000)
        local className = classes[(i % #classes) + 1]
        local name = names[(i % #names) + 1] .. "_" .. i
        table.insert(rows, { name, className, currentHp, maxHp, damage, heal, absorb })
    end
    return rows
end

function SharedData.GetAdvancedRows()
    local rows = {}
    for i = 1, 320 do
        local sevIdx = (i % 5) + 1
        local severity = ({ "TRACE", "INFO", "WARN", "ERROR", "CRITICAL" })[sevIdx]
        local source = categories[(i % #categories) + 1]
        local owner = names[(i % #names) + 1]
        local value = deterministicValue(i, 103, 41, 5000)
        local tag = (i % 2 == 0) and "burst" or "steady"
        local text = string.format("Event %04d from %s owner=%s mode=%s", i, source, owner, tag)
        table.insert(rows, { i, severity, source, owner, value, text, tag })
    end
    return rows
end

function SharedData.GeneratePerfRows(count, revision)
    local rows = {}
    local rev = revision or 0
    for i = 1, count do
        local idx = deterministicValue(i + rev * 11, 37, 101, count) + 1
        local cat = categories[(idx % #categories) + 1]
        local status = statuses[(idx % #statuses) + 1]
        local name = names[(idx % #names) + 1] .. "-" .. idx
        local score = deterministicValue(idx + rev, 97, 13, 100000)
        local hour = deterministicValue(idx + rev, 7, 3, 24)
        local minute = deterministicValue(idx + rev, 11, 5, 60)
        local second = deterministicValue(idx + rev, 13, 7, 60)
        local timestamp = string.format("%02d:%02d:%02d", hour, minute, second)
        rows[i] = { idx, name, cat, score, status, timestamp }
    end
    return rows
end

