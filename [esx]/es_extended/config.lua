Config = {}
Config.Locale = 'en'

Config.Accounts = {
	bank = _U('account_bank'),
	black_money = _U('account_black_money'),
	money = _U('account_money')
}

Config.FirstSpawnCoords		= {
	-- 1140
	{x = 78.53, y = -58.06, z = 76.14, heading = 68.49},
	{x = 75.89, y = -61.58, z = 76.14, heading = 341.99},
	{x = 78.77, y = -58.19, z = 72.14, heading = 62.94},
	{x = 76.12, y = -61.44, z = 72.14, heading = 341.10},
	
	-- 1141
	{x = 69.00, y = -57.69, z = 73.02, heading = 157.02},
	{x = 61.69, y = -54.36, z = 73.02, heading = 158.28},
	{x = 61.95, y = -54.26, z = 77.02, heading = 161.15},
	{x = 69.41, y = -57.21, z = 77.02, heading = 156.44},
	{x = 69.25, y = -57.63, z = 68.82, heading = 155.64},
	
	-- 1142
	{x = 48.47, y = -31.64, z = 73.68, heading = 63.60},
	{x = 46.47, y = -28.44, z = 73.68, heading = 76.45},
	
	-- 1143
	{x = 54.37, y = -66.84, z = 67.63, heading = 246.42},
	{x = 51.67, y = -74.23, z = 67.63, heading = 250.04},
	{x = 52.37, y = -74.50, z = 63.44, heading = 239.71},
	{x = 48.77, y = -84.81, z = 69.76, heading = 252.02},
	{x = 45.59, y = -92.33, z = 69.76, heading = 246.37},
	{x = 48.23, y = -84.43, z = 65.76, heading = 245.55},
	{x = 45.69, y = -92.13, z = 65.76, heading = 256.08},
	{x = 49.41, y = -84.99, z = 61.56, heading = 245.17},
	
	-- 1144
	{x = 63.69, y = -79.94, z = 62.51, heading = 69.59},
	{x = 67.14, y = -73.15, z = 66.70, heading = 70.77},
	{x = 64.47, y = -80.42, z = 66.70, heading = 71.87},
	
	-- 1145
	{x = 57.69, y = -98.27, z = 58.20, heading = 78.55},
	{x = 61.37, y = -90.85, z = 58.21, heading = 70.42},
}

Config.StartingAccountMoney 	= {bank = 50000}

Config.EnableSocietyPayouts 	= false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.EnableHud            	= true -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.MaxWeight            	= 24   -- the max inventory weight without backpack
Config.PaycheckInterval         = 7 * 60000 -- how often to recieve pay checks in milliseconds
Config.EnableDebug              = false -- Use Debug options?
Config.EnableDefaultInventory   = true -- Display the default Inventory ( F2 )
Config.EnableWantedLevel    	= false -- Use Normal GTA wanted Level?
Config.EnablePVP                = true -- Allow Player to player combat

Config.Multichar                = true -- Enable support for esx_multicharacter
Config.Identity                 = true -- Select a characters identity data before they have loaded in (this happens by default with multichar)
