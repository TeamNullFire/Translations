-- worst code ever. but it works


local gamin = getgenv().nullfireloadergivemethegameiminpls or "Doors" -- default to doors for no good reason
getgenv().nullfireloadergivemethegameiminpls = gamin

local translate = {}
translate.base = "https://raw.githubusercontent.com/TeamNullFire/Translations/refs/heads/main/"..gamin.."/"
translate.CurLang = "English"
translate.LangSave = {}
translate.baseFolder = "NullFire/Translations/"..gamin.."/"

local https = game:GetService("HttpService")
local plrs = game:GetService("Players")
getgenv = getfenv().getgenv or getfenv

local function trytogetda(url: string, lang: string?)
	local data = game:HttpGet(url)

	if not data then
		warn("[NF - translate] | Error: failed to get data")
		return nil
	end

	if lang then
		pcall(writefile, translate.baseFolder..lang.."_"..tostring(translate.version[lang])..".json", data)
	end

	local ok, result = pcall(function()
		return https:JSONDecode(data)
	end)
	if ok then
		return result
	else
		warn("[NF - translate] | Error: "..result)
		return nil
	end
end

translate.langs = trytogetda(translate.base.."langs.json") or {"English"}
translate.version = trytogetda(translate.base.."ver.json")

function translate:loadlang(lang: string)
	if self.LangSave[lang] then
		return self.LangSave[lang]
	end

	local success, filedata = pcall(readfile, translate.baseFolder..lang.."_"..tostring(translate.version[lang])..".json")
	if success and filedata then
		local ok, result = pcall(function()
			return https:JSONDecode(filedata)
		end)
		if ok then
			return result
		else
			warn("[NF - translate] | Error: "..result)
			return nil
		end
	end

	local data = trytogetda(self.base..lang..".json", lang)
	if data then
		self.LangSave[lang] = data
		return data
	else
		return nil
	end
end

function translate:gettransl(key: string, lang: string?)
	lang = lang or self.CurLang
	local langData = self:loadlang(lang)

	if langData and langData[key] then
		return langData[key]
	end

	local english = self:loadlang("English")
	if english and english[key] then
		return english[key]
	end

	return key
end

function translate:ihope()
	local lang = self.CurLang
	local langData = self:loadlang(lang)
	if not langData then
		warn("[NF - translate] what: "..lang)
		return
	end

	for thingname, option in pairs(getgenv().Options or {}) do
		pcall(function()
			local transl = self:gettransl(thingname, lang)
			if transl == thingname then -- prevent obsidian config name from changing for now
				return
			end
			option:SetText(transl)
		end)
	end

	for thingname, toggle in pairs(getgenv().Toggles or {}) do
		toggle:SetText(self:gettransl(thingname, lang))
	end
end

function translate:setlang(lang: string)
	if not table.find(self.langs, lang) then
		warn("[NF - translate] this language dont exist: "..lang)
		return self.CurLang
	end

	if not self:loadlang(lang) then
		warn("[NF - translate] failed to load :( : "..lang)
		return self.CurLang
	end

	self.CurLang = lang
	pcall(writefile, translate.baseFolder.."lang.null", lang)
	self:ihope()

	return lang
end

function translate:init()
	if isfolder then
		if not isfolder("NullFire") then
			makefolder("NullFire")
		end

		if not isfolder("NullFire/Translations") then
			makefolder("NullFire/Translations")
		end

		if not isfolder("NullFire/Translations/"..gamin) then
			makefolder("NullFire/Translations/"..gamin)
		end
	end

	local success, lang = pcall(function()
		return readfile(translate.baseFolder.."lang.null")
	end)
	if success and lang then
		lang = lang:match("^%s*(.-)%s*$")
	end
	
	translate.thefounddefault = lang or "English"

	for _,v in pairs(listfiles(translate.baseFolder)) do
		if string.find(v, "lang") then continue end

		local parts = string.split(v, "/")

		local name, ver = string.match(parts[#parts], "([^_]+)_([%d%.]+)%.json")

		if name and ver and ver ~= translate.version[name] then
			pcall(delfile, v)

			repeat task.wait() until not isfile(v) -- i think there was an exec that used a queue system if i remember correctly so just for safety
			
			if name == lang then
				self:loadlang(lang) -- technically not needed but good to have i think
			end
		end
	end

	if success and lang then
		self:setlang(lang)
	else
		self:setlang("English")
	end
end

--translate:init() -- this was for testing but to lazy to delete

return translate