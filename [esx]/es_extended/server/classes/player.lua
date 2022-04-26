local Inventory

if Config.OxInventory then
	AddEventHandler('ox_inventory:loadInventory', function(module)
		Inventory = module
	end)
end

function CreateExtendedPlayer(userData)
	local self = {}
	self = userData
	self.privilage = false
	self.name = self.playerName
	self.source = self.playerId
	self.variables = {}
	self.maxWeight = Config.MaxWeight

	ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))

	function self.triggerEvent(eventName, ...)
		TriggerClientEvent(eventName, self.source, ...)
	end

	self.logEvent = function(eventName, ...)
		TriggerEvent(eventName, self.source, ...)
	end

	function self.setCoords(coords)
		self.updateCoords(coords)
		self.triggerEvent('esx:teleport', coords)
	end

	function self.updateCoords(coords)
		self.coords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1), heading = ESX.Math.Round(coords.heading or 0.0, 1)}
	end

	function self.getCoords(vector)
		if vector then
			return vector3(self.coords.x, self.coords.y, self.coords.z)
		else
			return self.coords
		end
	end

	function self.kick(reason)
		DropPlayer(self.source, reason)
	end

	function self.setMoney(money, detail)
		money = ESX.Math.Round(money)
		self.setAccountMoney('money', money, detail)

		if(Config.EssentialMode)then
			TriggerEvent("es:getPlayerFromId", self.source, function(user) user.setMoney(money) end)
		end
	end

	function self.getMoney()
		return self.getAccount('money').money
	end

	function self.addMoney(money, detail)
		money = ESX.Math.Round(money)
		self.addAccountMoney('money', money, detail)

		if(Config.EssentialMode)then
			TriggerEvent("es:getPlayerFromId", self.source, function(user) user.addMoney(money, true) end)
		end
	end

	function self.removeMoney(money, detail)
		money = ESX.Math.Round(money)
		self.removeAccountMoney('money', money, detail)

		if(Config.EssentialMode)then
			TriggerEvent("es:getPlayerFromId", self.source, function(user) user.removeMoney(money, true) end)
		end
	end

	self.getBank = function()
		return self.getAccount('bank').money
	end

	self.removeBank = function(money, detail)
		self.removeAccountMoney('bank', money, detail)
	end

	self.addBank = function(money, detail)
		self.addAccountMoney('bank', money, detail)
	end

	function self.getIdentifier()
		return self.identifier
	end

	function self.setGroup(newGroup)
		ExecuteCommand(('remove_principal identifier.%s group.%s'):format(self.license, self.group))
		self.group = newGroup
		ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))
	end

	function self.getGroup()
		return self.group
	end

	function self.set(k, v)
		self.variables[k] = v
	end

	function self.get(k)
		return self.variables[k]
	end

	self.getAccountBalance = function(accountName)
		local account = self.getAccount(accountName)

		if account then
			return account.money
		else
			return 0
		end
	end

	self.getAccountMoney = self.getAccountBalance

	function self.getAccounts(minimal)
		if minimal then
			local minimalAccounts = {}

			for k,v in ipairs(self.accounts) do
				minimalAccounts[v.name] = v.money
			end

			return minimalAccounts
		else
			return self.accounts
		end
	end

	function self.getAccount(account)
		for k,v in ipairs(self.accounts) do
			if v.name == account then
				return v
			end
		end
	end

	function self.getInventory(minimal)
		if minimal then
			local minimalInventory = {}

			if not Inventory then
				for k, v in ipairs(self.inventory) do
					if v.count > 0 then
						minimalInventory[v.name] = v.count
					end
				end
			else
				for k, v in pairs(self.inventory) do
					if v.count and v.count > 0 then
						local metadata = v.metadata

						if v.metadata and next(v.metadata) == nil then
							metadata = nil
						end

						minimalInventory[#minimalInventory+1] = {
							name = v.name,
							count = v.count,
							slot = k,
							metadata = metadata
						}
					end
				end
			end

			return minimalInventory
		end

		return self.inventory
	end

	function self.getJob()
		return self.job
	end

	function self.getLoadout(minimal)
		if Inventory then return {} end
		if minimal then
			local minimalLoadout = {}

			for k,v in ipairs(self.loadout) do
				minimalLoadout[v.name] = {ammo = v.ammo, quality = v.quality, serial = v.serial}
				if v.tintIndex > 0 then minimalLoadout[v.name].tintIndex = v.tintIndex end

				if #v.components > 0 then
					local components = {}

					for k2,component in ipairs(v.components) do
						if component ~= 'clip_default' then
							components[#components + 1] = component
						end
					end

					if #components > 0 then
						minimalLoadout[v.name].components = components
					end
				end
			end

			return minimalLoadout
		else
			return self.loadout
		end
	end

	function self.getName()
		return self.name
	end

	function self.setName(newName)
		self.name = newName
		TriggerEvent('esx:setName', self.playerId, self.name)
	end

	function self.setAccountMoney(accountName, money, detail)
		if money >= 0 then
			local account = self.getAccount(accountName)

			if account then
				local prevMoney = account.money
				local newMoney = ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
				self.logEvent('log:setAccountMoney', account, prevMoney, detail)

				if Inventory and Inventory.accounts[accountName] then
					Inventory.SetItem(self.source, accountName, money)
				end
				return newMoney
			end
		end
	end

	function self.addAccountMoney(accountName, money, detail)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money + ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
				self.logEvent('log:addAccountMoney', account, money, detail)

				if Inventory and Inventory.accounts[accountName] then
					Inventory.AddItem(self.source, accountName, money)
				end
				return newMoney
			end
		end
	end

	function self.removeAccountMoney(accountName, money, detail)
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = account.money - ESX.Math.Round(money)
				account.money = newMoney

				self.triggerEvent('esx:setAccountMoney', account)
				self.logEvent('log:removeAccountMoney', account, money, detail)

				if Inventory and Inventory.accounts[accountName] then
					Inventory.RemoveItem(self.source, accountName, money)
				end
				return newMoney
			end
		end
	end

	function self.getInventoryItem(name, metadata)
		local found = false
		local newItem

		if Inventory then
			return Inventory.GetItem(self.source, name, metadata)
		end

		for k,v in ipairs(self.inventory) do
			if v.name == name then
				found = true
				return v
			end
		end

		-- Ran only if the item wasn't found in your inventory
		local item = ESX.Items[name]

		-- if item exists -> run
		if(item)then
			-- Create new item
			newItem = {}
			for key,val in pairs(item) do
				newItem[key] = val
			end
			newItem.count = 0
			newItem.batch = {}
			newItem.batchCount = 0
			newItem.usable = Core.UsableItemsCallbacks[name] ~= nil

			-- Insert into players inventory
			table.insert(self.inventory, newItem)

			-- Return the item that was just added
			return newItem
		end
	end

	function self.addInventoryItem(name, count, metadata, slot)
		if Inventory then
			return Inventory.AddItem(self.source, name, count or 1, metadata, slot)
		end

		local item = self.getInventoryItem(name)

		if item then
			local itemBatch = metadata
			count = ESX.Math.Round(count)
			item.count = item.count + count
			if not itemBatch and ESX.Items[name].batch then
				itemBatch = ESX.Table.Clone(ESX.Items[name].batch)
			end
			if itemBatch then
				if not itemBatch.batch then
					itemBatch.batch = ESX.GetBatch()
				end
				if item.batch[itemBatch.batch] then
					item.batch[itemBatch.batch].count = item.batch[itemBatch.batch].count + count
				else
					if itemBatch.lifetime and not itemBatch.expiredtime then
						itemBatch.expiredtime = os.time() + itemBatch.lifetime
					end
					item.batch[itemBatch.batch] = {count = count, info = itemBatch}
				end
				item.batchCount = item.batchCount + count
			end

			if item.weapon then
				self.weight = self.weight + item.weight + (count * item.ammo_weight)
			else
				self.weight = self.weight + (item.weight * count)
			end

			TriggerEvent('esx:onAddInventoryItem', self.source, item.name, item.count, item.batch)
			self.triggerEvent('esx:addInventoryItem', item.name, item.count, false, item)
		end
	end

	function self.removeInventoryItem(name, count, metadata, slot)
		if Inventory then
			return Inventory.RemoveItem(self.source, name, count or 1, metadata, slot)
		end

		local item = self.getInventoryItem(name)

		if item then
			count = ESX.Math.Round(count)
			local newCount = item.count - count

			if newCount >= 0 then
				local batchNumber = metadata
				item.count = newCount
				batchNumber = not batchNumber and self.get('removeBatch') or batchNumber
				if batchNumber and item.batch[batchNumber] then
					local batchCount = item.batch[batchNumber].count - count
					if batchCount > 0 then
						item.batch[batchNumber].count = batchCount
					else
						item.batch[batchNumber] = false
					end
					item.batchCount = item.batchCount - count
				end

				if newCount == 0 then
					item.batch = {}
					item.batchCount = 0
				end

				if item.weapon then
					self.weight = self.weight - item.weight - (count * item.ammo_weight)
				else
					self.weight = self.weight - (item.weight * count)
				end

				TriggerEvent('esx:onRemoveInventoryItem', self.source, item.name, item.count, batchNumber)
				self.triggerEvent('esx:removeInventoryItem', item.name, item.count, false, item.batch)
			end
		end
	end

	function self.setInventoryItem(name, count, metadata)
		if Inventory then
			return Inventory.SetItem(self.source, name, count, metadata)
		end

		local item = self.getInventoryItem(name)

		if item and count >= 0 then
			count = ESX.Math.Round(count)

			if count > item.count then
				self.addInventoryItem(item.name, count - item.count)
			else
				self.removeInventoryItem(item.name, item.count - count)
			end
		end
	end

	function self.getWeight()
		return self.weight
	end

	function self.getMaxWeight()
		return self.maxWeight
	end

	function self.canCarryItem(items, count, metadata)
		if Inventory then
			return Inventory.CanCarryItem(self.source, items, count, metadata)
		end

		if type(items) ~= 'table' then
			items = {[items] = count}
		end
		local currentWeight = self.weight
		for name,count in pairs(items) do
			if ESX.Items[name].limit and ESX.Items[name].limit ~= -1 then
				if count > ESX.Items[name].limit then
					return false
				elseif (self.getInventoryItem(name).count + count) > ESX.Items[name].limit then
					return false
				end
			end
			currentWeight = currentWeight+(ESX.Items[name].weight*count)
		end

		return currentWeight <= self.maxWeight
	end

	function self.canSwapItem(oldItems, newItems, testItem, testItemCount)
		if Inventory then
			return Inventory.CanSwapItem(self.source, oldItems, newItems, testItem, testItemCount)
		end

		if type(oldItems) ~= 'table' then
			oldItems = {[oldItems] = newItems}
			newItems = {[testItem] = testItemCount}
		end

		local weightWithoutFirstItem, weightChangeItems = self.weight, 0
		for name,count in pairs(newItems) do
			local item = self.getInventoryItem(name)
			if ESX.Items[name].limit and ESX.Items[name].limit ~= -1 and item.count + count > ESX.Items[name].limit then
				return false
			end
			weightChangeItems = weightChangeItems + (item.weight * count)
		end

		for name,count in pairs(oldItems) do
			local item = self.getInventoryItem(name)
			if item.count >= count then				
				weightWithoutFirstItem = weightWithoutFirstItem - (item.weight * count)
			else
				return false
			end
		end

		local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + weightChangeItems)
		return weightWithTestItem <= self.maxWeight
	end

	self.swapItem = function(removeItems, addItems)
		if type(removeItems) ~= 'table' then removeItems = {[removeItems] = 1} end
		if type(addItems) ~= 'table' then addItems = {[addItems] = 1} end
		if self.canSwapItem(removeItems, addItems) then
			for name,count in pairs(removeItems) do
				self.removeInventoryItem(name, count)
			end
			for name,count in pairs(addItems) do
				self.addInventoryItem(name, count)
			end
			return true
		end
		return false
	end

	function self.setMaxWeight(newWeight)
		self.maxWeight = newWeight
		self.triggerEvent('esx:setMaxWeight', self.maxWeight)

		if Inventory then
			return Inventory.Set(self.source, 'maxWeight', newWeight)
		end
	end

    function self.setDuty(bool)
        self.job.onDuty = bool
        self.triggerEvent('esx:setJob', self.job)
    end

	function self.setJob(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.job))

		if ESX.DoesJobExist(job, grade) then
			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

			self.job.id    = jobObject.id
			self.job.name  = jobObject.name
			self.job.label = jobObject.label

			self.job.grade        = tonumber(grade)
			self.job.grade_name   = gradeObject.name
			self.job.grade_label  = gradeObject.label
			self.job.grade_salary = gradeObject.salary
            self.job.onDuty = Config.OnDuty

			if gradeObject.skin_male then
				self.job.skin_male = json.decode(gradeObject.skin_male)
			else
				self.job.skin_male = {}
			end

			if gradeObject.skin_female then
				self.job.skin_female = json.decode(gradeObject.skin_female)
			else
				self.job.skin_female = {}
			end

			TriggerEvent('esx:setJob', self.source, self.job, lastJob)
			self.triggerEvent('esx:setJob', self.job)
		else
			print(('[es_extended] [^3WARNING^7] Ignoring invalid .setJob() usage for "%s"'):format(self.identifier))
		end
	end

	function self.addWeapon(weaponName, ammo, itemInfo)
		if Inventory then return end

		if not self.hasWeapon(weaponName) then
			local weaponLabel = ESX.GetWeaponLabel(weaponName)
			local quality = itemInfo and itemInfo.quality or 100
			local serial = itemInfo and itemInfo.serial or ESX.RandomString(8)

			table.insert(self.loadout, {
				name = weaponName,
				ammo = ammo,
				quality = quality,
				batch = serial,
				serial = serial,
				label = weaponLabel,
				components = {},
				tintIndex = 0
			})

			self.triggerEvent('esx:addWeapon', weaponName, ammo)
			self.triggerEvent('esx:addInventoryItem', weaponLabel, false, true)

			local item = self.getInventoryItem(weaponName)
			if item then
				self.weight = self.weight + item.weight + (ammo * item.ammo_weight)
			end
		else
			itemInfo.weapon = weaponName
			itemInfo.count = ammo
			self.addInventoryItem(weaponName, ammo, itemInfo)
		end
	end

	function self.addWeaponComponent(weaponName, weaponComponent)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if not self.hasWeaponComponent(weaponName, weaponComponent) then
					self.loadout[loadoutNum].components[#self.loadout[loadoutNum].components + 1] = weaponComponent
					self.triggerEvent('esx:addWeaponComponent', weaponName, weaponComponent)
					self.triggerEvent('esx:addInventoryItem', component.label, false, true)
				end
			end
		end
	end

	function self.addWeaponAmmo(weaponName, ammoCount)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo + ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	function self.updateWeaponAmmo(weaponName, ammoCount)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			if ammoCount < weapon.ammo then
				weapon.ammo = ammoCount
			end
		end
	end

	self.updateWeaponQuality = function(weaponName, quality)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.quality = quality
		end
	end

	function self.setWeaponTint(weaponName, weaponTintIndex)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local weaponNum, weaponObject = ESX.GetWeapon(weaponName)

			if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
				self.loadout[loadoutNum].tintIndex = weaponTintIndex
				self.triggerEvent('esx:setWeaponTint', weaponName, weaponTintIndex)
				self.triggerEvent('esx:addInventoryItem', weaponObject.tints[weaponTintIndex], false, true)
			end
		end
	end

	function self.getWeaponTint(weaponName)
		if Inventory then return 0 end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			return weapon.tintIndex
		end

		return 0
	end

	function self.removeWeapon(weaponName, ammo)
		if Inventory then return end

		local weaponLabel

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				weaponLabel = v.label

				for k2,v2 in ipairs(v.components) do
					self.removeWeaponComponent(weaponName, v2)
				end

				table.remove(self.loadout, k)
				break
			end
		end

		if weaponLabel then
			self.triggerEvent('esx:removeWeapon', weaponName, ammo)
			self.triggerEvent('esx:removeInventoryItem', weaponLabel, false, true)
		end
	end

	function self.removeWeaponComponent(weaponName, weaponComponent)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if self.hasWeaponComponent(weaponName, weaponComponent) then
					for k,v in ipairs(self.loadout[loadoutNum].components) do
						if v == weaponComponent then
							table.remove(self.loadout[loadoutNum].components, k)
							break
						end
					end

					self.triggerEvent('esx:removeWeaponComponent', weaponName, weaponComponent)
					self.triggerEvent('esx:removeInventoryItem', component.label, false, true)
				end
			end
		end
	end

	function self.removeWeaponAmmo(weaponName, ammoCount)
		if Inventory then return end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo - ammoCount
			self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	function self.hasWeaponComponent(weaponName, weaponComponent)
		if Inventory then return false end

		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			for k,v in ipairs(weapon.components) do
				if v == weaponComponent then
					return true
				end
			end

			return false
		else
			return false
		end
	end

	function self.hasWeapon(weaponName)
		if Inventory then return false end

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return true
			end
		end

		return false
	end

	function self.hasItem(item, metadata)
		if Inventory then
			return Inventory.GetItem(self.source, name, metadata)
		end

		for k,v in ipairs(self.inventory) do
			if (v.name == name) and (v.count >= 1) then
				return v, v.count
			end
		end

		return false
	end


	function self.getWeapon(weaponName)
		if Inventory then return end

		for k,v in ipairs(self.loadout) do
			if v.name == weaponName then
				return k, v
			end
		end
	end

	function self.showNotification(msg, flash, saveToBrief, hudColorIndex)
		self.triggerEvent('esx:showNotification', msg, flash, saveToBrief, hudColorIndex)
	end

	function self.showHelpNotification(msg, thisFrame, beep, duration)
		self.triggerEvent('esx:showHelpNotification', msg, thisFrame, beep, duration)
	end

	self.showAdvancedNotification = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex) self.triggerEvent('esx:showAdvancedNotification', sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex) end
	self.save = function(cb) ESX.SavePlayer(self, cb) end

	self.isAceAllowed = function(object) return IsPlayerAceAllowed(self.playerId, object) end

	self.getHealth = function() return self.health end
	self.getArmour = function() return self.armour end
	self.setArmour = function(newArmour)
		self.armour = newArmour
		self.triggerEvent('esx:setArmour', self.armour)
	end	
	self.updateHealth = function(_health, _armour)
		self.health = _health
		self.armour = _armour
	end

	self.setSkin = function(newSkin) self.skin = newSkin end
	self.getSkin = function() return self.skin end
	self.getStatus = function() return self.status end
	self.setStatus = function(newStatus) self.status = newStatus end
	self.getPhoneNumber = function() return self.phoneNumber end

	if Inventory then
		self.syncInventory = function(weight, maxWeight, items, money)
			self.weight, self.maxWeight = weight, maxWeight
			self.inventory = items

			if money then
				for k, v in pairs(money) do
					local account = self.getAccount(k)
					if ESX.Math.Round(account.money) ~= v then
						account.money = v
						self.triggerEvent('esx:setAccountMoney', account)
					end
				end
			end
		end
	end

	return self
end
