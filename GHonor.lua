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

-- Configuration par défaut
local defaults = {
    point = "CENTER",
    relativePoint = "CENTER",
    xOfs = 0,
    yOfs = 0,
    showOutsideBG = false
}

-- Initialisation de l'addon
function GHonor:Init()
    -- Initialisation des variables sauvegardées
    if not GHonorDB then
        GHonorDB = defaults
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
    self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
    self:RegisterEvent("COMBAT_TEXT_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
    
    -- Création de la fenêtre principale
    self:CreateMainFrame()
    
    -- Création des commandes slash
    self:CreateSlashCommands()
end

-- Création de la fenêtre principale
function GHonor:CreateMainFrame()
    if HonorFrame then return end
    
    -- Création du cadre principal
    HonorFrame = CreateFrame("Frame", "GHonorMainFrame", UIParent)
    HonorFrame:SetSize(180, 105)  -- Hauteur augmentée pour la nouvelle ligne
    HonorFrame:SetPoint(GHonorDB.point, UIParent, GHonorDB.relativePoint, GHonorDB.xOfs, GHonorDB.yOfs)
    HonorFrame:SetMovable(true)
    HonorFrame:EnableMouse(true)
    HonorFrame:RegisterForDrag("LeftButton")
    HonorFrame:SetScript("OnDragStart", HonorFrame.StartMoving)
    HonorFrame:SetScript("OnDragStop", function()
        HonorFrame:StopMovingOrSizing()
        -- Sauvegarder la position
        local point, _, relativePoint, xOfs, yOfs = HonorFrame:GetPoint()
        GHonorDB.point = point
        GHonorDB.relativePoint = relativePoint
        GHonorDB.xOfs = xOfs
        GHonorDB.yOfs = yOfs
    end)
    
    -- Fond principal
    local bg = HonorFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.8)
    
    -- Bordure supérieure
    local topBorder = HonorFrame:CreateTexture(nil, "BORDER")
    topBorder:SetPoint("TOPLEFT", 0, 0)
    topBorder:SetPoint("TOPRIGHT", 0, 0)
    topBorder:SetHeight(2)
    topBorder:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    
    -- Bordure inférieure
    local bottomBorder = HonorFrame:CreateTexture(nil, "BORDER")
    bottomBorder:SetPoint("BOTTOMLEFT", 0, 0)
    bottomBorder:SetPoint("BOTTOMRIGHT", 0, 0)
    bottomBorder:SetHeight(2)
    bottomBorder:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    
    -- Bordure gauche
    local leftBorder = HonorFrame:CreateTexture(nil, "BORDER")
    leftBorder:SetPoint("TOPLEFT", 0, 0)
    leftBorder:SetPoint("BOTTOMLEFT", 0, 0)
    leftBorder:SetWidth(2)
    leftBorder:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    
    -- Bordure droite
    local rightBorder = HonorFrame:CreateTexture(nil, "BORDER")
    rightBorder:SetPoint("TOPRIGHT", 0, 0)
    rightBorder:SetPoint("BOTTOMRIGHT", 0, 0)
    rightBorder:SetWidth(2)
    rightBorder:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    
    -- Titre
    local titleBg = HonorFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    titleBg:SetPoint("TOPLEFT", 2, -2)
    titleBg:SetPoint("TOPRIGHT", -2, -2)
    titleBg:SetHeight(20)
    titleBg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
    
    HonorFrame.title = HonorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HonorFrame.title:SetPoint("CENTER", titleBg, "CENTER", 0, 0)
    HonorFrame.title:SetText("GHonor")
    HonorFrame.title:SetTextColor(1, 0.82, 0)  -- Couleur dorée
    
    -- Conteneur pour les statistiques
    local statsContainer = CreateFrame("Frame", nil, HonorFrame)
    statsContainer:SetPoint("TOPLEFT", 8, -32)
    statsContainer:SetPoint("BOTTOMRIGHT", -8, 8)
    
    -- Textes d'information
    HonorFrame.hkText = statsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HonorFrame.hkText:SetPoint("TOPLEFT", 0, 0)
    HonorFrame.hkText:SetJustifyH("LEFT")
    HonorFrame.hkText:SetText("Nombre VH: 0")
    
    HonorFrame.honorKillsText = statsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HonorFrame.honorKillsText:SetPoint("TOPLEFT", HonorFrame.hkText, "BOTTOMLEFT", 0, -4)
    HonorFrame.honorKillsText:SetJustifyH("LEFT")
    HonorFrame.honorKillsText:SetText("Honneur VH: 0")
    
    HonorFrame.honorObjectivesText = statsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HonorFrame.honorObjectivesText:SetPoint("TOPLEFT", HonorFrame.honorKillsText, "BOTTOMLEFT", 0, -4)
    HonorFrame.honorObjectivesText:SetJustifyH("LEFT")
    HonorFrame.honorObjectivesText:SetText("Honneur objectif: 0")
    
    HonorFrame.totalHonorText = statsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    HonorFrame.totalHonorText:SetPoint("TOPLEFT", HonorFrame.honorObjectivesText, "BOTTOMLEFT", 0, -4)
    HonorFrame.totalHonorText:SetJustifyH("LEFT")
    HonorFrame.totalHonorText:SetText("Total: 0")
    
    -- Bouton de fermeture
    local closeButton = CreateFrame("Button", nil, HonorFrame)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint("TOPRIGHT", -4, -4)
    
    -- Texte de la croix
    local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    closeText:SetPoint("CENTER", 0, 0)
    closeText:SetText("×")
    closeText:SetTextColor(0.7, 0.7, 0.7)
    
    closeButton:SetScript("OnEnter", function()
        closeText:SetTextColor(1, 1, 1)
    end)
    
    closeButton:SetScript("OnLeave", function()
        closeText:SetTextColor(0.7, 0.7, 0.7)
    end)
    
    closeButton:SetScript("OnMouseDown", function()
        closeText:SetPoint("CENTER", 1, -1)
    end)
    
    closeButton:SetScript("OnMouseUp", function()
        closeText:SetPoint("CENTER", 0, 0)
    end)
    
    closeButton:SetScript("OnClick", function()
        GHonorDB.showOutsideBG = false
        if not isInBattleground then
            HonorFrame:Hide()
        end
    end)
    
    if not GHonorDB.showOutsideBG then
        HonorFrame:Hide()
    end
end

-- Création des commandes slash
function GHonor:CreateSlashCommands()
    SLASH_GHONOR1 = "/ghonor"
    SlashCmdList["GHONOR"] = function(msg)
        msg = msg:lower()
        if msg == "show" then
            GHonorDB.showOutsideBG = true
            HonorFrame:Show()
            print("|cFF00FF00GHonor:|r Fenêtre affichée")
        elseif msg == "hide" then
            GHonorDB.showOutsideBG = false
            if not isInBattleground then
                HonorFrame:Hide()
            end
            print("|cFF00FF00GHonor:|r Fenêtre masquée hors champ de bataille")
        elseif msg == "reset" then
            GHonorDB.point = defaults.point
            GHonorDB.relativePoint = defaults.relativePoint
            GHonorDB.xOfs = defaults.xOfs
            GHonorDB.yOfs = defaults.yOfs
            HonorFrame:ClearAllPoints()
            HonorFrame:SetPoint(GHonorDB.point, UIParent, GHonorDB.relativePoint, GHonorDB.xOfs, GHonorDB.yOfs)
            print("|cFF00FF00GHonor:|r Position réinitialisée")
        else
            print("|cFF00FF00GHonor - Commandes disponibles:|r")
            print("  /ghonor show - Affiche la fenêtre")
            print("  /ghonor hide - Masque la fenêtre hors champ de bataille")
            print("  /ghonor reset - Réinitialise la position de la fenêtre")
        end
    end
end

-- Gestion des événements
function GHonor:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:CheckBattleground()
    elseif event == "UPDATE_BATTLEFIELD_SCORE" then
        self:UpdateBattlefieldStats()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        self:CheckBattleground()
    elseif event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
        local text = ...
        self:ProcessHonorMessage(text)
    elseif event == "PLAYER_PVP_KILLS_CHANGED" then
        self:UpdateKillCount()
    elseif event == "COMBAT_TEXT_UPDATE" then
        local combatTextType = ...
        if combatTextType == "HONOR_GAINED" then
            local amount = select(2, ...)
            self:ProcessHonorGain(amount)
        end
    end
end

-- Traitement des gains d'honneur
function GHonor:ProcessHonorGain(amount)
    if not isInBattleground then return end
    
    -- Mise à jour de l'honneur total
    if amount and amount > 0 then
        currentBGHonor = currentBGHonor + amount
        self:UpdateDisplay()
    end
end

-- Traitement des messages d'honneur
function GHonor:ProcessHonorMessage(text)
    if not isInBattleground then return end
    
    -- Analyse du message pour déterminer si c'est un kill ou un objectif
    if text:find("victoire honorable") then
        -- C'est un kill honorable
        local honor = tonumber(text:match("(%d+)"))
        if honor then
            honorFromKills = honorFromKills + honor
        end
    else
        -- C'est probablement un objectif
        local honor = tonumber(text:match("(%d+)"))
        if honor then
            honorFromObjectives = honorFromObjectives + honor
        end
    end
    
    self:UpdateDisplay()
end

-- Mise à jour du nombre de kills
function GHonor:UpdateKillCount()
    if not isInBattleground then return end
    
    -- Récupération du nombre de kills dans le champ de bataille
    local numScores = GetNumBattlefieldScores()
    for i = 1, numScores do
        local name, kb, hk = GetBattlefieldScore(i)
        if name == UnitName("player") then
            honorableKills = hk
            break
        end
    end
    
    self:UpdateDisplay()
end

-- Mise à jour des statistiques du champ de bataille
function GHonor:UpdateBattlefieldStats()
    if not isInBattleground then return end
    
    local numScores = GetNumBattlefieldScores()
    for i = 1, numScores do
        local name, kb, hk, deaths, honorGained = GetBattlefieldScore(i)
        if name == UnitName("player") then
            honorableKills = hk
            if honorGained and honorGained > 0 then
                currentBGHonor = honorGained
            end
            self:UpdateDisplay()
            break
        end
    end
end

-- Vérification si le joueur est dans un champ de bataille
function GHonor:CheckBattleground()
    local inInstance, instanceType = IsInInstance()
    local wasInBG = isInBattleground
    isInBattleground = (inInstance and instanceType == "pvp")
    
    if isInBattleground and not wasInBG then
        -- Reset des compteurs pour le nouveau BG
        honorFromKills = 0
        honorFromObjectives = 0
        honorableKills = 0
        currentBGHonor = 0
        self:UpdateBattlefieldStats()
        HonorFrame:Show()
    elseif not isInBattleground and wasInBG and not GHonorDB.showOutsideBG then
        HonorFrame:Hide()
    end
end

-- Mise à jour de l'affichage
function GHonor:UpdateDisplay()
    if not HonorFrame then return end
    
    HonorFrame.hkText:SetText(string.format("Nombre VH: %d", honorableKills))
    HonorFrame.honorKillsText:SetText(string.format("Honneur VH: %d", honorFromKills))
    HonorFrame.honorObjectivesText:SetText(string.format("Honneur objectif: %d", honorFromObjectives))
    HonorFrame.totalHonorText:SetText(string.format("Total: %d", honorFromKills + honorFromObjectives))
end

-- Initialisation
GHonor:Init() 