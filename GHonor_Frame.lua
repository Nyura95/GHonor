local addonName, addon = ...
local Frame = {}

-- Création d'une nouvelle frame
function Frame:Create(title, name, point, relativePoint, xOfs, yOfs, isLocked, config)
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    local settings = config or addon.Config.FRAME
    
    -- Configuration de base
    frame:SetSize(settings.width, settings.height)
    frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    -- Configuration du z-index
    frame:SetFrameStrata(settings.strata)
    frame:SetFrameLevel(settings.level)

    -- Style 
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame:SetBackdropColor(0.15, 0.12, 0.1, 0.35)
    frame:SetBackdropBorderColor(0, 0, 0, 0.8)

    -- Suppression des textures de bordure par défaut
    local regions = {frame:GetRegions()}
    for _, region in ipairs(regions) do
        if region:IsObjectType("Texture") then
            region:SetTexture(nil)
        end
    end
    
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

    -- Titre
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -6)
    frame.title:SetText(title)
    frame.title:SetTextColor(1, 1, 1, 1)

    -- Bouton de fermeture
    local closeButton = CreateFrame("Button", nil, frame)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    
    -- Texture de la croix
    local closeTexture = closeButton:CreateTexture(nil, "ARTWORK")
    closeTexture:SetAllPoints()
    closeTexture:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeTexture:SetDesaturated(true)
    closeTexture:SetVertexColor(1, 1, 1, 0.8)
    
    closeButton:SetScript("OnEnter", function()
        closeTexture:SetVertexColor(1, 1, 1, 1)
    end)
    
    closeButton:SetScript("OnLeave", function()
        closeTexture:SetVertexColor(1, 1, 1, 0.8)
    end)
    
    closeButton:SetScript("OnClick", function()
        if frame.OnClose then
            frame:OnClose()
        else
            frame:Hide()
        end
    end)
    
    -- Zone de contenu simple sans fond
    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetPoint("TOPLEFT", 8, -24)
    frame.content:SetPoint("BOTTOMRIGHT", -8, 8)
    
    -- Ajout du redimensionnement
    frame:SetResizable(true)
    -- Création des poignées de redimensionnement
    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetPoint("BOTTOMRIGHT", 0, 0)
    resizeButton:SetSize(16, 16)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not frame.isLocked then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    
    resizeButton:SetScript("OnMouseUp", function(self, button)
      if button == "LeftButton" then
          frame:StopMovingOrSizing()
          -- Vérification de la taille minimale
          local width, height = frame:GetSize()
          if width < settings.minWidth then width = settings.minWidth end
          if height < settings.minHeight then height = settings.minHeight end
          frame:SetSize(width, height)
          
          if frame.OnResize then
              frame:OnResize(width, height)
          end
      end
    end) 
    
    -- Ajout d'un script pour vérifier la taille pendant le redimensionnement
    frame:SetScript("OnSizeChanged", function(self, width, height)
        if width < settings.minWidth then width = settings.minWidth end
        if height < settings.minHeight then height = settings.minHeight end
        if width ~= self:GetWidth() or height ~= self:GetHeight() then
            self:SetSize(width, height)
        end
    end)
    
    -- Fond principal
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(settings.bgColor))
    
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
        frame:SetLocked(not frame.isLocked)
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
        -- Gestion de la visibilité du bouton de redimensionnement
        if locked or not settings.canResize then
          resizeButton:Hide()
        else
          resizeButton:Show()
        end
        if self.OnLock then
            self:OnLock(self.isLocked)
        end
    end
    
    -- Méthode pour changer le z-index
    function frame:SetZIndex(strata, level)
        self:SetFrameStrata(strata or settings.strata)
        self:SetFrameLevel(level or settings.level)
    end
    
    -- Méthode pour sauvegarder la taille
    function frame:SaveSize()
        local width, height = self:GetSize()
        if self.OnSaveSize then
            self:OnSaveSize(width, height)
        end
    end
    
    -- Méthode pour restaurer la taille
    function frame:RestoreSize()
        if defaultConfig.width and defaultConfig.height then
            self:SetSize(defaultConfig.width, defaultConfig.height)
        end
    end
    
    return frame
end

-- Exporter la classe
addon.Frame = Frame 