-- =============================================================
-- Copyright 2018, Andrew Baronick, All rights reserved.
-- =============================================================
-- Easy Level Chooser
-- =============================================================
local composer = require( "composer" )
local scene = composer.newScene()

--------------------------------------------------------------------------------
-- "scene:create()"
--------------------------------------------------------------------------------
function scene:create( event )
  local sceneGroup = self.view
end

local content
--------------------------------------------------------------------------------
-- "scene:show()"
--------------------------------------------------------------------------------
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    ----------------------------------------------------------------------
    --                REQUIRES              --
    ----------------------------------------------------------------------
    local store = require( "plugin.google.iap.v3" )
    local jsonFunct = require( "modJson" )
    local admob = require( "plugin.admob" )
    local audioFunct = require( "modAudio" )
    local diffChooser = event.params

    ----------------------------------------------------------------------
    --                LOCALS                --
    ----------------------------------------------------------------------
    -- JSON Variables
    local gameValues = jsonFunct.readGameValues()
    local storeValues = jsonFunct.readStoreValues()
    local currentLevelValues = jsonFunct.readCurrentLevelValues()
    local lifeRegenerationValues = jsonFunct.readLifeRegeneration()
    local statsValues
    if diffChooser == 1 then
      statsValues = jsonFunct.readEasyStatsValues()
    elseif diffChooser == 2 then
      statsValues = jsonFunct.readMediumStatsValues()
    elseif diffChooser == 3 then
      statsValues = jsonFunct.readHardStatsValues()
    end

    --Assigned JSON Variables
    local coins = gameValues[1]
    local lives = gameValues[2]
    local currentLevel
    if diffChooser == 1 then
      currentLevel = currentLevelValues[1]
    elseif diffChooser == 2 then
      currentLevel = currentLevelValues[2]
    elseif diffChooser == 3 then
      currentLevel = currentLevelValues[3]
    end

    local soundOn = gameValues[6]

    -- Display Variables
    local dW = display.contentWidth
    local dH = display.contentHeight
    local cX = display.contentCenterX
    local cY = display.contentCenterY
    local handleTransitions
    local backgroundTable, starsTable, spotTable, spotNumTable = {}, {}, {}, {}
    local howManyBG, levelDiv, leveDec
    local spotX = {dW*.07,dW*.209,dW*.345,dW*.512,dW*.334,dW*.45,dW*.6,dW*.721,dW*.894,dW*.875}
    local spotY = {dH*.584,dH*.68,dH*.49,dH*.518,dH*.768,dH*.865,dH*.865,dH*.809,dH*.731,dH*.568}

    -- Screen Variables
    local screenName = "none"
    local windowName = "none"
    local changeScreen, statsMenuNum
    local storeParam, adProcessOnce = 0, 0

    --Parent Image Holders
    local images = {}
    content = display.newGroup()
    self.view:insert( content )

    ----------------------------------------------------------------------
    --             CREATE IMAGE GROUPS            --
    ----------------------------------------------------------------------

    bgGroup = display.newGroup()
    content:insert( bgGroup )
    hudGroup = display.newGroup()
    content:insert( hudGroup )
    nextLifeHudGroup = display.newGroup()
    content:insert( nextLifeHudGroup )
    notEnoughLivesGroup = display.newGroup()
    content:insert( notEnoughLivesGroup )
    statsMenuGroup = display.newGroup()
    content:insert( statsMenuGroup )
    parsedLevelGroup = display.newGroup()
    content:insert( parsedLevelGroup )

    --Function to Create Images
    local function createImage(dispGroup, imageLoc, xSize, ySize, xLoc, yLoc)
      local i = display.newImageRect(dispGroup, imageLoc, xSize, ySize )
      i.x = xLoc
      i.y = yLoc
      return i
    end

    --Function to Create Words
    local function createWords(dispGroup, text, xLoc, yLoc, textSize)
      local p = display.newText(dispGroup, text, xLoc, yLoc, "RifficFree-Bold.ttf", textSize)
      return p
    end

    ----------------------------------------------------------------------
    --               Parse Level           --
    ----------------------------------------------------------------------
    local function parseLevel(levelToParse)
      if images.parsedLevel1 then
        images.parsedLevel1:removeSelf()
        images.parsedLevel1 = nil
      end
      if images.parsedLevel2 then
        images.parsedLevel2:removeSelf()
        images.parsedLevel2 = nil
      end
      if images.parsedLevel3 then
        images.parsedLevel3:removeSelf()
        images.parsedLevel3 = nil
      end
      local stringParse = tostring( levelToParse )
      local parse1ImageName = "images/" .. string.sub(stringParse, 1, 1) .. ".png"
      images.parsedLevel1 =  createImage(parsedLevelGroup, parse1ImageName, 38, 38, dW*.577, dH*.384+dH)
      if levelToParse > 9 then
        local parse2ImageName = "images/" .. string.sub(stringParse, 2, 2) .. ".png"
        images.parsedLevel2 =  createImage(parsedLevelGroup, parse2ImageName, 38, 38, dW*.63, dH*.384+dH )
      end
      if levelToParse > 99 then
        local parse3ImageName = "images/" .. string.sub(stringParse, 3, 3) .. ".png"
        images.parsedLevel3 =  createImage(parsedLevelGroup, parse3ImageName, 38, 38, dW*.688, dH*.384+dH )
      end
    end

    ----------------------------------------------------------------------
    --            Change Screen Setup           --
    ----------------------------------------------------------------------

    local function handleInterstellar()
      if gameValues[12] == gameValues[13] then
        if ( admob.isLoaded( "interstitial" ) ) then
          gameValues[13]=math.random(3, 4)
          admob.show( "interstitial" )
        end
      else
        gameValues[12] = gameValues[12] + 1
      end
      jsonFunct.writeGameValues(gameValues)
    end

    local function changeScreenSetup(event)
      local target, phase
      if event=="nativeBackButton" then
        target = images.backButton
        phase = "began"
      else
        target = event.target
        phase = event.phase
      end
      if target == images.backButton then
        screenName = "code.mainMenu"
      end
      if ( phase=="began" ) then
        audioFunct.click()
        changeScreen()
      end
      return true
    end

    local function playNextLevel(event)
      local target = event.target
      local phase = event.phase
      if ( phase=="began" and windowName == "none") then
        audioFunct.click()
      elseif ( phase == "ended" and windowName == "none") then
        if lives > 0 then
          if diffChooser == 1 then
            currentLevelValues[4] = target.num
          elseif diffChooser == 2 then
            currentLevelValues[5] = target.num
          elseif diffChooser == 3 then
            currentLevelValues[6] = target.num
          end
          jsonFunct.writeCurrentLevelValues(currentLevelValues)
          screenName = "playGame"
          handleInterstellar()
          changeScreen()
        else
          windowName = "notEnoughLives"
          statsMenuNum = target.num
          if coins < 1 then
            images.notEnoughLivesOneCoinButton.fill.effect = "filter.grayscale"
          end
          if not ( admob.isLoaded( "rewardedVideo" ) ) then
            images.notEnoughLivesWatchAdButton.fill.effect = "filter.grayscale"
          end
          parseLevel(target.num)
          transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack} )
          transition.to(notEnoughLivesGroup, {time=450, y=-dH, transition=easing.outBack} )
        end
      end
      return true
    end

    local function statsMenu(event)
      local target = event.target
      local phase = event.phase
      if ( phase=="began" and windowName == "none" and target.num < currentLevel ) then
        audioFunct.click()
      elseif ( phase == "ended" and windowName == "none" and target.num < currentLevel) then
        windowName = "statsMenu"
        statsMenuNum = target.num
        parseLevel(target.num)
        images.statsMenuActualScore.text = statsValues[target.num][1]
        images.statsMenuActualMoves.text = statsValues[target.num][2]
        images.statsMenuActualTime.text = statsValues[target.num][3]
        if statsValues[target.num][4] == 2 then
          images.statsMenuStar2.fill.effect = ""
        elseif statsValues[target.num][4] == 3 then
          images.statsMenuStar2.fill.effect = ""
          images.statsMenuStar3.fill.effect = ""
        end
        transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack} )
        transition.to(statsMenuGroup, {time=450, y=-dH, transition=easing.outBack} )
      end
      return true
    end

    ----------------------------------------------------------------------
    --             CREATE IMAGES            --
    ----------------------------------------------------------------------

    --Determine how many background images to make
    levelDiv = currentLevel/10
    levelDec = currentLevel%10
    if levelDec < 5 then
      howManyBG = math.round(levelDiv)+1
    else
      howManyBG = math.round(levelDiv)
    end
    if howManyBG>=30 then
      howManyBG=29
    end

    --Create backgrounds
    for x=howManyBG,0,-1 do
      local background
      if diffChooser == 1 then
        background = display.newImageRect(bgGroup, "images/easyMap.png", dW, dH )
      elseif diffChooser == 2 then
        background = display.newImageRect(bgGroup, "images/mediumMap.png", dW, dH )
      elseif diffChooser == 3 then
        background = display.newImageRect(bgGroup, "images/hardMap.png", dW, dH )
      end
      background.x = cX+(dW*x)
      background.y = cY
      background.num=x
      table.insert(backgroundTable,background)
    end

    --Parse levels to images for spot points
    local function spotParser(numbers)
      numbersJoined = display.newGroup()
      local currentNumber = tonumber( string.sub( numbers, 1, 1 ) )
      local imageName = "images/" .. currentNumber .. ".png"
      local spotParserNumber1 = display.newImageRect(numbersJoined, imageName, 20, 20)
      spotParserNumber1.x = 0
      if string.len(numbers)>=2 then
        currentNumber = tonumber( string.sub( numbers, 2, 2 ) )
        imageName = "images/" .. currentNumber .. ".png"
        local spotParserNumber2 = display.newImageRect(numbersJoined, imageName, 20, 20 )
        spotParserNumber1.x = -7
        spotParserNumber2.x = 7
        if string.len(numbers)==3 then
          currentNumber = tonumber( string.sub( numbers, 3, 3 ) )
          imageName = "images/" .. currentNumber .. ".png"
          local numbers3Image2 = display.newImageRect(numbersJoined, imageName, 20, 20)
          spotParserNumber1.x = -14
          spotParserNumber2.x = 0
          spotParserNumber3.x = 14
        end
      end
      bgGroup:insert(numbersJoined)
    end

    --Create Spot Points
    for j=1,currentLevel,1 do
      table.insert(starsTable,statsValues[j][4])
    end
    for t=0,howManyBG,1 do
      for x=1,10,1 do
        local levelCounter = x+(t*10)
        local starLevels = starsTable[levelCounter]
        if diffChooser == 1 and x==1 and t==0 then
          spot = display.newImageRect(bgGroup, "images/easySpotTutorial.png", 28, 28 )
          spot:addEventListener( "touch", statsMenu )
        elseif starLevels ~= nil then
          if starLevels == 0 then
            if (x%5)==0 then
              if diffChooser == 1 then
                spot = display.newImageRect(bgGroup, "images/easySpotCoinUnlocked.png", 28, 28 )
              elseif diffChooser == 2 then
                spot = display.newImageRect(bgGroup, "images/mediumSpotCoinUnlocked.png", 28, 28 )
              elseif diffChooser == 3 then
                spot = display.newImageRect(bgGroup, "images/hardSpotCoinUnlocked.png", 28, 28 )
              end
            else
              if diffChooser == 1 then
                spot = display.newImageRect(bgGroup, "images/easySpot0Star.png", 28, 28 )
              elseif diffChooser == 2 then
                spot = display.newImageRect(bgGroup, "images/mediumSpot0Star.png", 28, 28 )
              elseif diffChooser == 3 then
                spot = display.newImageRect(bgGroup, "images/hardSpot0Star.png", 28, 28 )
              end
            end
          elseif starLevels == 1 then
            if diffChooser == 1 then
            spot = display.newImageRect(bgGroup, "images/easySpot1Star.png", 28, 28 )
            elseif diffChooser == 2 then
              spot = display.newImageRect(bgGroup, "images/mediumSpot1Star.png", 28, 28 )
              elseif diffChooser == 3 then
                spot = display.newImageRect(bgGroup, "images/hardSpot1Star.png", 28, 28 )
              end
          elseif starLevels == 2 then
            if diffChooser == 1 then
            spot = display.newImageRect(bgGroup, "images/easySpot2Star.png", 28, 28 )
            elseif diffChooser == 2 then
              spot = display.newImageRect(bgGroup, "images/mediumSpot2Star.png", 28, 28 )
              elseif diffChooser == 3 then
                spot = display.newImageRect(bgGroup, "images/hardSpot2Star.png", 28, 28 )
              end
          elseif starLevels == 3 then
            if diffChooser == 1 then
            spot = display.newImageRect(bgGroup, "images/easySpot3Star.png", 28, 28 )
            elseif diffChooser == 2 then
              spot = display.newImageRect(bgGroup, "images/mediumSpot3Star.png", 28, 28 )
              elseif diffChooser == 3 then
                spot = display.newImageRect(bgGroup, "images/hardSpot3Star.png", 28, 28 )
              end
          end
          if starLevels == 0 then
            spot:addEventListener( "touch", playNextLevel )
          else
            spot:addEventListener( "touch", statsMenu )
          end
        else
          if (x%5)==0 then
            if diffChooser == 1 then
              spot = display.newImageRect(bgGroup, "images/easySpotCoinLocked.png", 28, 28 )
            elseif diffChooser == 2 then
              spot = display.newImageRect(bgGroup, "images/mediumSpotCoinLocked.png", 28, 28 )
            elseif diffChooser == 3 then
              spot = display.newImageRect(bgGroup, "images/hardSpotCoinLocked.png", 28, 28 )
            end
          else
            if diffChooser == 1 then
              spot = display.newImageRect(bgGroup, "images/easySpotLocked.png", 28, 28 )
            elseif diffChooser == 2 then
              spot = display.newImageRect(bgGroup, "images/mediumSpotLocked.png", 28, 28 )
            elseif diffChooser == 3 then
              spot = display.newImageRect(bgGroup, "images/hardSpotLocked.png", 28, 28 )
            end
          end
        end
        spot.x = spotX[x] + (dW*t) ; spot.y = spotY[x]
        spot.num = x+(t*10)
        spotParser(levelCounter)
        numbersJoined.x = spotX[x] + (dW*t) ; numbersJoined.y = spotY[x]-20
        table.insert(spotTable,spot)
        table.insert(spotNumTable,numbersJoined)
      end
    end

    --Hud Group
    images.backButton = createImage(hudGroup, "images/back.png", 45, 45, dW*.07, dH*.087)
    images.healthHud = createImage(hudGroup, "images/healthHud.png", 85, 41, dW*.91, dH*.081)
    images.coinHud = createImage(hudGroup, "images/coinHud.png", 85, 41, dW*.719, dH*.081)
    images.actualCoins = createWords(hudGroup, coins, dW*.689, dH*.075, 15)

    if storeValues[2] == 1 then
      images.actualLives = createWords(hudGroup, lives, dW*.88, dH*.075+dH, 15)
      images.infiniteLivesPic = createImage(hudGroup, "images/infiniteSign.png", 21, 18, dW*.885, dH*.075)
    else
      images.actualLives = createWords(hudGroup, lives, dW*.88, dH*.075, 15)
      images.infiniteLivesPic = createImage(hudGroup, "images/infiniteSign.png", 21, 18, dW*.885, dH*.075+dH)
    end

    --Next Life Hud
    images.healthTimerHud = createImage(nextLifeHudGroup, "images/heartClock.png", 85, 41, dW*.91, dH*.225+dH)
    images.actualHealthTimerMin = createWords(nextLifeHudGroup, "", dW*.867, dH*.225+dH, 15)
    images.actualHealthTimerSec = createWords(nextLifeHudGroup, "", dW*.901, dH*.225+dH, 15)
    images.actualHealthTimerColon = createWords(nextLifeHudGroup, ":", dW*.88, dH*.218+dH, 15)

    --Not Enough Lives Window
    images.backNotEnoughLivesWindow = display.newRect(notEnoughLivesGroup, cX, cY+dH, dW*2, dH)
    images.backNotEnoughLivesWindow.fill = {.13, .92}
    images.notEnoughLivesWindow = createImage(notEnoughLivesGroup, "images/notEnoughLivesWindow.png", 430, 290, cX, cY+dH)
    images.notEnoughLivesExitButton = createImage(notEnoughLivesGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.notEnoughLivesHomeButton = createImage(notEnoughLivesGroup, "images/homeButton.png", 90, 45, cX-dW*.132, dH*.906+dH)
    images.notEnoughLivesStoreButton = createImage(notEnoughLivesGroup, "images/storeButton.png", 90, 45, cX+dW*.132, dH*.906+dH)
    images.notEnoughLivesOneCoinButton = createImage(notEnoughLivesGroup, "images/life1Coin.png", 97, 141, dW*.252, dH*.595+dH)
    images.notEnoughLivesWatchAdButton = createImage(notEnoughLivesGroup, "images/lifeWatchAd.png", 97, 141, dW*.75, dH*.595+dH)

    --Create Stats Menu Window
    images.backStatsMenuWindow = display.newRect(statsMenuGroup, cX, cY+dH, dW*2, dH)
    images.backStatsMenuWindow.fill = {.13, .92}
    images.statsMenuWindow = createImage(statsMenuGroup, "images/statsWindow.png", 430, 290, cX, cY+dH)
    images.statsMenuExitButton = createImage(statsMenuGroup, "images/exit.png", 50, 50, dW*.82, dH*.25+dH )
    images.statsMenuPlayButton = createImage(statsMenuGroup, "images/playStatsButton.png", 90, 45, cX, dH*.906+dH)
    images.statsMenuActualTime = createWords(statsMenuGroup, "", dW*.26, dH*.71+dH, 18 )
    images.statsMenuActualScore = createWords(statsMenuGroup, "", dW*.478, dH*.703+dH, 20 )
    images.statsMenuActualMoves = createWords(statsMenuGroup, "", dW*.691, dH*.712+dH, 18 )
    images.statsMenuStar1 = createImage(statsMenuGroup, "images/star.png", 48, 48, dW*.387, dH*.537+dH)
    images.statsMenuStar2 = createImage(statsMenuGroup, "images/star.png", 48, 48, dW*.49, dH*.537+dH)
    images.statsMenuStar3 = createImage(statsMenuGroup, "images/star.png", 48, 48, dW*.598, dH*.537+dH)
    images.statsMenuStar2.fill.effect = "filter.grayscale"
    images.statsMenuStar3.fill.effect = "filter.grayscale"

    ----------------------------------------------------------------------
    --              Next Life Handler          --
    ----------------------------------------------------------------------
    --Handle Next Life Counter
    local function nextLifeHandler()
      if lifeRegenerationValues[1] > 0 then
      local currentTimeNextLife = os.date( '*t' )
    currentTimeNextLife = os.time(currentTimeNextLife)
    local timeGap = lifeRegenerationValues[1] - currentTimeNextLife
    if timeGap <= 0 then
      if #lifeRegenerationValues == 1 and currentTimeNextLife >= lifeRegenerationValues[1] then
          lifeRegenerationValues[1] = 0
          transition.to(nextLifeHudGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        else
          table.remove(lifeRegenerationValues,1)
          images.actualHealthTimerMin.text = "3"
      images.actualHealthTimerSec.text = "00"
        end
      lives = lives + 1
      images.actualLives.text = lives
      gameValues[2] = lives
      jsonFunct.writeGameValues(gameValues)
      jsonFunct.writeLifeRegenerationValues(lifeRegenerationValues)
      images.actualHealthTimerSec.x = dW*.901
      images.actualHealthTimerColon.text = ":"
    else
      if timeGap < 60 then
        images.actualHealthTimerSec.x = dW*.889
        images.actualHealthTimerMin.text = ""
        images.actualHealthTimerColon.text = ""
        if timeGap < 10 then
          images.actualHealthTimerSec.text = "0" .. tostring( timeGap )
        else
        images.actualHealthTimerSec.text = tostring( timeGap )
      end
        elseif timeGap >= 60 and timeGap < 120 then
        images.actualHealthTimerMin.text = "1"
        if timeGap < 70 then
          images.actualHealthTimerSec.text = "0" .. tostring( timeGap - 60 )
        else
        images.actualHealthTimerSec.text = tostring( timeGap - 60 )
      end
      else
        images.actualHealthTimerMin.text = "2"
        if timeGap < 130 then
          images.actualHealthTimerSec.text = "0" .. tostring( timeGap - 120 )
        else
        images.actualHealthTimerSec.text = tostring( timeGap - 120 )
      end
end
end
end
end

    --Handle Initial Lives
      local currentTimeCheckLives = os.date( '*t' )
      currentTimeCheckLives = os.time(currentTimeCheckLives)
      local howManyPops = 0
      for r=1, #lifeRegenerationValues, 1 do
        if currentTimeCheckLives >= lifeRegenerationValues[r] and lifeRegenerationValues[r] > 0 then
          howManyPops = howManyPops + 1
          end
        end
          if howManyPops > 0 then
            for r=1, howManyPops, 1 do
              if #lifeRegenerationValues == 1 then
                lifeRegenerationValues[1] = 0
              else
              table.remove(lifeRegenerationValues,1)
            end
            lives=lives+1
            end
          gameValues[2] = lives
          images.actualLives.text = lives
          jsonFunct.writeGameValues(gameValues)
          jsonFunct.writeLifeRegenerationValues(lifeRegenerationValues)
          end
      if lifeRegenerationValues[1] ~= 0 then
        nextLifeHudGroup.y = nextLifeHudGroup.y - dH
      local loopTimes = #lifeRegenerationValues * 180
      timer.performWithDelay( 1000, nextLifeHandler, loopTimes)
    end

    ----------------------------------------------------------------------
    --         Initial Store Data Handler      --
    ----------------------------------------------------------------------
    if storeValues[2] == 1 or storeValues[3] == 1 or storeValues[4] == 1 then
      local currentTimeStore = os.date( '*t' )
      currentTimeStore = os.time(currentTimeStore)
      if storeValues[2] == 1 or storeValues[4] == 1 then
        if currentTimeStore >= storeValues[5] then
          if storeValues[2] == 1 then
            images.actualLives.y = images.actualLives.y - dH
            images.infiniteLivesPic.y = images.infiniteLivesPic.y + dH
          end
          storeValues[2] = 0
          storeValues[4] = 0
          storeValues[5] = 0
          gameValues[3] = 7
        jsonFunct.writeStoreValues(storeValues)
        jsonFunct.writeGameValues(gameValues)
        end
      end
      if storeValues[3] == 1 then
        if currentTimeStore >= storeValues[6] then
          storeValues[3] = 0
          storeValues[6] = 0
        jsonFunct.writeStoreValues(storeValues)
        end
      end
    end

    ----------------------------------------------------------------------
    --           Transition Handlers         --
    ----------------------------------------------------------------------
    local function transitionExitWindow(event)
      local target = event.target
      local phase = event.phase
      local function changeScreenFunct()
        changeScreen()
      end
      local function showNotEnoughLives()
        if coins < 1 then
          images.notEnoughLivesOneCoinButton.fill.effect = "filter.grayscale"
        end
        if not ( admob.isLoaded( "rewardedVideo" ) ) then
          images.notEnoughLivesWatchAdButton.fill.effect = "filter.grayscale"
        end
        parseLevel(statsMenuNum)
        transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack} )
        transition.to(notEnoughLivesGroup, {time=450, y=-dH, transition=easing.outBack} )
      end
      if ( "began" == phase ) then
        audioFunct.click()
      elseif ( phase == "ended" ) then
        windowName = "none"
        if target ~= images.notEnoughLivesWatchAdButton then 
        transition.to(parsedLevelGroup, {time=450, y=dH+dH, transition=easing.inBack} )
      end
        if target == images.statsMenuExitButton then
          transition.to(statsMenuGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        elseif target == images.statsMenuPlayButton then
          if lives > 0 then
            if diffChooser == 1 then
              currentLevelValues[4] = statsMenuNum
            elseif diffChooser == 2 then
              currentLevelValues[5] = statsMenuNum
            elseif diffChooser == 3 then
              currentLevelValues[6] = statsMenuNum
            end
            jsonFunct.writeCurrentLevelValues(currentLevelValues)
            screenName = "playGame"
            handleInterstellar()
            transition.to(statsMenuGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          else
            windowName = "notEnoughLives"
            parseLevel(statsMenuNum)
            transition.to(statsMenuGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=showNotEnoughLives} )
          end
        elseif target == images.notEnoughLivesExitButton then
          transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        elseif target == images.notEnoughLivesStoreButton then
          screenName = "code.mainMenu"
          storeParam = 1
          transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.notEnoughLivesHomeButton then
          screenName = "code.mainMenu"
          transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.notEnoughLivesOneCoinButton then
          if coins > 0 then
            coins = coins - 1
            lives = lives + 1
            gameValues[1] = coins
            gameValues[2] = lives
            if diffChooser == 1 then
              currentLevelValues[4] = statsMenuNum
            elseif diffChooser == 2 then
              currentLevelValues[5] = statsMenuNum
            elseif diffChooser == 3 then
              currentLevelValues[6] = statsMenuNum
            end
            jsonFunct.writeGameValues(gameValues)
            jsonFunct.writeCurrentLevelValues(currentLevelValues)
            screenName = "playGame"
            handleInterstellar()
            transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          end
        elseif target == images.notEnoughLivesWatchAdButton then
          if ( admob.isLoaded( "rewardedVideo" ) ) then
            transition.to(parsedLevelGroup, {time=450, y=dH+dH, transition=easing.inBack} )
            transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack} )
            admob.show( "rewardedVideo")
          end
        end
      end
      return true
    end

    ----------------------------------------------------------------------
    --          Load Current Level in Middle Of Screen     --
    ----------------------------------------------------------------------
    local function bringCurrentToMiddle()
  if currentLevel>293 then
    currentLevel=293
  end
 local currentLevelMover = ((howManyBG*dW)-(((howManyBG+1)*dW)-spotTable[currentLevel].x))+cX
  if currentLevel > 7 then
    bgGroup.x = bgGroup.x - currentLevelMover
  end
end

    ----------------------------------------------------------------------
    --          Make Background Moveable     --
    ----------------------------------------------------------------------
    --Background Scroll Function
    local function moveBG(event)
      local target = event.target
      local phase = event.phase
      if ( "began" == phase and windowName == "none") then
        display.currentStage:setFocus( target )
        bgGroup.startX = bgGroup.x
      elseif ( "moved" == phase and windowName == "none" and (event.x - event.xStart) + bgGroup.startX<=0 and (event.x - event.xStart) + bgGroup.startX>=-dW*howManyBG) then
        bgGroup.x = (event.x - event.xStart) + bgGroup.startX
      elseif phase == "ended" or phase == "cancelled" and windowName == "none" then
        display.getCurrentStage():setFocus( nil )
      end
      return true
    end



    ----------------------------------------------------------------------
    --          Ad Handler         --
    ----------------------------------------------------------------------
    if not admob.isLoaded( "interstitial" ) and storeValues[1]==0 and (gameValues[13]-gameValues[12])<3 then
      admob.load( "interstitial", { adUnitId="ca-app-pub-6435409860009337/6932271253" } )
    end
    if admob.isLoaded( "rewardedVideo" )==false and gameValues[2]<3 then
      admob.load( "rewardedVideo", { adUnitId="ca-app-pub-6435409860009337/6547034542" } )
    end

    function scene:processReward()
      lives = lives + 1
      gameValues[2] = lives
      jsonFunct.writeGameValues(gameValues)
      if diffChooser == 1 then
        currentLevelValues[4] = statsMenuNum
      elseif diffChooser == 2 then
        currentLevelValues[5] = statsMenuNum
      elseif diffChooser == 3 then
        currentLevelValues[6] = statsMenuNum
      end
      jsonFunct.writeCurrentLevelValues(currentLevelValues)
      screenName = "playGame"
      changeScreen()
  end

    function scene:processInterstitial()
      if diffChooser == 1 then
        currentLevelValues[4] = statsMenuNum
      elseif diffChooser == 2 then
        currentLevelValues[5] = statsMenuNum
      elseif diffChooser == 3 then
        currentLevelValues[6] = statsMenuNum
      end
      jsonFunct.writeCurrentLevelValues(currentLevelValues)
      screenName = "playGame"
      changeScreen()
  end

    ----------------------------------------------------------------------
    --              Audio Handler              --
    ----------------------------------------------------------------------
    --Start Of Game Music + Sound Handler
    local function startSoundHandler()
      if soundOn==0 then
        audio.setVolume(  0, { channel = 2 } )
      else
        audio.setVolume(  .75, { channel = 2 } )
      end
    end
    startSoundHandler()

    ----------------------------------------------------------------------
    --          Create Event Listeners         --
    ----------------------------------------------------------------------
    bringCurrentToMiddle()
    for y=#backgroundTable,1,-1 do
      backgroundTable[y]:addEventListener( "touch", moveBG )
    end
    images.backButton:addEventListener( "touch", changeScreenSetup )
    images.statsMenuExitButton:addEventListener( "touch", transitionExitWindow )
    images.statsMenuPlayButton:addEventListener( "touch", transitionExitWindow )
    images.notEnoughLivesExitButton:addEventListener( "touch", transitionExitWindow )
    images.notEnoughLivesStoreButton:addEventListener( "touch", transitionExitWindow )
    images.notEnoughLivesHomeButton:addEventListener( "touch", transitionExitWindow )
    images.notEnoughLivesOneCoinButton:addEventListener( "touch", transitionExitWindow )
    images.notEnoughLivesWatchAdButton:addEventListener( "touch", transitionExitWindow )

    ----------------------------------------------------------------------
    --        Back Button Handler      --
    ----------------------------------------------------------------------
    function scene:backButton()
      changeScreenSetup("nativeBackButton")
    end

    ----------------------------------------------------------------------
    --              Change Screen            --
    ----------------------------------------------------------------------
    changeScreen  = function ( self, event )
    if screenName == "playGame" then
      if diffChooser == 1 then
        if statsMenuNum == 1 then
          screenName = "code.playEasyFirst"
        else
        screenName = "code.playEasy"
      end
      elseif diffChooser == 2 then
        screenName = "code.playMedium"
      elseif diffChooser == 3 then
        screenName = "code.playHard"
      end
    end
    local options1 =
    {
      effect = "fromBottom",
      time = 750,
    }
    local options2 =
    {
      effect = "fromBottom",
      time = 750,
      params="store",
    }
    if adProcessOnce == 0 then
      adProcessOnce = 1
    if storeParam == 0 then
      composer.gotoScene( screenName, options1  )
    else
      composer.gotoScene( screenName, options2  )
    end
  end
  return true
end

  ----------------------------------------------------------------------
  --          Scene Show Did         --
  ----------------------------------------------------------------------
elseif ( phase == "did" ) then
end
end

--------------------------------------------------------------------------------
-- "scene:hide()"
--------------------------------------------------------------------------------
function scene:hide( event )
local sceneGroup = self.view
local phase = event.phase
if ( phase == "will" ) then
elseif ( phase == "did" ) then
  display.remove( content )
  content = nil
end
end

--------------------------------------------------------------------------------
-- "scene:destroy()"
--------------------------------------------------------------------------------
function scene:destroy( event )
local sceneGroup = self.view
end

--------------------------------------------------------------------------------
-- Listener setup
--------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
--------------------------------------------------------------------------------

return scene