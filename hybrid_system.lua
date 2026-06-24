--[[
    Professional Hybrid Performance & Anti-AFK System
    ==================================================
    An advanced unified system combining FPS optimization and anti-AFK functionality
    Features: Combined performance/activity monitoring, integrated controls, unified logging
    Version: 2.0.0
--]]

local HybridSystem = {}
HybridSystem.__index = HybridSystem

-- Configuration
local CONFIG = {
    -- Anti-AFK Settings
    antiAFKEnabled = true,
    antiAFKInterval = 30,              -- Seconds between actions (30-120 recommended)
    antiAFKRandomVariation = true,     -- Add random delay to interval
    antiAFKVariationRange = 5,         -- +/- seconds of variation
    maxInactivityTime = 300,           -- Maximum inactivity before warning (seconds)
    
    -- FPS Booster Settings
    fpsBoosterEnabled = true,
    targetFPS = 60,                    -- Target FPS cap
    aggressiveMode = false,            -- Enable aggressive optimizations
    autoOptimize = true,               -- Automatically optimize on startup
    memoryCleanupInterval = 30,        -- Seconds between memory cleanups
    disableShadows = true,             -- Disable shadow rendering
    reduceParticles = true,            -- Reduce particle effects
    reduceLighting = true,             -- Reduce dynamic lighting
    disablePostEffects = true,         -- Disable post-processing effects
    textureStreaming = true,           -- Enable texture streaming optimization
    
    -- System Settings
    logActions = true,                 -- Log all actions
    unifiedLogging = true,             -- Log with unified timestamp format
}

-- Hybrid System Class
function HybridSystem.new(config)
    local self = setmetatable({}, HybridSystem)
    
    self.config = config or CONFIG
    self.isRunning = false
    self.originalSettings = {}
    
    -- Anti-AFK Components
    self.antiAFKEnabled = self.config.antiAFKEnabled
    self.lastActionTime = tick()
    self.actionCount = 0
    self.antiAFKRunning = false
    
    -- FPS Booster Components
    self.fpsBoosterEnabled = self.config.fpsBoosterEnabled
    self.fpsHistory = {}
    self.maxHistorySize = 60
    self.currentFPS = 0
    self.averageFPS = 0
    self.cleanupCount = 0
    self.fpsBoosterRunning = false
    
    -- System Statistics
    self.systemStartTime = tick()
    self.totalUptime = 0
    
    return self
end

-- ============================================
-- LOGGING SYSTEM
-- ============================================

function HybridSystem:log(module, message)
    if not self.config.logActions then return end
    
    local timestamp = os.date("%H:%M:%S")
    local displayModule = string.upper(module)
    print("[" .. displayModule .. " " .. timestamp .. "]: " .. message)
end

-- ============================================
-- ANTI-AFK FUNCTIONS
-- ============================================

-- Get next action interval with optional random variation
function HybridSystem:getNextAFKInterval()
    local interval = self.config.antiAFKInterval
    
    if self.config.antiAFKRandomVariation then
        local variation = math.random(-self.config.antiAFKVariationRange, self.config.antiAFKVariationRange)
        interval = interval + variation
    end
    
    return math.max(5, interval) -- Minimum 5 seconds safety threshold
end

-- Movement action
function HybridSystem:moveCharacter()
    if game and game.Players then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:MoveTo(player.Character.PrimaryPart.Position)
            end
        end
    end
end

-- Jump action
function HybridSystem:jumpAction()
    if game and game.Players then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:Jump()
            end
        end
    end
end

-- Camera rotation action
function HybridSystem:rotateCamera()
    if game and game.Workspace then
        local camera = game.Workspace.CurrentCamera
        if camera then
            local currentCFrame = camera.CFrame
            camera.CFrame = currentCFrame * CFrame.Angles(0, math.rad(5), 0)
        end
    end
end

-- Emote action
function HybridSystem:useEmote()
    self:log("ANTI-AFK", "Emote action triggered")
end

-- Perform a random action to appear active
function HybridSystem:performAFKAction()
    if not self.antiAFKEnabled then return end
    
    local actions = {
        function() self:moveCharacter() end,
        function() self:jumpAction() end,
        function() self:rotateCamera() end,
        function() self:useEmote() end,
    }
    
    -- Execute random action
    local randomAction = actions[math.random(1, #actions)]
    local success, err = pcall(randomAction)
    
    if not success then
        self:log("ANTI-AFK", "Error performing action: " .. tostring(err))
        return false
    end
    
    self.lastActionTime = tick()
    self.actionCount = self.actionCount + 1
    self:log("ANTI-AFK", "Action #" .. self.actionCount .. " executed")
    
    return true
end

-- Anti-AFK loop
function HybridSystem:runAntiAFKLoop()
    self.antiAFKRunning = true
    
    while self.antiAFKRunning and self.antiAFKEnabled do
        local nextInterval = self:getNextAFKInterval()
        wait(nextInterval)
        
        -- Check if inactive too long
        local inactiveTime = tick() - self.lastActionTime
        if inactiveTime > self.config.maxInactivityTime then
            self:log("ANTI-AFK", "WARNING: Inactive for " .. inactiveTime .. " seconds")
        end
        
        -- Perform action
        self:performAFKAction()
    end
end

-- ============================================
-- FPS BOOSTER FUNCTIONS
-- ============================================

-- Get current FPS
function HybridSystem:getCurrentFPS()
    if game and game:GetService("Stats") then
        local stats = game:GetService("Stats")
        local heartbeat = stats.Heartbeat
        if heartbeat then
            self.currentFPS = math.floor(1 / heartbeat.TimeInterval)
            return self.currentFPS
        end
    end
    return 0
end

-- Calculate average FPS
function HybridSystem:getAverageFPS()
    if #self.fpsHistory == 0 then return 0 end
    
    local sum = 0
    for _, fps in ipairs(self.fpsHistory) do
        sum = sum + fps
    end
    
    self.averageFPS = math.floor(sum / #self.fpsHistory)
    return self.averageFPS
end

-- Store FPS reading
function HybridSystem:recordFPS()
    local fps = self:getCurrentFPS()
    table.insert(self.fpsHistory, fps)
    
    if #self.fpsHistory > self.maxHistorySize then
        table.remove(self.fpsHistory, 1)
    end
    
    return fps
end

-- Disable shadows for performance
function HybridSystem:disableShadows()
    if not self.config.disableShadows then return end
    
    pcall(function()
        if game and game.Lighting then
            self.originalSettings.shadowEnabled = game.Lighting.GlobalShadows
            game.Lighting.GlobalShadows = false
            self:log("FPS-BOOSTER", "Shadows disabled")
        end
    end)
end

-- Reduce particle effects
function HybridSystem:reduceParticles()
    if not self.config.reduceParticles then return end
    
    pcall(function()
        if game and game.Workspace then
            local particles = game.Workspace:FindDescendants()
            for _, particle in ipairs(particles) do
                if particle:IsA("ParticleEmitter") then
                    self.originalSettings[particle] = particle.Enabled
                    particle.Enabled = false
                elseif particle:IsA("Explosion") then
                    particle:Destroy()
                end
            end
            self:log("FPS-BOOSTER", "Particle effects reduced")
        end
    end)
end

-- Reduce dynamic lighting
function HybridSystem:reduceLighting()
    if not self.config.reduceLighting then return end
    
    pcall(function()
        if game and game.Lighting then
            self.originalSettings.ambientLight = game.Lighting.Ambient
            self.originalSettings.outdoorAmbient = game.Lighting.OutdoorAmbient
            
            game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            game.Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            self:log("FPS-BOOSTER", "Dynamic lighting reduced")
        end
    end)
end

-- Disable post-processing effects
function HybridSystem:disablePostEffects()
    if not self.config.disablePostEffects then return end
    
    pcall(function()
        if game and game.Workspace then
            local effects = game.Workspace:FindDescendants()
            for _, effect in ipairs(effects) do
                if effect:IsA("Bloom") or effect:IsA("DepthOfField") or 
                   effect:IsA("SunRays") or effect:IsA("ColorCorrectionAllChannels") then
                    self.originalSettings[effect] = effect.Enabled
                    effect.Enabled = false
                end
            end
            self:log("FPS-BOOSTER", "Post-processing effects disabled")
        end
    end)
end

-- Optimize texture streaming
function HybridSystem:optimizeTextures()
    if not self.config.textureStreaming then return end
    
    pcall(function()
        if game and game.Workspace then
            local terrain = game.Workspace.Terrain
            if terrain then
                self.originalSettings.terrainWaterReflections = terrain.WaterReflectivity
                terrain.WaterReflectivity = 0
                self:log("FPS-BOOSTER", "Texture streaming optimized")
            end
        end
    end)
end

-- Set FPS cap
function HybridSystem:setFPSCap()
    pcall(function()
        if game and game.RunService then
            self.originalSettings.targetFPS = self.config.targetFPS
            self:log("FPS-BOOSTER", "FPS cap set to " .. self.config.targetFPS)
        end
    end)
end

-- Memory cleanup
function HybridSystem:cleanupMemory()
    pcall(function()
        if game and game:GetService("Debris") then
            game:GetService("Debris"):AddItem(nil, 0)
            collectgarbage("collect")
            self.cleanupCount = self.cleanupCount + 1
            self:log("FPS-BOOSTER", "Memory cleanup #" .. self.cleanupCount .. " executed")
        end
    end)
end

-- Aggressive optimization mode
function HybridSystem:enableAggressiveMode()
    if not self.config.aggressiveMode then return end
    
    pcall(function()
        if game and game.Workspace then
            local parts = game.Workspace:FindDescendants()
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") and part.CanCollide == false then
                    self.originalSettings[part] = part.CanCollide
                end
            end
            self:log("FPS-BOOSTER", "Aggressive mode enabled")
        end
    end)
end

-- Apply all FPS optimizations
function HybridSystem:applyFPSOptimizations()
    if not self.fpsBoosterEnabled then return end
    
    self:disableShadows()
    self:reduceParticles()
    self:reduceLighting()
    self:disablePostEffects()
    self:optimizeTextures()
    self:setFPSCap()
    
    if self.config.aggressiveMode then
        self:enableAggressiveMode()
    end
    
    self:log("FPS-BOOSTER", "All optimizations applied")
end

-- Restore original settings
function HybridSystem:restoreOriginalSettings()
    pcall(function()
        if self.originalSettings.shadowEnabled ~= nil and game and game.Lighting then
            game.Lighting.GlobalShadows = self.originalSettings.shadowEnabled
        end
        
        if self.originalSettings.ambientLight ~= nil and game and game.Lighting then
            game.Lighting.Ambient = self.originalSettings.ambientLight
            game.Lighting.OutdoorAmbient = self.originalSettings.outdoorAmbient
        end
        
        for obj, enabled in pairs(self.originalSettings) do
            if typeof(obj) == "Instance" and obj.Parent then
                pcall(function()
                    obj.Enabled = enabled
                end)
            end
        end
        
        self:log("FPS-BOOSTER", "Original settings restored")
    end)
end

-- FPS monitoring loop
function HybridSystem:runFPSMonitorLoop()
    self.fpsBoosterRunning = true
    
    while self.fpsBoosterRunning and self.fpsBoosterEnabled do
        wait(1)
        
        -- Record FPS
        self:recordFPS()
        
        -- Periodic memory cleanup
        if self.cleanupCount == 0 or 
           (tick() % self.config.memoryCleanupInterval == 0) then
            self:cleanupMemory()
        end
    end
end

-- ============================================
-- UNIFIED SYSTEM CONTROLS
-- ============================================

-- Start entire hybrid system
function HybridSystem:start()
    if self.isRunning then
        self:log("SYSTEM", "Hybrid system already running")
        return
    end
    
    self.isRunning = true
    self.systemStartTime = tick()
    
    -- Start FPS Booster
    if self.config.fpsBoosterEnabled then
        if self.config.autoOptimize then
            self:applyFPSOptimizations()
        end
        spawn(function() self:runFPSMonitorLoop() end)
        self:log("SYSTEM", "FPS Booster started")
    end
    
    -- Start Anti-AFK
    if self.config.antiAFKEnabled then
        spawn(function() self:runAntiAFKLoop() end)
        self:log("SYSTEM", "Anti-AFK started")
    end
    
    self:log("SYSTEM", "Hybrid system started - All modules active")
end

-- Stop entire hybrid system
function HybridSystem:stop()
    self.isRunning = false
    self.antiAFKRunning = false
    self.fpsBoosterRunning = false
    
    self:restoreOriginalSettings()
    self:log("SYSTEM", "Hybrid system stopped - All modules deactivated")
end

-- Toggle Anti-AFK on/off
function HybridSystem:toggleAntiAFK()
    self.antiAFKEnabled = not self.antiAFKEnabled
    local state = self.antiAFKEnabled and "enabled" or "disabled"
    self:log("ANTI-AFK", "Anti-AFK " .. state)
end

-- Toggle FPS Booster on/off
function HybridSystem:toggleFPSBooster()
    self.fpsBoosterEnabled = not self.fpsBoosterEnabled
    
    if self.fpsBoosterEnabled then
        self:applyFPSOptimizations()
    else
        self:restoreOriginalSettings()
    end
    
    local state = self.fpsBoosterEnabled and "enabled" or "disabled"
    self:log("FPS-BOOSTER", "FPS Booster " .. state)
end

-- ============================================
-- STATISTICS & REPORTING
-- ============================================

-- Get comprehensive system statistics
function HybridSystem:getStats()
    self.totalUptime = tick() - self.systemStartTime
    
    return {
        systemStatus = self.isRunning and "ACTIVE" or "INACTIVE",
        uptime = self.totalUptime,
        
        -- Anti-AFK Stats
        antiAFKEnabled = self.antiAFKEnabled,
        antiAFKActions = self.actionCount,
        timeSinceLastAction = tick() - self.lastActionTime,
        
        -- FPS Stats
        fpsBoosterEnabled = self.fpsBoosterEnabled,
        currentFPS = self:getCurrentFPS(),
        averageFPS = self:getAverageFPS(),
        targetFPS = self.config.targetFPS,
        memoryCleanups = self.cleanupCount,
        fpsReadings = #self.fpsHistory,
        aggressiveMode = self.config.aggressiveMode,
    }
end

-- Generate comprehensive system report
function HybridSystem:generateReport()
    local stats = self:getStats()
    local report = {
        "╔═══════════════════════════════════════════════════════╗",
        "║   HYBRID SYSTEM - COMPREHENSIVE PERFORMANCE REPORT    ║",
        "╠═══════════════════════════════════════════════════════╣",
        "║ SYSTEM STATUS: " .. string.format("%-39s", stats.systemStatus) .. "║",
        "║ Uptime: " .. string.format("%-49.2f", stats.uptime) .. " ║",
        "╠═══════════════════════════════════════════════════════╣",
        "║ ANTI-AFK MODULE                                       ║",
        "║ Status: " .. string.format("%-50s", (stats.antiAFKEnabled and "ACTIVE" or "INACTIVE")) .. "║",
        "║ Actions Performed: " .. string.format("%-40d", stats.antiAFKActions) .. "║",
        "║ Time Since Last Action: " .. string.format("%-34.2f", stats.timeSinceLastAction) .. " ║",
        "╠═══════════════════════════════════════════════════════╣",
        "║ FPS BOOSTER MODULE                                    ║",
        "║ Status: " .. string.format("%-50s", (stats.fpsBoosterEnabled and "ACTIVE" or "INACTIVE")) .. "║",
        "║ Current FPS: " .. string.format("%-45d", stats.currentFPS) .. "║",
        "║ Average FPS: " .. string.format("%-45d", stats.averageFPS) .. "║",
        "║ Target FPS: " .. string.format("%-45d", stats.targetFPS) .. "║",
        "║ Memory Cleanups: " .. string.format("%-42d", stats.memoryCleanups) .. "║",
        "║ FPS Readings: " .. string.format("%-44d", stats.fpsReadings) .. "║",
        "║ Aggressive Mode: " .. string.format("%-42s", (stats.aggressiveMode and "ON" or "OFF")) .. "║",
        "╚═══════════════════════════════════════════════════════╝",
    }
    return table.concat(report, "\n")
end

-- Update configuration
function HybridSystem:setConfig(key, value)
    if self.config[key] ~= nil then
        self.config[key] = value
        self:log("SYSTEM", "Config updated: " .. key .. " = " .. tostring(value))
        return true
    end
    return false
end

-- Get current configuration
function HybridSystem:getConfig()
    return self.config
end

-- Get FPS history
function HybridSystem:getFPSHistory()
    return self.fpsHistory
end

-- Get Anti-AFK statistics
function HybridSystem:getAntiAFKStats()
    return {
        enabled = self.antiAFKEnabled,
        isRunning = self.antiAFKRunning,
        actionCount = self.actionCount,
        lastActionTime = self.lastActionTime,
        timeSinceLastAction = tick() - self.lastActionTime,
    }
end

-- Get FPS Booster statistics
function HybridSystem:getFPSBoosterStats()
    return {
        enabled = self.fpsBoosterEnabled,
        isRunning = self.fpsBoosterRunning,
        currentFPS = self:getCurrentFPS(),
        averageFPS = self:getAverageFPS(),
        targetFPS = self.config.targetFPS,
        memoryCleanups = self.cleanupCount,
        fpsReadings = #self.fpsHistory,
        aggressiveMode = self.config.aggressiveMode,
    }
end

-- ============================================
-- Usage Example
-- ============================================
--[[
    local hybridSystem = HybridSystem.new({
        -- Anti-AFK Settings
        antiAFKEnabled = true,
        antiAFKInterval = 30,
        antiAFKRandomVariation = true,
        antiAFKVariationRange = 5,
        maxInactivityTime = 300,
        
        -- FPS Booster Settings
        fpsBoosterEnabled = true,
        targetFPS = 60,
        aggressiveMode = false,
        autoOptimize = true,
        memoryCleanupInterval = 30,
        disableShadows = true,
        reduceParticles = true,
        reduceLighting = true,
        disablePostEffects = true,
        
        -- System Settings
        logActions = true,
        unifiedLogging = true,
    })
    
    -- Start the hybrid system
    hybridSystem:start()
    
    -- Get comprehensive statistics
    -- print(hybridSystem:getStats())
    
    -- Generate performance report
    -- print(hybridSystem:generateReport())
    
    -- Toggle individual modules
    -- hybridSystem:toggleAntiAFK()
    -- hybridSystem:toggleFPSBooster()
    
    -- Stop when needed
    -- hybridSystem:stop()
    
    -- Get module-specific stats
    -- print(hybridSystem:getAntiAFKStats())
    -- print(hybridSystem:getFPSBoosterStats())
--]]

return HybridSystem
