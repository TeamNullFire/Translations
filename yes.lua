local alldata = {}

for thingname, option in pairs(getgenv().Options or {}) do
    alldata[thingname] = option.Text
end

for thingname, toggle in pairs(getgenv().Toggles or {}) do
    alldata[thingname] = toggle.Text
end

writefile("exported.json", game:GetService("HttpService"):JSONEncode(alldata))