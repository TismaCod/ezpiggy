--[[ =========================
      SCRIPT FINAL PIGGY GUI
      (Intégration Rayfield + modules fusionnés)
========================= ]]

-- Chargement de la librairie Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Création de la fenêtre principale Rayfield
local Window = Rayfield:CreateWindow({
    Name = "EZ 🐷 HUB",
    LoadingTitle = "In Progression...",
    LoadingSubtitle = "by Mimir💤",
    Discord = {
        Enabled = true,
        Invite = "MuVPBab66F"
    }
})

--[[ =========================
      SECTION ESP
========================= ]]
local ESP = {
    piggy = false,
    players = false,
    objects = false,
    highlights = {}, -- [Instance] = Highlight
    nameTags = {},   -- [Instance] = BillboardGui
    trap = false,
    ghost = false
}

-- Couleurs personnalisables
ESP.enemyColor = Color3.new(1, 0, 0)
ESP.playersColor = Color3.new(1, 1, 0)
ESP.trapColor = Color3.new(1, 0, 0)
ESP.ghostColor = Color3.fromRGB(0, 170, 255)

-- Fonction utilitaire pour nettoyer les highlights et nameTags qui ne sont plus valides
function ESP:cleanOrphans()
    for inst, h in pairs(self.highlights) do
        if not inst or not inst.Parent or not h or not h.Parent then
            if h and h.Parent then h:Destroy() end
            self.highlights[inst] = nil
        end
    end
    for inst, tag in pairs(self.nameTags) do
        if not inst or not inst.Parent or not tag or not tag.Parent then
            if tag and tag.Parent then tag:Destroy() end
            self.nameTags[inst] = nil
        end
    end
end

-- Fonction pour ajouter ou mettre à jour un Highlight sur un Model ou Part (avec couleur paramétrable)
function ESP:addOrUpdateHighlight(target, color)
    local highlight = self.highlights[target]
    if not highlight or not highlight.Parent then
        highlight = Instance.new("Highlight")
        highlight.Parent = target
        self.highlights[target] = highlight
    end
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Enabled = true
end

-- Fonction pour retirer un Highlight d'un Model ou Part
function ESP:removeHighlight(target)
    local highlight = self.highlights[target]
    if highlight and highlight.Parent then
        highlight:Destroy()
    end
    self.highlights[target] = nil
end

-- Fonction pour ajouter ou mettre à jour un BillboardGui avec le pseudo
function ESP:addOrUpdateNameTag(model, text)
    if not model:FindFirstChild("Head") then return end
    local tag = self.nameTags[model]
    if not tag or not tag.Parent then
        tag = Instance.new("BillboardGui")
        tag.Name = "PiggyNameTag"
        tag.Size = UDim2.new(0, 100, 0, 20)
        tag.Adornee = model.Head
        tag.AlwaysOnTop = true
        tag.StudsOffset = Vector3.new(0, 2, 0)
        tag.Parent = model.Head
        local label = Instance.new("TextLabel")
        label.Name = "TextLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = false
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.Parent = tag
        self.nameTags[model] = tag
    end
    -- Mettre à jour le texte uniquement si besoin
    local label = tag:FindFirstChild("TextLabel")
    if label and label.Text ~= text then
        label.Text = text
    end
    tag.Enabled = true
end

function ESP:removeNameTag(model)
    local tag = self.nameTags[model]
    if tag and tag.Parent then
        tag:Destroy()
    end
    self.nameTags[model] = nil
end

-- Fonction pour ajouter ou mettre à jour un Highlight Trap (utilise la couleur paramétrable)
function ESP:addOrUpdateTrapHighlight(part)
    local highlight = self.highlights[part]
    if not highlight or not highlight.Parent then
        highlight = Instance.new("Highlight")
        highlight.Parent = part
        self.highlights[part] = highlight
    end
    highlight.FillColor = self.trapColor
    highlight.OutlineColor = self.trapColor
    highlight.Enabled = true
end

function ESP.toggleGhostESP(state)
    ESP.ghost = state
    ESP:refresh()
end

function ESP:refresh()
    self:cleanOrphans()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local usedHighlights = {}
    local usedNameTags = {}
    -- Enemy ESP (Piggy + Traitor)
    if self.piggy then
        local piggyNPC = Workspace:FindFirstChild("PiggyNPC")
        if piggyNPC then
            for _, child in ipairs(piggyNPC:GetChildren()) do
                if child:IsA("Model") and child:FindFirstChild("Head") then
                    self:addOrUpdateHighlight(child, self.enemyColor)
                    self:addOrUpdateNameTag(child, "PiggyNPC : " .. child.Name)
                    usedHighlights[child] = true
                    usedNameTags[child] = true
                end
            end
            if piggyNPC:IsA("Model") and piggyNPC:FindFirstChild("Head") then
                self:addOrUpdateHighlight(piggyNPC, self.enemyColor)
                self:addOrUpdateNameTag(piggyNPC, "PiggyNPC : " .. piggyNPC.Name)
                usedHighlights[piggyNPC] = true
                usedNameTags[piggyNPC] = true
            end
        end
        -- Ajout de TOUS les Piggy (Enemy sans Ghost)
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and Players:FindFirstChild(model.Name) then
                local isEnemy = model:FindFirstChild("Enemy") and model.Enemy:IsA("BoolValue") and model.Enemy.Value
                local isGhost = model:FindFirstChild("Ghost") and model.Ghost:IsA("BoolValue") and model.Ghost.Value
                if isEnemy and not isGhost then
                    self:addOrUpdateHighlight(model, self.enemyColor)
                    self:addOrUpdateNameTag(model, "Piggy : " .. model.Name)
                    usedHighlights[model] = true
                    usedNameTags[model] = true
                end
            end
        end
        -- Ajout des Traitors
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and Players:FindFirstChild(model.Name) then
                local isTraitor = model:FindFirstChild("Traitor") and model.Traitor:IsA("BoolValue") and model.Traitor.Value
                local isGhost = model:FindFirstChild("Ghost") and model.Ghost:IsA("BoolValue") and model.Ghost.Value
                if isTraitor and not isGhost then
                    self:addOrUpdateHighlight(model, self.enemyColor)
                    self:addOrUpdateNameTag(model, "Traitor : " .. model.Name)
                    usedHighlights[model] = true
                    usedNameTags[model] = true
                end
            end
        end
    end
    -- Players ESP
    if self.players then
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and Players:FindFirstChild(model.Name) then
                local isEnemy = model:FindFirstChild("Enemy") and model.Enemy:IsA("BoolValue") and model.Enemy.Value
                local isTraitor = model:FindFirstChild("Traitor") and model.Traitor:IsA("BoolValue") and model.Traitor.Value
                local isGhost = model:FindFirstChild("Ghost") and model.Ghost:IsA("BoolValue") and model.Ghost.Value
                if not isGhost and not isEnemy and not isTraitor then
                    self:addOrUpdateHighlight(model, self.playersColor)
                    self:addOrUpdateNameTag(model, model.Name)
                    usedHighlights[model] = true
                    usedNameTags[model] = true
                end
            end
        end
    end
    -- Ghost ESP
    if self.ghost then
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and Players:FindFirstChild(model.Name) then
                local isGhost = model:FindFirstChild("Ghost") and model.Ghost:IsA("BoolValue") and model.Ghost.Value
                if isGhost then
                    self:addOrUpdateHighlight(model, self.ghostColor)
                    self:addOrUpdateNameTag(model, "Ghost : " .. model.Name)
                    usedHighlights[model] = true
                    usedNameTags[model] = true
                end
            end
        end
    end
    -- Object ESP
    if self.objects then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Folder") and obj.Name ~= "GameFolder" and obj.Name ~= "LoadedMap" and obj.Name ~= "PiggyNPC" then
                for _, part in ipairs(obj:GetChildren()) do
                    if part:IsA("BasePart") then
                        local emitter = part:FindFirstChildOfClass("ParticleEmitter")
                        if emitter then
                            self:addOrUpdateHighlight(part, emitter.Color.Keypoints[1].Value)
                            usedHighlights[part] = true
                        end
                    end
                end
            end
        end
    end
    -- Trap ESP (activé automatiquement avec Enemy ESP)
    if self.piggy then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Folder") and obj.Name ~= "GameFolder" and obj.Name ~= "LoadedMap" and obj.Name ~= "PiggyNPC" then
                for _, part in ipairs(obj:GetChildren()) do
                    if part:IsA("BasePart") and not part:FindFirstChildOfClass("ClickDetector") then
                        self:addOrUpdateTrapHighlight(part)
                        usedHighlights[part] = true
                    end
                end
            end
        end
    end
    -- Désactiver les Highlights/NameTags non utilisés
    for inst, h in pairs(self.highlights) do
        if not usedHighlights[inst] and h and h.Parent then
            h.Enabled = false
        end
    end
    for inst, tag in pairs(self.nameTags) do
        if not usedNameTags[inst] and tag and tag.Parent then
            tag:Destroy()
            self.nameTags[inst] = nil
        end
    end
    -- Supprimer tous les nameTags si aucun ESP n'est actif
    if not self.piggy and not self.players and not self.ghost then
        for inst, tag in pairs(self.nameTags) do
            if tag and tag.Parent then
                tag:Destroy()
            end
            self.nameTags[inst] = nil
        end
    end
end

function ESP:init()
    self:refresh()
    if self._conn then self._conn:Disconnect() end
    self._conn = game:GetService("RunService").RenderStepped:Connect(function()
        self:refresh()
    end)
end

function ESP:stop()
    if self._conn then self._conn:Disconnect() end
    self:clear()
end

function ESP.togglePiggyESP(state)
    ESP.piggy = state
    ESP:refresh()
end
function ESP.togglePlayersESP(state)
    ESP.players = state
    ESP:refresh()
end
function ESP.toggleObjectESP(state)
    ESP.objects = state
    ESP:refresh()
end

-- Rafraîchissement automatique de l'ESP toutes les secondes
spawn(function()
    while true do
        wait(1)
        ESP:refresh()
    end
end)

--[[ =========================
      SECTION TP OBJECTS
========================= ]]
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local collectibleParts = {}
local partBoxes = {}
local screenGui = nil
local mainContainer = nil
local isTeleportingSoul = false

local function simulateClickOnPart(part)
    if isTeleportingSoul then return end
    isTeleportingSoul = true
    local clickDetector = part:FindFirstChildOfClass("ClickDetector")
    if clickDetector and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        local humanoid = player.Character.Humanoid
        local originalCFrame = humanoidRootPart.CFrame
        local originalPlatformStand = humanoid.PlatformStand
        humanoid.PlatformStand = true
        humanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0.5, 0)
        -- Maintenir la position pendant 0.5s pour éviter de tomber
        local holdTime = 0.5
        local start = tick()
        while tick() - start < holdTime do
            humanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0.5, 0)
            task.wait()
        end
        wait(0.07)
        pcall(function()
            fireclickdetector(clickDetector)
        end)
        wait(0.2)
        humanoidRootPart.CFrame = originalCFrame
        humanoid.PlatformStand = originalPlatformStand
    end
    wait(0.5)
    isTeleportingSoul = false
end

local function teleportToPart(part)
    simulateClickOnPart(part)
end

local function collectAllParts()
    collectibleParts = {}
    for _, child in pairs(workspace:GetChildren()) do
        if child:IsA("Folder") and child.Name ~= "GameFolder" and child.Name ~= "LoadedMap" and child.Name ~= "PiggyNPC" then
            for _, part in pairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(collectibleParts, part)
                end
            end
            break
        end
    end
    return collectibleParts
end

local function refreshBoxes()
    for _, box in pairs(partBoxes) do
        if box then box:Destroy() end
    end
    partBoxes = {}
    for i, part in pairs(collectibleParts) do
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 80, 0, 80)
        box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        box.BorderSizePixel = 3
        box.BorderColor3 = Color3.fromRGB(255, 80, 180)
        local totalWidth = #collectibleParts * 90 - 10
        local startX = -totalWidth / 2
        box.Position = UDim2.new(0.5, startX + (i-1) * 90, 0, 10)
        box.Parent = mainContainer
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 10)
        boxCorner.Parent = box
        local viewport = Instance.new("ViewportFrame")
        viewport.Size = UDim2.new(1, -10, 1, -10)
        viewport.Position = UDim2.new(0, 5, 0, 5)
        viewport.BackgroundTransparency = 1
        viewport.BorderSizePixel = 0
        viewport.Parent = box
        local partClone = part:Clone()
        partClone.Parent = viewport
        local cam = Instance.new("Camera")
        cam.CameraType = Enum.CameraType.Fixed
        local objectPosition = part.Position
        local cameraPosition = objectPosition + Vector3.new(0, 3, 0)
        cam.CoordinateFrame = CFrame.new(cameraPosition, objectPosition)
        cam.Parent = viewport
        viewport.CurrentCamera = cam
        local light = Instance.new("PointLight")
        light.Brightness = 2
        light.Range = 15
        light.Parent = partClone
        box.MouseEnter:Connect(function()
            box.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
        box.MouseLeave:Connect(function()
            box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        box.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                teleportToPart(part)
            end
        end)
        table.insert(partBoxes, box)
    end
end

local function createSimpleUI()
    if screenGui then screenGui:Destroy() end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleObjectCollector"
    screenGui.Parent = playerGui
    mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(1, 0, 0, 100)
    mainContainer.Position = UDim2.new(0, 0, 1, -100)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = screenGui
    refreshBoxes()
    spawn(function()
        while screenGui and screenGui.Parent do
            wait(1)
            collectAllParts()
            refreshBoxes()
        end
    end)
end

local function refreshObjects()
    collectAllParts()
    createSimpleUI()
end

local function initTPObject()
    collectAllParts()
    createSimpleUI()
end

--[[ =========================
      SECTION PIGGY (KILL ALL)
========================= ]]
-- Onglet ESP (doit être créé avant PiggyTab)
local TabESP = Window:CreateTab("ESP", 4483362458)
TabESP:CreateToggle({
    Name = "Enemy ESP",
    CurrentValue = false,
    Callback = function(state)
        ESP.togglePiggyESP(state)
    end
})
TabESP:CreateToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Callback = function(state)
        ESP.togglePlayersESP(state)
    end
})
TabESP:CreateToggle({
    Name = "Object ESP",
    CurrentValue = false,
    Callback = function(state)
        ESP.toggleObjectESP(state)
    end
})
TabESP:CreateToggle({
    Name = "Ghost ESP",
    CurrentValue = false,
    Callback = function(state)
        ESP.toggleGhostESP(state)
    end
})
-- Onglet Piggy (ordre demandé)
local TabPiggy = Window:CreateTab("Piggy", 4483362458)
TabPiggy:CreateButton({
    Name = "Kill All",
    Callback = function()
        _G.StopKillAll = false
        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local localPlayer = Players.LocalPlayer
        local myModel = Workspace:FindFirstChild(localPlayer.Name)
        if myModel and myModel:FindFirstChild("Ghost") and myModel.Ghost:IsA("BoolValue") and myModel.Ghost.Value then
            Rayfield:Notify({
                Title = "Piggy Hub",
                Content = "You cannot use Kill All as a Ghost!",
                Duration = 3,
                Image = 4483362458
            })
            return
        end
        if myModel and myModel:FindFirstChild("Enemy") and myModel.Enemy:IsA("BoolValue") and myModel.Enemy.Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if _G.StopKillAll then break end
                if player ~= localPlayer then
                    local targetModel = Workspace:FindFirstChild(player.Name)
                    if targetModel and targetModel:FindFirstChild("HumanoidRootPart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local isEnemy = targetModel:FindFirstChild("Enemy") and targetModel.Enemy:IsA("BoolValue") and targetModel.Enemy.Value
                        if not isEnemy then
                            local hrp = localPlayer.Character.HumanoidRootPart
                            local targetHRP = targetModel.HumanoidRootPart
                            local start = tick()
                            while tick() - start < 2 do
                                if _G.StopKillAll then break end
                                if hrp and targetHRP then
                                    hrp.CFrame = targetHRP.CFrame
                                end
                                task.wait()
                            end
                        end
                    end
                end
            end
        else
            Rayfield:Notify({
                Title = "Piggy Hub",
                Content = "You must be Piggy to use this function!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})
TabPiggy:CreateButton({
    Name = "Stop Kill All",
    Callback = function()
        _G.StopKillAll = true
    end
})
TabPiggy:CreateDivider()
local selectedPlayer = nil
local playerDropdown = nil
local function getPlayerNamesExceptLocal()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end
playerDropdown = TabPiggy:CreateDropdown({
    Name = "Choose Player",
    Options = getPlayerNamesExceptLocal(),
    CurrentOption = nil,
    Callback = function(option)
        if type(option) == "table" then
            selectedPlayer = option[1]
        else
            selectedPlayer = option
        end
    end
})
TabPiggy:CreateButton({
    Name = "Kill Player",
    Callback = function()
        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local localPlayer = Players.LocalPlayer
        local myModel = Workspace:FindFirstChild(localPlayer.Name)
        if not selectedPlayer then
            Rayfield:Notify({
                Title = "Piggy Hub",
                Content = "No player selected!",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        if not (myModel and myModel:FindFirstChild("Enemy") and myModel.Enemy:IsA("BoolValue") and myModel.Enemy.Value) then
            Rayfield:Notify({
                Title = "Piggy Hub",
                Content = "You must be Piggy to use this function!",
                Duration = 3,
                Image = 4483362458
            })
            return
        end
        local targetModel = Workspace:FindFirstChild(selectedPlayer)
        if targetModel and targetModel:FindFirstChild("HumanoidRootPart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local isEnemy = targetModel:FindFirstChild("Enemy") and targetModel.Enemy:IsA("BoolValue") and targetModel.Enemy.Value
            if isEnemy then
                Rayfield:Notify({
                    Title = "Piggy Hub",
                    Content = "You cannot target another Piggy!",
                    Duration = 2,
                    Image = 4483362458
                })
                return
            end
            local hrp = localPlayer.Character.HumanoidRootPart
            local targetHRP = targetModel.HumanoidRootPart
            local start = tick()
            while tick() - start < 2 do
                if hrp and targetHRP then
                    hrp.CFrame = targetHRP.CFrame
                end
                task.wait()
            end
        end
    end
})
-- Rafraîchir dynamiquement le dropdown toutes les 5 secondes
spawn(function()
    while true do
        task.wait(5)
        if playerDropdown and playerDropdown.Refresh then
            playerDropdown:Refresh(getPlayerNamesExceptLocal())
        end
    end
end)

-- Onglet TP Objects (ordre demandé)
local TabTP = Window:CreateTab("TP Objets", 4483362458)
TabTP:CreateButton({
    Name = "Show UI",
    Callback = function()
        initTPObject()
    end
})
TabTP:CreateButton({
    Name = "Close UI",
    Callback = function()
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
            screenGui = nil
        end
    end
})

-- Onglet Customization
local TabCustom = Window:CreateTab("Customization", 4483362458)
TabCustom:CreateColorPicker({
    Name = "Enemy ESP Color",
    Color = ESP.enemyColor,
    Callback = function(color)
        ESP.enemyColor = color
    end
})
TabCustom:CreateColorPicker({
    Name = "Players ESP Color",
    Color = ESP.playersColor,
    Callback = function(color)
        ESP.playersColor = color
    end
})
TabCustom:CreateColorPicker({
    Name = "Ghost ESP Color",
    Color = ESP.ghostColor,
    Callback = function(color)
        ESP.ghostColor = color
    end
})

-- Onglet Miscellaneous (ordre demandé)
local TabMisc = Window:CreateTab("Miscellaneous", 4483362458)

TabMisc:CreateButton({
    Name = "Destroy PiggyNPC",
    Callback = function()
        local Workspace = game:GetService("Workspace")
        local piggyNPC = Workspace:FindFirstChild("PiggyNPC")
        if piggyNPC then
            for _, child in ipairs(piggyNPC:GetChildren()) do
                if child:IsA("Model") then
                    child:Destroy()
                end
            end
        end
    end
})

TabMisc:CreateToggle({
    Name = "Uneffective Traps",
    CurrentValue = false,
    Callback = function(state)
        local Workspace = game:GetService("Workspace")
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Folder") and obj.Name ~= "GameFolder" and obj.Name ~= "LoadedMap" and obj.Name ~= "PiggyNPC" then
                for _, part in ipairs(obj:GetChildren()) do
                    if part:IsA("BasePart") and not part:FindFirstChildOfClass("ClickDetector") then
                        part.CanCollide = not state and true or false
                        part.CanQuery = not state and true or false
                        part.CanTouch = not state and true or false
                    end
                end
            end
        end
    end
})

TabMisc:CreateDivider()

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local baseWalkSpeed = 16
local baseJumpPower = 50
if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
    local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    baseWalkSpeed = humanoid.WalkSpeed
    baseJumpPower = humanoid.JumpPower
end

TabMisc:CreateSlider({
    Name = "Speed Boost",
    Range = {0, 100},
    Increment = 1,
    Suffix = "Boost",
    CurrentValue = 0,
    Callback = function(value)
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = baseWalkSpeed + value
        end
    end
})

TabMisc:CreateSlider({
    Name = "Jump Boost",
    Range = {0, 100},
    Increment = 1,
    Suffix = "Boost",
    CurrentValue = 0,
    Callback = function(value)
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = baseJumpPower + value
        end
    end
})

-- Onglet NoClip
local TabNoClip = Window:CreateTab("NoClip", 4483362458)

TabNoClip:CreateToggle({
    Name = "Invisible Walls",
    CurrentValue = false,
    Callback = function(state)
        local Workspace = game:GetService("Workspace")
        local loadedMap = Workspace:FindFirstChild("LoadedMap")
        if loadedMap then
            for _, part in ipairs(loadedMap:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency == 1 then
                    part.CanCollide = not state and true or false
                end
            end
        end
    end
})

TabNoClip:CreateToggle({
    Name = "Doors",
    CurrentValue = false,
    Callback = function(state)
        local Workspace = game:GetService("Workspace")
        local Players = game:GetService("Players")
        local playerNames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(playerNames, p.Name)
        end
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and not table.find(playerNames, model.Name)
                and model.Name ~= "Spawns" and model.Name ~= "MainMenuScreen" and model.Name ~= "PlayerDummy" then
                for _, descendant in ipairs(model:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.Material == Enum.Material.Wood then
                        descendant.CanCollide = not state and true or false
                    end
                end
            end
        end
    end
})

-- Onglet Changelogs
local TabChangelogs = Window:CreateTab("Changelogs", 4483362458)

TabChangelogs:CreateParagraph({
    Title = "Changelogs",
    Content = [[

--- ESP ---
• Enemy ESP (Piggy, Traitor, customizable color)
• Players ESP (customizable color)
• Ghost ESP (customizable color)
• Object ESP (highlight map objects)
• Trap ESP (automatic with Enemy ESP)
• Color pickers for each ESP

--- TP Objects ---
• Teleportation UI for all map objects
• Reliable teleportation (anti-fall)
• Close UI on demand

--- Piggy ---
• Kill All (sticks to target, only targets innocents)
• Stop Kill All
• Kill Player (dynamic dropdown, only targets innocents)

--- NoClip ---
• Invisible Walls (CanCollide off on transparent walls)
• Doors (CanCollide off on wooden doors)
• General NoClip (to be completed)

--- Miscellaneous ---
• Destroy PiggyNPC
• Uneffective Traps (disables collisions and interactions for traps)
• Speed Boost (slider, bonus on speed)
• Jump Boost (slider, bonus on jump)

--- Other ---
• Modern and clear Rayfield interface
• Changelogs always accessible
• Notifications for every important action
• Join our Discord: discord.gg/MuVPBab66F

]]
})
