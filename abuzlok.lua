-- Вспомогательная функция для поиска роли
local function getRole(player)
    -- 1. Стандартный Team
    local ok1, team = pcall(function() return player.Team end)
    if ok1 and team then
        local teamName = team.Name:lower()
        if teamName:find("killer") or teamName:find("убийца") or teamName:find("slasher") then
            return "Killer"
        end
        if teamName:find("survivor") or teamName:find("выжив") or teamName:find("runner") then
            return "Survivor"
        end
    end

    -- 2. Атрибуты (безопасно)
    local ok2, roleAttr = pcall(function()
        return player:GetAttribute("Role") or player:GetAttribute("Team") or player:GetAttribute("role")
    end)
    if ok2 and roleAttr then
        local r = tostring(roleAttr):lower()
        if r:find("killer") then return "Killer" end
        if r:find("survivor") then return "Survivor" end
    end

    -- 3. leaderstats (безопасно)
    local ok3, ls = pcall(function() return player:FindFirstChild("leaderstats") end)
    if ok3 and ls then
        local roleStat = ls:FindFirstChild("Role") or ls:FindFirstChild("Team")
        if roleStat then
            local r = tostring(roleStat.Value):lower()
            if r:find("killer") then return "Killer" end
            if r:find("survivor") then return "Survivor" end
        end
    end

    -- 4. По имени персонажа
    local char = player.Character
    if char then
        local cn = char.Name:lower()
        if cn:find("killer") then return "Killer" end
        if cn:find("survivor") then return "Survivor" end
    end

    -- 5. По имени игрока
    local n = player.Name:lower()
    if n:find("killer") then return "Killer" end

    -- По умолчанию — выживший
    return "Survivor"
end
