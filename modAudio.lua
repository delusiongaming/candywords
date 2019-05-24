-- =============================================================
-- Copyright 2018, Andrew Baronick, All rights reserved.
-- =============================================================
-- modAudio.lua
-- =============================================================

----------------------------------------------------------------------
--								Variables							--
----------------------------------------------------------------------
local click = audio.loadSound( "audio/select.mp3" )
local countGameStart = audio.loadSound( "audio/countGameStart.mp3" )
local freeGift = audio.loadSound( "audio/giftSound.mp3" )
local gameWon = audio.loadSound( "audio/gameWon.mp3" )
local wordWin = audio.loadSound( "audio/wordWin.mp3" )
local loseGame = audio.loadSound( "audio/loseGame.mp3" )
local star1 = audio.loadSound( "audio/star1.mp3" )
local star2 = audio.loadSound( "audio/star3.mp3" )
local star3 = audio.loadSound( "audio/star7.mp3" )
----------------------------------------------------------------------
--								  Mods    							--
----------------------------------------------------------------------
-- Audio Mods
local jsonFunct = require( "modJson" )
local audioFunct = {}

--Stop and Play Audio
function audioFunct.playSound(soundType, channelNum)
  local gameValues = jsonFunct.readGameValues()
  if gameValues[6] == 1 then
audio.stop(channelNum)
audio.play(soundType, {channel=channelNum} )
end
end

function audioFunct.click()
audioFunct.playSound(click, 2)
end

function audioFunct.freeGift()
audioFunct.playSound(freeGift, 2)
end

function audioFunct.countGameStart()
audioFunct.playSound(countGameStart, 2)
end

function audioFunct.gameWonner()
audioFunct.playSound(gameWon, 4)
end

function audioFunct.wordWin()
audioFunct.playSound(wordWin, 3)
end

function audioFunct.loseGame()
audioFunct.playSound(loseGame, 3)
end

function audioFunct.star1()
audioFunct.playSound(star1, 2)
end

function audioFunct.star2()
audioFunct.playSound(star2, 5)
end

function audioFunct.star3()
audioFunct.playSound(star3, 3)
end

return audioFunct