local addonName, addon = ...

-- Table de traductions
local L = {
    frFR = {
        ["GHonor"] = "GHonor",
        ["HK Count"] = "Nombre VH",
        ["HK Honor"] = "Honneur VH",
        ["Objective Honor"] = "Honneur objectif",
        ["Total"] = "Total",
        ["Window shown"] = "Fenêtre affichée",
        ["Window hidden outside battleground"] = "Fenêtre masquée hors champ de bataille",
        ["Position reset"] = "Position réinitialisée",
        ["Available commands"] = "Commandes disponibles",
        ["Show window"] = "Affiche la fenêtre",
        ["Hide window outside battleground"] = "Masque la fenêtre hors champ de bataille",
        ["Reset window position"] = "Réinitialise la position de la fenêtre"
    },
    enUS = {
        ["GHonor"] = "GHonor",
        ["HK Count"] = "HK Count",
        ["HK Honor"] = "HK Honor",
        ["Objective Honor"] = "Objective Honor",
        ["Total"] = "Total",
        ["Window shown"] = "Window shown",
        ["Window hidden outside battleground"] = "Window hidden outside battleground",
        ["Position reset"] = "Position reset",
        ["Available commands"] = "Available commands",
        ["Show window"] = "Show window",
        ["Hide window outside battleground"] = "Hide window outside battleground",
        ["Reset window position"] = "Reset window position"
    }
}

-- Fonction de traduction
local function _(text)
    local locale = GetLocale()
    return L[locale] and L[locale][text] or L["enUS"][text] or text
end

-- Exporter les fonctions et tables nécessaires
GHonor_L = L
GHonor_ = _ 