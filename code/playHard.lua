-- =============================================================
-- Copyright 2018, Andrew Baronick, All rights reserved.
-- =============================================================
-- playHard
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
    local admob = require( "plugin.admob" )
    local jsonFunct = require( "modJson" )
    local audioFunct = require( "modAudio" )

    ----------------------------------------------------------------------
    --                LOCALS                --
    ----------------------------------------------------------------------
    -- JSON Variables
    local gameValues = jsonFunct.readGameValues()
    local storeValues = jsonFunct.readStoreValues()
    local currentLevelValues = jsonFunct.readCurrentLevelValues()
    local hardWordsValues = jsonFunct.readHardWords()
    local hardLettersValues = jsonFunct.readHardLetters()
    local hardWordsHintsValues = jsonFunct.readHardWordsHints()
    local hardAnswerLetters = jsonFunct.readHardAnswerLetters()
    local hardLevelStats = jsonFunct.readHardStatsValues()
    local lifeRegenerationValues = jsonFunct.readLifeRegeneration()

    --Assigned JSON Variables
    local coins = gameValues[1]
    local lives = gameValues[2]
    local musicOn = gameValues[5]
    local soundOn = gameValues[6]
    local level = currentLevelValues[6]
    local levelWords = hardWordsValues[level]
    local levelLetters = hardLettersValues[level]
    local levelWordsHints = hardWordsHintsValues[level]
    local levelAnswerLetters = hardAnswerLetters[level]

    -- Display Variables
    local dW = display.contentWidth
    local dH = display.contentHeight
    local cX = display.contentCenterX
    local cY = display.contentCenterY
    local screenName = "none"
    local candyCount=1
    local candyXPos = {dW*.68, dW*.53, dW*.38, dW*.23, dW*.08}
    local candyYPos = {dH*.87, dH*.625, dH*.38, dH*.135}
    local levelWordsTable, candyTable, candyLetterTable, answerTable, greenCandyTable, wordTracker, oldWordTracker = {}, {}, {}, {}, {}, {}, {}
    for c=#levelWords, 1, -1 do
      wordTracker[c]=0
    end

    -- Forward Declarations
    local changeScreen

    -- Scene Variables
    local candyChoice = 1
    local candyNumTracker, candyXTracker, candyYTracker, letterTracker, gameTimerDelay, timerVar
    local windowName = "countDown"
    local moves, totalScore, storeParam, goToNextLevel, adProcessOnce = 0, 0, 0, 0, 0
    if storeValues[3] == 1 then
      timerVar = 300
    else
      timerVar = 150
    end

    ----------------------------------------------------------------------
    --             Minus Life and Life Regeneration Handler           --
    ----------------------------------------------------------------------
    --Minus 1 Life
    if storeValues[2] == 0 then
      lives = lives - 1
      gameValues[2] = lives
      jsonFunct.writeGameValues(gameValues)
    end

    --Life Regeneration Handler
    if storeValues[2] == 0 then
      if lifeRegenerationValues[1] == 0 then
        local currentTimeLifeRegen = os.date( '*t' )
        currentTimeLifeRegen = os.time(currentTimeLifeRegen)
        lifeRegenerationValues[1] = currentTimeLifeRegen + 180
      else
        if #lifeRegenerationValues < gameValues[3] then
          table.insert(lifeRegenerationValues, lifeRegenerationValues[#lifeRegenerationValues] + 180)
        end
      end
      jsonFunct.writeLifeRegenerationValues(lifeRegenerationValues)
    end

    ----------------------------------------------------------------------
    --             CREATE IMAGE GROUPS            --
    ----------------------------------------------------------------------
    --Parent Image Holder
    local images = {}
    content = display.newGroup()
    self.view:insert( content )

    --Create Image Groups
    bgGroup = display.newGroup()
    content:insert( bgGroup )
    hudGroup = display.newGroup()
    content:insert( hudGroup )
    candys = display.newGroup()
    content:insert( candys )
    candysGreenGroup = display.newGroup()
    content:insert( candysGreenGroup )
    otherGroup = display.newGroup()
    content:insert( otherGroup )
    candyWordsGroup = display.newGroup()
    content:insert( candyWordsGroup )
    candyLettersGroup = display.newGroup()
    content:insert( candyLettersGroup )
    candyLettersAnswerGroup = display.newGroup()
    content:insert( candyLettersAnswerGroup )
    countInGroup = display.newGroup()
    content:insert( countInGroup )
    pauseGroup = display.newGroup()
    content:insert( pauseGroup )
    gameWonGroup = display.newGroup()
    content:insert( gameWonGroup )
    outOfTimeGroup = display.newGroup()
    content:insert( outOfTimeGroup )
    hintGroup = display.newGroup()
    content:insert( hintGroup )
    notEnoughCoinsGroup = display.newGroup()
    content:insert( notEnoughCoinsGroup )
    notEnoughLivesGroup = display.newGroup()
    content:insert( notEnoughLivesGroup )
    parsedLevelGroup = display.newGroup()
    content:insert( parsedLevelGroup )
    plusOneCoinGroup = display.newGroup()
    content:insert( plusOneCoinGroup )

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
    --           Store Data Handler         --
    ----------------------------------------------------------------------
    local function storeDataHandler()
      if storeValues[2] == 1 or storeValues[3] == 1 or storeValues[4] == 1 then
        currentTimeShop = os.date( '*t' )
        currentTimeShop = os.time(currentTimeShop)
        if storeValues[2] == 1 or storeValues[4] == 1 then
          if currentTimeShop >= storeValues[5] then
            storeValues[2] = 0
            storeValues[4] = 0
            storeValues[5] = 0
            gameValues[3] = 7
        jsonFunct.writeStoreValues(storeValues)
        jsonFunct.writeGameValues(gameValues)
          end
        end
        if storeValues[3] == 1 then
          if currentTimeShop >= storeValues[6] then
            storeValues[3] = 0
            storeValues[6] = 0
        jsonFunct.writeStoreValues(storeValues)
          end
        end
      end
    end

    ----------------------------------------------------------------------
    --           Check For Lives         --
    ----------------------------------------------------------------------
    local function checkForLives()
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
          images.pauseActualLives.text = lives
          images.outOfTimeActualLives.text = lives
          jsonFunct.writeGameValues(gameValues)
          jsonFunct.writeLifeRegenerationValues(lifeRegenerationValues)
          end
        end

    ----------------------------------------------------------------------
    --                  Game Won Handler                --
    ----------------------------------------------------------------------
    local function gameWon()
      local starCounter = 0
      checkForLives()
      local function plusCoinFinish()
        images.plusOneCoin.y = images.plusOneCoin.y + dH
        windowName = "gameWonWindow"
      end
      local function plusCoinTransitionBack()
        transition.scaleTo(images.plusOneCoin, {time750, xScale=1, yScale=1, onComplete=plusCoinFinish } )
      end
      local function checkPlusCoin()
        if level%5 == 0 and hardLevelStats[level][1] == 0  then
          images.plusOneCoin.y = images.plusOneCoin.y - dH
          coins = coins + 1
          gameValues[1] = coins
          jsonFunct.writeGameValues(gameValues)
          audioFunct.freeGift()
          transition.scaleTo(images.plusOneCoin, {time=750, xScale=1.4, yScale=1.4, onComplete=plusCoinTransitionBack } )
        else
          windowName = "gameWonWindow"
        end
        if totalScore > hardLevelStats[level][1] then
          hardLevelStats[level][1] = totalScore
          hardLevelStats[level][2] = moves
          hardLevelStats[level][3] = timerVar
          hardLevelStats[level][4] = starCounter
          jsonFunct.writeHardStatsValues(hardLevelStats)
        end
      end
      local function starTransitions33()
        transition.scaleTo(images.gameWonStar3, {time=300, xScale=1, yScale=1 } )
        checkPlusCoin()
      end
      local function starTransitions3()
        if starCounter > 2 then
          images.gameWonStar3.fill.effect = ""
          audioFunct.star3()
          transition.scaleTo(images.gameWonStar3, {time=300, xScale=1.3, yScale=1.3, onComplete=starTransitions33 } )
        else
          checkPlusCoin()
        end
      end
      local function starTransitions22()
        transition.scaleTo(images.gameWonStar2, {time=300, xScale=1, yScale=1, onComplete=starTransitions3 } )
      end
      local function starTransitions2()
        if starCounter > 1 then
          images.gameWonStar2.fill.effect = ""
          audioFunct.star2()
          transition.scaleTo(images.gameWonStar2, {time=300, xScale=1.3, yScale=1.3, onComplete=starTransitions22 } )
        else
          checkPlusCoin()
        end
      end
      local function starTransitions11()
        transition.scaleTo(images.gameWonStar1, {time=300, xScale=1, yScale=1, onComplete=starTransitions2 } )
      end
      local function starTransitions1()
        images.gameWonStar1.fill.effect = ""
        audioFunct.star1()
        transition.scaleTo(images.gameWonStar1, {time=300, xScale=1.3, yScale=1.3, onComplete=starTransitions11 } )
      end
      timer.pause( gameTimerDelay )
      if moves < 30 then
        totalScore = 1700-(moves*57)
      end
      totalScore = totalScore + (timerVar * 15)
      if totalScore >= 750 and totalScore < 1500 then
        starCounter = 2
      elseif totalScore >= 1500 then
        starCounter = 3
      else
        starCounter=1
      end
      windowName = "gameWonStarHandler"
      images.gameWonActualMoves.text = moves
      images.gameWonActualTime.text = timerVar
      images.gameWonTotalScore.text = totalScore
      transition.to(gameWonGroup, {time=450, y=-dH, transition=easing.outBack} )
      transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack, onComplete=starTransitions1} )
      if level == currentLevelValues[3] and level < 300 then
        currentLevelValues[3] = currentLevelValues[3]+1
        table.insert(hardLevelStats,{0,0,0,0})
        jsonFunct.writeHardStatsValues(hardLevelStats)
        jsonFunct.writeCurrentLevelValues(currentLevelValues)
      end
    end

    ----------------------------------------------------------------------
    --                 Out Of Time Handler              --
    ----------------------------------------------------------------------
    local function outOfTime()
      windowName = "outOfTimeWindow"
      checkForLives()
      audioFunct.loseGame()
      transition.to(outOfTimeGroup, {time=450, y=-dH, transition=easing.outBack} )
      transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack} )
    end

    ----------------------------------------------------------------------
    --          Check For Correct Words Handler         --
    ----------------------------------------------------------------------
    --Word Tracker Handler
    local function checkWords()
      for c=#levelWords, 1, -1 do
        oldWordTracker[c]=wordTracker[c]
        wordTracker[c]=0
      end

      --Clear Green Boxes And Put Back Orange Boxes
      local greenCounter=1
      for h = #candyYPos, 1, -1 do
        for i = #candyXPos, 1, -1 do
          greenCandyTable[greenCounter].x = candyXPos[i] ; greenCandyTable[greenCounter].y = candyYPos[h]+dH
          greenCounter=greenCounter+1
        end
      end

      --Clear Words On Right
      for f = #levelWordsTable, 1, -1 do
        levelWordsTable[f]:setFillColor(1)
      end

      --Parse Combinations
      local fiveWord1 = levelLetters[1] .. levelLetters[2] .. levelLetters[3] .. levelLetters[4] .. levelLetters[5]
      local fiveWord2 = levelLetters[6] .. levelLetters[7] .. levelLetters[8] .. levelLetters[9] .. levelLetters[10]
      local fiveWord3 = levelLetters[11] .. levelLetters[12] .. levelLetters[13] .. levelLetters[14] .. levelLetters[15]
      local fiveWord4 = levelLetters[16] .. levelLetters[17] .. levelLetters[18] .. levelLetters[19] .. levelLetters[20]
      local fourWord1 = levelLetters[1] .. levelLetters[2] .. levelLetters[3] .. levelLetters[4]
      local fourWord2 = levelLetters[2] .. levelLetters[3] .. levelLetters[4] .. levelLetters[5]
      local fourWord3 = levelLetters[6] .. levelLetters[7] .. levelLetters[8] .. levelLetters[9]
      local fourWord4 = levelLetters[7] .. levelLetters[8] .. levelLetters[9] .. levelLetters[10]
      local fourWord5 = levelLetters[11] .. levelLetters[12] .. levelLetters[13] .. levelLetters[14]
      local fourWord6 = levelLetters[12] .. levelLetters[13] .. levelLetters[14] .. levelLetters[15]
      local fourWord7 = levelLetters[16] .. levelLetters[17] .. levelLetters[18] .. levelLetters[19]
      local fourWord8 = levelLetters[17] .. levelLetters[18] .. levelLetters[19] .. levelLetters[20]
      local fourWord9 = levelLetters[1] .. levelLetters[6] .. levelLetters[11] .. levelLetters[16]
      local fourWord10 = levelLetters[2] .. levelLetters[7] .. levelLetters[12] .. levelLetters[17]
      local fourWord11 = levelLetters[3] .. levelLetters[8] .. levelLetters[13] .. levelLetters[18]
      local fourWord12 = levelLetters[4] .. levelLetters[9] .. levelLetters[14] .. levelLetters[19]
      local fourWord13 = levelLetters[5] .. levelLetters[10] .. levelLetters[15] .. levelLetters[20]
      local threeWord1 = levelLetters[1] .. levelLetters[2] .. levelLetters[3]
      local threeWord2 = levelLetters[2] .. levelLetters[3] .. levelLetters[4]
      local threeWord3 = levelLetters[3] .. levelLetters[4] .. levelLetters[5]
      local threeWord4 = levelLetters[6] .. levelLetters[7] .. levelLetters[8]
      local threeWord5 = levelLetters[7] .. levelLetters[8] .. levelLetters[9]
      local threeWord6 = levelLetters[8] .. levelLetters[9] .. levelLetters[10]
      local threeWord7 = levelLetters[11] .. levelLetters[12] .. levelLetters[13]
      local threeWord8 = levelLetters[12] .. levelLetters[13] .. levelLetters[14]
      local threeWord9 = levelLetters[13] .. levelLetters[14] .. levelLetters[15]
      local threeWord10 = levelLetters[16] .. levelLetters[17] .. levelLetters[18]
      local threeWord11 = levelLetters[17] .. levelLetters[18] .. levelLetters[19]
      local threeWord12 = levelLetters[18] .. levelLetters[19] .. levelLetters[20]
      local threeWord13 = levelLetters[1] .. levelLetters[6] .. levelLetters[11]
      local threeWord14 = levelLetters[6] .. levelLetters[11] .. levelLetters[16]
      local threeWord15 = levelLetters[2] .. levelLetters[7] .. levelLetters[12]
      local threeWord16 = levelLetters[7] .. levelLetters[12] .. levelLetters[17]
      local threeWord17 = levelLetters[3] .. levelLetters[8] .. levelLetters[13]
      local threeWord18 = levelLetters[8] .. levelLetters[13] .. levelLetters[18]
      local threeWord19 = levelLetters[4] .. levelLetters[9] .. levelLetters[14]
      local threeWord20 = levelLetters[9] .. levelLetters[14] .. levelLetters[19]
      local threeWord21 = levelLetters[5] .. levelLetters[10] .. levelLetters[15]
      local threeWord22 = levelLetters[10] .. levelLetters[15] .. levelLetters[20]
      local twoWord1 = levelLetters[1] .. levelLetters[2]
      local twoWord2 = levelLetters[2] .. levelLetters[3]
      local twoWord3 = levelLetters[3] .. levelLetters[4]
      local twoWord4 = levelLetters[4] .. levelLetters[5]
      local twoWord5 = levelLetters[6] .. levelLetters[7]
      local twoWord6 = levelLetters[7] .. levelLetters[8]
      local twoWord7 = levelLetters[8] .. levelLetters[9]
      local twoWord8 = levelLetters[9] .. levelLetters[10]
      local twoWord9 = levelLetters[11] .. levelLetters[12]
      local twoWord10 = levelLetters[12] .. levelLetters[13]
      local twoWord11 = levelLetters[13] .. levelLetters[14]
      local twoWord12 = levelLetters[14] .. levelLetters[15]
      local twoWord13 = levelLetters[16] .. levelLetters[17]
      local twoWord14 = levelLetters[17] .. levelLetters[18]
      local twoWord15 = levelLetters[18] .. levelLetters[19]
      local twoWord16 = levelLetters[19] .. levelLetters[20]
      local twoWord17 = levelLetters[1] .. levelLetters[6]
      local twoWord18 = levelLetters[6] .. levelLetters[11]
      local twoWord19 = levelLetters[11] .. levelLetters[16]
      local twoWord20 = levelLetters[2] .. levelLetters[7]
      local twoWord21 = levelLetters[7] .. levelLetters[12]
      local twoWord22 = levelLetters[12] .. levelLetters[17]
      local twoWord23 = levelLetters[3] .. levelLetters[8]
      local twoWord24 = levelLetters[8] .. levelLetters[13]
      local twoWord25 = levelLetters[13] .. levelLetters[18]
      local twoWord26 = levelLetters[4] .. levelLetters[9]
      local twoWord27 = levelLetters[9] .. levelLetters[14]
      local twoWord28 = levelLetters[14] .. levelLetters[19]
      local twoWord29 = levelLetters[5] .. levelLetters[10]
      local twoWord30 = levelLetters[10] .. levelLetters[15]
      local twoWord31 = levelLetters[15] .. levelLetters[20]

      local function checkFives(word, parsedWord, wordNum, startNum, yPos)
        if word == parsedWord then
          for v=0, 4, 1 do
            greenCandyTable[startNum+v].y = candyYPos[yPos]-dH
          end
          levelWordsTable[wordNum]:setFillColor(.1,.95,.1)
          wordTracker[wordNum]=1
        end
      end

      local function checkFours(word, parsedWord, wordNum, acrOrDown, startNum, yPos)
        if word == parsedWord then
          if acrOrDown==0 then
          for v=0, 3, 1 do
            greenCandyTable[startNum+v].y = candyYPos[yPos]-dH
          end
        else
            greenCandyTable[startNum].y = candyYPos[4]-dH
            greenCandyTable[startNum+5].y = candyYPos[3]-dH
            greenCandyTable[startNum+10].y = candyYPos[2]-dH
            greenCandyTable[startNum+15].y = candyYPos[1]-dH
        end
          levelWordsTable[wordNum]:setFillColor(.1,.95,.1)
          wordTracker[wordNum]=1
        end
      end

      local function checkThrees(word, parsedWord, wordNum, acrOrDown, startNum, yPos)
        if word == parsedWord then
          if acrOrDown==0 then
            for v=0, 2, 1 do
              greenCandyTable[startNum+v].y = candyYPos[yPos]-dH
            end
          else
            greenCandyTable[startNum].y = candyYPos[yPos]-dH
            greenCandyTable[startNum+5].y = candyYPos[yPos-1]-dH
            greenCandyTable[startNum+10].y = candyYPos[yPos-2]-dH
          end
          levelWordsTable[wordNum]:setFillColor(.1,.95,.1)
          wordTracker[wordNum]=1
        end
      end

      local function checkTwos(word, parsedWord, wordNum, acrOrDown, startNum, yPos)
        if word == parsedWord then
          if acrOrDown==0 then
            for v=0, 1, 1 do
              greenCandyTable[startNum+v].y = candyYPos[yPos]-dH
            end
          else
            greenCandyTable[startNum].y = candyYPos[yPos]-dH
            greenCandyTable[startNum+5].y = candyYPos[yPos-1]-dH
          end
          levelWordsTable[wordNum]:setFillColor(.1,.95,.1)
          wordTracker[wordNum]=1
        end
      end

      --Compare Parses with words
      for c=#levelWords,1,-1 do
        if #levelWords[c] == 5 then
          checkFives(levelWords[c], fiveWord1, c, 1, 4)
          checkFives(levelWords[c], fiveWord2, c, 6, 3)
          checkFives(levelWords[c], fiveWord3, c, 11, 2)
          checkFives(levelWords[c], fiveWord4, c, 16, 1)
        end
        if #levelWords[c] == 4 then
          checkFours(levelWords[c], fourWord1, c, 0, 1, 4)
          checkFours(levelWords[c], fourWord2, c, 0, 2, 4)
          checkFours(levelWords[c], fourWord3, c, 0, 6, 3)
          checkFours(levelWords[c], fourWord4, c, 0, 7, 3)
          checkFours(levelWords[c], fourWord5, c, 0, 11, 2)
          checkFours(levelWords[c], fourWord6, c, 0, 12, 2)
          checkFours(levelWords[c], fourWord7, c, 0, 16, 1)
          checkFours(levelWords[c], fourWord8, c, 0, 17, 1)
          checkFours(levelWords[c], fourWord9, c, 1, 1)
          checkFours(levelWords[c], fourWord10, c, 1, 2)
          checkFours(levelWords[c], fourWord11, c, 1, 3)
          checkFours(levelWords[c], fourWord12, c, 1, 4)
          checkFours(levelWords[c], fourWord13, c, 1, 5)
        end
        if #levelWords[c] == 3 then
          checkThrees(levelWords[c], threeWord1, c, 0, 1, 4)
          checkThrees(levelWords[c], threeWord2, c, 0, 2, 4)
          checkThrees(levelWords[c], threeWord3, c, 0, 3, 4)
          checkThrees(levelWords[c], threeWord4, c, 0, 6, 3)
          checkThrees(levelWords[c], threeWord5, c, 0, 7, 3)
          checkThrees(levelWords[c], threeWord6, c, 0, 8, 3)
          checkThrees(levelWords[c], threeWord7, c, 0, 11, 2)
          checkThrees(levelWords[c], threeWord8, c, 0, 12, 2)
          checkThrees(levelWords[c], threeWord9, c, 0, 13, 2)
          checkThrees(levelWords[c], threeWord10, c, 0, 16, 1)
          checkThrees(levelWords[c], threeWord11, c, 0, 17, 1)
          checkThrees(levelWords[c], threeWord12, c, 0, 18, 1)
          checkThrees(levelWords[c], threeWord13, c, 1, 1, 4)
          checkThrees(levelWords[c], threeWord14, c, 1, 6, 3)
          checkThrees(levelWords[c], threeWord15, c, 1, 2, 4)
          checkThrees(levelWords[c], threeWord16, c, 1, 7, 3)
          checkThrees(levelWords[c], threeWord17, c, 1, 3, 4)
          checkThrees(levelWords[c], threeWord18, c, 1, 8, 3)
          checkThrees(levelWords[c], threeWord19, c, 1, 4, 4)
          checkThrees(levelWords[c], threeWord20, c, 1, 9, 3)
          checkThrees(levelWords[c], threeWord21, c, 1, 5, 4)
          checkThrees(levelWords[c], threeWord22, c, 1, 10, 3)
        end
        if #levelWords[c] == 2 then
          checkTwos(levelWords[c], twoWord1, c, 0, 1, 4)
          checkTwos(levelWords[c], twoWord2, c, 0, 2, 4)
          checkTwos(levelWords[c], twoWord3, c, 0, 3, 4)
          checkTwos(levelWords[c], twoWord4, c, 0, 4, 4)
          checkTwos(levelWords[c], twoWord5, c, 0, 6, 3)
          checkTwos(levelWords[c], twoWord6, c, 0, 7, 3)
          checkTwos(levelWords[c], twoWord7, c, 0, 8, 3)
          checkTwos(levelWords[c], twoWord8, c, 0, 9, 3)
          checkTwos(levelWords[c], twoWord9, c, 0, 11, 2)
          checkTwos(levelWords[c], twoWord10, c, 0, 12, 2)
          checkTwos(levelWords[c], twoWord11, c, 0, 13, 2)
          checkTwos(levelWords[c], twoWord12, c, 0, 14, 2)
          checkTwos(levelWords[c], twoWord13, c, 0, 16, 1)
          checkTwos(levelWords[c], twoWord14, c, 0, 17, 1)
          checkTwos(levelWords[c], twoWord15, c, 0, 18, 1)
          checkTwos(levelWords[c], twoWord16, c, 0, 19, 1)
          checkTwos(levelWords[c], twoWord17, c, 1, 1, 4)
          checkTwos(levelWords[c], twoWord18, c, 1, 6, 3)
          checkTwos(levelWords[c], twoWord19, c, 1, 11, 2)
          checkTwos(levelWords[c], twoWord20, c, 1, 2, 4)
          checkTwos(levelWords[c], twoWord21, c, 1, 7, 3)
          checkTwos(levelWords[c], twoWord22, c, 1, 12, 2)
          checkTwos(levelWords[c], twoWord23, c, 1, 3, 4)
          checkTwos(levelWords[c], twoWord24, c, 1, 8, 3)
          checkTwos(levelWords[c], twoWord25, c, 1, 13, 2)
          checkTwos(levelWords[c], twoWord26, c, 1, 4, 4)
          checkTwos(levelWords[c], twoWord27, c, 1, 9, 3)
          checkTwos(levelWords[c], twoWord28, c, 1, 14, 2)
          checkTwos(levelWords[c], twoWord29, c, 1, 5, 4)
          checkTwos(levelWords[c], twoWord30, c, 1, 10, 3)
          checkTwos(levelWords[c], twoWord31, c, 1, 15, 2)
        end
      end

      --Check for Sound And Animations
      for c=#levelWords, 1, -1 do
        if wordTracker[c]==1 and oldWordTracker[c]==0 then
          audioFunct.wordWin()
          for t=#greenCandyTable, 1, -1 do
            local function scaleBack()
              transition.to(candyLetterTable[t], { time=200, xScale=1, yScale=1 } )
              transition.to(greenCandyTable[t], { time=200, xScale=1, yScale=1 } )
            end
            if greenCandyTable[t].y<dH then
              transition.to(candyLetterTable[t], { time=200, xScale=1.1, yScale=1.1 } )
              transition.to(greenCandyTable[t], { time=200, xScale=1.1, yScale=1.1, onComplete=scaleBack } )
            end
          end
          for t=#levelWords, 1, -1 do
            local function scaleBackWords()
              transition.to(levelWordsTable[t], { time=200, xScale=1, yScale=1 } )
            end
            if wordTracker[t]==1 then
              transition.to(levelWordsTable[t], { time=200, xScale=1.4, yScale=1.4, onComplete=scaleBackWords } )
            end
          end
        end
      end

      --Check If Game Won
      local gameWonTracker = 0
      for d=#levelWords, 1, -1 do
        if wordTracker[d] > 0 then
          gameWonTracker = gameWonTracker + 1
        end
      end
      if gameWonTracker == #levelWords then
        audioFunct.gameWonner()
        gameWon()
      end
      if windowName ~= "gameWonWindow" and windowName ~= "gameWonStarHandler" then
        windowName = "none"
      end
    end

    ----------------------------------------------------------------------
    --              Letter Transition Handler             --
    ----------------------------------------------------------------------
    local function candyTapHandler(event)
      local function candyTapHandler2(evenNum, evenX, evenY)
        candyChoice = candyChoice + 1
        if candyChoice%2 == 0 then
          candyNumTracker = evenNum
          candyXTracker = evenX
          candyYTracker = evenY
          images.pinkSpinner.x = candyXTracker ; images.pinkSpinner.y = candyYTracker-dH
          candyTable[candyNumTracker].y = candyTable[candyNumTracker].y+dH
          if greenCandyTable[candyNumTracker].y<dH then
            greenCandyTable[candyNumTracker].y = greenCandyTable[candyNumTracker].y+dH
          end
          candyLetterTableTracker = candyLetterTable[candyNumTracker]
          candyTableTracker = candyTable[evenNum]
          letterTracker = levelLetters[evenNum]
        else
          windowName="switching"
          images.pinkSpinner.y=images.pinkSpinner.y+dH
          moves = moves + 1
          candyTable[candyNumTracker].y = candyTable[candyNumTracker].y - dH
          transition.to(candyTable[evenNum], { time=400, x=candyXTracker, y=candyYTracker } )
          transition.to(candyTable[candyNumTracker], { time=400, x=evenX, y=evenY } )
          transition.to(candyLetterTable[evenNum], { time=400, x=candyXTracker, y=candyYTracker } )
          transition.to(candyLetterTable[candyNumTracker], { time=400, x=evenX, y=evenY, onComplete=checkWords } )
          levelLetters[candyNumTracker] = levelLetters[evenNum]
          levelLetters[evenNum] = letterTracker
          candyTable[candyNumTracker].num = evenNum
          candyTable[evenNum].num = candyNumTracker
          candyTable[candyNumTracker] = candyTable[evenNum]
          candyTable[evenNum] = candyTableTracker
          candyLetterTable[candyNumTracker] = candyLetterTable[evenNum]
          candyLetterTable[evenNum] = candyLetterTableTracker
          if greenCandyTable[evenNum].y<dH then
            greenCandyTable[evenNum].y = greenCandyTable[evenNum].y+dH
          end
        end
      end
      local phase = event.phase
      local target=event.target
      if ( phase == "began" and windowName=="none") then
        audioFunct.click()
        candyTapHandler2(target.num, target.x, target.y)
      elseif ( "moved" == phase ) then
      elseif ( "ended" == phase or "cancelled" == phase ) then
        if windowName=="none" then
          for o=#candyTable,1,-1 do
            if event.x > (candyTable[o].x-(dW*.0704)) and event.x < (candyTable[o].x+(dW*.0704)) and event.y > ((candyTable[o].y-(dW*.0704)-dH)) and event.y < ((candyTable[o].y+(dW*.0704)-dH)) then
              if candyTable[o].num ~= candyNumTracker then
                audioFunct.click()
                candyTapHandler2(candyTable[o].num,candyTable[o].x, candyTable[o].y )
              end
            end
          end
        end
        return true
      end
    end

    ----------------------------------------------------------------------
    --               Hint Handler             --
    ----------------------------------------------------------------------
    local function hintHandler()
      timer.pause( gameTimerDelay )
      local function resumeTimer()
        timer.resume( gameTimerDelay )
        windowName = "none"
      end
      for u=#wordTracker,1,-1 do
        local function changeColorWord()
          levelWordsTable[u]:setFillColor(1)
        end
        local function hintScaleBackWord()
          transition.to(levelWordsTable[u], { time=1800, xScale=1, yScale=1, onComplete=changeColorWord } )
        end
        if wordTracker[u] == 0 then
          levelWordsTable[u]:setFillColor(.1,.1,.95)
          transition.to(levelWordsTable[u], { time=800, xScale=1.4, yScale=1.4, onComplete=hintScaleBackWord } )
          for w=#levelWords[u], 1, -1 do
            local function lowerHint()
              candyLetterTable[levelWordsHints[u][w]].y = candyLetterTable[levelWordsHints[u][w]].y - dH
              transition.to(answerTable[levelWordsHints[u][w]], {time=450, y=answerTable[levelWordsHints[u][w]].y+dH, transition=easing.inBack, onComplete=resumeTimer} )
              if greenCandyTable[levelWordsHints[u][w]].tracker == 0 then
                transition.to(greenCandyTable[levelWordsHints[u][w]], {time=450, y=greenCandyTable[levelWordsHints[u][w]].y+dH, transition=easing.inBack} )
              end
            end
            local function hintScaleBack()
              transition.to(answerTable[levelWordsHints[u][w]], { time=1600, xScale=1, yScale=1 } )
              transition.to(greenCandyTable[levelWordsHints[u][w]], { time=1600, xScale=1, yScale=1, onComplete=lowerHint } )
            end
            candyLetterTable[levelWordsHints[u][w]].y = candyLetterTable[levelWordsHints[u][w]].y + dH
            transition.to(answerTable[levelWordsHints[u][w]], { time=600, y=answerTable[levelWordsHints[u][w]].y-dH } )
            greenCandyTable[levelWordsHints[u][w]].tracker = 0
            if greenCandyTable[levelWordsHints[u][w]].y > dH then
              transition.to(greenCandyTable[levelWordsHints[u][w]], { time=600, y=greenCandyTable[levelWordsHints[u][w]].y-dH-dH } )
            elseif greenCandyTable[levelWordsHints[u][w]].y < 0 and greenCandyTable[levelWordsHints[u][w]].y > (dH*-1) then
              greenCandyTable[levelWordsHints[u][w]].tracker = 1
            else
              transition.to(greenCandyTable[levelWordsHints[u][w]], { time=600, y=greenCandyTable[levelWordsHints[u][w]].y-dH } )
            end
            transition.to(answerTable[levelWordsHints[u][w]], { time=800, xScale=1.12, yScale=1.12 } )
            transition.to(greenCandyTable[levelWordsHints[u][w]], { time=800, xScale=1.12, yScale=1.12, onComplete=hintScaleBack } )
          end
          return
        end
      end
    end

    ----------------------------------------------------------------------
    --               Parse Level           --
    ----------------------------------------------------------------------
    local function parseLevel()
      local stringParse = tostring( level )
      local parse1ImageName = "images/" .. string.sub(stringParse, 1, 1) .. ".png"
      images.parsedLevel1 =  createImage(parsedLevelGroup, parse1ImageName, 38, 38, dW*.577, 123+dH)
      if level > 9 then
        local parse2ImageName = "images/" .. string.sub(stringParse, 2, 2) .. ".png"
        images.parsedLevel2 =  createImage(parsedLevelGroup, parse2ImageName, 38, 38, dW*.63, 123+dH )
      end
      if level > 99 then
        local parse3ImageName = "images/" .. string.sub(stringParse, 3, 3) .. ".png"
        images.parsedLevel3 =  createImage(parsedLevelGroup, parse3ImageName, 38, 38, dW*.688, 123+dH )
      end
    end

    ----------------------------------------------------------------------
    --               Image Creation            --
    ----------------------------------------------------------------------
    --Create Background Group
    images.background = createImage(bgGroup, "images/background3.png", dW*2, dH, cX, cY)
    images.backBox = display.newRoundedRect(bgGroup, dW*.38, cY, dW*.75, dH*.98, 40)
    images.backBox.fill = {.4, .4}
    images.backBoxWords = display.newRoundedRect(bgGroup, dW*.88, cY,dW*.22, dH*.98, 15)
    images.backBoxWords.fill = {.4, .4}
    images.pauseButton = createImage(bgGroup, "images/pauseButton.png", 45, 45, dW*.935, dH*.1 )
    images.hintButton = createImage(bgGroup, "images/hintButton.png", 45, 45, dW*.83, dH*.1)
    images.actualGameTimer = createWords(bgGroup, timerVar, dW*.88, dH*.23, 30 )

    --Create Count In Group
    images.countIn1 = createImage(countInGroup, "images/1.png", dW*.7, dW*.7, cX, cY+dH+dH)
    images.countIn2 = createImage(countInGroup, "images/2.png", dW*.7, dW*.7, cX, cY+dH+dH)
    images.countIn3 = createImage(countInGroup, "images/3.png", dW*.7, dW*.7, cX, cY)

    --Create Pause Window
    images.backPauseWindow = display.newRect(pauseGroup, cX, cY+dH, dW*2, dH)
    images.backPauseWindow.fill = {.13, .92}
    images.pauseWindow = createImage(pauseGroup, "images/pauseWindow2.png", 430, 290, cX, cY+dH)
    images.pauseExitButton = createImage(pauseGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.pauseHomeButton = createImage(pauseGroup, "images/homeButton.png", 90, 45, dW*.281, dH*.906+dH)
    images.pauseRestartButton = createImage(pauseGroup, "images/restartButton.png", 90, 45, cX, dH*.906+dH)
    images.pauseResumeButton = createImage(pauseGroup, "images/resumeButton.png", 90, 45, dW*.721, dH*.906+dH)
    images.pauseActualCoins = createWords(pauseGroup, coins, dW*.397, dH*.75+dH, 18 )
    images.pauseActualMoves = createWords(pauseGroup, moves, dW*.633, dH*.75+dH, 18 )
    images.pauseActualTime = createWords(pauseGroup, timerVar, dW*.633, dH*.553+dH, 18 )
    images.musicButton = createImage(pauseGroup, "images/musicButton.png", 38, 38, dW*.25, dH*.578+dH )
    images.soundButton = createImage(pauseGroup, "images/soundButton.png", 38, 38, dW*.25, dH*.743+dH )
    parseLevel()
    if storeValues[2] == 1 then
      images.pauseActualLives = createWords(pauseGroup, lives, dW*.397, dH*.553+dH+dH, 18 )
      images.pauseInfiniteLivesPic = createImage(pauseGroup, "images/infiniteSign.png", 21, 18, dW*.399, dH*.553+dH)
    else
      images.pauseActualLives = createWords(pauseGroup, lives, dW*.397, dH*.553+dH, 18 )
      images.pauseInfiniteLivesPic = createImage(pauseGroup, "images/infiniteSign.png", 21, 18, dW*.399, dH*.553+dH+dH)
    end

    --Create Game Won Window
    images.backGameWonWindow = display.newRect(gameWonGroup, cX, cY+dH, dW*2, dH)
    images.backGameWonWindow.fill = {.13, .92}
    images.gameWonWindow = createImage(gameWonGroup, "images/gameWonWindow.png", 430, 290, cX, cY+dH)
    images.gameWonExitButton = createImage(gameWonGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.gameWonHomeButton = createImage(gameWonGroup, "images/homeButton.png", 90, 45, dW*.281, dH*.906+dH)
    images.gameWonStoreButton = createImage(gameWonGroup, "images/storeButton.png", 90, 45, cX, dH*.906+dH)
    images.gameWonNextButton = createImage(gameWonGroup, "images/nextButton.png", 90, 45, dW*.721, dH*.906+dH)
    images.gameWonActualTime = createWords(gameWonGroup, timerVar, dW*.26, dH*.712+dH, 18 )
    images.gameWonTotalScore = createWords(gameWonGroup, totalScore, dW*.478, dH*.703+dH, 20 )
    images.gameWonActualMoves = createWords(gameWonGroup, moves, dW*.691, dH*.712+dH, 18 )
    images.gameWonStar1 = createImage(gameWonGroup, "images/star.png", dH*.15, dH*.15, dW*.387, dH*.537+dH)
    images.gameWonStar2 = createImage(gameWonGroup, "images/star.png", dH*.15, dH*.15, dW*.492, dH*.537+dH)
    images.gameWonStar3 = createImage(gameWonGroup, "images/star.png", dH*.15, dH*.15, dW*.598, dH*.537+dH)
    images.gameWonStar1.fill.effect = "filter.grayscale"
    images.gameWonStar2.fill.effect = "filter.grayscale"
    images.gameWonStar3.fill.effect = "filter.grayscale"

    --Create Out Of Time Window
    images.backOutOfTimeWindow = display.newRect(outOfTimeGroup, cX, cY+dH, dW*2, dH)
    images.backOutOfTimeWindow.fill = {.13, .92}
    images.outOfTimeWindow = createImage(outOfTimeGroup, "images/outOfTimeWindow.png", 430, 290, cX, cY+dH)
    images.outOfTimeExitButton = createImage(outOfTimeGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.outOfTimeHomeButton = createImage(outOfTimeGroup, "images/homeButton.png", 90, 45, dW*.281, dH*.906+dH)
    images.outOfTimeStoreButton = createImage(outOfTimeGroup, "images/storeButton.png", 90, 45, cX, dH*.906+dH)
    images.outOfTimeRestartButton = createImage(outOfTimeGroup, "images/restartButton.png", 90, 45, dW*.721, dH*.906+dH)
    images.outOfTimeActualCoins = createWords(outOfTimeGroup, coins, dW*.633, dH*.743+dH, 18 )
    if storeValues[2] == 1 then
      images.outOfTimeActualLives = createWords(outOfTimeGroup, lives, dW*.32, dH*.743+dH+dH, 18 )
      images.outOfTimeInfiniteLivesPic = createImage(outOfTimeGroup, "images/infiniteSign.png", 27, 24, dW*.323, dH*.738+dH)
    else
      images.outOfTimeActualLives = createWords(outOfTimeGroup, lives, dW*.32, dH*.743+dH, 18 )
      images.outOfTimeInfiniteLivesPic = createImage(outOfTimeGroup, "images/infiniteSign.png", 27, 24, dW*.323, dH*.738+dH+dH)
    end

    --Create Hint Window
    images.backHintWindow = display.newRect(hintGroup, cX, cY+dH, dW*2, dH)
    images.backHintWindow.fill = {.13, .92}
    images.hintWindow = createImage(hintGroup, "images/hintWindow.png", 430, 290, cX, cY+dH)
    images.hintExitButton = createImage(hintGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.hintYesButton = createImage(hintGroup, "images/yesButton.png", 90, 45, cX-(dW*.132), dH*.906+dH)
    images.hintNoButton = createImage(hintGroup, "images/noButton.png", 90, 45, cX+(dW*.132), dH*.906+dH)
    images.hintActualCoins = createWords(hintGroup, coins, dW*.459, dH*.759+dH, 18 )

    --Create Not Enough Coins Window
    images.backNotEnoughCoinsWindow = display.newRect(notEnoughCoinsGroup, cX, cY+dH, dW*2, dH)
    images.backNotEnoughCoinsWindow.fill = {.13, .92}
    images.notEnoughCoinsWindow = createImage(notEnoughCoinsGroup, "images/notEnoughCoinsWindow.png", 430, 290, cX, cY+dH)
    images.notEnoughCoinsExitButton = createImage(notEnoughCoinsGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.notEnoughCoinsStoreButton = createImage(notEnoughCoinsGroup, "images/storeButton.png", 90, 45, cX-(dW*.132), dH*.906+dH)
    images.notEnoughCoinsResumeButton = createImage(notEnoughCoinsGroup, "images/resumeButton.png", 90, 45, cX+(dW*.132), dH*.906+dH)
    images.notEnoughCoinsActualCoins = createWords(notEnoughCoinsGroup, coins, dW*.459, dH*.759+dH, 18 )

    --Create Not Enough Lives Window
    images.backNotEnoughLivesWindow = display.newRect(notEnoughLivesGroup, cX, cY+dH, dW*2, dH)
    images.backNotEnoughLivesWindow.fill = {.13, .92}
    images.notEnoughLivesWindow = createImage(notEnoughLivesGroup, "images/notEnoughLivesWindow.png", 430, 290, cX, cY+dH)
    images.notEnoughLivesExitButton = createImage(notEnoughLivesGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.notEnoughLivesHomeButton = createImage(notEnoughLivesGroup, "images/homeButton.png", 90, 45, cX-(dW*.132), dH*.906+dH)
    images.notEnoughLivesStoreButton = createImage(notEnoughLivesGroup, "images/storeButton.png", 90, 45, cX+(dW*.132), dH*.906+dH)
    images.notEnoughLivesOneCoinButton = createImage(notEnoughLivesGroup, "images/life1Coin.png", 97, 141, dW*.252, dH*.595+dH)
    images.notEnoughLivesWatchAdButton = createImage(notEnoughLivesGroup, "images/lifeWatchAd.png", 97, 141, dW*.75, dH*.595+dH)

    if level%5 == 0 and hardLevelStats[level][1] == 0  then
      images.plusOneCoin = createImage(plusOneCoinGroup, "images/plusOneCoin.png", 148, 65, cX, dH*.303+dH )
    end

    --Create Words
    for e = 1, #levelWords, 1 do
      local actualLevelWords = createWords(candyWordsGroup, levelWords[e], dW*.876, (dH*.99)-(e*(dH*.75)/(#levelWords+1))+dH, 20 )
      table.insert(levelWordsTable,actualLevelWords)
    end

    --Create Orange, Green and Pink Candys
    for h = #candyYPos, 1, -1 do
      for i = #candyXPos, 1, -1 do
        local orangeCandy = display.newImageRect(candys, "images/orangeCandy.png", dW*.125, dW*.125 )
        local answerLetter = display.newText(candyLettersAnswerGroup, levelAnswerLetters[candyCount], candyXPos[i], candyYPos[h]+dH, "RifficFree-Bold.ttf", 35 )
        local greenCandy = display.newImageRect(candysGreenGroup, "images/greenCandy.png", dW*.125, dW*.125 )
        local candyLetter = display.newText(candyLettersGroup, levelLetters[candyCount], candyXPos[i], candyYPos[h]+dH, "RifficFree-Bold.ttf", 35 )
        answerLetter:setFillColor(.1,.1,.5)
        candyLetter:setFillColor(0)
        orangeCandy.x = candyXPos[i] ; orangeCandy.y = candyYPos[h]+dH
        greenCandy.x = candyXPos[i] ; greenCandy.y = candyYPos[h]
        orangeCandy.num = candyCount
        candyLetter.num = candyCount
        greenCandy.tracker = 0
        orangeCandy:addEventListener( "touch", candyTapHandler )
        table.insert(candyTable,orangeCandy)
        table.insert(answerTable,answerLetter)
        table.insert(greenCandyTable,greenCandy)
        table.insert(candyLetterTable,candyLetter)
        transition.to(greenCandy, { time=3000, rotation=360, iterations=1} )
        candyCount = candyCount + 1
      end
    end

    images.pinkSpinner = createImage(otherGroup, "images/pinkCandy.png", dW*.125, dW*.125, cX, cY+dH )
    transition.to(images.pinkSpinner, { time=2000, rotation=360, iterations=0 } )

    ----------------------------------------------------------------------
    --           Transition Handlers         --
    ----------------------------------------------------------------------
    --Handle Initial Store Data
    storeDataHandler()

    --Go To Next Level Handler
    local function goToNextLevelHandler()
      if goToNextLevel == 1 and level < 300 then
        level = level + 1
        currentLevelValues[6]=level
        jsonFunct.writeCurrentLevelValues(currentLevelValues)
      end
    end

    --Transitions for Exit Scene Transitions and Handlers
    local function transitionExitWindows(event)
      local phase = event.phase
      local target = event.target
      checkForLives()
      storeDataHandler()
      local function changeScreenFunct()
        changeScreen()
      end
      local function notEnoughLivesTransition()
        if coins < 1 then
          images.notEnoughLivesOneCoinButton.fill.effect = "filter.grayscale"
        end
        if not ( admob.isLoaded( "rewardedVideo" ) ) then
          images.notEnoughLivesWatchAdButton.fill.effect = "filter.grayscale"
        end
        transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack} )
        transition.to(notEnoughLivesGroup, {time=450, y=-dH, transition=easing.outBack} )
      end
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

      if ( phase=="began" ) then
        audioFunct.click()
      elseif ( phase == "ended" ) then
        if windowName ~= "gameWonStarHandler" and target ~= images.notEnoughLivesWatchAdButton then
          transition.to(parsedLevelGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        end
        if windowName=="hint" then
          timer.resume( gameTimerDelay )
          windowName = "none"
          transition.to(hintGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          if target == images.hintYesButton then
            coins=coins-2
            windowName = "handlingHint"
            gameValues[1] = coins
            jsonFunct.writeGameValues(gameValues)
            hintHandler()
          end
        elseif target == images.pauseExitButton or target == images.pauseResumeButton then
          timer.resume( gameTimerDelay )
          windowName = "none"
          transition.to(pauseGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        elseif target == images.pauseRestartButton then
          if lives > 0 then
            screenName = "code.playHard"
            handleInterstellar()
            transition.to(pauseGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          else
            transition.to(pauseGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=notEnoughLivesTransition} )
          end
        elseif target == images.pauseHomeButton then
          screenName = "code.mainMenu"
          transition.to(pauseGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.outOfTimeRestartButton then
          if lives > 0 then
            screenName = "code.playHard"
            handleInterstellar()
            transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          else
            transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=notEnoughLivesTransition} )
          end
        elseif target == images.outOfTimeStoreButton then
          screenName = "code.mainMenu"
          storeParam = 1
          transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.outOfTimeHomeButton then
          screenName = "code.mainMenu"
          transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.outOfTimeExitButton then
          if lives > 0 then
            screenName = "code.playHard"
            handleInterstellar()
            transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          else
            transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=notEnoughLivesTransition} )
          end
        elseif target == images.gameWonNextButton and windowName == "gameWonWindow" then
          if lives > 0 then
            screenName = "code.playHard"
            handleInterstellar()
            if currentLevelValues[6] < 300 then
              currentLevelValues[6] = currentLevelValues[6] + 1
              jsonFunct.writeCurrentLevelValues(currentLevelValues)
            end
            transition.to(gameWonGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          else
            goToNextLevel = 1
            transition.to(gameWonGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=notEnoughLivesTransition} )
          end
        elseif target == images.gameWonStoreButton and windowName == "gameWonWindow" then
          screenName = "code.mainMenu"
          storeParam = 1
          transition.to(gameWonGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.gameWonHomeButton and windowName == "gameWonWindow" then
          screenName = "code.mainMenu"
          transition.to(gameWonGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.gameWonExitButton and windowName == "gameWonWindow" then
          if lives > 0 then
            screenName = "code.playHard"
            handleInterstellar()
            if currentLevelValues[6] < 300 then
              currentLevelValues[6] = currentLevelValues[6] + 1
              jsonFunct.writeCurrentLevelValues(currentLevelValues)
            end
            transition.to(gameWonGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          else
            goToNextLevel = 1
            transition.to(gameWonGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=notEnoughLivesTransition} )
          end
        elseif target == images.notEnoughCoinsStoreButton then
          screenName = "code.mainMenu"
          storeParam = 1
          transition.to(notEnoughCoinsGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.notEnoughCoinsResumeButton or target == images.notEnoughCoinsExitButton then
          timer.resume( gameTimerDelay )
          windowName = "none"
          transition.to(notEnoughCoinsGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        elseif target == images.notEnoughLivesOneCoinButton then
          if coins > 0 then
            coins = coins - 1
            lives = lives + 1
            gameValues[1] = coins
            gameValues[2] = lives
            goToNextLevelHandler()
            jsonFunct.writeGameValues(gameValues)
            screenName = "code.playHard"
            handleInterstellar()
            transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          end
        elseif target == images.notEnoughLivesStoreButton then
          screenName = "code.mainMenu"
          storeParam = 1
          transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.notEnoughLivesHomeButton then
          screenName = "code.mainMenu"
          transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
        elseif target == images.notEnoughLivesExitButton then
          if windowName == "pause" then
            timer.resume( gameTimerDelay )
            windowName = "none"
            transition.to(notEnoughLivesGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          else
            screenName = "code.mainMenu"
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

    --Handle Transitions to Screen and Handle
    local function transitionToScreen(event)
      local target = event.target
      local phase = event.phase
      if ( phase=="began" and windowName=="none") then
        audioFunct.click()
      elseif ( phase == "ended" and windowName=="none") then
        transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack} )
        if target == images.pauseButton or windowName == "backButton" then
          windowName="pause"
          timer.pause( gameTimerDelay )
          images.pauseActualCoins.text = coins
          images.pauseActualMoves.text = moves
          images.pauseActualTime.text = timerVar
          transition.to(pauseGroup, {time=450, y=-dH, transition=easing.outBack} )
        elseif target == images.hintButton then
          timer.pause( gameTimerDelay )
          if coins>1 then
            windowName = "hint"
            images.hintActualCoins.text = coins
            transition.to(hintGroup, {time=450, y=-dH, transition=easing.outBack} )
          else
            windowName = "notEnoughCoins"
            images.notEnoughCoinsActualCoins.text = coins
            transition.to(notEnoughCoinsGroup, {time=450, y=-dH, transition=easing.outBack} )
          end
        end
      end
      return true
    end

    ----------------------------------------------------------------------
    --              Start Of Game Countdown             --
    ----------------------------------------------------------------------
    local function startGameTimer()
      local function gameTimer()
        timerVar = timerVar-1
        images.actualGameTimer.text = timerVar
        if timerVar == 0 then
          outOfTime()
        end
      end
      if storeValues[3] == 1 then
        gameTimerDelay = timer.performWithDelay( 1000, gameTimer, 300)
      else
        gameTimerDelay = timer.performWithDelay( 1000, gameTimer, 150)
      end
    end

    ----------------------------------------------------------------------
    --              Game Countdown Timer            --
    ----------------------------------------------------------------------
    local function finishCountIn()
      images.countIn1.y=images.countIn1.y+dH
      candyWordsGroup.y=-dH
      candyLettersGroup.y=-dH
      candys.y=-dH
      candysGreenGroup.y=candysGreenGroup.y+dH
      windowName = "none"
      startGameTimer()
    end
    local function count1Funct()
      images.countIn2.y=images.countIn2.y+dH
      images.countIn1.y=images.countIn1.y-dH-dH
      audioFunct.countGameStart()
      transition.scaleTo(images.countIn1, {time=1000, xScale=.01, yScale=.01, onComplete=finishCountIn } )
    end
    local function count2Funct()
      images.countIn3.y=images.countIn3.y+dH
      images.countIn2.y=images.countIn2.y-dH-dH
      audioFunct.countGameStart()
      transition.scaleTo(images.countIn2, {time=1000, xScale=.01, yScale=.01, onComplete=count1Funct } )
    end
    audioFunct.countGameStart()
    transition.scaleTo(images.countIn3, {time=1000, xScale=.01, yScale=.01, onComplete=count2Funct } )

    ----------------------------------------------------------------------
    --              Audio Handler              --
    ----------------------------------------------------------------------
    --Start Of Game Music + Sound Handler
    local function startMusicSoundHandler()
      if musicOn==0 then
        images.musicButton.fill.effect = "filter.grayscale"
        audio.setVolume(  0, { channel = 1 } )
      else
        images.musicButton.fill.effect = ""
        audio.setVolume(  .55, { channel = 1 } )
      end
      if soundOn==0 then
        images.soundButton.fill.effect = "filter.grayscale"
        audio.setVolume(  0, { channel = 2 } )
        audio.setVolume(  0, { channel = 3 } )
        audio.setVolume(  0, { channel = 4 } )
        audio.setVolume(  0, { channel = 5 } )
      else
        images.soundButton.fill.effect = ""
        audio.setVolume(  .75, { channel = 2 } )
        audio.setVolume(  .75, { channel = 3 } )
        audio.setVolume(  .75, { channel = 4 } )
        audio.setVolume(  .75, { channel = 5 } )
      end
    end

    --Turn Music / Sound On Or Off Handler
    local function musicSoundHandler(event)
      local target = event.target
      local phase = event.phase
      if ( phase == "ended") then
        if target==images.musicButton then
          if musicOn==0 then
            musicOn=1
          else
            musicOn=0
          end
        elseif target==images.soundButton then
          if soundOn==0 then
            soundOn=1
            gameValues[6] = soundOn
            jsonFunct.writeGameValues(gameValues)
            audioFunct.click()
          else
            soundOn=0
          end
        end
        startMusicSoundHandler()
        gameValues[5] = musicOn
        gameValues[6] = soundOn
        jsonFunct.writeGameValues(gameValues)
      end
      return true
    end

    startMusicSoundHandler()

    ----------------------------------------------------------------------
    --          Create Event Listeners         --
    ----------------------------------------------------------------------
    images.pauseButton:addEventListener( "touch", transitionToScreen )-- Play Button
    images.hintButton:addEventListener( "touch", transitionToScreen )-- Hint Button
    images.hintYesButton:addEventListener( "touch", transitionExitWindows )-- Hint Yes Button
    images.hintNoButton:addEventListener( "touch", transitionExitWindows )-- Hint No Button
    images.hintExitButton:addEventListener( "touch", transitionExitWindows )-- Hint Exit Button
    images.pauseExitButton:addEventListener( "touch", transitionExitWindows )-- Pause Exit Button
    images.pauseResumeButton:addEventListener( "touch", transitionExitWindows )-- Pause Exit Button
    images.pauseRestartButton:addEventListener( "touch", transitionExitWindows )-- Pause Restart Button
    images.pauseHomeButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.outOfTimeRestartButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.outOfTimeStoreButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.outOfTimeHomeButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.outOfTimeExitButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.gameWonNextButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.gameWonStoreButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.gameWonHomeButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.gameWonExitButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughCoinsResumeButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughCoinsStoreButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughCoinsExitButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughLivesExitButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughLivesHomeButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughLivesStoreButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughLivesOneCoinButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.notEnoughLivesWatchAdButton:addEventListener( "touch", transitionExitWindows )-- Pause Home Button
    images.musicButton:addEventListener( "touch", musicSoundHandler )-- Music Button
    images.soundButton:addEventListener( "touch", musicSoundHandler )-- Sound Button

    ----------------------------------------------------------------------
    --        Back Button Handler      --
    ----------------------------------------------------------------------
    function scene:backButton()
      if windowName == "none" then
        windowName="pause"
        audioFunct.click()
        timer.pause( gameTimerDelay )
        images.pauseActualCoins.text = coins
        images.pauseActualMoves.text = moves
        images.pauseActualTime.text = timerVar
        transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack} )
        transition.to(pauseGroup, {time=450, y=-dH, transition=easing.outBack} )
      end
    end

    ----------------------------------------------------------------------
    --              Change Screen            --
    ----------------------------------------------------------------------
    changeScreen  = function ( self, event )
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
    --          Ad Handler         --
    ----------------------------------------------------------------------
    --Load Ad If Needed
    if not admob.isLoaded( "interstitial" ) and storeValues[1]==0 and (gameValues[13]-gameValues[12])<3 then
      admob.load( "interstitial", { adUnitId="ca-app-pub-6435409860009337/6932271253" } )
    end
    if admob.isLoaded( "rewardedVideo" )==false and gameValues[2]<3 then
      admob.load( "rewardedVideo", { adUnitId="ca-app-pub-6435409860009337/6547034542" } )
    end

    --Process Reward Ad
    function scene:processReward()
      if adProcessOnce == 0 then
      adProcessOnce = 1
      goToNextLevelHandler()
      lives = lives + 1
      gameValues[2] = lives
      jsonFunct.writeGameValues(gameValues)
      composer.gotoScene( "code.playHard"  )
    end
  end

    --Process Interstitial
    function scene:processInterstitial()
      if adProcessOnce == 0 then
      adProcessOnce = 1
      goToNextLevelHandler()
      composer.gotoScene( "code.playHard"  )
    end
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