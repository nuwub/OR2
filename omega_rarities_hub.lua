local repo = 'https://raw.githubusercontent.com/nuwub/OR2/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- detect mobile
local isMobile = (game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").KeyboardEnabled)

local Window = Library:CreateWindow({
   Title = 'omega rarities hub',
   Center = true,
   AutoShow = true,
   Size = isMobile and UDim2.fromOffset(380, 550) or nil,
   MenuFadeTime = 0,
})

-- Floating toggle button works on both mobile (tap) and PC (click)
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "HubToggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.Parent = game:GetService("CoreGui")

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.fromOffset(60, 60)
Btn.Position = UDim2.new(0, 10, 0.5, -30)
Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Btn.BorderSizePixel = 0
Btn.Text = "☰"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.TextSize = 26
Btn.Font = Enum.Font.GothamBold
Btn.Parent = ToggleGui
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)

-- Make button draggable so it's not in the way
local dragging, dragStart, startPos
Btn.InputBegan:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = Btn.Position
   end
end)
Btn.InputChanged:Connect(function(input)
   if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMove) then
      local delta = input.Position - dragStart
      Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
   end
end)
Btn.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = false
   end
end)

local menuOpen = true
Btn.MouseButton1Click:Connect(function()
   menuOpen = not menuOpen
   Library:SetVisible(menuOpen)
   Btn.Text = menuOpen and "☰" or "✕"
end)

local Tabs = {
   Main = Window:AddTab('spawn world'),
   Snow = Window:AddTab('snow world'),
   Space = Window:AddTab('space world'),
   Volcano = Window:AddTab('volcano world'),
   Settings = Window:AddTab('settings'),
}

local SlimeBox = Tabs.Main:AddLeftGroupbox('slime upgrades')
local LevelBox = Tabs.Main:AddLeftGroupbox('level upgrades')
local FireBox = Tabs.Main:AddRightGroupbox('fire upgrades')
local Fire2Box = Tabs.Main:AddRightGroupbox('extra fire upgrades')
local WaterBox = Tabs.Main:AddRightGroupbox('water upgrades')
local AutomationBox = Tabs.Main:AddRightGroupbox('automations')

local SnowBox = Tabs.Snow:AddLeftGroupbox('snow upgrades')
local Snow2Box = Tabs.Snow:AddLeftGroupbox('extra snow upgrades')
local SnowflakesBox = Tabs.Snow:AddLeftGroupbox('snowflakes upgrades')
local SnowAutoBox = Tabs.Snow:AddRightGroupbox('snow automations')
local FrostBox = Tabs.Snow:AddRightGroupbox('frost upgrades')
local SnowflakesTreeBox = Tabs.Snow:AddRightGroupbox('snowflakes tree')

local StardustBox = Tabs.Space:AddLeftGroupbox('stardust upgrades')
local SpaceAutoBox = Tabs.Space:AddLeftGroupbox('space automations')
local CometsBox = Tabs.Space:AddRightGroupbox('comets upgrades')

local activeUpgrades = {}
local autoReset = {
   slime = false,
   fire = false,
   water = false
}

local upgradeCycles = {
   slime = 0,
   water = 0
}

local resetAfterCycles = 100

-- AUTO VARIABLES
local autoPlasma = false
local autoSnow = false
local autoClickSnowflakes = false
local autoConvertStardust = false

-- function to check if category has active upgrades
local function hasActiveUpgrades(category)
   if category == "slime" then
      return activeUpgrades['slime1'] or activeUpgrades['slime2'] or activeUpgrades['slime3'] or activeUpgrades['slime4']
   elseif category == "fire" then
      return activeUpgrades['fire1'] or activeUpgrades['fire2'] or activeUpgrades['fire3'] or activeUpgrades['fire4'] or
             activeUpgrades['fire2_1'] or activeUpgrades['fire2_2'] or activeUpgrades['fire2_3'] or activeUpgrades['fire2_4']
   elseif category == "water" then
      return activeUpgrades['water1'] or activeUpgrades['water2'] or activeUpgrades['water3'] or activeUpgrades['water4'] or activeUpgrades['water5']
   end
   return false
end

-- auto upgrade loop
spawn(function()
   while true do
      local hadSlimeUpgrade = false
      local hadWaterUpgrade = false
      
      for upgradeName, upgradeId in pairs(activeUpgrades) do
         pcall(function()
            local args = {upgradeId, true}
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Upgrade"):FireServer(unpack(args))
            
            if upgradeId:find("Slime") then
               hadSlimeUpgrade = true
            elseif upgradeId:find("Water") then
               hadWaterUpgrade = true
            end
         end)
         wait(0.3)
      end
      
      if hadSlimeUpgrade then
         upgradeCycles.slime = upgradeCycles.slime + 1
      end
      if hadWaterUpgrade then
         upgradeCycles.water = upgradeCycles.water + 1
      end
      
      -- auto reset for slime and water (cycle-based)
      if autoReset.slime and upgradeCycles.slime >= resetAfterCycles and hasActiveUpgrades("slime") then
         pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Slime")
            print("auto reset: slime (after " .. upgradeCycles.slime .. " cycles)")
            upgradeCycles.slime = 0
            wait(2)
         end)
      end
      
      if autoReset.water and upgradeCycles.water >= resetAfterCycles and hasActiveUpgrades("water") then
         pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Water")
            print("auto reset: water (after " .. upgradeCycles.water .. " cycles)")
            upgradeCycles.water = 0
            wait(2)
         end)
      end
      
      wait(0.5)
   end
end)

-- auto fire reset spam loop
spawn(function()
   while true do
      wait(1)
      if autoReset.fire then
         pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Fire")
            print("auto reset: fire (spam)")
         end)
      end
   end
end)

-- AUTO PLASMA FARM LOOP
spawn(function()
   local plasmaTouch = nil
   local lockedCFrame = nil
   
   pcall(function()
      plasmaTouch = game:GetService("Workspace").Game.Buttons.Plasma.Plasma.Touch
   end)
   
   while true do
      wait(0.05)
      
      if autoPlasma then
         pcall(function()
            local player = game.Players.LocalPlayer
            local character = player and player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if hrp and plasmaTouch then
               if not lockedCFrame then
                  lockedCFrame = plasmaTouch.CFrame * CFrame.new(0, 2, 0)
               end
               hrp.CFrame = lockedCFrame
               firetouchinterest(hrp, plasmaTouch, 0)
            end
         end)
      else
         lockedCFrame = nil
      end
   end
end)

-- AUTO SNOW FARM LOOP
spawn(function()
   local zoneCenter = Vector3.new(-697.228, 69.975, 548.519)
   
   while true do
      wait(0.3)
      
      if autoSnow then
         pcall(function()
            local player = game.Players.LocalPlayer
            local character = player and player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
               local snowBalls = game:GetService("Workspace").Game.Snow.SnowBalls
               local balls = snowBalls:GetChildren()
               
               if #balls > 0 then
                  for _, ball in pairs(balls) do
                     if ball:IsA("BasePart") then
                        hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0, 3, 0))
                        wait(0.1)
                     end
                  end
               else
                  hrp.CFrame = CFrame.new(zoneCenter + Vector3.new(0, 3, 0))
               end
            end
         end)
      end
   end
end)

-- AUTO SNOWFLAKES CLICK LOOP
spawn(function()
   while true do
      wait(0.05)
      if autoClickSnowflakes then
         pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Click"):FireServer()
         end)
      end
   end
end)

-- AUTO CONVERT STARDUST LOOP
spawn(function()
   while true do
      wait(1)
      if autoConvertStardust then
         pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Use"):FireServer("Stardust")
         end)
      end
   end
end)

-- =====================
-- SLIME UPGRADES
-- =====================
SlimeBox:AddToggle('SlimeUpgrade1', {
   Text = 'auto slime multiplier',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['slime1'] = value and "SlimeUpgrades_1" or nil
end)

SlimeBox:AddToggle('SlimeUpgrade2', {
   Text = 'auto slime luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['slime2'] = value and "SlimeUpgrades_2" or nil
end)

SlimeBox:AddToggle('SlimeUpgrade3', {
   Text = 'auto slime xp multiplier',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['slime3'] = value and "SlimeUpgrades_3" or nil
end)

SlimeBox:AddToggle('SlimeUpgrade4', {
   Text = 'auto rune luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['slime4'] = value and "SlimeUpgrades_4" or nil
end)

SlimeBox:AddToggle('AutoResetSlime', {
   Text = 'auto reset when maxed',
   Default = false,
}):OnChanged(function(value)
   autoReset.slime = value
   if value then
      upgradeCycles.slime = 0
   end
end)

SlimeBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'SlimeUpgrade1','SlimeUpgrade2','SlimeUpgrade3','SlimeUpgrade4'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'SlimeUpgrade1','SlimeUpgrade2','SlimeUpgrade3','SlimeUpgrade4'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

SlimeBox:AddButton({
   Text = 'reset slime',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Slime")
   end
})

-- =====================
-- LEVEL UPGRADES
-- =====================
LevelBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'LevelUpgrade1','LevelUpgrade2','LevelUpgrade3','LevelUpgrade4'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'LevelUpgrade1','LevelUpgrade2','LevelUpgrade3','LevelUpgrade4'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

LevelBox:AddToggle('LevelUpgrade1', {
   Text = 'auto farm xp upgrade',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['level1'] = value and "LevelUpgrades_1" or nil
end)

LevelBox:AddToggle('LevelUpgrade2', {
   Text = 'more luck upgrade',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['level2'] = value and "LevelUpgrades_2" or nil
end)

LevelBox:AddToggle('LevelUpgrade3', {
   Text = 'auto farm roll faster upgrade',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['level3'] = value and "LevelUpgrades_3" or nil
end)

LevelBox:AddToggle('LevelUpgrade4', {
   Text = 'more rune bulk',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['level4'] = value and "LevelUpgrades_4" or nil
end)

-- =====================
-- FIRE UPGRADES
-- =====================
FireBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'FireUpgrade1','FireUpgrade2','FireUpgrade3','FireUpgrade4'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'FireUpgrade1','FireUpgrade2','FireUpgrade3','FireUpgrade4'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

FireBox:AddToggle('FireUpgrade1', {
   Text = 'more fire points',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire1'] = value and "FireUpgrades_1" or nil
end)

FireBox:AddToggle('FireUpgrade2', {
   Text = 'unlock 2nd',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire2'] = value and "FireUpgrades_2" or nil
end)

FireBox:AddToggle('FireUpgrade3', {
   Text = 'faster dropper',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire3'] = value and "FireUpgrades_3" or nil
end)

FireBox:AddToggle('FireUpgrade4', {
   Text = 'faster conveyors',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire4'] = value and "FireUpgrades_4" or nil
end)

-- =====================
-- EXTRA FIRE UPGRADES
-- =====================
Fire2Box:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'Fire2Upgrade1','Fire2Upgrade2','Fire2Upgrade3','Fire2Upgrade4'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'Fire2Upgrade1','Fire2Upgrade2','Fire2Upgrade3','Fire2Upgrade4'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

Fire2Box:AddToggle('Fire2Upgrade1', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire2_1'] = value and "Fire2Upgrades_1" or nil
end)

Fire2Box:AddToggle('Fire2Upgrade2', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire2_2'] = value and "Fire2Upgrades_2" or nil
end)

Fire2Box:AddToggle('Fire2Upgrade3', {
   Text = 'more slime points',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire2_3'] = value and "Fire2Upgrades_3" or nil
end)

Fire2Box:AddToggle('Fire2Upgrade4', {
   Text = 'more xp 2',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['fire2_4'] = value and "Fire2Upgrades_4" or nil
end)

Fire2Box:AddToggle('AutoResetFire', {
   Text = 'auto reset fire (spam)',
   Default = false,
}):OnChanged(function(value)
   autoReset.fire = value
end)

Fire2Box:AddButton({
   Text = 'reset fire',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Fire")
   end
})

-- =====================
-- WATER UPGRADES
-- =====================
WaterBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'WaterUpgrade1','WaterUpgrade2','WaterUpgrade3','WaterUpgrade4','WaterUpgrade5'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'WaterUpgrade1','WaterUpgrade2','WaterUpgrade3','WaterUpgrade4','WaterUpgrade5'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

WaterBox:AddToggle('WaterUpgrade1', {
   Text = 'more fire',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['water1'] = value and "WaterUpgrades_1" or nil
end)

WaterBox:AddToggle('WaterUpgrade2', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['water2'] = value and "WaterUpgrades_2" or nil
end)

WaterBox:AddToggle('WaterUpgrade3', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['water3'] = value and "WaterUpgrades_3" or nil
end)

WaterBox:AddToggle('WaterUpgrade4', {
   Text = 'unlock automations',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['water4'] = value and "WaterUpgrades_4" or nil
end)

WaterBox:AddToggle('WaterUpgrade5', {
   Text = 'water boost plasma',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['water5'] = value and "WaterUpgrades_5" or nil
end)

WaterBox:AddToggle('AutoResetWater', {
   Text = 'auto reset when maxed',
   Default = false,
}):OnChanged(function(value)
   autoReset.water = value
   if value then
      upgradeCycles.water = 0
   end
end)

WaterBox:AddButton({
   Text = 'reset water',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Water")
   end
})

-- =====================
-- AUTOMATIONS
-- =====================
AutomationBox:AddToggle('AutoPlasma', {
   Text = 'auto farm plasma',
   Default = false,
}):OnChanged(function(value)
   autoPlasma = value
end)

AutomationBox:AddButton({
   Text = 'buy auto rarity (max 5)',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Upgrade"):FireServer("AutomationsUpgrades_1", true)
   end
})

AutomationBox:AddButton({
   Text = 'buy auto level upgrades',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Upgrade"):FireServer("AutomationsUpgrades_2", true)
   end
})

AutomationBox:AddButton({
   Text = 'buy auto slime',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Upgrade"):FireServer("AutomationsUpgrades_3", true)
   end
})

AutomationBox:AddButton({
   Text = 'buy auto slime upgrades',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Upgrade"):FireServer("AutomationsUpgrades_4", true)
   end
})

AutomationBox:AddButton({
   Text = 'buy auto fire upgrades',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Upgrade"):FireServer("AutomationsUpgrades_5", true)
   end
})

-- =====================
-- SNOW UPGRADES
-- =====================
SnowBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'SnowUpgrade1','SnowUpgrade2','SnowUpgrade3','SnowUpgrade4','SnowUpgrade5','SnowUpgrade6'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'SnowUpgrade1','SnowUpgrade2','SnowUpgrade3','SnowUpgrade4','SnowUpgrade5','SnowUpgrade6'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

SnowBox:AddToggle('SnowUpgrade1', {
   Text = 'more snow',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow1'] = value and "SnowUpgrades_1" or nil
end)

SnowBox:AddToggle('SnowUpgrade2', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow2'] = value and "SnowUpgrades_2" or nil
end)

SnowBox:AddToggle('SnowUpgrade3', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow3'] = value and "SnowUpgrades_3" or nil
end)

SnowBox:AddToggle('SnowUpgrade4', {
   Text = 'unlock frost',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow4'] = value and "SnowUpgrades_4" or nil
end)

SnowBox:AddToggle('SnowUpgrade5', {
   Text = 'auto water',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow5'] = value and "SnowUpgrades_5" or nil
end)

SnowBox:AddToggle('SnowUpgrade6', {
   Text = 'auto water upgrades',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow6'] = value and "SnowUpgrades_6" or nil
end)

-- =====================
-- EXTRA SNOW UPGRADES
-- =====================
Snow2Box:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'Snow2Upgrade1','Snow2Upgrade2','Snow2Upgrade3','Snow2Upgrade4'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'Snow2Upgrade1','Snow2Upgrade2','Snow2Upgrade3','Snow2Upgrade4'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

Snow2Box:AddToggle('Snow2Upgrade1', {
   Text = 'more snow capacity',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow2_1'] = value and "Snow2Upgrades_1" or nil
end)

Snow2Box:AddToggle('Snow2Upgrade2', {
   Text = 'faster snowballs',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow2_2'] = value and "Snow2Upgrades_2" or nil
end)

Snow2Box:AddToggle('Snow2Upgrade3', {
   Text = 'more snow luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow2_3'] = value and "Snow2Upgrades_3" or nil
end)

Snow2Box:AddToggle('Snow2Upgrade4', {
   Text = 'increase range',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['snow2_4'] = value and "Snow2Upgrades_4" or nil
end)

-- =====================
-- SNOWFLAKES UPGRADES (base 6)
-- =====================
SnowflakesBox:AddToggle('AutoClickSnowflakes', {
   Text = 'auto click snowflakes',
   Default = false,
}):OnChanged(function(value)
   autoClickSnowflakes = value
end)

SnowflakesBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'SnowflakesUpgrade1','SnowflakesUpgrade2','SnowflakesUpgrade3','SnowflakesUpgrade4','SnowflakesUpgrade5','SnowflakesUpgrade6'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'SnowflakesUpgrade1','SnowflakesUpgrade2','SnowflakesUpgrade3','SnowflakesUpgrade4','SnowflakesUpgrade5','SnowflakesUpgrade6'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

SnowflakesBox:AddToggle('SnowflakesUpgrade1', {
   Text = 'more snowflakes',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sf1'] = value and "SnowflakesUpgrades_1" or nil
end)

SnowflakesBox:AddToggle('SnowflakesUpgrade2', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sf2'] = value and "SnowflakesUpgrades_2" or nil
end)

SnowflakesBox:AddToggle('SnowflakesUpgrade3', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sf3'] = value and "SnowflakesUpgrades_3" or nil
end)

SnowflakesBox:AddToggle('SnowflakesUpgrade4', {
   Text = 'more snow',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sf4'] = value and "SnowflakesUpgrades_4" or nil
end)

SnowflakesBox:AddToggle('SnowflakesUpgrade5', {
   Text = 'more frost',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sf5'] = value and "SnowflakesUpgrades_5" or nil
end)

SnowflakesBox:AddToggle('SnowflakesUpgrade6', {
   Text = 'unlock upgrade tree',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sf6'] = value and "SnowflakesUpgrades_6" or nil
end)

-- =====================
-- FROST UPGRADES
-- =====================
FrostBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'FrostUpgrade1','FrostUpgrade2','FrostUpgrade3','FrostUpgrade4','FrostUpgrade5','FrostUpgrade6','FrostUpgrade7'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'FrostUpgrade1','FrostUpgrade2','FrostUpgrade3','FrostUpgrade4','FrostUpgrade5','FrostUpgrade6','FrostUpgrade7'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

FrostBox:AddToggle('FrostUpgrade1', {
   Text = 'more frost',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['frost1'] = value and "FrostUpgrades_1" or nil
end)

FrostBox:AddToggle('FrostUpgrade2', {
   Text = 'more snow',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['frost2'] = value and "FrostUpgrades_2" or nil
end)

FrostBox:AddToggle('FrostUpgrade3', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['frost3'] = value and "FrostUpgrades_3" or nil
end)

FrostBox:AddToggle('FrostUpgrade4', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['frost4'] = value and "FrostUpgrades_4" or nil
end)

FrostBox:AddToggle('FrostUpgrade5', {
   Text = 'more plasma milestones',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['frost5'] = value and "FrostUpgrades_5" or nil
end)

FrostBox:AddToggle('FrostUpgrade6', {
   Text = 'multiply all runes boost',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['frost6'] = value and "FrostUpgrades_6" or nil
end)

FrostBox:AddToggle('FrostUpgrade7', {
   Text = 'unlock snowflakes',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['frost7'] = value and "FrostUpgrades_7" or nil
end)

FrostBox:AddButton({
   Text = 'reset frost',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Frost")
   end
})

-- =====================
-- SNOWFLAKES TREE UPGRADES (14 total)
-- =====================
local sfTreeIds = {
   'SnowflakesTree1','SnowflakesTree2','SnowflakesTree3','SnowflakesTree4',
   'SnowflakesTree5','SnowflakesTree6','SnowflakesTree7','SnowflakesTree8',
   'SnowflakesTree9','SnowflakesTree10','SnowflakesTree11','SnowflakesTree12',
   'SnowflakesTree13','SnowflakesTree14'
}
local sfTreeNames = {
   'more snowflakes','more luck','more snow','more frost',
   'more xp','more rune bulk','more all spawn stats','more snowflakes xp',
   'more luck (t2)','extra rarity bulk','auto snowflakes','more rune luck',
   'more rune clone','more rune bulk (t2)'
}

SnowflakesTreeBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs(sfTreeIds) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs(sfTreeIds) do
         Toggles[id]:SetValue(false)
      end
   end,
})

for i, id in ipairs(sfTreeIds) do
   SnowflakesTreeBox:AddToggle(id, {
      Text = sfTreeNames[i],
      Default = false,
   }):OnChanged(function(value)
      activeUpgrades['sft'..i] = value and ("SnowflakesTree_"..i) or nil
   end)
end

-- =====================
-- SNOW AUTOMATIONS
-- =====================
SnowAutoBox:AddToggle('AutoSnow', {
   Text = 'auto farm snow',
   Default = false,
}):OnChanged(function(value)
   autoSnow = value
end)

-- =====================
-- STARDUST UPGRADES (6 total)
-- =====================
StardustBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'StardustUpgrade1','StardustUpgrade2','StardustUpgrade3','StardustUpgrade4','StardustUpgrade5','StardustUpgrade6'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'StardustUpgrade1','StardustUpgrade2','StardustUpgrade3','StardustUpgrade4','StardustUpgrade5','StardustUpgrade6'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

StardustBox:AddToggle('StardustUpgrade1', {
   Text = 'more stardust',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sd1'] = value and "StardustUpgrades_1" or nil
end)

StardustBox:AddToggle('StardustUpgrade2', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sd2'] = value and "StardustUpgrades_2" or nil
end)

StardustBox:AddToggle('StardustUpgrade3', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sd3'] = value and "StardustUpgrades_3" or nil
end)

StardustBox:AddToggle('StardustUpgrade4', {
   Text = 'more plasma',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sd4'] = value and "StardustUpgrades_4" or nil
end)

StardustBox:AddToggle('StardustUpgrade5', {
   Text = 'more water',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sd5'] = value and "StardustUpgrades_5" or nil
end)

StardustBox:AddToggle('StardustUpgrade6', {
   Text = 'more fire',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['sd6'] = value and "StardustUpgrades_6" or nil
end)

StardustBox:AddButton({
   Text = 'reset stardust',
   Func = function()
      game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Stardust")
   end
})

-- =====================
-- SPACE AUTOMATIONS
-- =====================
SpaceAutoBox:AddToggle('AutoConvertStardust', {
   Text = 'auto convert stardust',
   Default = false,
}):OnChanged(function(value)
   autoConvertStardust = value
end)

-- =====================
-- COMETS UPGRADES (5 total)
-- =====================
CometsBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'CometsUpgrade1','CometsUpgrade2','CometsUpgrade3','CometsUpgrade4','CometsUpgrade5'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'CometsUpgrade1','CometsUpgrade2','CometsUpgrade3','CometsUpgrade4','CometsUpgrade5'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

CometsBox:AddToggle('CometsUpgrade1', {
   Text = 'more comets',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['cm1'] = value and "CometsUpgrades_1" or nil
end)

CometsBox:AddToggle('CometsUpgrade2', {
   Text = 'more stardust',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['cm2'] = value and "CometsUpgrades_2" or nil
end)

CometsBox:AddToggle('CometsUpgrade3', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['cm3'] = value and "CometsUpgrades_3" or nil
end)

CometsBox:AddToggle('CometsUpgrade4', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['cm4'] = value and "CometsUpgrades_4" or nil
end)

CometsBox:AddToggle('CometsUpgrade5', {
   Text = 'more plasma',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['cm5'] = value and "CometsUpgrades_5" or nil
end)

-- =====================
-- VOLCANO TAB
-- =====================
local AshBox = Tabs.Volcano:AddLeftGroupbox('ash tree upgrades')
local AshLavaBox = Tabs.Volcano:AddLeftGroupbox('ash lava branch')
local LavaBox = Tabs.Volcano:AddRightGroupbox('lava upgrades')
local GeneratorBox = Tabs.Volcano:AddRightGroupbox('generators')
local VolcanoAutoBox = Tabs.Volcano:AddRightGroupbox('volcano automations')

-- AUTO ASH RESET (smart: resets when rank stops increasing)
local autoAshReset = false
local lastRank = -1
local sameRankCount = 0
local rankCheckThreshold = 10 -- reset after this many checks with no rank change

-- Generator auto level up
local autoLevelGenerators = false

-- Ash exchange auto
local autoExchangeAsh = false

-- ASH TREE UPGRADES (standard IDs 1-9, then fractional 8/1 through 8/6)
local ashTreeStandardIds = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17'}
local ashTreeStandardNames = {
   'more volcanic ash','luck based on ash','unlock generator 1',
   'ash based on generator 1','faster generators','more plasma milestone',
   'unlock ash rune','unlock lava branch','more world 1 upgrades cap',
   'auto ash','auto stardust','more ash (t2)','more lava (t2)',
   'more luck (t2)','double passives keys gain','unlock mobs','unlock volcano eruption'
}
local ashLavaBranchIds = {'8/1','8/2','8/3','8/4','8/5','8/6'}
local ashLavaBranchNames = {
   'more lava','unlock generator 2','more rune luck',
   'unlock generator 3','reduce tokens cooldown','unlock lava rune'
}

-- Select/deselect all ash tree
AshBox:AddButton({
   Text = 'select all',
   Func = function()
      for i = 1, #ashTreeStandardIds do
         pcall(function() Toggles['AshTree'..i]:SetValue(true) end)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for i = 1, #ashTreeStandardIds do
         pcall(function() Toggles['AshTree'..i]:SetValue(false) end)
      end
   end,
})

for i, id in ipairs(ashTreeStandardIds) do
   AshBox:AddToggle('AshTree'..i, {
      Text = ashTreeStandardNames[i],
      Default = false,
   }):OnChanged(function(value)
      activeUpgrades['ast'..i] = value and ("AshTree_"..id) or nil
   end)
end

AshBox:AddButton({
   Text = 'exchange ash (manual)',
   Func = function()
      pcall(function()
         game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Ash")
      end)
   end
})

-- Ash lava branch
AshLavaBox:AddButton({
   Text = 'select all',
   Func = function()
      for i = 1, #ashLavaBranchIds do
         pcall(function() Toggles['AshLava'..i]:SetValue(true) end)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for i = 1, #ashLavaBranchIds do
         pcall(function() Toggles['AshLava'..i]:SetValue(false) end)
      end
   end,
})

for i, id in ipairs(ashLavaBranchIds) do
   AshLavaBox:AddToggle('AshLava'..i, {
      Text = ashLavaBranchNames[i],
      Default = false,
   }):OnChanged(function(value)
      activeUpgrades['alava'..i] = value and ("AshTree_"..id) or nil
   end)
end

-- LAVA UPGRADES (5 total)
LavaBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'LavaUpgrade1','LavaUpgrade2','LavaUpgrade3','LavaUpgrade4','LavaUpgrade5'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'LavaUpgrade1','LavaUpgrade2','LavaUpgrade3','LavaUpgrade4','LavaUpgrade5'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

LavaBox:AddToggle('LavaUpgrade1', {
   Text = 'more lava',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['lv1'] = value and "LavaUpgrades_1" or nil
end)

LavaBox:AddToggle('LavaUpgrade2', {
   Text = 'more ash',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['lv2'] = value and "LavaUpgrades_2" or nil
end)

LavaBox:AddToggle('LavaUpgrade3', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['lv3'] = value and "LavaUpgrades_3" or nil
end)

LavaBox:AddToggle('LavaUpgrade4', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['lv4'] = value and "LavaUpgrades_4" or nil
end)

LavaBox:AddToggle('LavaUpgrade5', {
   Text = 'more singularity',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['lv5'] = value and "LavaUpgrades_5" or nil
end)

-- GENERATORS (level up buttons for gen 1, 2, 3)
GeneratorBox:AddButton({
   Text = 'level up generator 1',
   Func = function()
      pcall(function()
         game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Generator"):FireServer("Generator1")
      end)
   end
})

GeneratorBox:AddButton({
   Text = 'level up generator 2',
   Func = function()
      pcall(function()
         game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Generator"):FireServer("Generator2")
      end)
   end
})

GeneratorBox:AddButton({
   Text = 'level up generator 3',
   Func = function()
      pcall(function()
         game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Generator"):FireServer("Generator3")
      end)
   end
})

GeneratorBox:AddToggle('AutoLevelGenerators', {
   Text = 'auto level all generators',
   Default = false,
}):OnChanged(function(value)
   autoLevelGenerators = value
end)

-- VOLCANO AUTOMATIONS
VolcanoAutoBox:AddToggle('AutoExchangeAsh', {
   Text = 'auto exchange volcanic ash',
   Default = false,
}):OnChanged(function(value)
   autoExchangeAsh = value
end)

VolcanoAutoBox:AddToggle('AutoAshReset', {
   Text = 'auto ash reset (when rank stalls)',
   Default = false,
}):OnChanged(function(value)
   autoAshReset = value
   if value then
      lastRank = -1
      sameRankCount = 0
   end
end)

-- AUTO GENERATOR LEVEL LOOP
spawn(function()
   while true do
      wait(0.5)
      if autoLevelGenerators then
         for _, g in ipairs({"Generator1","Generator2","Generator3"}) do
            pcall(function()
               game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Generator"):FireServer(g)
            end)
            wait(0.2)
         end
      end
   end
end)

-- AUTO EXCHANGE ASH LOOP
spawn(function()
   while true do
      wait(1)
      if autoExchangeAsh then
         pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Reset"):FireServer("Ash")
         end)
      end
   end
end)

-- AUTO ASH RESET LOOP (smart: watches Rarity, resets when it stops climbing)
-- Ash reset requires Rarity >= 525, resets Rarity back to 1
spawn(function()
   while true do
      wait(5)
      if autoAshReset then
         pcall(function()
            local RS = game:GetService("ReplicatedStorage")
            local Packages = RS:WaitForChild("Packages")
            local Knit = require(Packages.Knit)
            local DataController = Knit.GetController("DataController")
            DataController:waitForData()
            local replica = DataController:getReplica()
            
            local currentRarity = tonumber(tostring(replica.Data.Rarity)) or -1
            if currentRarity == -1 then return end
            
            print("[ash reset] current rarity: " .. currentRarity .. " | last: " .. lastRank .. " | stall count: " .. sameRankCount)
            
            if currentRarity > lastRank then
               -- Rarity went up, reset counter
               lastRank = currentRarity
               sameRankCount = 0
            else
               sameRankCount = sameRankCount + 1
               if sameRankCount >= rankCheckThreshold then
                  -- Rarity stalled, do ash reset
                  print("[ash reset] rarity stalled at " .. currentRarity .. ", resetting ash!")
                  RS:WaitForChild("Events"):WaitForChild("Reset"):FireServer("Ash")
                  wait(3)
                  sameRankCount = 0
                  lastRank = -1
               end
            end
         end)
      end
   end
end)

-- =====================
-- MOBS TAB
-- =====================
local MobsTab = Window:AddTab('mobs')
local MobsUpgradeBox = MobsTab:AddLeftGroupbox('mobs upgrades')
local MobsAutoBox = MobsTab:AddRightGroupbox('mobs automations')
local MobsLevelBox = MobsTab:AddRightGroupbox('mob level')

local autoClickMob = false

-- AUTO MOB CLICK LOOP
spawn(function()
   while true do
      wait(0.05)
      if autoClickMob then
         pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DamageMob"):FireServer()
         end)
      end
   end
end)

-- MOBS UPGRADES (0-5, currency: SpiritOrbs)
MobsUpgradeBox:AddButton({
   Text = 'select all',
   Func = function()
      for _, id in pairs({'MobsUpgrade0','MobsUpgrade1','MobsUpgrade2','MobsUpgrade3','MobsUpgrade4','MobsUpgrade5'}) do
         Toggles[id]:SetValue(true)
      end
   end,
}):AddButton({
   Text = 'deselect all',
   Func = function()
      for _, id in pairs({'MobsUpgrade0','MobsUpgrade1','MobsUpgrade2','MobsUpgrade3','MobsUpgrade4','MobsUpgrade5'}) do
         Toggles[id]:SetValue(false)
      end
   end,
})

MobsUpgradeBox:AddToggle('MobsUpgrade0', {
   Text = 'more damage',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['mob0'] = value and "MobsUpgrades_0" or nil
end)

MobsUpgradeBox:AddToggle('MobsUpgrade1', {
   Text = 'more spirit orbs',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['mob1'] = value and "MobsUpgrades_1" or nil
end)

MobsUpgradeBox:AddToggle('MobsUpgrade2', {
   Text = 'more lava',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['mob2'] = value and "MobsUpgrades_2" or nil
end)

MobsUpgradeBox:AddToggle('MobsUpgrade3', {
   Text = 'more ash',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['mob3'] = value and "MobsUpgrades_3" or nil
end)

MobsUpgradeBox:AddToggle('MobsUpgrade4', {
   Text = 'more luck',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['mob4'] = value and "MobsUpgrades_4" or nil
end)

MobsUpgradeBox:AddToggle('MobsUpgrade5', {
   Text = 'more xp',
   Default = false,
}):OnChanged(function(value)
   activeUpgrades['mob5'] = value and "MobsUpgrades_5" or nil
end)

-- MOBS AUTOMATIONS
MobsAutoBox:AddToggle('AutoClickMob', {
   Text = 'auto kill mob',
   Default = false,
}):OnChanged(function(value)
   autoClickMob = value
end)

-- MOB LEVEL
MobsLevelBox:AddButton({
   Text = 'next level',
   Func = function()
      pcall(function()
         game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ChangeMobLevel"):FireServer(1)
      end)
   end
})

MobsLevelBox:AddButton({
   Text = 'previous level',
   Func = function()
      pcall(function()
         game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ChangeMobLevel"):FireServer(-1)
      end)
   end
})

-- =====================
-- SETTINGS TAB
-- =====================
local MenuGroup = Tabs.Settings:AddLeftGroupbox('menu')
local ConfigGroup = Tabs.Settings:AddRightGroupbox('configuration')

MenuGroup:AddButton({
   Text = 'unload script',
   Func = function()
      Library:Unload()
   end
})

MenuGroup:AddLabel('menu toggle keybind'):AddKeyPicker('MenuKeybind', {
   Default = 'RightShift',
   NoUI = true,
   Text = 'menu keybind',
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('omega_rarities')
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
SaveManager:SetFolder('omega_rarities/configs')
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
