-- =============================================================
-- Copyright 2018, Andrew Baronick, All rights reserved.
-- =============================================================
-- mainMenu
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
    local audioFunct = require( "modAudio" )

    ----------------------------------------------------------------------
    --                LOCALS                --
    ----------------------------------------------------------------------
    -- JSON Variables
    local gameValues = jsonFunct.readGameValues()
    local storeValues = jsonFunct.readStoreValues()
    local lifeRegenerationValues = jsonFunct.readLifeRegeneration()
    local firstTimeFileContents = jsonFunct.readFirstTimeOpenValue()

    --Assigned JSON Variables
    local coins = gameValues[1]
    local lives = gameValues[2]
    local musicOn = gameValues[5]
    local soundOn = gameValues[6]
    local dailyRewardDay = gameValues[10]
    local dailyRewardTime = gameValues[11]
    if firstTimeFileContents == nil then
      firstTimeFileContents = 0
    else
      firstTimeFileContents = 1
    end
    -- Display Variables
    local dW = display.contentWidth --568
    local dH = display.contentHeight --320
    local cX = display.contentCenterX 
    local cY = display.contentCenterY
    local windowName = "none"
    local shopScreenName = "none"
    local diffChooser = 0

    -- Screen Variables
    local screenName
    local goToLevelChooser
    local transactionType = "none"

    ----------------------------------------------------------------------
    --             Daily Reward Day           --
    ----------------------------------------------------------------------
    local currentTimeDailyReward = os.date( '*t' )
    currentTimeDailyReward = os.time(currentTimeDailyReward)
    if dailyRewardTime == 0 then
    dailyRewardTime = currentTimeDailyReward
  elseif currentTimeDailyReward >= dailyRewardTime+68400 and currentTimeDailyReward <= dailyRewardTime+172800 then
    dailyRewardTime = currentTimeDailyReward
    dailyRewardDay = dailyRewardDay + 1
  elseif currentTimeDailyReward > dailyRewardTime+172800 then
    dailyRewardTime = currentTimeDailyReward
    dailyRewardDay = 1
  end

    ----------------------------------------------------------------------
    --             CREATE IMAGES            --
    ----------------------------------------------------------------------
    --Parent Image Holders
    local images = {}
    content = display.newGroup()
    self.view:insert( content )

    --Create Image Groups
    bgGroup = display.newGroup()
    content:insert( bgGroup )
    hudGroup = display.newGroup()
    content:insert( hudGroup )
    nextLifeHudGroup = display.newGroup()
    content:insert( nextLifeHudGroup )
    difficultyChooserGroup = display.newGroup()
    content:insert( difficultyChooserGroup )
    giftGroup = display.newGroup()
    content:insert( giftGroup )
    dailyRewardGroup = display.newGroup()
    content:insert( dailyRewardGroup )
    staticShopGroup = display.newGroup()
    content:insert( staticShopGroup )
    TabSelectedGroup = display.newGroup()
    content:insert( TabSelectedGroup )
    coinShopGroup = display.newGroup()
    content:insert( coinShopGroup )
    removeAdsShopGroup = display.newGroup()
    content:insert( removeAdsShopGroup )
    infiniteLivesShopGroup = display.newGroup()
    content:insert( infiniteLivesShopGroup )
    doubleTimeShopGroup = display.newGroup()
    content:insert( doubleTimeShopGroup )
    doubleLivesShopGroup = display.newGroup()
    content:insert( doubleLivesShopGroup )

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

    --Create Background Group
    images.background = createImage(bgGroup, "images/mainMenuBackground.png", dW*3, dH, cX, cY)
    images.playButton = createImage(bgGroup, "images/playButton.png", 86, 86, cX, dH*.8 )
    images.giftButton = createImage(bgGroup, "images/giftButton.png", 63, 63, dW*.33, dH*.83 )
    images.storeButton = createImage(bgGroup, "images/purchaseButton.png", 63, 63, dW*.67, dH*.83 )

    --Hud Group
    images.actualCoins = createWords(hudGroup, coins, dW*.718, dH*.083, 15)
    images.musicButton = createImage(hudGroup, "images/musicButton.png", 45, 45, dW*.065, dH*.12 )
    images.soundButton = createImage(hudGroup, "images/soundButton.png", 45, 45, dW*.065, dH*.29 )

    if storeValues[2] == 1 then
    images.actualLives = createWords(hudGroup, lives, dW*.882, dH*.083+dH, 15)
    images.infiniteLivesPic = createImage(hudGroup, "images/infiniteSign.png", 21, 18, dW*.88, dH*.08)
  else
    images.actualLives = createWords(hudGroup, lives, dW*.882, dH*.083, 15)
    images.infiniteLivesPic = createImage(hudGroup, "images/infiniteSign.png", 21, 18, dW*.88, dH*.08+dH)
  end

    --Next Life Hud
    images.healthTimerHud = createImage(nextLifeHudGroup, "images/heartClock.png", 77, 38, dW*.908, dH*.24+dH)
    images.actualHealthTimerMin = createWords(nextLifeHudGroup, "", dW*.865, dH*.24+dH, 15)
    images.actualHealthTimerSec = createWords(nextLifeHudGroup, "", dW*.898, dH*.24+dH, 15)
    images.actualHealthTimerColon = createWords(nextLifeHudGroup, ":", dW*.8768, dH*.238+dH, 15)

    --Daily Reward Group
    images.backWindowDailyReward = display.newRect(dailyRewardGroup, cX, cY+dH, dW*2, dH)
    images.backWindowDailyReward.fill = {.13, .92}
    images.dailyRewardWindow = createImage(dailyRewardGroup, "images/dailyRewardWindow.png", dW-60, dH-10, cX, cY+dH)

    if dailyRewardDay <= 4 then
    images.dailyRewardSpot1 = createImage(dailyRewardGroup, "images/day1.png", 102, 158, dW*.22, dH*.615+dH)
    images.dailyRewardSpot2 = createImage(dailyRewardGroup, "images/day2.png", 102, 158, dW*.408, dH*.615+dH)
    images.dailyRewardSpot3 = createImage(dailyRewardGroup, "images/day3.png", 102, 158, dW*.593, dH*.615+dH)
    images.dailyRewardSpot4 = createImage(dailyRewardGroup, "images/day4.png", 102, 158, dW*.779, dH*.615+dH)
    elseif dailyRewardDay > 4 and dailyRewardDay <= 8 then
    images.dailyRewardSpot1 = createImage(dailyRewardGroup, "images/day5.png", 102, 158, dW*.22, dH*.615+dH)
    images.dailyRewardSpot2 = createImage(dailyRewardGroup, "images/day6.png", 102, 158, dW*.408, dH*.615+dH)
    images.dailyRewardSpot3 = createImage(dailyRewardGroup, "images/day7.png", 102, 158, dW*.593, dH*.615+dH)
    images.dailyRewardSpot4 = createImage(dailyRewardGroup, "images/day8.png", 102, 158, dW*.779, dH*.615+dH)
    elseif dailyRewardDay > 8 then
    images.dailyRewardSpot1 = createImage(dailyRewardGroup, "images/day9.png", 102, 158, dW*.22, dH*.615+dH)
    images.dailyRewardSpot2 = createImage(dailyRewardGroup, "images/day10.png", 102, 158, dW*.408, dH*.615+dH)
    images.dailyRewardSpot3 = createImage(dailyRewardGroup, "images/day11.png", 102, 158, dW*.593, dH*.615+dH)
    images.dailyRewardSpot4 = createImage(dailyRewardGroup, "images/day12.png", 102, 158, dW*.779, dH*.615+dH)
      end

    --Difficulty Chooser (Play Button) Group
    images.backWindowDifficultyChooser = display.newRect(difficultyChooserGroup, cX, cY+dH, dW*2, dH)
    images.backWindowDifficultyChooser.fill = {.13, .92}
    images.difficultyChooserPauseWindow = createImage(difficultyChooserGroup, "images/difficultyWindow.png", dW-60, dH-10, cX, cY+dH)
    images.difficultyChooserExitButton = createImage(difficultyChooserGroup, "images/exit.png", 50, 50, dW*.87, dH*.25+dH)
    images.easyChooser = createImage(difficultyChooserGroup, "images/difficultyChooser1.png", 102, 158, dW*.25, dH*.6+dH)
    images.mediumChooser = createImage(difficultyChooserGroup, "images/difficultyChooser2.png", 102, 158, cX, dH*.6+dH)
    images.hardChooser = createImage(difficultyChooserGroup, "images/difficultyChooser3.png", 102, 158, dW*.75,  dH*.6+dH)

    --Gift Group
    images.backGiftWindow = display.newRect(giftGroup, cX, cY+dH, dW*2, dH)
    images.backGiftWindow.fill = {.13, .92}
    images.giftsWindow = createImage(giftGroup, "images/giftWindow.png", dW-60, dH-10, cX, cY+dH)
    images.giftsExitButton = createImage(giftGroup, "images/exit.png", 50, 50, dW*.87, dH*.25+dH)
    images.rateGift = createImage(giftGroup, "images/rateGift.png", 102, 158, dW*.25, dH*.63+dH)
    images.facebookLikeGift = createImage(giftGroup, "images/facebookLike.png", 102, 158, cX, dH*.63+dH)
    images.facebookPostGift = createImage(giftGroup, "images/facebookPost.png", 102, 158, dW*.75, dH*.63+dH)
    images.facebookLikeGift.fill.effect = "filter.grayscale"
    images.facebookPostGift.fill.effect = "filter.grayscale"
    if gameValues[15] == 1 then
    images.rateGift.fill.effect = "filter.grayscale"
    end

    --Static Shop Group
    images.backWindowShop = display.newRect(staticShopGroup, cX, cY+dH, dW*2, dH)
    images.backWindowShop.fill = {.13, .92}
    images.shopPauseWindow = createImage(staticShopGroup, "images/pauseWindow.png", 466, dH, cX, cY+dH)
    images.shopExitButton = createImage(staticShopGroup, "images/exit.png", 50, 50, dW*.87, dH*.25+dH)
    images.storeWord = createImage(staticShopGroup, "images/store.png", 157, 68, cX, dH*.125+dH)
    images.infiniteLivesTab = createImage(staticShopGroup, "images/infiniteLivesTab.png", 58, 32, cX, dH*.341+dH)
    images.removeAdsTab = createImage(staticShopGroup, "images/adsTab.png", 58, 32, images.infiniteLivesTab.x-dW*.1, dH*.341+dH)
    images.doubleTimeTab = createImage(staticShopGroup, "images/doubleTimeTab.png", 58, 32, images.infiniteLivesTab.x+dW*.1, dH*.341+dH)
    images.coinTab = createImage(staticShopGroup, "images/coinTab.png", 58, 32, images.removeAdsTab.x-dW*.1, dH*.341+dH)
    images.doubleLivesTab = createImage(staticShopGroup, "images/doubleLivesTab.png", 58, 32, images.doubleTimeTab.x+dW*.1, dH*.341+dH)

    --Shop Selected Tab Images
    images.infiniteLivesTabSelected = createImage(TabSelectedGroup, "images/infiniteLivesTabSelected.png", 58, 32, cX, dH*.341+dH)
    images.removeAdsTabSelected = createImage(TabSelectedGroup, "images/adsTabSelected.png", 58, 32, images.infiniteLivesTab.x-dW*.1, dH*.341+dH)
    images.doubleTimeTabSelected = createImage(TabSelectedGroup, "images/doubleTimeTabSelected.png", 58, 32, images.infiniteLivesTab.x+dW*.1, dH*.341+dH)
    images.coinTabSelected = createImage(TabSelectedGroup, "images/coinTabSelected.png", 58, 32, images.removeAdsTab.x-dW*.1, dH*.341+dH)
    images.doubleLivesTabSelected = createImage(TabSelectedGroup, "images/doubleLivesTabSelected.png", 58, 32, images.doubleTimeTab.x+dW*.1, dH*.341+dH)

    --Shop Coin Group
    images.coinsWord = createImage(coinShopGroup, "images/coinsWord.png", 86, 32, cX, dH*.443+dH)
    images.buy2Coins = createImage(coinShopGroup, "images/buy2Coins.png", 80, 117, dW*.22, dH*.693+dH)
    images.buy7Coins = createImage(coinShopGroup, "images/buy7Coins.png", 80, 117, dW*.408, dH*.693+dH)
    images.buy25Coins = createImage(coinShopGroup, "images/buy25Coins.png", 80, 117, dW*.593, dH*.693+dH)
    images.buy50Coins = createImage(coinShopGroup, "images/buy50Coins.png", 80, 117, dW*.779, dH*.693+dH)

    --Shop Remove Ads Group
    images.removeAdsWord = createImage(removeAdsShopGroup, "images/removeAds.png", 250, 32, cX, dH*.443+dH)
    images.buyRemoveAds = createImage(removeAdsShopGroup, "images/buyRemoveAds.png", 80, 117, dW*.53, dH*.693+dH)
    images.boughtAdAlreadyWord = createImage(removeAdsShopGroup, "images/boughtAdAlready.png", 176, 41, dW*.285, dH*.6+dH)
    images.restoreAdsButton = createImage(removeAdsShopGroup, "images/restoreAdsButton.png", 80, 40, dW*.285, dH*.75+dH)

    --Shop Infinite Lives Group
    images.infiniteLivesWord = createImage(infiniteLivesShopGroup, "images/infiniteLivesWord.png", 179, 32, cX, dH*.443+dH)
    images.buy1DayInfinite = createImage(infiniteLivesShopGroup, "images/buy1DayInfinite.png", 80, 117, dW*.22, dH*.693+dH)
    images.buy3DaysInfinite = createImage(infiniteLivesShopGroup, "images/buy3DaysInfinite.png", 80, 117, dW*.408, dH*.693+dH)
    images.buy7DaysInfinite = createImage(infiniteLivesShopGroup, "images/buy7DaysInfinite.png", 80, 117, dW*.593, dH*.693+dH)
    images.buy14DaysInfinite = createImage(infiniteLivesShopGroup, "images/buy14DaysInfinite.png", 80, 117, dW*.779, dH*.693+dH)

    --Shop Double Time Group
    images.doubleTimeWord = createImage(doubleTimeShopGroup, "images/doubleTimeWord.png", 352, 32, cX, dH*.443+dH)
    images.buy1DayDoubleTime = createImage(doubleTimeShopGroup, "images/buy1DayDoubleTime.png", 80, 117, dW*.22, dH*.693+dH)
    images.buy3DaysDoubleTime = createImage(doubleTimeShopGroup, "images/buy3DaysDoubleTime.png", 80, 117, dW*.408, dH*.693+dH)
    images.buy7DaysDoubleTime = createImage(doubleTimeShopGroup, "images/buy7DaysDoubleTime.png", 80, 117, dW*.593, dH*.693+dH)
    images.buy14DaysDoubleTime = createImage(doubleTimeShopGroup, "images/buy14DaysDoubleTime.png", 80, 117, dW*.779, dH*.693+dH)

    --Shop Double Life Group
    images.doubleLivesWord = createImage(doubleLivesShopGroup, "images/doubleLives.png", 250, 32, cX, dH*.443+dH)
    images.buy1DayDoubleLife = createImage(doubleLivesShopGroup, "images/buy1DayDoubleLife.png", 80, 117, dW*.22, dH*.693+dH)
    images.buy3DaysDoubleLife = createImage(doubleLivesShopGroup, "images/buy3DaysDoubleLife.png", 80, 117, dW*.408, dH*.693+dH)
    images.buy7DaysDoubleLife = createImage(doubleLivesShopGroup, "images/buy7DaysDoubleLife.png", 80, 117, dW*.593, dH*.693+dH)
    images.buy14DaysDoubleLife = createImage(doubleLivesShopGroup, "images/buy14DaysDoubleLife.png", 80, 117, dW*.779, dH*.693+dH)

    if storeValues[1] == 1 then
      images.buyRemoveAds.fill.effect = "filter.grayscale"
    end

    if storeValues[2] == 1 or storeValues[4] == 1 then
    images.buy1DayInfinite.fill.effect = "filter.grayscale"
    images.buy3DaysInfinite.fill.effect = "filter.grayscale"
    images.buy7DaysInfinite.fill.effect = "filter.grayscale"
    images.buy14DaysInfinite.fill.effect = "filter.grayscale"
    images.buy1DayDoubleLife.fill.effect = "filter.grayscale"
    images.buy3DaysDoubleLife.fill.effect = "filter.grayscale"
    images.buy7DaysDoubleLife.fill.effect = "filter.grayscale" 
    images.buy14DaysDoubleLife.fill.effect = "filter.grayscale"
    end

    if storeValues[3] == 1 then
    images.buy1DayDoubleTime.fill.effect = "filter.grayscale"
    images.buy3DaysDoubleTime.fill.effect = "filter.grayscale"
    images.buy7DaysDoubleTime.fill.effect = "filter.grayscale"
    images.buy14DaysDoubleTime.fill.effect = "filter.grayscale"
    end

    ----------------------------------------------------------------------
    --             Infinite / Double Lives Handler        --
    ----------------------------------------------------------------------
local function clearLifeRegenValues() 
        for q=#lifeRegenerationValues, 1, -1 do
        if q == 1 then
          lifeRegenerationValues[1] = 0
        else
        table.remove(lifeRegenerationValues,q)
      end
    end
    jsonFunct.writeLifeRegenerationValues(lifeRegenerationValues)
  end
      local function infiniteToFront()
        lives=7
        transition.to(nextLifeHudGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        transition.to(images.actualLives, {time=450, y=dH+dH, transition=easing.inBack} )
        images.infiniteLivesPic.y = dH*.08
        clearLifeRegenValues() 
        gameValues[2] = lives
      end
      local function doubleLivesToFront()
        lives = 14
        gameValues[2] = 14
        images.actualLives.text = lives
        transition.to(nextLifeHudGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        clearLifeRegenValues() 
      end

    ----------------------------------------------------------------------
    --             Daily Reward Handler        --
    ----------------------------------------------------------------------
    --Daily Reward Handler
    local function dailyRewardHandler(event)
      local phase = event.phase
      local currentTimeRewardHandler = os.date( '*t' )
      currentTimeRewardHandler = os.time(currentTimeRewardHandler)
      if ( phase=="began" ) then
        audioFunct.freeGift()
      elseif ( phase == "ended" ) then
      if dailyRewardDay == 1 then
        coins =  coins + 1
        gameValues[1] = coins
      elseif dailyRewardDay == 2 then
        if storeValues[2] == 1 then
          storeValues[5] = storeValues[5] + 10800
        else
        storeValues[2] = 1
        storeValues[5] = currentTimeRewardHandler + 10800
      end
        infiniteToFront()
      elseif dailyRewardDay == 3 then
        coins =  coins + 2
        gameValues[1] = coins
      elseif dailyRewardDay == 4 then
        if storeValues[3] == 1 then
          storeValues[6] = storeValues[6] + 10800
        else
        storeValues[3] = 1
        storeValues[6] = currentTimeRewardHandler + 10800
      end
      elseif dailyRewardDay == 5 then
        if storeValues[4] == 1 then
          storeValues[5] = storeValues[5] + 10800
        else
        storeValues[4] = 1
        storeValues[5] = currentTimeRewardHandler + 10800
      end
        doubleLivesToFront()
      elseif dailyRewardDay == 6 then
        if storeValues[3] == 1 then
          storeValues[6] = storeValues[6] + 10800
        else
        storeValues[3] = 1
        storeValues[6] = currentTimeRewardHandler + 10800
      end
      elseif dailyRewardDay == 7 then
        coins =  coins + 3
        gameValues[1] = coins
      elseif dailyRewardDay == 8 then
        if storeValues[2] == 1 then
          storeValues[5] = storeValues[5] + 10800
        else
        storeValues[2] = 1
        storeValues[5] = currentTimeRewardHandler + 10800
      end
        infiniteToFront()
      elseif dailyRewardDay == 9 then
        if storeValues[3] == 1 then
          storeValues[6] = storeValues[6] + 10800
        else
        storeValues[3] = 1
        storeValues[6] = currentTimeRewardHandler + 10800
      end
      elseif dailyRewardDay == 10 then
        coins =  coins + 4
        gameValues[1] = coins
      elseif dailyRewardDay == 11 then
        if storeValues[2] == 1 then
          storeValues[5] = storeValues[5] + 10800
        else
        storeValues[2] = 1
        storeValues[5] = currentTimeRewardHandler + 10800
      end
        infiniteToFront()
      elseif dailyRewardDay >= 12 then
        coins =  coins + 5
      end
      transition.to(dailyRewardGroup, {time=450, y=dH+dH, transition=easing.inBack} )
      gameValues[10] = dailyRewardDay
      gameValues[11] = dailyRewardTime
      images.actualCoins.text = coins
      jsonFunct.writeStoreValues(storeValues)
      jsonFunct.writeGameValues(gameValues)
    end
    return true
  end

  --Initial Daily Reward Handler
    if dailyRewardTime ~= gameValues[11] then
      if dailyRewardDay == 1 or dailyRewardDay == 5 or dailyRewardDay == 9 then
        images.dailyRewardSpot2.fill.effect = "filter.grayscale"
        images.dailyRewardSpot3.fill.effect = "filter.grayscale"
        images.dailyRewardSpot4.fill.effect = "filter.grayscale"
        images.dailyRewardSpot1:addEventListener( "touch", dailyRewardHandler )-- Daily Reward Spot 1 Button
      elseif dailyRewardDay == 2 or dailyRewardDay == 6 or dailyRewardDay == 10 then
        images.dailyRewardSpot1.fill.effect = "filter.grayscale"
        images.dailyRewardSpot3.fill.effect = "filter.grayscale"
        images.dailyRewardSpot4.fill.effect = "filter.grayscale"
        images.dailyRewardSpot2:addEventListener( "touch", dailyRewardHandler )-- Daily Reward Spot 2 Button
      elseif dailyRewardDay == 3 or dailyRewardDay == 7 or dailyRewardDay == 11 then
        images.dailyRewardSpot1.fill.effect = "filter.grayscale"
        images.dailyRewardSpot2.fill.effect = "filter.grayscale"
        images.dailyRewardSpot4.fill.effect = "filter.grayscale"
        images.dailyRewardSpot3:addEventListener( "touch", dailyRewardHandler )-- Daily Reward Spot 3 Button
      elseif dailyRewardDay == 4 or dailyRewardDay == 8 or dailyRewardDay == 12 then
        images.dailyRewardSpot1.fill.effect = "filter.grayscale"
        images.dailyRewardSpot2.fill.effect = "filter.grayscale"
        images.dailyRewardSpot3.fill.effect = "filter.grayscale"
        images.dailyRewardSpot4:addEventListener( "touch", dailyRewardHandler )-- Daily Reward Spot 4 Button
      end
    transition.to(dailyRewardGroup, {time=450, y=-dH, transition=easing.outBack} )
    end

    ----------------------------------------------------------------------
    --              Rate Game Handler          --
    ----------------------------------------------------------------------
    local function rateGameHandler(event)
      local phase = event.phase
      if ( phase=="began" ) then
        if gameValues[15] == 0 then
        audioFunct.freeGift()
      end
      elseif ( phase == "ended") then
      if gameValues[15] == 0 then
        gameValues[15] = 1
        coins = coins + 5
        gameValues[1] = coins
        jsonFunct.writeGameValues(gameValues)
        images.actualCoins.text = coins
        local function rateApp()
    local options =
{
  androidAppPackageName="com.delusiongaming.Candy_Words",
   supportedAndroidStores = { "google", "amazon" }
}
      native.showPopup( "rateApp", options )
    end
    windowName = "none"
      transition.to(giftGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=rateApp} )
    end
  end
  return true
end
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
    --           Transition Handlers         --
    ----------------------------------------------------------------------

    --Transition Selected Tab Images Down
    local function transitionSelectedTabs() 
    images.infiniteLivesTabSelected.y = dH*.341+dH
    images.removeAdsTabSelected.y = dH*.341+dH
    images.doubleTimeTabSelected.y = dH*.341+dH
    images.coinTabSelected.y = dH*.341+dH
    images.doubleLivesTabSelected.y = dH*.341+dH
  end

    --Transition Screens Down
    local function transitionExitWindows(event)
      local phase = event.phase
      if ( phase=="began" ) then
        audioFunct.click()
      elseif ( phase == "ended" or event == "boughtItem" ) then
      if event == "boughtItem" then
        audioFunct.click()
      end
        if windowName=="difficultyChooser" then
          transition.to(difficultyChooserGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif windowName == "giftChooser" then
            transition.to(giftGroup, {time=450, y=dH+dH, transition=easing.inBack} )
        elseif windowName=="shopWindow" then
          transitionSelectedTabs() 
          transition.to(staticShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          if shopScreenName=="coinShopWindow" then
            transition.to(coinShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="removeAdsShopWindow" then
            transition.to(removeAdsShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="infiniteLivesShopWindow" then
            transition.to(infiniteLivesShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="doubleTimeShopWindow" then
            transition.to(doubleTimeShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="doubleLivesShopWindow" then
            transition.to(doubleLivesShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          end
        end
        windowName="none"
      end
      return true
    end


    transition.to(tabAds, { time=200, xScale=1.15, yScale=1.15, onComplete=tester  } )
    local function tester()
        transition.to(tabAds, { time=200, xScale=1, yScale=1   } )
      end

    --Transition Windows To Screen
    local function transitionToScreen(event)
      local target = event.target
      local phase = event.phase
      local function shopTransition()
        transitionSelectedTabs() 
        if shopScreenName=="coinShopWindow" then
          coinShopGroup.y=dH+dH
        elseif shopScreenName=="removeAdsShopWindow" then
          removeAdsShopGroup.y=dH+dH
        elseif shopScreenName=="infiniteLivesShopWindow" then
          infiniteLivesShopGroup.y=dH+dH
        elseif shopScreenName=="doubleTimeShopWindow" then
          doubleTimeShopGroup.y=dH+dH
        elseif shopScreenName=="doubleLivesShopWindow" then
          doubleLivesShopGroup.y=dH+dH
        end
      end
      if ( phase=="began" ) then
        audioFunct.click()
      elseif ( phase == "ended") then
             local function rescaleTabSelected()
        transition.to(images.coinTabSelected, { time=200, xScale=1, yScale=1 } )
        transition.to(images.removeAdsTabSelected, { time=200, xScale=1, yScale=1 } )
        transition.to(images.infiniteLivesTabSelected, { time=200, xScale=1, yScale=1 } )
        transition.to(images.doubleTimeTabSelected, { time=200, xScale=1, yScale=1 } )
        transition.to(images.doubleLivesTabSelected, { time=200, xScale=1, yScale=1 } )
    end
        if target==images.playButton and windowName=="none" then
          if firstTimeFileContents == 1 then
          windowName="difficultyChooser"
          transition.to(difficultyChooserGroup, {time=450, y=-dH, transition=easing.outBack} )
        else
          windowName="playFirstTime"
          screenName = "code.playEasyFirst"
          goToLevelChooser()
        end
        elseif target==images.storeButton and windowName=="none" then
          windowName="shopWindow"
          shopScreenName="coinShopWindow"
          transition.to(staticShopGroup, {time=450, y=-dH, transition=easing.outBack} )
          transition.to(coinShopGroup, {time=450, y=-dH, transition=easing.outBack} )
          transition.to(images.coinTabSelected, {time=450, y=dH*.341, transition=easing.outBack} )
        elseif target==images.coinTab and shopScreenName~="coinShopWindow" and windowName=="shopWindow" then
          shopTransition()
          images.coinTabSelected.y = dH*.341
          shopScreenName="coinShopWindow"
          coinShopGroup.y=-dH
          transition.to(images.coinTabSelected, { time=200, xScale=1.15, yScale=1.15, onComplete=rescaleTabSelected  } )
        elseif target==images.removeAdsTab and shopScreenName~="removeAdsShopWindow" and windowName=="shopWindow" then
          shopTransition()
          images.removeAdsTabSelected.y = dH*.341
          shopScreenName="removeAdsShopWindow"
          removeAdsShopGroup.y=-dH
          transition.to(images.removeAdsTabSelected, { time=200, xScale=1.15, yScale=1.15, onComplete=rescaleTabSelected  } )
        elseif target==images.infiniteLivesTab and shopScreenName~="infiniteLivesShopWindow" and windowName=="shopWindow" then
          shopTransition()
          images.infiniteLivesTabSelected.y = dH*.341
          shopScreenName="infiniteLivesShopWindow"
          infiniteLivesShopGroup.y=-dH
          transition.to(images.infiniteLivesTabSelected, { time=200, xScale=1.15, yScale=1.15, onComplete=rescaleTabSelected  } )
        elseif target==images.doubleTimeTab and shopScreenName~="doubleTimeShopWindow" and windowName=="shopWindow" then
          shopTransition()
          images.doubleTimeTabSelected.y = dH*.341
          shopScreenName="doubleTimeShopWindow"
          doubleTimeShopGroup.y=-dH
          transition.to(images.doubleTimeTabSelected, { time=200, xScale=1.15, yScale=1.15, onComplete=rescaleTabSelected  } )
        elseif target==images.doubleLivesTab and shopScreenName~="doubleLivesShopWindow" and windowName=="shopWindow" then
          shopTransition()
          images.doubleLivesTabSelected.y = dH*.341
          shopScreenName="doubleLivesShopWindow"
          doubleLivesShopGroup.y=-dH
          transition.to(images.doubleLivesTabSelected, { time=200, xScale=1.15, yScale=1.15, onComplete=rescaleTabSelected  } )
          elseif target==images.giftButton and windowName=="none" then
          windowName="giftChooser"
          transition.to(giftGroup, {time=450, y=-dH, transition=easing.outBack} )
        end
      end
      return true
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
    --              Store Handler              --
    ----------------------------------------------------------------------
    -- Handle Store Transaction
local function transactionListener( event )
    local transaction = event.transaction
    if ( transaction.isError ) then
    else
if ( transaction.state == "consumed" and transactionType~="remove_ads") then
store.consumePurchase( transactionType )
end
        if ( transaction.state == "purchased" or transaction.state == "restored" ) then
if transactionType=="2_coins" then
coins = coins+2
gameValues[1] = coins
images.actualCoins.text = coins
elseif transactionType=="7_coins" then
coins = coins+7
gameValues[1] = coins
images.actualCoins.text = coins
elseif transactionType=="25_coins" then
coins = coins+25
gameValues[1] = coins
images.actualCoins.text = coins
elseif transactionType=="50_coins" then
coins = coins+50
gameValues[1] = coins
images.actualCoins.text = coins
elseif transactionType=="remove_ads" then
      storeValues[1] = 1
      images.buyRemoveAds.fill.effect = "filter.grayscale"
elseif transactionType=="infinite_1_day" or transactionType=="infinite_3_days" or transactionType=="infinite_1_week" or transactionType=="infinite_2_weeks" then
  local currentTimeStoreTrans = os.date( '*t' )
      currentTimeStoreTrans = os.time(currentTimeStoreTrans)
if transactionType=="infinite_1_day" then
  storeValues[5] = currentTimeStoreTrans + 86400
elseif transactionType=="infinite_3_days" then
storeValues[5] = currentTimeStoreTrans + 259200
elseif transactionType=="infinite_1_week" then
storeValues[5] = currentTimeStoreTrans + 604800
elseif transactionType=="infinite_2_weeks" then
storeValues[5] = currentTimeStoreTrans + 1209600
end
storeValues[2] = 1
      gameValues[2] = 7
      infiniteToFront()
      images.buy1DayInfinite.fill.effect = "filter.grayscale"
    images.buy3DaysInfinite.fill.effect = "filter.grayscale"
    images.buy7DaysInfinite.fill.effect = "filter.grayscale"
    images.buy14DaysInfinite.fill.effect = "filter.grayscale"
    images.buy1DayDoubleLife.fill.effect = "filter.grayscale"
    images.buy3DaysDoubleLife.fill.effect = "filter.grayscale"
    images.buy7DaysDoubleLife.fill.effect = "filter.grayscale" 
    images.buy14DaysDoubleLife.fill.effect = "filter.grayscale"
elseif transactionType=="doubletime_1_day" or transactionType=="doubletime_3_days" or transactionType=="doubletime_1_week" or transactionType=="doubletime_2_weeks" then
  local currentTimeStoreTrans = os.date( '*t' )
      currentTimeStoreTrans = os.time(currentTimeStoreTrans)
if transactionType=="doubletime_1_day" then
storeValues[6] = currentTimeStoreTrans + 86400
elseif transactionType=="doubletime_3_days" then
storeValues[6] = currentTimeStoreTrans + 259200
elseif transactionType=="doubletime_1_week" then
storeValues[6] = currentTimeStoreTrans + 604800
elseif transactionType=="doubletime_2_weeks" then
storeValues[6] = currentTimeStoreTrans + 1209600
end
      storeValues[3] = 1
    images.buy1DayDoubleTime.fill.effect = "filter.grayscale"
    images.buy3DaysDoubleTime.fill.effect = "filter.grayscale"
    images.buy7DaysDoubleTime.fill.effect = "filter.grayscale"
    images.buy14DaysDoubleTime.fill.effect = "filter.grayscale"
 elseif transactionType=="doublelives_1_day" or transactionType=="doublelives_3_days" or transactionType=="doublelives_1_week" or transactionType=="doublelives_2_weeks" then
  local currentTimeStoreTrans = os.date( '*t' )
      currentTimeStoreTrans = os.time(currentTimeStoreTrans)
if transactionType=="doublelives_1_day" then
storeValues[5] = currentTimeStoreTrans + 86400
elseif transactionType=="doublelives_3_days" then
storeValues[5] = currentTimeStoreTrans + 259200
elseif transactionType=="doublelives_1_week" then
storeValues[5] = currentTimeStoreTrans + 604800
elseif transactionType=="doublelives_2_weeks" then
storeValues[5] = currentTimeStoreTrans + 1209600
end
      storeValues[4] = 1
      gameValues[2] = 14
      gameValues[3] = 14
      doubleLivesToFront()
      images.buy1DayInfinite.fill.effect = "filter.grayscale"
    images.buy3DaysInfinite.fill.effect = "filter.grayscale"
    images.buy7DaysInfinite.fill.effect = "filter.grayscale"
    images.buy14DaysInfinite.fill.effect = "filter.grayscale"
    images.buy1DayDoubleLife.fill.effect = "filter.grayscale"
    images.buy3DaysDoubleLife.fill.effect = "filter.grayscale"
    images.buy7DaysDoubleLife.fill.effect = "filter.grayscale" 
    images.buy14DaysDoubleLife.fill.effect = "filter.grayscale"
end
if transactionType~="remove_ads" then
store.consumePurchase( transactionType )
end
if transactionType ~= "none" then
jsonFunct.writeStoreValues(storeValues)
jsonFunct.writeGameValues(gameValues)
        end
        store.finishTransaction( transaction )
        transitionSelectedTabs() 
        transition.to(staticShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          if shopScreenName=="coinShopWindow" then
            transition.to(coinShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="removeAdsShopWindow" then
            transition.to(removeAdsShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="infiniteLivesShopWindow" then
            transition.to(infiniteLivesShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="doubleTimeShopWindow" then
            transition.to(doubleTimeShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          elseif shopScreenName=="doubleLivesShopWindow" then
            transition.to(doubleLivesShopGroup, {time=450, y=dH+dH, transition=easing.inBack} )
          end
          windowName = "none"
        end
    end
end

-- Initialize store
store.init( transactionListener )

--Initial Store Transaction Handler
local function buyButtonSetup(event)
local target = event.target
local phase = event.phase
if ( phase=="began" ) then
        audioFunct.click()
      elseif ( phase == "ended") then
if target==images.buy2Coins then
transactionType="2_coins"
store.purchase( "2_coins" )
elseif target==images.buy7Coins then
transactionType="7_coins"
store.purchase( "7_coins" )
elseif target==images.buy25Coins then
transactionType="25_coins"
store.purchase( "25_coins" )
elseif target==images.buy50Coins then
transactionType="50_coins"
store.purchase( "50_coins" )
elseif target==images.buyRemoveAds then
transactionType="remove_ads"
store.purchase( "remove_ads" )
elseif target==images.restoreAdsButton then
--Secret Consume Purchase Button
  store.consumePurchase( "2_coins" )
  store.consumePurchase( "7_coins" )
  store.consumePurchase( "25_coins" )
  store.consumePurchase( "50_coins" )
  store.consumePurchase( "infinite_1_day" )
  store.consumePurchase( "infinite_3_days" )
  store.consumePurchase( "infinite_1_week" )
  store.consumePurchase( "infinite_2_weeks" )
  store.consumePurchase( "doubletime_1_day" )
  store.consumePurchase( "doubletime_3_days" )
  store.consumePurchase( "doubletime_1_week" )
  store.consumePurchase( "doubletime_2_weeks" )
  store.consumePurchase( "doublelives_1_day" )
  store.consumePurchase( "doublelives_3_days" )
  store.consumePurchase( "doublelives_1_week" )
  store.consumePurchase( "doublelives_2_weeks" )
transactionType="remove_ads"
store.purchase( "remove_ads" )
store.restore()
elseif target==images.buy1DayInfinite and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="infinite_1_day"
store.purchase( "infinite_1_day" )
elseif target==images.buy3DaysInfinite and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="infinite_3_days"
store.purchase( "infinite_3_days" )
elseif target==images.buy7DaysInfinite and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="infinite_1_week"
store.purchase( "infinite_1_week" )
elseif target==images.buy14DaysInfinite and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="infinite_2_weeks"
store.purchase( "infinite_2_weeks" )
elseif target==images.buy1DayDoubleTime and storeValues[3] == 0 then
transactionType="doubletime_1_day"
store.purchase( "doubletime_1_day" )
elseif target==images.buy3DaysDoubleTime and storeValues[3] == 0 then
transactionType="doubletime_3_days"
store.purchase( "doubletime_3_days" )
elseif target==images.buy7DaysDoubleTime and storeValues[3] == 0 then
transactionType="doubletime_1_week"
store.purchase( "doubletime_1_week" )
elseif target==images.buy14DaysDoubleTime and storeValues[3] == 0 then
transactionType="doubletime_2_weeks"
store.purchase( "doubletime_2_weeks" )
elseif target==images.buy1DayDoubleLife and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="doublelives_1_day"
store.purchase( "doublelives_1_day" )
elseif target==images.buy3DaysDoubleLife and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="doublelives_3_days"
store.purchase( "doublelives_3_days" )
elseif target==images.buy7DaysDoubleLife and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="doublelives_1_week"
store.purchase( "doublelives_1_week" )
elseif target==images.buy14DaysDoubleLife and storeValues[2] == 0 and storeValues[4] == 0 then
transactionType="doublelives_2_weeks"
store.purchase( "doublelives_2_weeks" )
  end
end
end

    ----------------------------------------------------------------------
    --              Change Screen              --
    ----------------------------------------------------------------------
    local function changeScreen(event)
      local target = event.target
      local phase = event.phase
      if ( phase=="began" ) then
        audioFunct.click()
      elseif ( phase == "ended" and windowName=="difficultyChooser") then
      screenName="code.levelChooser"
        if target==images.easyChooser then
          diffChooser = 1
        elseif target==images.mediumChooser then
          diffChooser = 2
        elseif target==images.hardChooser then
          diffChooser = 3
        end
        transition.to(difficultyChooserGroup, {time=450, y=dH+dH, transition=easing.inBack, onComplete=goToLevelChooser} )
      end
      return true
    end

    ----------------------------------------------------------------------
    --              Audio Handler              --
    ----------------------------------------------------------------------
    --Start Of Game Music + Sound Handler
    local function startMusicSoundHandler()
      if musicOn==0 then
        images.musicButton.fill.effect = "filter.grayscale"
        audio.setVolume(  0, { channel = 1 } )
      elseif musicOn==1 then
        images.musicButton.fill.effect = ""
        audio.setVolume(  .55, { channel = 1 } )
      end
      if soundOn==0 then
        images.soundButton.fill.effect = "filter.grayscale"
        audio.setVolume(  0, { channel = 2 } )
        audio.setVolume(  0, { channel = 3 } )
        audio.setVolume(  0, { channel = 4 } )
        audio.setVolume(  0, { channel = 5 } )
      elseif soundOn==1 then
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
      if ( phase == "ended" and windowName == "none") then
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
    images.playButton:addEventListener( "touch", transitionToScreen )-- Play Button
    images.storeButton:addEventListener( "touch", transitionToScreen )-- Store Button
    images.giftButton:addEventListener( "touch", transitionToScreen )-- Gift Button
    images.giftsExitButton:addEventListener( "touch", transitionExitWindows )-- Gift Button
    images.rateGift:addEventListener( "touch", rateGameHandler )-- Gift Button
    images.coinTab:addEventListener( "touch", transitionToScreen )-- Coin Store Tab Button
    images.removeAdsTab:addEventListener( "touch", transitionToScreen )-- Remove Ads Store tab Button
    images.infiniteLivesTab:addEventListener( "touch", transitionToScreen )-- Infinite Lives Store Tab Button
    images.doubleTimeTab:addEventListener( "touch", transitionToScreen )-- Double Time Store Tab Button
    images.doubleLivesTab:addEventListener( "touch", transitionToScreen )-- Double Lives Store tab Button
    images.difficultyChooserExitButton:addEventListener( "touch", transitionExitWindows )--Difficulty Chooser Exit Button
    images.shopExitButton:addEventListener( "touch", transitionExitWindows )-- Shop Exit Button
    images.musicButton:addEventListener( "touch", musicSoundHandler )-- Music Button
    images.soundButton:addEventListener( "touch", musicSoundHandler )-- Sound Button
    images.easyChooser:addEventListener( "touch", changeScreen )-- Hard Level Chooser
    images.mediumChooser:addEventListener( "touch", changeScreen )-- Hard Level Chooser
    images.hardChooser:addEventListener( "touch", changeScreen )-- Hard Level Chooser
    images.buy2Coins:addEventListener( "touch", buyButtonSetup )-- Buy 2 Coins
    images.buy7Coins:addEventListener( "touch", buyButtonSetup )-- Buy 7 Coins
    images.buy25Coins:addEventListener( "touch", buyButtonSetup )-- Buy 25 Coins
    images.buy50Coins:addEventListener( "touch", buyButtonSetup )-- Buy 50 Coins
    images.buyRemoveAds:addEventListener( "touch", buyButtonSetup )-- Buy Remove Ads
    images.restoreAdsButton:addEventListener( "touch", buyButtonSetup )-- Buy Remove Ads
    images.buy1DayInfinite:addEventListener( "touch", buyButtonSetup )-- Buy 1 Day Infinite Lives
    images.buy3DaysInfinite:addEventListener( "touch", buyButtonSetup )-- Buy 3 Day Infinite Lives
    images.buy7DaysInfinite:addEventListener( "touch", buyButtonSetup )-- Buy 7 Day Infinite Lives
    images.buy14DaysInfinite:addEventListener( "touch", buyButtonSetup )-- Buy 14 Day Infinite Lives
    images.buy1DayDoubleTime:addEventListener( "touch", buyButtonSetup )-- Buy 1 Day Double Time
    images.buy3DaysDoubleTime:addEventListener( "touch", buyButtonSetup )-- Buy 3 Day Double Time
    images.buy7DaysDoubleTime:addEventListener( "touch", buyButtonSetup )-- Buy 7 Day Double Time
    images.buy14DaysDoubleTime:addEventListener( "touch", buyButtonSetup )-- Buy 14 Day Double Time
    images.buy1DayDoubleLife:addEventListener( "touch", buyButtonSetup )-- Buy 1 Day Double Life
    images.buy3DaysDoubleLife:addEventListener( "touch", buyButtonSetup )-- Buy 3 Day Double Life
    images.buy7DaysDoubleLife:addEventListener( "touch", buyButtonSetup )-- Buy 7 Day Double Life
    images.buy14DaysDoubleLife:addEventListener( "touch", buyButtonSetup )-- Buy 14 Day Double Life



    ----------------------------------------------------------------------
    --        Back Button Handler      --
    ----------------------------------------------------------------------
    function scene:backButton()
      local function onComplete( event )
        if ( event.action == "clicked" ) then
          local i = event.index
          if ( i == 1 ) then
            native.requestExit()
          else
          end
        end
      end
      local alert = native.showAlert( "Exit Candy Words?", "Are you sure you want to exit Candy Words?", { "Yes", "No" }, onComplete )
    end
    
    ----------------------------------------------------------------------
    --              Change Screen            --
    ----------------------------------------------------------------------

  goToLevelChooser  = function ( self, event )
       local options1 =
    {
      effect = "fromBottom",
      time = 750,
    }
    local options2 =
    {
      effect = "fromBottom",
      time = 750,
      params = diffChooser,
    }
    if diffChooser == 0 then
    composer.gotoScene( screenName, options1  )
  else
    composer.gotoScene( screenName, options2  )
  end
    return true
  end

    ----------------------------------------------------------------------
    --              Open Store If Needed            --
    ----------------------------------------------------------------------
    local function storeOpenFunct()
      windowName="shopWindow"
          shopScreenName="coinShopWindow"
          transition.to(staticShopGroup, {time=450, y=-dH, transition=easing.outBack} )
          transition.to(coinShopGroup, {time=450, y=-dH, transition=easing.outBack} )
          transition.to(images.coinTabSelected, {time=450, y=dH*.341, transition=easing.outBack} )
    end

    local storeOpen = event.params
    if storeOpen and storeOpen=="store" then
      storeOpenFunct()
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