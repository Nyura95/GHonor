local addonName, addon = ...

-- Configuration de l'addon
local Config = {
    -- Mode debug
    DEBUG = {
        enabled = false,
        prefix = "|cFF00FFFF[GHonor Debug]|r ",
        events = {
            ADDON_LOADED = true,
            PLAYER_ENTERING_WORLD = true,
            UPDATE_BATTLEFIELD_SCORE = true,
            ZONE_CHANGED_NEW_AREA = true,
            CHAT_MSG_COMBAT_HONOR_GAIN = true,
            PLAYER_PVP_KILLS_CHANGED = true,
            COMBAT_TEXT_UPDATE = true
        }
    },

    -- Configuration de la frame
    FRAME = {
        width = 180,
        height = 105,
        bgColor = {0, 0, 0, 0.8},
        borderColor = {0.5, 0.5, 0.5, 0.8},
        titleBgColor = {0.2, 0.2, 0.2, 0.9},
        titleTextColor = {1, 0.82, 0},
        titleHeight = 20,
        padding = 8,
        strata = "LOW",  -- HIGH, MEDIUM, LOW, BACKGROUND
        level = 1,
        minWidth = 130,
        minHeight = 105,
        canResize = true
    },

    -- Commandes slash
    SLASH_COMMAND = "ghonor",
    
    -- Patterns de recherche
    PATTERNS = {
        HONOR_KILL = ":",  -- Pattern pour détecter un kill honorable
    },
    
    -- Messages
    MESSAGES = {
        WINDOW_SHOWN = "Window shown",
        WINDOW_HIDDEN = "Window hidden outside battleground",
        POSITION_RESET = "Position reset",
        AVAILABLE_COMMANDS = "Available commands",
        SHOW_WINDOW = "Show window",
        HIDE_WINDOW = "Hide window outside battleground",
        RESET_WINDOW = "Reset window position",
        DEBUG_ENABLED = "Debug mode enabled",
        DEBUG_DISABLED = "Debug mode disabled"
    },
    
    -- Valeurs par défaut
    DEFAULTS = {
        point = "CENTER",
        relativePoint = "CENTER",
        xOfs = 0,
        yOfs = 0,
        showOutsideBG = false,
        isLocked = false
    },
    
    -- Couleurs
    COLORS = {
        ADDON_PREFIX = "|cFF00FF00GHonor:|r "
    }
}

-- Fonction de debug
function Config:Debug(event, ...)
    if not self.DEBUG.enabled or not self.DEBUG.events[event] then return end
    
    local args = {...}
    local message = string.format("%s[%s] ", self.DEBUG.prefix, event)
    
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            message = message .. "Table: " .. table.concat(arg, ", ") .. " "
        else
            message = message .. tostring(arg) .. " "
        end
    end
    
    print(message)
end

-- Exporter la configuration
addon.Config = Config 