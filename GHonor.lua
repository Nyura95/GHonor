-- Variables globales
local addonName, addon = ...
local GHonor = CreateFrame("Frame")
local HonorFrame = nil
local honorableKills = 0
local honorFromKills = 0
local honorFromObjectives = 0
local isInBattleground = false
local sessionStartHonor = 0
local currentBGHonor = 0

-- Raccourci pour la fonction de traduction
local _ = GHonor_

-- Raccourci pour la configuration
local Config = addon.Config

-- Configuration par défaut
local defaults = {
    point = "CENTER",
    relativePoint = "CENTER",
    xOfs = 0,
    yOfs = 0,
    showOutsideBG = false,
    isLocked = false
}

-- Initialisation de l'addon
function GHonor:Init()
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
    self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
    self:RegisterEvent("COMBAT_TEXT_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
end

-- Création de la fenêtre principale
function GHonor:CreateMainFrame()
    if HonorFrame then return end
    
    -- Création de la frame avec la nouvelle classe
    HonorFrame = addon.Frame:Create(_("GHonor"), "GHonorMainFrame", GHonorDB.point, GHonorDB.relativePoint, GHonorDB.xOfs, GHonorDB.yOfs, GHonorDB.isLocked)
    
    -- Configuration du callback de déplacement
    HonorFrame.OnMove = function(self, point, relativePoint, xOfs, yOfs)
        GHonorDB.point = point
        GHonorDB.relativePoint = relativePoint
        GHonorDB.xOfs = xOfs
        GHonorDB.yOfs = yOfs
    end
    
    -- Configuration du callback de fermeture
    HonorFrame.OnClose = function(self)
        GHonorDB.showOutsideBG = false
        if not isInBattleground and not Config.DEBUG.enabled then
            self:Hide()
        end
    end
    
    -- Configuration du callback de verrouillage
    HonorFrame.OnLock = function(self, isLocked)
        GHonorDB.isLocked = isLocked
    end
    
    -- Application de l'état de verrouillage sauvegardé
    HonorFrame:SetLocked(GHonorDB.isLocked)
    
    -- Ajout des textes
    HonorFrame.hkText = HonorFrame:AddText(_("HK Count") .. ": 0")
    
    HonorFrame.honorKillsText = HonorFrame:AddText(_("HK Honor") .. ": 0", {
        relativeTo = HonorFrame.hkText,
        point = "TOPLEFT",
        relativePoint = "BOTTOMLEFT",
        yOfs = -4
    })
    
    HonorFrame.honorObjectivesText = HonorFrame:AddText(_("Objective Honor") .. ": 0", {
        relativeTo = HonorFrame.honorKillsText,
        point = "TOPLEFT",
        relativePoint = "BOTTOMLEFT",
        yOfs = -4
    })
    
    HonorFrame.totalHonorText = HonorFrame:AddText(_("Total") .. ": 0", {
        relativeTo = HonorFrame.honorObjectivesText,
        point = "TOPLEFT",
        relativePoint = "BOTTOMLEFT",
        yOfs = -4
    })
    
    if not GHonorDB.showOutsideBG then
        HonorFrame:Hide()
    end
end

-- Création des commandes slash
function GHonor:CreateSlashCommands()
    SLASH_GHONOR1 = "/" .. Config.SLASH_COMMAND
    SlashCmdList["GHONOR"] = function(msg)
        msg = msg:lower()
        Config:Debug("SLASH_COMMAND", "Received command:", msg)
        if msg == "show" then
            GHonorDB.showOutsideBG = not GHonorDB.showOutsideBG
            if GHonorDB.showOutsideBG then
                HonorFrame:Show()
                print(Config.COLORS.ADDON_PREFIX .. _(Config.MESSAGES.WINDOW_SHOWN))
            else
                if not isInBattleground then
                    HonorFrame:Hide()
                end
                print(Config.COLORS.ADDON_PREFIX .. _(Config.MESSAGES.WINDOW_HIDDEN))
            end
        elseif msg == "reset" then
            GHonorDB.point = Config.DEFAULTS.point
            GHonorDB.relativePoint = Config.DEFAULTS.relativePoint
            GHonorDB.xOfs = Config.DEFAULTS.xOfs
            GHonorDB.yOfs = Config.DEFAULTS.yOfs
            HonorFrame:ClearAllPoints()
            HonorFrame:SetPoint(GHonorDB.point, UIParent, GHonorDB.relativePoint, GHonorDB.xOfs, GHonorDB.yOfs)
            print(Config.COLORS.ADDON_PREFIX .. _(Config.MESSAGES.POSITION_RESET))
        elseif msg == "debug" then
            Config.DEBUG.enabled = not Config.DEBUG.enabled
            print(Config.COLORS.ADDON_PREFIX .. (Config.DEBUG.enabled and _(Config.MESSAGES.DEBUG_ENABLED) or _(Config.MESSAGES.DEBUG_DISABLED)))
        elseif msg:find("^test ") then
            local testType = msg:match("^test (.+)$")
            local testHonorMessage = Config.PATTERNS.HONOR_KILL .. " 12"
            local testObjectiveMessage = " 12"
            if testType == "honor" then
                -- Simulation d'un gain d'honneur par kill
                print(Config.COLORS.ADDON_PREFIX .. "Simulate a kill")
                GHonor:ProcessHonorMessage(testHonorMessage)
            elseif testType == "objective" then
                -- Simulation d'un gain d'honneur par objectif
                print(Config.COLORS.ADDON_PREFIX .. "Simulate a objective")
                GHonor:ProcessHonorMessage(testObjectiveMessage)
            elseif testType == "loop" then
                -- Simulation d'une boucle de gains d'honneur
                print(Config.COLORS.ADDON_PREFIX .. "Start simulate")
                local count = 0
                local function simulateHonorGain()
                    if count < 10 then
                        print(Config.COLORS.ADDON_PREFIX .. "Simulate a kill")
                        GHonor:ProcessHonorMessage(testHonorMessage)
                        count = count + 1
                        C_Timer.After(1, simulateHonorGain)
                    else
                        print(Config.COLORS.ADDON_PREFIX .. "Simulation terminée")
                    end
                end
                simulateHonorGain()
            end
        else
            print(Config.COLORS.ADDON_PREFIX .. _(Config.MESSAGES.AVAILABLE_COMMANDS) .. ":|r")
            print(string.format("  /%s %s - %s", Config.SLASH_COMMAND, "show", _("Toggle window visibility")))
            print(string.format("  /%s %s - %s", Config.SLASH_COMMAND, "reset", _(Config.MESSAGES.RESET_WINDOW)))
            print(string.format("  /%s %s - %s", Config.SLASH_COMMAND, "debug", _("Toggle debug mode")))
            print(string.format("  /%s %s - %s", Config.SLASH_COMMAND, "test", _("Test commands")))
        end
    end
end

-- Gestion des événements
function GHonor:OnEvent(event, ...)
    Config:Debug(event, ...)
    
    if event == "ADDON_LOADED" and ... == "GHonor" then
        -- Initialisation des variables sauvegardées
        if not GHonorDB then
            GHonorDB = Config.DEFAULTS
            Config:Debug("INIT", "Created new GHonorDB with defaults")
        else
            -- Mise à jour des valeurs par défaut si nécessaire
            for key, value in pairs(Config.DEFAULTS) do
                if GHonorDB[key] == nil then
                    GHonorDB[key] = value
                    Config:Debug("INIT", "Added default value for", key, value)
                end
            end
        end
        
        -- Création de la fenêtre principale
        self:CreateMainFrame()
        
        -- Création des commandes slash
        self:CreateSlashCommands()
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:CheckBattleground()
    elseif event == "UPDATE_BATTLEFIELD_SCORE" then
        self:UpdateBattlefieldStats()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        self:CheckBattleground()
    elseif event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
        local text = ...
        self:ProcessHonorMessage(text)
    end
end

-- Traitement des messages d'honneur
function GHonor:ProcessHonorMessage(text)
    if not isInBattleground and not Config.DEBUG.enabled then return end
    
    Config:Debug("HONOR_MESSAGE", "Processing message:", text)
    
    -- Analyse du message pour déterminer si c'est un kill ou un objectif
    if text:find(Config.PATTERNS.HONOR_KILL) then
        -- C'est un kill honorable
        local honor = tonumber(text:match("(%d+)"))
        if honor then
            honorFromKills = honorFromKills + honor
            honorableKills = honorableKills + 1
            Config:Debug("HONOR_MESSAGE", "Added honor from kill:", honor, " HK:", honorableKills, " Total:", honorFromKills)
        end
    else
        -- C'est probablement un objectif
        local honor = tonumber(text:match("(%d+)"))
        if honor then
            honorFromObjectives = honorFromObjectives + honor
            Config:Debug("HONOR_MESSAGE", "Added honor from objective:", honor, " Total:", honorFromObjectives)
        end
    end
    
    self:UpdateDisplay()
end

-- Mise à jour des statistiques du champ de bataille
function GHonor:UpdateBattlefieldStats()
    if not isInBattleground and not Config.DEBUG.enabled then 
        Config:Debug("UPDATE_BATTLEFIELD_STATS", "Not in battleground, skipping update")
        return 
    end
    
    local numScores = GetNumBattlefieldScores()
    Config:Debug("UPDATE_BATTLEFIELD_STATS", "Number of scores:", numScores)
    
    for i = 1, numScores do
        local name, kb, hk, deaths, honorGained = GetBattlefieldScore(i)
        if name == UnitName("player") then
            Config:Debug("UPDATE_BATTLEFIELD_STATS", "Found player stats - Name:", name, "KB:", kb, "HK:", hk, "Deaths:", deaths, "Honor:", honorGained)
            honorableKills = hk
            if honorGained and honorGained > 0 then
                Config:Debug("UPDATE_BATTLEFIELD_STATS", "Updating current BG honor from", currentBGHonor, "to", honorGained)
                currentBGHonor = honorGained
                honorFromObjectives = honorGained
            end
            self:UpdateDisplay()
            break
        end
    end
    
    Config:Debug("UPDATE_BATTLEFIELD_STATS", "Final stats - HK:", honorableKills, "Current BG Honor:", currentBGHonor)
end

-- Vérification si le joueur est dans un champ de bataille
function GHonor:CheckBattleground()
    local inInstance, instanceType = IsInInstance()
    local wasInBG = isInBattleground
    isInBattleground = (inInstance and instanceType == "pvp")
    
    Config:Debug("BATTLEGROUND", "inInstance:", inInstance, "instanceType:", instanceType, "isInBattleground:", isInBattleground)
    
    if isInBattleground and not wasInBG then
        -- Reset des compteurs pour le nouveau BG
        honorFromKills = 0
        honorFromObjectives = 0
        honorableKills = 0
        currentBGHonor = 0
        self:UpdateBattlefieldStats()
        HonorFrame:Show()
        Config:Debug("BATTLEGROUND", "Entered battleground, reset counters")
    elseif not isInBattleground and wasInBG and not GHonorDB.showOutsideBG then
        HonorFrame:Hide()
        Config:Debug("BATTLEGROUND", "Left battleground, hiding frame")
    end
end

-- Mise à jour de l'affichage
function GHonor:UpdateDisplay()
    if not HonorFrame then return end
    
    HonorFrame.hkText:SetText(string.format(_("HK Count") .. ": %d", honorableKills))
    HonorFrame.honorKillsText:SetText(string.format(_("HK Honor") .. ": %d", honorFromKills))
    HonorFrame.honorObjectivesText:SetText(string.format(_("Objective Honor") .. ": %d", honorFromObjectives))
    HonorFrame.totalHonorText:SetText(string.format(_("Total") .. ": %d", honorFromKills + honorFromObjectives))
end

-- Initialisation
GHonor:Init()