if string.sub(system.getInfo("model"),1,4) == "iPad" then
application =
{
    license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvwT8EX4zFJ0w9y2WJiKKWdy6M9AmUOhnNz/8X/x40taRVkOsLc2FbFVw7LYP5QSxhrawwwLIPO8CbMKtR2uOkJGwYBtLe8eZY9a+ium1hEdW/rzdiNpU+t04SITZYOdBgOnocg4Z0XiaMRpD+zDQoSTAxAN0fhz6VP4RyXOul/JRRhxYzEz3LFFZgkNorm6+fpz6FZkd3Lv7U+xyeWkkP48YfALIkcm4eQbMVeb8f+yoNCh9ZeG4/P3YT0q3h4aXyxQfcEX47Xd2XUQ3DCqU9kojELv3Eb7bMSS/fbI9s0G98ZmQNWiGdcOfbdiRH2IIrO5ugucf3bH969oTShIhwIDAQAB",
        },
    },
        content =
        {
            width = 360,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
application =
{
    license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvwT8EX4zFJ0w9y2WJiKKWdy6M9AmUOhnNz/8X/x40taRVkOsLc2FbFVw7LYP5QSxhrawwwLIPO8CbMKtR2uOkJGwYBtLe8eZY9a+ium1hEdW/rzdiNpU+t04SITZYOdBgOnocg4Z0XiaMRpD+zDQoSTAxAN0fhz6VP4RyXOul/JRRhxYzEz3LFFZgkNorm6+fpz6FZkd3Lv7U+xyeWkkP48YfALIkcm4eQbMVeb8f+yoNCh9ZeG4/P3YT0q3h4aXyxQfcEX47Xd2XUQ3DCqU9kojELv3Eb7bMSS/fbI9s0G98ZmQNWiGdcOfbdiRH2IIrO5ugucf3bH969oTShIhwIDAQAB",
        },
    },
        content =
        {
            width = 320,
            height = 568,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" then
application =
{
    license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvwT8EX4zFJ0w9y2WJiKKWdy6M9AmUOhnNz/8X/x40taRVkOsLc2FbFVw7LYP5QSxhrawwwLIPO8CbMKtR2uOkJGwYBtLe8eZY9a+ium1hEdW/rzdiNpU+t04SITZYOdBgOnocg4Z0XiaMRpD+zDQoSTAxAN0fhz6VP4RyXOul/JRRhxYzEz3LFFZgkNorm6+fpz6FZkd3Lv7U+xyeWkkP48YfALIkcm4eQbMVeb8f+yoNCh9ZeG4/P3YT0q3h4aXyxQfcEX47Xd2XUQ3DCqU9kojELv3Eb7bMSS/fbI9s0G98ZmQNWiGdcOfbdiRH2IIrO5ugucf3bH969oTShIhwIDAQAB",
        },
    },
        content =
        {
            width = 320,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
elseif display.pixelHeight / display.pixelWidth > 1.72 then
application =
{
    license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvwT8EX4zFJ0w9y2WJiKKWdy6M9AmUOhnNz/8X/x40taRVkOsLc2FbFVw7LYP5QSxhrawwwLIPO8CbMKtR2uOkJGwYBtLe8eZY9a+ium1hEdW/rzdiNpU+t04SITZYOdBgOnocg4Z0XiaMRpD+zDQoSTAxAN0fhz6VP4RyXOul/JRRhxYzEz3LFFZgkNorm6+fpz6FZkd3Lv7U+xyeWkkP48YfALIkcm4eQbMVeb8f+yoNCh9ZeG4/P3YT0q3h4aXyxQfcEX47Xd2XUQ3DCqU9kojELv3Eb7bMSS/fbI9s0G98ZmQNWiGdcOfbdiRH2IIrO5ugucf3bH969oTShIhwIDAQAB",
        },
    },
        content =
        {
            width = 320,
            height = 570,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
    }
else
application =
{
    license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvwT8EX4zFJ0w9y2WJiKKWdy6M9AmUOhnNz/8X/x40taRVkOsLc2FbFVw7LYP5QSxhrawwwLIPO8CbMKtR2uOkJGwYBtLe8eZY9a+ium1hEdW/rzdiNpU+t04SITZYOdBgOnocg4Z0XiaMRpD+zDQoSTAxAN0fhz6VP4RyXOul/JRRhxYzEz3LFFZgkNorm6+fpz6FZkd3Lv7U+xyeWkkP48YfALIkcm4eQbMVeb8f+yoNCh9ZeG4/P3YT0q3h4aXyxQfcEX47Xd2XUQ3DCqU9kojELv3Eb7bMSS/fbI9s0G98ZmQNWiGdcOfbdiRH2IIrO5ugucf3bH969oTShIhwIDAQAB",
        },
    },
        content =
        {
            width = 320,
            height = 512,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
end



--OLD INO
		--[[
application =
{
    license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvwT8EX4zFJ0w9y2WJiKKWdy6M9AmUOhnNz/8X/x40taRVkOsLc2FbFVw7LYP5QSxhrawwwLIPO8CbMKtR2uOkJGwYBtLe8eZY9a+ium1hEdW/rzdiNpU+t04SITZYOdBgOnocg4Z0XiaMRpD+zDQoSTAxAN0fhz6VP4RyXOul/JRRhxYzEz3LFFZgkNorm6+fpz6FZkd3Lv7U+xyeWkkP48YfALIkcm4eQbMVeb8f+yoNCh9ZeG4/P3YT0q3h4aXyxQfcEX47Xd2XUQ3DCqU9kojELv3Eb7bMSS/fbI9s0G98ZmQNWiGdcOfbdiRH2IIrO5ugucf3bH969oTShIhwIDAQAB",
        },
    },
	content =
	{

		width = 320,
		height = 480, 
		scale = "adaptive",
		fps = 60
		
         THIS PART IS USUALLY COMMENTED OUT FROM BELOW
		 
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		
		UNTIL HERE
		
	},
}
		--]]
--IphoneX Test Info
--		width = 360,
--		height = 640, 
--		scale = "letterbox",
--		xAlign = "center",
  --      yAlign = "center",
--		fps = 60