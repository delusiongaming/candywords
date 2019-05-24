-- =============================================================
-- Copyright 2018, Andrew Baronick, All rights reserved.
-- =============================================================
-- main.lua
-- =============================================================

----------------------------------------------------------------------
--	1. Requires
----------------------------------------------------------------------
local composer 	= require "composer"
local json = require( "json" )
local admob = require( "plugin.admob" )
local jsonFunct = require( "modJson" )

----------------------------------------------------------------------
--	2. Initialization
----------------------------------------------------------------------

-- Test If First Time Opening
local firstTimeFileContents = jsonFunct.readFirstTimeOpenValue()

-- If first time opening write all the first time files
if firstTimeFileContents == nil then

  --Set Game Files
  -- 1-Coins, 2-ives, 3-totaLLives, 4-livesTime, 5-Music On / Off, 6-Audio On / Off, 7-OPEN SPOT X, 8- OPEN SPOT X, 9-OPEN SPOT
  -- 10-Daily Reward Day, 11-Daily Reward Time, 12-Play Count, 13-Random Ad Num, 14-OPEN SPOT, 15-Rated
  gameValues = {9,7,7,0,0,1,0,0,0,1,0,0,4,0,0}

  --Set Current Level, Current Playing Level, and Restarts For All Difficultys
  -- 1-Easy Current Level, 2-Medium Current Level, 3-Hard Current Level
  -- 4-Easy Current Playing Level, 5-Medium Current Playing Level, 6-Hard Current Playing Level
  currentLevelValues = {1,1,1,1,1,1}

  -- Set Easy Game Stats
  -- Easy   1-Score, 2-Moves, 3-Time, 4-Stars
  easyStatsValues = {{0,0,0,0}}

  -- Set Medium Game Stats
  -- Medium 1-Score, 2-Moves, 3-Time, 4-Stars
  mediumStatsValues = {{0,0,0,0}}

  -- Set Hard Game Stats
  -- Hard 1-Score, 2-Moves, 3-Time, 4-Stars
  hardStatsValues = {{0,0,0,0}}

  --Store Data
  -- 1. Remove Ads, 2. Infinite Lives Bought, 3. Double Time Bought, 4. Double Lives Bought, 5. Lives Expiration, 6.Time Expiration
  storeValues = {0,0,0,0,0,0}

  --Life Regeneration Data
  lifeRegenerationValues = {0}

  -- Store All First Time Opening Data
  jsonFunct.writeGameValues(gameValues)
  jsonFunct.writeCurrentLevelValues(currentLevelValues)
  jsonFunct.writeEasyStatsValues(easyStatsValues)
  jsonFunct.writeMediumStatsValues(mediumStatsValues)
  jsonFunct.writeHardStatsValues(hardStatsValues)
  jsonFunct.writeStoreValues(storeValues)
  jsonFunct.writeLifeRegenerationValues(lifeRegenerationValues)
end

--Start Music
local backgroundMusic = audio.loadStream( "audio/backgroundMusic.mp3" )
audio.reserveChannels( 1 )
audio.play( backgroundMusic, { channel=1, loops=-1 } )

--Set Audio Channel Volumes
audio.setVolume( 0, { channel = 1 } )
audio.setVolume( 0, { channel = 2 } )
audio.setVolume( 0, { channel = 3 } )
audio.setVolume( 0, { channel = 4 } )
audio.setVolume( 0, { channel = 5 } )

--Ad Handler
local storeValues = jsonFunct.readStoreValues()
local gameValues = jsonFunct.readGameValues()
local function adListener( event )
  if ( event.phase == "init") then
    if storeValues[1]==0 and (gameValues[13]-gameValues[12])<3 then
      admob.load( "interstitial", { adUnitId="ca-app-pub-6435409860009337/6932271253"} )
    end
    if gameValues[2]<3 then
      admob.load( "rewardedVideo", { adUnitId="ca-app-pub-6435409860009337/6547034542" } )
    end
  elseif ( event.phase == "reward") then
    local callingScene = composer.getScene( composer.getSceneName( "current" ) )
    callingScene:processReward()
  elseif ( event.phase == "closed") then
    if ( event.type == "interstitial") then
      local callingScene = composer.getScene( composer.getSceneName( "current" ) )
      callingScene:processInterstitial()
    end
  end
  return true
end
admob.init( adListener, { appId="ca-app-pub-6435409860009337~3062166862"} )

-- Back Button Handler for Android and Amazon
local function onKeyEvent( event )
	local keyButton = event.keyName
	local phase = event.phase
	local returnType = true
  if keyButton == "back" and phase == "down" then
    local callingScene = composer.getScene( composer.getSceneName( "current" ) )
    callingScene:backButton()
    returnType = true
    elseif keyButton == "volumeDown" and phase == "down" then
    returnType = false
    elseif keyButton == "volumeUp" and phase == "down" then
    returnType = false
  end
  return returnType
end

Runtime:addEventListener( "key", onKeyEvent )
----------------------------------------------------------------------
-- 3. Execution
----------------------------------------------------------------------

--Go to Main Menu
composer.gotoScene( "code.mainMenu" )