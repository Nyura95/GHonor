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
        ["Reset window position"] = "Réinitialise la position de la fenêtre",
        ["Toggle window visibility"] = "Affiche/Masque la fenêtre",
        ["Toggle debug mode"] = "Active/Désactive le mode débogage"
    },
    enUS = {
        ["GHonor"] = "GHonor",
        ["HK Count"] = "HK Count",
        ["HK Honor"] = "HK Honor",
        ["Objective Honor"] = "Objective Honor",
        ["Total"] = "Total",
        ["Position reset"] = "Position reset",
        ["Available commands"] = "Available commands",
        ["Show window"] = "Show window",
        ["Hide window outside battleground"] = "Hide window outside battleground",
        ["Reset window position"] = "Reset window position",
        ["Toggle window visibility"] = "Toggle window visibility",
        ["Toggle debug mode"] = "Toggle debug mode"
    },
    ruRU = {
        ["GHonor"] = "GHonor",
        ["HK Count"] = "Количество убийств",
        ["HK Honor"] = "Честь за убийства",
        ["Objective Honor"] = "Честь за цели",
        ["Total"] = "Итого",
        ["Position reset"] = "Сброс позиции",
        ["Available commands"] = "Доступные команды",
        ["Show window"] = "Показать окно",
        ["Hide window outside battleground"] = "Скрыть окно вне поля боя",
        ["Reset window position"] = "Сбросить позицию окна",
        ["Toggle window visibility"] = "Переключить видимость окна",
        ["Toggle debug mode"] = "Переключить режим отладки"
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
