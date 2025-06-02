local addonName, addon = ...
local Frame = {}

local defaultConfig = {
    width = 180,
    height = 105,
    bgColor = {0, 0, 0, 0.8},
    borderColor = {0.5, 0.5, 0.5, 0.8},
    titleBgColor = {0.2, 0.2, 0.2, 0.9},
    titleTextColor = {1, 0.82, 0},
    titleHeight = 20,
    padding = 8,
    strata = "LOW",  -- HIGH, MEDIUM, LOW, BACKGROUND
    level = 1
}

-- Création d'une nouvelle frame
function Frame:Create(title, name, point, relativePoint, xOfs, yOfs, isLocked, config)
    local frame = CreateFrame("Frame", name, UIParent)
    local settings = config or defaultConfig
    
    -- Configuration de base
    frame:SetSize(settings.width, settings.height)
    frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    -- Configuration du z-index
    frame:SetFrameStrata(settings.strata)
    frame:SetFrameLevel(settings.level)
    
    -- État de verrouillage
    frame.isLocked = isLocked or false
    
    -- Gestion du déplacement
    frame:SetScript("OnDragStart", function(self)
        if not self.isLocked then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if self.OnMove then
            local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
            self:OnMove(point, relativePoint, xOfs, yOfs)
        end
    end)
    
    -- Fond principal
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(settings.bgColor))
    
    -- Bordures
    local borders = {
        {point = "TOPLEFT", point2 = "TOPRIGHT", height = 2},
        {point = "BOTTOMLEFT", point2 = "BOTTOMRIGHT", height = 2},
        {point = "TOPLEFT", point2 = "BOTTOMLEFT", width = 2},
        {point = "TOPRIGHT", point2 = "BOTTOMRIGHT", width = 2}
    }
    
    for _, border in ipairs(borders) do
        local borderFrame = frame:CreateTexture(nil, "BORDER")
        borderFrame:SetPoint(border.point, 0, 0)
        borderFrame:SetPoint(border.point2, 0, 0)
        if border.height then
            borderFrame:SetHeight(border.height)
        else
            borderFrame:SetWidth(border.width)
        end
        borderFrame:SetColorTexture(unpack(settings.borderColor))
    end
    
    -- Titre
    local titleBg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    titleBg:SetPoint("TOPLEFT", 2, -2)
    titleBg:SetPoint("TOPRIGHT", -2, -2)
    titleBg:SetHeight(settings.titleHeight)
    titleBg:SetColorTexture(unpack(settings.titleBgColor))
    
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.title:SetPoint("CENTER", titleBg, "CENTER", 0, 0)
    frame.title:SetText(title)
    frame.title:SetTextColor(unpack(settings.titleTextColor))
    
    -- Conteneur pour le contenu
    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetPoint("TOPLEFT", settings.padding, -(settings.titleHeight + settings.padding))
    frame.content:SetPoint("BOTTOMRIGHT", -settings.padding, settings.padding)
    
    -- Bouton de verrouillage
    local lockButton = CreateFrame("Button", nil, frame)
    lockButton:SetSize(16, 16)
    lockButton:SetPoint("TOPRIGHT", -24, -4)
    
    local lockText = lockButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lockText:SetPoint("CENTER", 0, 0)
    lockText:SetText("_")
    lockText:SetTextColor(0.7, 0.7, 0.7)
    
    lockButton:SetScript("OnEnter", function()
        lockText:SetTextColor(1, 1, 1)
        GameTooltip:SetOwner(lockButton, "ANCHOR_TOP")
        GameTooltip:SetText(frame.isLocked and "Déverrouiller" or "Verrouiller")
        GameTooltip:Show()
    end)
    
    lockButton:SetScript("OnLeave", function()
        lockText:SetTextColor(0.7, 0.7, 0.7)
        GameTooltip:Hide()
    end)
    
    lockButton:SetScript("OnClick", function()
        frame.isLocked = not frame.isLocked
        lockText:SetText(frame.isLocked and "-" or "_")
        if frame.OnLock then
            frame:OnLock(frame.isLocked)
        end
    end)
    
    -- Bouton de fermeture
    local closeButton = CreateFrame("Button", nil, frame)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint("TOPRIGHT", -4, -4)
    
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
        if frame.OnClose then
            frame:OnClose()
        else
            frame:Hide()
        end
    end)
    
    -- Méthodes pour ajouter du texte
    function frame:AddText(text, options)
        options = options or {}
        local textFrame = self.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        textFrame:SetPoint(options.point or "TOPLEFT", options.relativeTo or self.content, options.relativePoint or "TOPLEFT", options.xOfs or 0, options.yOfs or 0)
        textFrame:SetJustifyH(options.justifyH or "LEFT")
        textFrame:SetText(text)
        return textFrame
    end
    
    -- Méthode pour verrouiller/déverrouiller la frame
    function frame:SetLocked(locked)
        self.isLocked = locked
        lockText:SetText(self.isLocked and "-" or "_")
    end
    
    -- Méthode pour changer le z-index
    function frame:SetZIndex(strata, level)
        self:SetFrameStrata(strata or settings.strata)
        self:SetFrameLevel(level or settings.level)
    end
    
    return frame
end

-- Exporter la classe
addon.Frame = Frame 