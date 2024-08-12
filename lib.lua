local lib = {}

function lib:init()
    for _,path in ipairs(Utils.getFilesRecursive(self.info.path.."/scripts/init")) do
        love.filesystem.load(self.info.path .. "/scripts/init/" .. path)()
    end
end

function lib:isStatusEffectsLoaded()
    return not not Mod.libs["status-effects"]
end

return lib