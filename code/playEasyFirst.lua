-- =============================================================
-- Copyright 2018, Andrew Baronick, All rights reserved.
-- =============================================================
-- playEasyFirst
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
    local easyWordsValues = jsonFunct.readEasyWords()
    local easyLettersValues = jsonFunct.readEasyLetters()
    local easyWordsHintsValues = jsonFunct.readEasyWordsHints()
    local easyAnswerLetters = jsonFunct.readEasyAnswerLetters()
    local easyLevelStats = jsonFunct.readEasyStatsValues()
    local lifeRegenerationValues = jsonFunct.readLifeRegeneration()

    --Assigned JSON Variables
    local coins = gameValues[1]
    local lives = gameValues[2]
    local musicOn = gameValues[5]
    local soundOn = gameValues[6]
    local level = currentLevelValues[4]
    local levelWords = easyWordsValues[level]
    local levelLetters = easyLettersValues[level]
    local levelWordsHints = easyWordsHintsValues[level]
    local levelAnswerLetters = easyAnswerLetters[level]

    -- Display Variables
    local dW = display.contentWidth
    local dH = display.contentHeight
    local cX = display.contentCenterX
    local cY = display.contentCenterY
    local screenName = "none"
    local candyCount=1
    local candyXPos = {dW*.64, dW*.47, dW*.3, dW*.12}
    local candyYPos = {dH*.8, dH*.5, dH*.2}
    local levelWordsTable, candyTable, candyLetterTable, answerTable, greenCandyTable, wordTracker, oldWordTracker = {}, {}, {}, {}, {}, {}, {}
    for c=#levelWords, 1, -1 do
      wordTracker[c]=0
    end

    -- Forward Declarations
    local changeScreen
    local tutorialHandler

    -- Scene Variables
    local candyChoice, tutorialCount = 1, 1
    local candyNumTracker, candyXTracker, candyYTracker, letterTracker, gameTimerDelay, timerVar
    local windowName = "countDown"
    local moves, totalScore, storeParam, goToNextLevel, adProcessOnce = 0, 0, 0, 0, 0
    local timerVar = 180

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
    tutorialGroup = display.newGroup()
    content:insert( tutorialGroup )
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
    directionsWindowGroup = display.newGroup()
    content:insert( directionsWindowGroup )

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
            jsonFunct.writeStoreValues(storeValues)
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
        if level%5 == 0 and easyLevelStats[level][1] == 0  then
          images.plusOneCoin.y = images.plusOneCoin.y - dH
          coins = coins + 1
          gameValues[1] = coins
          jsonFunct.writeGameValues(gameValues)
          audioFunct.freeGift()
          transition.scaleTo(images.plusOneCoin, {time=750, xScale=1.4, yScale=1.4, onComplete=plusCoinTransitionBack } )
        else
          windowName = "gameWonWindow"
        end
        if totalScore > easyLevelStats[level][1] then
          easyLevelStats[level][1] = totalScore
          easyLevelStats[level][2] = moves
          easyLevelStats[level][3] = timerVar
          easyLevelStats[level][4] = starCounter
          jsonFunct.writeEasyStatsValues(easyLevelStats)
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
      if moves < 20 then
        totalScore = 1700-(moves*85)
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
      jsonFunct.writeFirstTimeValues("v2.3.0")
      transition.to(gameWonGroup, {time=450, y=-dH, transition=easing.outBack} )
      transition.to(parsedLevelGroup, {time=450, y=-dH, transition=easing.outBack, onComplete=starTransitions1} )
      if level == currentLevelValues[1] and level < 300 then
        currentLevelValues[1] = currentLevelValues[1]+1
        table.insert(easyLevelStats,{0,0,0,0})
        jsonFunct.writeEasyStatsValues(easyLevelStats)
        jsonFunct.writeCurrentLevelValues(currentLevelValues)
      end
    end

    ----------------------------------------------------------------------
    --                 Out Of Time Handler              --
    ----------------------------------------------------------------------
    local function outOfTime()
      windowName = "outOfTimeWindow"
      checkForLives()
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
      local fourWord1 = levelLetters[1] .. levelLetters[2] .. levelLetters[3] .. levelLetters[4]
      local fourWord2 = levelLetters[5] .. levelLetters[6] .. levelLetters[7] .. levelLetters[8]
      local fourWord3 = levelLetters[9] .. levelLetters[10] .. levelLetters[11] .. levelLetters[12]
      local threeWord1 = levelLetters[1] .. levelLetters[2] .. levelLetters[3]
      local threeWord2 = levelLetters[2] .. levelLetters[3] .. levelLetters[4]
      local threeWord3 = levelLetters[5] .. levelLetters[6] .. levelLetters[7]
      local threeWord4 = levelLetters[6] .. levelLetters[7] .. levelLetters[8]
      local threeWord5 = levelLetters[9] .. levelLetters[10] .. levelLetters[11]
      local threeWord6 = levelLetters[10] .. levelLetters[11] .. levelLetters[12]
      local threeWord7 = levelLetters[1] .. levelLetters[5] .. levelLetters[9]
      local threeWord8 = levelLetters[2] .. levelLetters[6] .. levelLetters[10]
      local threeWord9 = levelLetters[3] .. levelLetters[7] .. levelLetters[11]
      local threeWord10 = levelLetters[4] .. levelLetters[8] .. levelLetters[12]
      local twoWord1 = levelLetters[1] .. levelLetters[2]
      local twoWord2 = levelLetters[2] .. levelLetters[3]
      local twoWord3 = levelLetters[3] .. levelLetters[4]
      local twoWord4 = levelLetters[5] .. levelLetters[6]
      local twoWord5 = levelLetters[6] .. levelLetters[7]
      local twoWord6 = levelLetters[7] .. levelLetters[8]
      local twoWord7 = levelLetters[9] .. levelLetters[10]
      local twoWord8 = levelLetters[10] .. levelLetters[11]
      local twoWord9 = levelLetters[11] .. levelLetters[12]
      local twoWord10 = levelLetters[1] .. levelLetters[5]
      local twoWord11 = levelLetters[5] .. levelLetters[9]
      local twoWord12 = levelLetters[2] .. levelLetters[6]
      local twoWord13 = levelLetters[6] .. levelLetters[10]
      local twoWord14 = levelLetters[3] .. levelLetters[7]
      local twoWord15 = levelLetters[7] .. levelLetters[11]
      local twoWord16 = levelLetters[4] .. levelLetters[8]
      local twoWord17 = levelLetters[8] .. levelLetters[12]

      local function checkFours(word, parsedWord, wordNum, startNum, yPos)
        if word == parsedWord then
          for v=0, 3, 1 do
            greenCandyTable[startNum+v].y = candyYPos[yPos]-dH
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
            greenCandyTable[startNum].y = candyYPos[3]-dH
            greenCandyTable[startNum+4].y = candyYPos[2]-dH
            greenCandyTable[startNum+8].y = candyYPos[1]-dH
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
            greenCandyTable[startNum+4].y = candyYPos[yPos-1]-dH
          end
          levelWordsTable[wordNum]:setFillColor(.1,.95,.1)
          wordTracker[wordNum]=1
        end
      end

      --Compare Parses with words
      for c=#levelWords,1,-1 do
        if #levelWords[c] == 4 then
          checkFours(levelWords[c], fourWord1, c, 1, 3)
          checkFours(levelWords[c], fourWord2, c, 5, 2)
          checkFours(levelWords[c], fourWord3, c, 9, 1)
        end
        if #levelWords[c] == 3 then
          checkThrees(levelWords[c], threeWord1, c, 0, 1, 3)
          checkThrees(levelWords[c], threeWord2, c, 0, 2, 3)
          checkThrees(levelWords[c], threeWord3, c, 0, 5, 2)
          checkThrees(levelWords[c], threeWord4, c, 0, 6, 2)
          checkThrees(levelWords[c], threeWord5, c, 0, 9, 1)
          checkThrees(levelWords[c], threeWord6, c, 0, 10,1)
          checkThrees(levelWords[c], threeWord7, c, 1, 1)
          checkThrees(levelWords[c], threeWord8, c, 1, 2)
          checkThrees(levelWords[c], threeWord9, c, 1, 3)
          checkThrees(levelWords[c], threeWord10, c, 1, 4)
        end
        if #levelWords[c] == 2 then
          checkTwos(levelWords[c], twoWord1, c, 0, 1, 3)
          checkTwos(levelWords[c], twoWord2, c, 0, 2, 3)
          checkTwos(levelWords[c], twoWord3, c, 0, 3, 3)
          checkTwos(levelWords[c], twoWord4, c, 0, 5, 2)
          checkTwos(levelWords[c], twoWord5, c, 0, 6, 2)
          checkTwos(levelWords[c], twoWord6, c, 0, 7, 2)
          checkTwos(levelWords[c], twoWord7, c, 0, 9, 1)
          checkTwos(levelWords[c], twoWord8, c, 0, 10, 1)
          checkTwos(levelWords[c], twoWord9, c, 0, 11, 1)
          checkTwos(levelWords[c], twoWord10, c, 1, 1, 3)
          checkTwos(levelWords[c], twoWord11, c, 1, 5, 2)
          checkTwos(levelWords[c], twoWord12, c, 1, 2, 3)
          checkTwos(levelWords[c], twoWord13, c, 1, 6, 2)
          checkTwos(levelWords[c], twoWord14, c, 1, 3, 3)
          checkTwos(levelWords[c], twoWord15, c, 1, 7, 2)
          checkTwos(levelWords[c], twoWord16, c, 1, 4, 3)
          checkTwos(levelWords[c], twoWord17, c, 1, 8, 2)
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
        tutorialCount = tutorialCount + 1
        tutorialHandler()
      elseif ( "moved" == phase ) then
      elseif ( "ended" == phase or "cancelled" == phase ) then
        if windowName=="none" then
          for o=#candyTable,1,-1 do
            if tutorialCount > 1 and event.x > (candyTable[o].x-(dW*.0704)) and event.x < (candyTable[o].x+(dW*.0704)) and event.y > ((candyTable[o].y-(dW*.0704)-dH)) and event.y < ((candyTable[o].y+(dW*.0704)-dH)) then
              if candyTable[o].num ~= candyNumTracker then
                audioFunct.click()
                candyTapHandler2(candyTable[o].num,candyTable[o].x, candyTable[o].y )
                tutorialCount = tutorialCount + 1
                tutorialHandler()
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
    images.background = createImage(bgGroup, "images/background1.png", dW*2, dH, cX, cY)
    images.backBox = display.newRoundedRect(bgGroup, dW*.38, cY, dW*.7, dH*.9, 40)
    images.backBox.fill = {.4, .4}
    images.backBoxWords = display.newRoundedRect(bgGroup, dW*.87, cY,dW*.22, dH*.88, 15)
    images.backBoxWords.fill = {.4, .4}
    images.pauseButton = createImage(bgGroup, "images/pauseButton.png", 45, 45, dW*.925, dH*.15 )
    images.hintButton = createImage(bgGroup, "images/hintButton.png", 45, 45, dW*.82, dH*.15)
    images.actualGameTimer = createWords(bgGroup, timerVar, dW*.87, dH*.31, 30 )

    --Create Count In Group
    images.countIn1 = createImage(countInGroup, "images/1.png", dW*.7, dW*.7, cX, cY+dH+dH)
    images.countIn2 = createImage(countInGroup, "images/2.png", dW*.7, dW*.7, cX, cY+dH+dH)
    images.countIn3 = createImage(countInGroup, "images/3.png", dW*.7, dW*.7, cX, cY)

    --Create Background Group
    images.tutorialFinger = createImage(tutorialGroup, "images/finger.png", 60, 77, dW*.545, dH*.89+dH )

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
      images.infiniteLivesPic = createImage(pauseGroup, "images/infiniteSign.png", 21, 18, dW*.399, dH*.553+dH)
    else
      images.pauseActualLives = createWords(pauseGroup, lives, dW*.397, dH*.553+dH, 18 )
      images.infiniteLivesPic = createImage(pauseGroup, "images/infiniteSign.png", 21, 18, dW*.399, dH*.553+dH+dH)
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
      images.infiniteLivesPic = createImage(outOfTimeGroup, "images/infiniteSign.png", 21, 18, dW*.399, dH*.553+dH)
    else
      images.outOfTimeActualLives = createWords(outOfTimeGroup, lives, dW*.32, dH*.743+dH, 18 )
      images.infiniteLivesPic = createImage(outOfTimeGroup, "images/infiniteSign.png", 21, 18, dW*.399, dH*.553+dH+dH)
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

    --Create Direction Window
    images.backDirectionWindow = display.newRect(directionsWindowGroup, cX, cY+dH, dW*2, dH)
    images.backDirectionWindow.fill = {.13, .92}
    images.directionsWindow = createImage(directionsWindowGroup, "images/directionsWindow.png", 430, 290, cX, cY+dH)
    images.directionsWindowExitButton = createImage(directionsWindowGroup, "images/exit.png", 50, 50, dW*.827, dH*.25+dH )
    images.check1DirectionsWindow = createImage(directionsWindowGroup, "images/checkButton.png", 27, 27, dW*.23, dH*.425+dH)
    images.check2DirectionsWindow = createImage(directionsWindowGroup, "images/checkButton.png", 27, 27, dW*.23, dH*.545+dH)
    images.check3DirectionsWindow = createImage(directionsWindowGroup, "images/checkButton.png", 27, 27, dW*.23, dH*.67+dH)
    images.playButtonDirectionsWindow = createImage(directionsWindowGroup, "images/okButton.png", 90, 45, cX, dH*.906+dH)
    images.check1DirectionsWindow.fill.effect = "filter.grayscale"
    images.check2DirectionsWindow.fill.effect = "filter.grayscale"
    images.check3DirectionsWindow.fill.effect = "filter.grayscale"

    if level%5 == 0 and easyLevelStats[level][1] == 0  then
      images.plusOneCoin = createImage(plusOneCoinGroup, "images/plusOneCoin.png", 148, 65, cX, dH*.303+dH )
    end

    for e = 1, #levelWords, 1 do
      local actualLevelWords = createWords(candyWordsGroup, levelWords[e], dW*.876, (dH*.99)-(e*(dH*.65)/(#levelWords+1))+dH, 20 )
      table.insert(levelWordsTable,actualLevelWords)
    end

    --Create Orange, Green and Pink Candys
    for h = #candyYPos, 1, -1 do
      for i = #candyXPos, 1, -1 do
        local orangeCandy = display.newImageRect(candys, "images/orangeCandy.png", dW*.149, dW*.149 )
        local answerLetter = display.newText(candyLettersAnswerGroup, levelAnswerLetters[candyCount], candyXPos[i], candyYPos[h]+dH, "RifficFree-Bold.ttf", 35 )
        local greenCandy = display.newImageRect(candysGreenGroup, "images/greenCandy.png", dW*.149, dW*.149 )
        local candyLetter = display.newText(candyLettersGroup, levelLetters[candyCount], candyXPos[i], candyYPos[h]+dH, "RifficFree-Bold.ttf", 35 )
        answerLetter:setFillColor(.1,.1,.5)
        candyLetter:setFillColor(0)
        orangeCandy.x = candyXPos[i] ; orangeCandy.y = candyYPos[h]+dH
        greenCandy.x = candyXPos[i] ; greenCandy.y = candyYPos[h]
        orangeCandy.num = candyCount
        candyLetter.num = candyCount
        greenCandy.tracker = 0
        table.insert(candyTable,orangeCandy)
        table.insert(answerTable,answerLetter)
        table.insert(greenCandyTable,greenCandy)
        table.insert(candyLetterTable,candyLetter)
        transition.to(greenCandy, { time=3000, rotation=360, iterations=1} )
        candyCount = candyCount + 1
      end
    end

    images.pinkSpinner = createImage(otherGroup, "images/pinkCandy.png", dW*.149, dW*.149, cX, cY+dH )
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
        currentLevelValues[4]=level
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
        if windowName ~= "gameWonStarHandler" then
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
            screenName = "code.playEasyFirst"
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
            screenName = "code.playEasyFirst"
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
            screenName = "code.playEasyFirst"
            handleInterstellar()
            transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=changeScreenFunct} )
          else
            transition.to(outOfTimeGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=notEnoughLivesTransition} )
          end
        elseif target == images.gameWonNextButton and windowName == "gameWonWindow" then
          if lives > 0 then
            screenName = "code.playEasy"
            handleInterstellar()
            if currentLevelValues[4] < 300 then
              currentLevelValues[4] = currentLevelValues[4] + 1
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
            screenName = "code.playEasy"
            handleInterstellar()
            if currentLevelValues[4] < 300 then
              currentLevelValues[4] = currentLevelValues[4] + 1
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
            screenName = "code.playEasyFirst"
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
          print(windowName)
          if windowName~="directionsWindow" then
          windowName="pause"
          timer.pause( gameTimerDelay )
          images.pauseActualCoins.text = coins
          images.pauseActualMoves.text = moves
          images.pauseActualTime.text = timerVar
          transition.to(pauseGroup, {time=450, y=-dH, transition=easing.outBack} )
        end
        elseif target == images.hintButton and windowName~="directionsWindow" then
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
    --              Tutorial Handler            --
    ----------------------------------------------------------------------
    local function startPlayingGame(event)
      local phase = event.phase
      if ( phase=="began" and windowName=="none") then
        audioFunct.click()
      elseif ( phase == "ended" and windowName=="directionsWindow") then
      for e = #candyTable, 1, -1 do
          candyTable[e]:addEventListener( "touch", candyTapHandler )
        end
        images.hintButton:addEventListener( "touch", transitionToScreen )
        timer.resume( gameTimerDelay )
        transition.to(directionsWindowGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        windowName = "none"
        end
      return true
    end

    tutorialHandler  = function ( self )
        local fingerScaleBack
        local function fingerScaleUp()
          if tutorialCount < 3 then
          transition.scaleTo(images.tutorialFinger, {time=800, xScale=1.25, yScale=1.25, onComplete=fingerScaleBack } )
          elseif tutorialCount >= 3 and tutorialCount < 5 then
            transition.to(images.tutorialFinger, {time=920, x=dW*.2, y=dH*.57, transition=easing.outBack, onComplete=fingerScaleBack} )
          else
            images.tutorialFinger.y = images.tutorialFinger.y+dH+dH
        end
      end
      local function activatePlayButton()
        images.playButtonDirectionsWindow:addEventListener( "touch", startPlayingGame )
        images.directionsWindowExitButton:addEventListener( "touch", startPlayingGame )
      end
      local function checkTwoClose()
        transition.scaleTo(images.check2DirectionsWindow, {time=500, xScale=1, yScale=1, onComplete=activatePlayButton } )
      end
      local function checkTwo()
        images.check2DirectionsWindow.fill.effect = ""
        audioFunct.star2()
        transition.scaleTo(images.check2DirectionsWindow, {time=500, xScale=1.4, yScale=1.4, onComplete=checkTwoClose } )
      end
      local function checkOneClose()
        transition.scaleTo(images.check1DirectionsWindow, {time=500, xScale=1, yScale=1, onComplete=checkTwo } )
      end
      local function checkOne()
        windowName = "directionsWindow"
        images.check1DirectionsWindow.fill.effect = ""
        audioFunct.star1()
        transition.scaleTo(images.check1DirectionsWindow, {time=500, xScale=1.4, yScale=1.4, onComplete=checkOneClose } )
      end
        fingerScaleBack  = function ( self )
        transition.scaleTo(images.tutorialFinger, {time=800, xScale=1, yScale=1, onComplete=fingerScaleUp } )
        if tutorialCount >= 3 and tutorialCount < 5 then
          images.tutorialFinger.x = dW*.71 ; images.tutorialFinger.y = dH*.9
        end
      end
      if tutorialCount == 1 then
        images.tutorialFinger.y = images.tutorialFinger.y - dH
        candyTable[11]:addEventListener( "touch", candyTapHandler )
        fingerScaleUp()
      elseif tutorialCount == 2 then
        candyTable[11]:removeEventListener( "touch", candyTapHandler )
        candyTable[2]:addEventListener( "touch", candyTapHandler )
        images.tutorialFinger.x = dW*.38 ; images.tutorialFinger.y = dH*.31
      elseif tutorialCount == 3 then
        candyTable[2]:removeEventListener( "touch", candyTapHandler )
        candyTable[11]:removeEventListener( "touch", candyTapHandler )
        candyTable[12]:addEventListener( "touch", candyTapHandler )
        candyTable[5]:addEventListener( "touch", candyTapHandler )
        images.tutorialFinger.x = dW*.71 ; images.tutorialFinger.y = dH*.9
      elseif tutorialCount == 5 then
        candyTable[12]:removeEventListener( "touch", candyTapHandler )
        candyTable[5]:removeEventListener( "touch", candyTapHandler )
        windowName = "directionsWindow"
        timer.pause( gameTimerDelay )
        transition.to(directionsWindowGroup, {delay=1000, time=450, y=-dH, transition=easing.outBack, onComplete=checkOne} )
      end
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
        gameTimerDelay = timer.performWithDelay( 1000, gameTimer, 180)
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
      tutorialHandler()
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
      screenName = "code.playEasyFirst"
      changeScreen()
    end
  end

    --Process Interstitial
    function scene:processInterstitial()
      if adProcessOnce == 0 then
      adProcessOnce = 1
      goToNextLevelHandler()
      screenName = "code.playEasyFirst"
      changeScreen()
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