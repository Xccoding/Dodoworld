local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift
local __TS__New = ____lualib.__TS__New
local __TS__Decorate = ____lualib.__TS__Decorate
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["12"] = 1,["13"] = 1,["14"] = 3,["15"] = 4,["16"] = 3,["18"] = 6,["19"] = 8,["20"] = 10,["21"] = 12,["22"] = 184,["23"] = 187,["24"] = 187,["25"] = 187,["26"] = 187,["27"] = 187,["28"] = 182,["29"] = 27,["30"] = 32,["33"] = 34,["34"] = 35,["35"] = 35,["36"] = 35,["38"] = 36,["39"] = 37,["40"] = 38,["41"] = 39,["44"] = 40,["45"] = 41,["47"] = 43,["48"] = 44,["49"] = 45,["52"] = 46,["53"] = 47,["55"] = 27,["56"] = 51,["57"] = 52,["58"] = 52,["60"] = 54,["61"] = 55,["62"] = 55,["64"] = 56,["65"] = 57,["66"] = 57,["69"] = 58,["70"] = 58,["71"] = 59,["72"] = 59,["74"] = 58,["78"] = 62,["79"] = 63,["80"] = 63,["85"] = 67,["87"] = 70,["88"] = 51,["89"] = 90,["90"] = 95,["93"] = 97,["94"] = 98,["95"] = 98,["96"] = 98,["98"] = 99,["99"] = 99,["100"] = 99,["102"] = 101,["103"] = 102,["104"] = 103,["105"] = 104,["107"] = 106,["108"] = 107,["109"] = 108,["111"] = 90,["112"] = 125,["113"] = 131,["114"] = 136,["115"] = 137,["116"] = 142,["117"] = 143,["118"] = 146,["119"] = 147,["121"] = 148,["122"] = 148,["123"] = 149,["124"] = 150,["125"] = 153,["126"] = 154,["127"] = 148,["131"] = 159,["133"] = 161,["134"] = 125,["135"] = 164,["136"] = 165,["137"] = 166,["139"] = 164,["140"] = 173,["141"] = 174,["142"] = 175,["143"] = 175,["145"] = 173,["146"] = 192,["147"] = 195,["148"] = 196,["149"] = 197,["152"] = 200,["153"] = 201,["154"] = 202,["155"] = 203,["158"] = 207,["161"] = 208,["163"] = 209,["164"] = 210,["165"] = 210,["167"] = 211,["168"] = 212,["169"] = 213,["174"] = 192,["175"] = 218,["176"] = 219,["177"] = 220,["178"] = 222,["179"] = 224,["180"] = 225,["181"] = 228,["183"] = 231,["184"] = 232,["185"] = 234,["187"] = 236,["188"] = 237,["189"] = 240,["190"] = 242,["192"] = 249,["193"] = 250,["194"] = 253,["195"] = 254,["199"] = 261,["200"] = 219,["201"] = 218,["202"] = 266,["203"] = 267,["204"] = 268,["206"] = 270,["207"] = 266,["208"] = 272,["209"] = 272,["210"] = 3,["211"] = 4});
local ____exports = {}
local ____tstl_2Dutils = require("lib.tstl-utils")
local reloadable = ____tstl_2Dutils.reloadable
____exports.XNetTable = __TS__Class()
local XNetTable = ____exports.XNetTable
XNetTable.name = "XNetTable"
function XNetTable.prototype.____constructor(self)
    self.MTU = 2048
    self._data = {}
    self._player_data = {}
    self._data_queue = {}
    self:_startHeartbeat()
    ListenToGameEvent(
        "player_connect_full",
        function(____, keys) return self:_onPlayerConnectFull(keys) end,
        self
    )
end
function XNetTable.prototype.SetTableValue(self, tname, key, value)
    if not IsServer() then
        return
    end
    local k = tostring(key)
    local ____self__data_0, ____tname_1 = self._data, tname
    if ____self__data_0[____tname_1] == nil then
        ____self__data_0[____tname_1] = {}
    end
    if value == nil then
        local noUpdate = ____exports.XNetTable:isEqual(self._data[tname][k], {})
        self._data[tname][k] = {}
        if noUpdate then
            return
        end
        local data = self:_prepareDataChunks(tname, k, {})
        self:_updatePositively(nil, data)
    else
        local noUpdate = ____exports.XNetTable:isEqual(self._data[tname][k], value)
        self._data[tname][k] = value
        if noUpdate then
            return
        end
        local data = self:_prepareDataChunks(tname, k, value)
        self:_updatePositively(nil, data)
    end
end
function XNetTable.isEqual(self, prev, next)
    if type(prev) ~= type(next) then
        return false
    end
    if type(prev) == "table" then
        if prev == nil then
            return next == nil
        end
        if __TS__ArrayIsArray(prev) then
            if #__TS__ObjectValues(prev) ~= #__TS__ObjectValues(next) then
                return false
            end
            do
                local i = 0
                while i < #prev do
                    if not ____exports.XNetTable:isEqual(prev[i + 1], next[i]) then
                        return false
                    end
                    i = i + 1
                end
            end
        else
            for key in pairs(prev) do
                if not ____exports.XNetTable:isEqual(prev[key], next[key]) then
                    return false
                end
            end
        end
    else
        return prev == next
    end
    return true
end
function XNetTable.prototype.SetPlayerTableValue(self, playerId, tname, key, value)
    if not IsServer() then
        return
    end
    local k = tostring(key)
    local ____self__player_data_2, ____playerId_3 = self._player_data, playerId
    if ____self__player_data_2[____playerId_3] == nil then
        ____self__player_data_2[____playerId_3] = {}
    end
    local ____self__player_data_playerId_4, ____tname_5 = self._player_data[playerId], tname
    if ____self__player_data_playerId_4[____tname_5] == nil then
        ____self__player_data_playerId_4[____tname_5] = {}
    end
    if value == nil then
        self._player_data[playerId][tname][k] = {}
        local data = self:_prepareDataChunks(tname, k, nil, playerId)
        self:_updatePositively(playerId, data)
    else
        self._player_data[playerId][tname][k] = value
        local data = self:_prepareDataChunks(tname, k, value, playerId)
        self:_updatePositively(playerId, data)
    end
end
function XNetTable.prototype._prepareDataChunks(self, tname, key, value, playerId)
    local data = json.encode({table = tname, key = key, value = value})
    local chunks = {}
    local chunk_size = self.MTU - 2
    local unique_id = DoUniqueString("")
    local data_length = string.len(data)
    if data_length > chunk_size then
        local chunk_count = math.ceil(data_length / chunk_size)
        do
            local i = 0
            while i < chunk_count do
                local chunk = __TS__StringSubstring(data, i * chunk_size, (i + 1) * chunk_size)
                print(string.len(chunk))
                chunk = (((((("#" .. unique_id) .. "#") .. tostring(chunk_count)) .. "#") .. tostring(i)) .. "#") .. chunk
                chunks[#chunks + 1] = chunk
                i = i + 1
            end
        end
    else
        chunks[#chunks + 1] = data
    end
    return chunks
end
function XNetTable.prototype._updatePositively(self, target, chunks)
    for ____, chunk in ipairs(chunks) do
        __TS__ArrayUnshift(self._data_queue, {target = target, data = chunk})
    end
end
function XNetTable.prototype._updateNegatively(self, target, chunks)
    for ____, chunk in ipairs(chunks) do
        local ____self__data_queue_6 = self._data_queue
        ____self__data_queue_6[#____self__data_queue_6 + 1] = {target = target, data = chunk}
    end
end
function XNetTable.prototype._onPlayerConnectFull(self, keys)
    local playerId = keys.PlayerID
    local player = PlayerResource:GetPlayer(playerId)
    if player == nil then
        return
    end
    for tname in pairs(self._data) do
        for key in pairs(self._data[tname]) do
            local data = self:_prepareDataChunks(tname, key, self._data[tname][key], playerId)
            self:_updateNegatively(playerId, data)
        end
    end
    if self._player_data[playerId] == nil then
        return
    end
    for tname in pairs(self._player_data[playerId]) do
        do
            local ____table = self._player_data[playerId][tname]
            if ____table == nil then
                goto __continue44
            end
            for key in pairs(____table) do
                local data = self:_prepareDataChunks(tname, key, ____table[key], playerId)
                self:_updateNegatively(playerId, data)
            end
        end
        ::__continue44::
    end
end
function XNetTable.prototype._startHeartbeat(self)
    Timers:CreateTimer(function()
        local data_sent_length = 0
        while #self._data_queue > 0 do
            if data_sent_length > self.MTU * 2.5 then
                print(((("[x_net_table]当前帧发送数据量" .. tostring(data_sent_length)) .. ",剩余") .. tostring(#self._data_queue)) .. "条数据未发送，留到下一帧执行")
                return FrameTime()
            end
            local data = table.remove(self._data_queue, 1)
            if data == nil then
                return FrameTime()
            end
            local data_str = data.data
            data_sent_length = data_sent_length + #data_str
            if data.target == nil or data.target == -1 then
                CustomGameEventManager:Send_ServerToAllClients("x_net_table", {data = data_str})
            else
                local playerId = data.target
                local player = PlayerResource:GetPlayer(playerId)
                if player ~= nil and not player:IsNull() then
                    CustomGameEventManager:Send_ServerToPlayer(player, "x_net_table", {data = data_str})
                end
            end
        end
        return FrameTime()
    end)
end
function XNetTable.getInstance(self)
    if self.instance == nil then
        self.instance = __TS__New(____exports.XNetTable)
    end
    return self.instance
end
function XNetTable.reload(self)
end
XNetTable = __TS__Decorate({reloadable}, XNetTable)
____exports.XNetTable = XNetTable
return ____exports
