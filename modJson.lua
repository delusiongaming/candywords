-- =============================================================
-- Copyright 2018, Andrew Baronick, All rights reserved.
-- =============================================================
-- modJson.lua
-- =============================================================

----------------------------------------------------------------------
--								Variables							--
----------------------------------------------------------------------
local file
local firstTimeFilePath = system.pathForFile( "data.json", system.DocumentsDirectory )
local gameValuesPath = system.pathForFile( "gameFiles.json", system.DocumentsDirectory )
local currentLevelValuesPath = system.pathForFile( "currentLevel.json", system.DocumentsDirectory )
local easyStatsValuesPath = system.pathForFile( "easyStats.json", system.DocumentsDirectory )
local mediumStatsValuesPath = system.pathForFile( "mediumStats.json", system.DocumentsDirectory )
local hardStatsValuesPath = system.pathForFile( "hardStats.json", system.DocumentsDirectory )
local storeValuesPath = system.pathForFile( "storeData.json", system.DocumentsDirectory )
local easyWordsFilePath = system.pathForFile( "levels/easyWords.json", system.ResourceDirectory )
local easyLettersFilePath = system.pathForFile( "levels/easyLetters.json", system.ResourceDirectory )
local easyWordsHintFilePath = system.pathForFile( "levels/easyWordsHint.json", system.ResourceDirectory )
local easyAnswerLettersFilePath = system.pathForFile( "levels/easyAnswerLetters.json", system.ResourceDirectory )
local mediumWordsFilePath = system.pathForFile( "levels/mediumWords.json", system.ResourceDirectory )
local mediumLettersFilePath = system.pathForFile( "levels/mediumLetters.json", system.ResourceDirectory )
local mediumWordsHintFilePath = system.pathForFile( "levels/mediumWordsHint.json", system.ResourceDirectory )
local mediumAnswerLettersFilePath = system.pathForFile( "levels/mediumAnswerLetters.json", system.ResourceDirectory )
local hardWordsFilePath = system.pathForFile( "levels/hardWords.json", system.ResourceDirectory )
local hardLettersFilePath = system.pathForFile( "levels/hardLetters.json", system.ResourceDirectory )
local hardWordsHintFilePath = system.pathForFile( "levels/hardWordsHint.json", system.ResourceDirectory )
local hardAnswerLettersFilePath = system.pathForFile( "levels/hardAnswerLetters.json", system.ResourceDirectory )
local lifeRegenerationValuesPath = system.pathForFile( "liveRegeneration.json", system.DocumentsDirectory )
----------------------------------------------------------------------
--								  Mods    							--
----------------------------------------------------------------------
-- Json Mods
local json = require( "json" )
local jsonFunct = {}

--Json Write Mod
function jsonFunct.write(filePath, fileContents)
  file = io.open(filePath, "w")
  if file then
    file:write(json.encode(fileContents))
  end
  io.close(file)
end

--Write Files Mods
--Write Game Values
function jsonFunct.writeFirstTimeValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(firstTimeFilePath, fileValues)
end
function jsonFunct.writeGameValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(gameValuesPath, fileValues)
end
--Write Current Level Values
function jsonFunct.writeCurrentLevelValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(currentLevelValuesPath, fileValues)
end
--Write Easy Stats Values
function jsonFunct.writeEasyStatsValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(easyStatsValuesPath, fileValues)
end
--Write Medium Stats Values
function jsonFunct.writeMediumStatsValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(mediumStatsValuesPath, fileValues)
end
--Write Hard Stats Values
function jsonFunct.writeHardStatsValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(hardStatsValuesPath, fileValues)
end
--Write Store Values
function jsonFunct.writeStoreValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(storeValuesPath, fileValues)
end
--Write Store Values
function jsonFunct.writeLifeRegenerationValues(fileValues)
  fileValues=fileValues
  jsonFunct.write(lifeRegenerationValuesPath, fileValues)
end

--Json Read Mod
function jsonFunct.read(filePath)
  file = io.open(filePath, "r")
  if file then
    contents = file:read( "*a" )
    io.close(file)
    return contents
  end
end

--Read Files Mods
--Read Game Values
function jsonFunct.readFirstTimeOpenValue()
  local firstTimeFileContents
local firstTimeFile = io.open( firstTimeFilePath, "r")
if firstTimeFile then
  local contents = firstTimeFile:read( "*a" )
  io.close( firstTimeFile )
  firstTimeFileContents = json.decode( contents )
end
  return firstTimeFileContents
end

function jsonFunct.readGameValues()
  local jsonResult=json.decode(jsonFunct.read(gameValuesPath))
  return jsonResult
end
--Read Current Level Values
function jsonFunct.readCurrentLevelValues()
  local jsonResult=json.decode(jsonFunct.read(currentLevelValuesPath))
  return jsonResult
end
--Read Easy Stats Values
function jsonFunct.readEasyStatsValues()
  local jsonResult=json.decode(jsonFunct.read(easyStatsValuesPath))
  return jsonResult
end
--Read Medium Stats Values
function jsonFunct.readMediumStatsValues()
  local jsonResult=json.decode(jsonFunct.read(mediumStatsValuesPath))
  return jsonResult
end
--Read Hard Stats Values
function jsonFunct.readHardStatsValues()
  local jsonResult=json.decode(jsonFunct.read(hardStatsValuesPath))
  return jsonResult
end
--Read Store Values
function jsonFunct.readStoreValues()
  local jsonResult=json.decode(jsonFunct.read(storeValuesPath))
  return jsonResult
end
  --Read Easy Words
function jsonFunct.readEasyWords()
  local jsonResult=json.decode(jsonFunct.read(easyWordsFilePath))
  return jsonResult
end
  --Read Easy Letters
function jsonFunct.readEasyLetters()
  local jsonResult=json.decode(jsonFunct.read(easyLettersFilePath))
  return jsonResult
end
  --Read Easy Word Hints
function jsonFunct.readEasyWordsHints()
  local jsonResult=json.decode(jsonFunct.read(easyWordsHintFilePath))
  return jsonResult
end
  --Read Easy Letter Hints
function jsonFunct.readEasyAnswerLetters()
  local jsonResult=json.decode(jsonFunct.read(easyAnswerLettersFilePath))
  return jsonResult
end
  --Read Medium Words
function jsonFunct.readMediumWords()
  local jsonResult=json.decode(jsonFunct.read(mediumWordsFilePath))
  return jsonResult
end
  --Read Medium Letters
function jsonFunct.readMediumLetters()
  local jsonResult=json.decode(jsonFunct.read(mediumLettersFilePath))
  return jsonResult
end
  --Read Medium Word Hints
function jsonFunct.readMediumWordsHints()
  local jsonResult=json.decode(jsonFunct.read(mediumWordsHintFilePath))
  return jsonResult
end
  --Read Medium Letter Hints
function jsonFunct.readMediumAnswerLetters()
  local jsonResult=json.decode(jsonFunct.read(mediumAnswerLettersFilePath))
  return jsonResult
end
  --Read Hard Words
function jsonFunct.readHardWords()
  local jsonResult=json.decode(jsonFunct.read(hardWordsFilePath))
  return jsonResult
end
  --Read Hard Letters
function jsonFunct.readHardLetters()
  local jsonResult=json.decode(jsonFunct.read(hardLettersFilePath))
  return jsonResult
end
  --Read Hard Word Hints
function jsonFunct.readHardWordsHints()
  local jsonResult=json.decode(jsonFunct.read(hardWordsHintFilePath))
  return jsonResult
end
  --Read Hard Letter Hints
function jsonFunct.readHardAnswerLetters()
  local jsonResult=json.decode(jsonFunct.read(hardAnswerLettersFilePath))
  return jsonResult
end
  --Read Life Regeneration Values
function jsonFunct.readLifeRegeneration()
  local jsonResult=json.decode(jsonFunct.read(lifeRegenerationValuesPath))
  return jsonResult
end

return jsonFunct