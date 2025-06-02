local addonName, addon = ...

-- Table de traductions
local L = {
    frFR = {
        ["GHonor"] = "GHonor",
        ["Nombre VH"] = "Nombre VH",
        ["Honneur VH"] = "Honneur VH",
        ["Honneur objectif"] = "Honneur objectif",
        ["Total"] = "Total",
        ["Fenêtre affichée"] = "Fenêtre affichée",
        ["Fenêtre masquée hors champ de bataille"] = "Fenêtre masquée hors champ de bataille",
        ["Position réinitialisée"] = "Position réinitialisée",
        ["Commandes disponibles"] = "Commandes disponibles",
        ["Affiche la fenêtre"] = "Affiche la fenêtre",
        ["Masque la fenêtre hors champ de bataille"] = "Masque la fenêtre hors champ de bataille",
        ["Réinitialise la position de la fenêtre"] = "Réinitialise la position de la fenêtre"
    },
    enUS = {
        ["GHonor"] = "GHonor",
        ["Nombre VH"] = "HK Count",
        ["Honneur VH"] = "HK Honor",
        ["Honneur objectif"] = "Objective Honor",
        ["Total"] = "Total",
        ["Fenêtre affichée"] = "Window shown",
        ["Fenêtre masquée hors champ de bataille"] = "Window hidden outside battleground",
        ["Position réinitialisée"] = "Position reset",
        ["Commandes disponibles"] = "Available commands",
        ["Affiche la fenêtre"] = "Show window",
        ["Masque la fenêtre hors champ de bataille"] = "Hide window outside battleground",
        ["Réinitialise la position de la fenêtre"] = "Reset window position"
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