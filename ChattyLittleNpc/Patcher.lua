C_AddOns = C_AddOns or {}
C_AddOns.IsAddOnLoaded = IsAddOnLoaded

local orgCreateFrame = CreateFrame
CreateFrame = function (frameType, frameName, parentFrame, template)
  if template and template:match("BackdropTemplate") then
    template= template:gsub("BackdropTemplate", "")
  end
  return orgCreateFrame(frameType, frameName, parentFrame, template)
end

local soundCache = {}
local orgPlaySoundFile = PlaySoundFile
PlaySoundFile = function (sound, ...)
  local willPlay, soundHandle = orgPlaySoundFile(sound, ...)
  if willPlay then
    soundCache[soundHandle] = {
      sound = sound,
      startTime = GetTime()
    }
  end
  return willPlay, soundHandle
end
local orgStopSound = StopSound
StopSound = function (soundHandle, ...)
  soundCache[soundHandle] = nil
  return orgStopSound(soundHandle, ...)
end

C_Sound = C_Sound or {}
C_Sound.IsPlaying = function (soundHandle)
  local now = GetTime()
  local cached = soundCache[soundHandle]
  if cached and cached.sound then
    local soundFile = cached.sound
    if soundFile then
      local filename = soundFile:match("([^\\/]+)$")
      if _G["SoundDurations"] then
        local duration = _G["SoundDurations"][filename]
        if duration then
          return (now - cached.startTime < duration)
        end
      end
    end
  end
  return cached and (now - cached.startTime < 5)
end

C_GossipInfo = C_GossipInfo or {}
C_GossipInfo.GetText = function (...)
  return GetGossipText(...)
end

C_Item = C_Item or {}
C_Item.GetItemInfoInstant = function (...)
  return GetItemInfoInstant(...)
end
