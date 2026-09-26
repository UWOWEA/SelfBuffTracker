local addonName, addon = ...

local GameType = {
    CLASSIC = 1,
    FOREVER = 1.60,
    TBC = 2,
    WOTLK = 3,
    CATACLYSM = 4,
    MOP = 5,
    WOD = 6,
    Legion = 7,
    BFA = 8,
    SL = 9,
    DF = 10,
    TWW = 11,
}

local GameInfo = {
    buildVersion = nil, -- 2.5.6
    buildNumber = nil, -- 69795
    buildDate = nil,
    interfaceVersion = nil, -- 20506
    localizedVersion = nil,
    buildInfo = nil,
    currentVersion = nil, -- 20506
    name = nil,
    inicialized = false,
}
addon.GameInfo = GameInfo

function Init()
    local buildVersion, buildNumber, buildDate, interfaceVersion, localizedVersion, buildInfo, currentVersion  = GetBuildInfo()
    addon.GameInfo.buildVersion = buildVersion
    addon.GameInfo.buildNumber = buildNumber
    addon.GameInfo.buildDate = buildDate
    addon.GameInfo.interfaceVersion = interfaceVersion
    addon.GameInfo.localizedVersion = localizedVersion
    addon.GameInfo.buildInfo = buildInfo
    addon.GameInfo.currentVersion = currentVersion
    addon.GameInfo.inicialized = true
end

addon.GameInfo.Init = Init

function IsInicialized()
    return addon.GameInfo.inicialized
end

addon.GameInfo.IsInicialized = IsInicialized

function addon.GetGameVersion ()
    
    local buildVersion, buildNumber, buildDate, interfaceVersion, localizedVersion, buildInfo, currentVersion  = GetBuildInfo()
    print("buildVersion: ", buildVersion)
    print("buildNumber: ", buildNumber)
    print("interfaceVersion: ", interfaceVersion)
    print("currentVersion: ", currentVersion)
end