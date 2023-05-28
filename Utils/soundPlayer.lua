local audio = _G.audio

local SoundPlayer = {}
SoundPlayer.musicVolume   = 1
SoundPlayer.sfxVolume     = 1

local device = require("Utils.device")

-- Configuration -------------------------------------------------------------------------------------------------------

-- Stinger configuration
local fadeOutDelay = 100
local fadeOutTime  = 200
local fadeInDelay  = 600
local fadeInTime   = 200

-- ---------------------------------------------------------------------------------------------------------------------

local soundTable      = {}
local playingSounds   = {}
local eventSoundTable = {}
audio.reserveChannels( 1 )
audio.reserveChannels( 2 )

function SoundPlayer.loadSound(sound, long, ext, music)
    if not ext then ext = ".mp3" end
    if device.isAndroid and not device.isSimulator and not long then
      if not eventSoundTable[sound] then
        eventSoundTable[sound] = media.newEventSound("Assets/Audio/Sfx/"..sound..ext)
        if not eventSoundTable[sound] then
          error( "not sound", sound )
        end
      end
    elseif not soundTable[sound] then
      if not music                      then soundTable[sound] = audio.loadSound("Assets/Audio/Sfx/"..sound..ext)    end
      if music or not soundTable[sound] then soundTable[sound] = audio.loadSound("Assets/Audio/Musics/"..sound..ext) end

      if not soundTable[sound] then
        error( "Can't load sound: \""..sound..ext.."\"" )
      end
    end
end


function SoundPlayer.setState(state)
  SoundPlayer.muteMusic(not state:observe("settings.musicVolume", SoundPlayer, SoundPlayer._musicConfigsUpdated, true))
  SoundPlayer.muteSfx(not state:observe("settings.sfxVolume", SoundPlayer, SoundPlayer._sfxConfigsUpdated, true))
end


function SoundPlayer.playSound(sound, params)
  if _G.DEBUG.MUTE_SOUND or SoundPlayer.muted or SoundPlayer.sfxMuted or not SoundPlayer.canPlay(sound) then return end

  if not soundTable[sound] and device.isAndroid and not device.isSimulator then
    if not eventSoundTable[sound] then
      eventSoundTable[sound] = media.newEventSound("Assets/Audio/Sfx/"..sound..".mp3")
    end
    media.playEventSound(eventSoundTable[sound])
  else
    if not soundTable[sound] then
      soundTable[sound] = audio.loadSound("Assets/Audio/Sfx/"..sound..".mp3")
    end
    return audio.play(soundTable[sound], params)
  end
end


function SoundPlayer.canPlay(sound)
  local time = system.getTimer()
  if not playingSounds[sound] or time - playingSounds[sound] > 30 then
    playingSounds[sound] = time
    return true

  else
    return false

  end
end


function SoundPlayer.longSound(sound)
  if _G.DEBUG.MUTE_SOUND or SoundPlayer.muted or SoundPlayer.sfxMuted or not SoundPlayer.canPlay(sound) then return end

	if not soundTable[sound] then
		SoundPlayer.loadSound(sound,true)
	end
	return audio.play(soundTable[sound])
end


function SoundPlayer.playMusic(sound, stinger, once, onComplete, channel)
  if SoundPlayer.muted or _G.DEBUG.MUTE_MUSIC then return end

  channel = channel or 1

  if sound ~= nil then
    if not soundTable[sound] then
       SoundPlayer.loadSound(sound, true)
    end
  end
  if stinger then
    if _G.DEBUG.MUTE_SOUND or SoundPlayer.muted or SoundPlayer.sfxMuted then
      audio.play(soundTable[stinger])
    end

    timer.performWithDelay(fadeOutDelay,function()
      audio.fade{channel=channel, time=fadeOutTime, volume=0}
    end)
    if sound ~= nil then
      timer.performWithDelay(fadeInDelay,function()
        audio.stop(channel)
        audio.play(soundTable[sound],{channel = channel, loops = once and 1 or -1, onComplete = onComplete })
        audio.fade{channel = channel, time = fadeInTime, volume = 1}
      end)
    end
  else
    audio.stop(1)
  	return audio.play(soundTable[sound],{
      channel    = channel,
      loops      = once and 0 or -1,
      onComplete = onComplete
    })
  end

  return 1
end


function SoundPlayer.stop(channel)
  audio.stop(channel)
end


function SoundPlayer.fade(handler, time)
  audio.fadeOut{channel=handler, time = time}
  timer.performWithDelay(time or 1000, function()
    local volume = handler == 1 and SoundPlayer.musicVolume or SoundPlayer.sfxVolume
    SoundPlayer.setVolume(volume, handler)
  end)
end


function SoundPlayer.setVolume(v,channel)
  SoundPlayer.musicVolume = v
  SoundPlayer.sfxVolume = v
  audio.setVolume(v,{channel=channel})
end


function SoundPlayer.resume()
  audio.resume()
end


function SoundPlayer.pause()
  audio.pause()
end


function SoundPlayer.getDuration(sound)
  if soundTable[sound] then
    return audio.getDuration( soundTable[sound] )
  else
    return -1
  end
end


function SoundPlayer.mute(mute)
  if mute then
    audio.fadeOut { time = 0 }
    media.stopSound()

    if type(mute) == "string" then
      timer.performWithDelay( 20, function()
        SoundPlayer.muted = false
        SoundPlayer.playSound(mute)
        SoundPlayer.muted = true
      end)
    end
    SoundPlayer.muted = true

  else
    SoundPlayer.muted = false
  end

end


function SoundPlayer.muteSfx(mute)
  for i=2,32 do
    audio.fade{channel = i, time = 0, volume = mute and 0 or 1, 1}
  end

  SoundPlayer.sfxMuted = mute
end


function SoundPlayer.setMusicVolume(volume)
  SoundPlayer.musicVolume = volume
  audio.setVolume(volume, {channel = 1, time = 0, volume = volume})
end


function SoundPlayer.setSfxVolume(volume)
  SoundPlayer.sfxVolume = volume
  for i=2,32 do
    audio.setVolume(volume, {channel = i, time = 0, volume = volume})
  end
end


function SoundPlayer.muteMusic(mute)
  audio.fade{channel = 1, time = 500, volume = mute and 0 or 1, 1}
end


function SoundPlayer:_musicConfigsUpdated(e)
  SoundPlayer.setMusicVolume(e.value)
end


function SoundPlayer:_sfxConfigsUpdated(e)
  SoundPlayer.setSfxVolume(e.value)
end


return SoundPlayer
