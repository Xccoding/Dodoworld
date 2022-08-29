--=======================================modifier_Vehicle_Bezier=======================================
if modifier_Vehicle_Bezier == nil then
    modifier_Vehicle_Bezier = class({})
end
function modifier_Vehicle_Bezier:IsHidden()
    return true
end
function modifier_Vehicle_Bezier:IsDebuff()
    return false
end
function modifier_Vehicle_Bezier:IsPurgable()
    return false
end
function modifier_Vehicle_Bezier:IsPurgeException()
    return false
end
function modifier_Vehicle_Bezier:OnCreated(params)
    if IsServer() then
        local hParent = self:GetParent()
        self.Total_trip = {}
        self.t = 0 --贝塞尔参数
        self.n = 0 --当前正在行进的路段上的路点数量
        self.current_section = 0
        local path_name = KeyValues:GetUnitSpecialValue(hParent, "VehicleData").PathwayName

        local Section_index = 0
        --循环100次，再怎么也不会有100个路点吧？
        for i = 0, 100 do
            if self.Total_trip["Section"..Section_index] == nil then
                self.Total_trip["Section"..Section_index] = {}
            end
            local waypoint_ent_connection = Entities:FindByName(nil, path_name.."_"..i.."_connection")
            local waypoint_ent = Entities:FindByName(nil, path_name.."_"..i)
            if waypoint_ent_connection ~= nil then
                --找到了一个关键点，说明当前组的点都检索完毕
                table.insert(self.Total_trip["Section"..Section_index], waypoint_ent_connection:GetAbsOrigin())
                self.Total_trip["Section"..Section_index].num = #self.Total_trip["Section"..Section_index]
                self.Total_trip["Section"..Section_index].finish = false
                Section_index = Section_index + 1
                if self.Total_trip["Section"..Section_index] == nil then
                    self.Total_trip["Section"..Section_index] = {}
                end
                table.insert(self.Total_trip["Section"..Section_index], waypoint_ent_connection:GetAbsOrigin())
            else
                --尝试找一个普通点
                if waypoint_ent ~= nil then
                    table.insert(self.Total_trip["Section"..Section_index], waypoint_ent:GetAbsOrigin())
                else
                    self.Total_trip["Section"..Section_index].num = #self.Total_trip["Section"..Section_index]
                    self.Total_trip["Section"..Section_index].finish = false
                    break
                end
            end
        end
        -- for Section_name, Section in pairs(self.Total_trip) do
        --     --print("N2O", Section_name)
        --     if Section ~= nil then
        --         for index, waypoint in pairs(Section) do
        --             --print("N2O", index, waypoint)
        --         end
        --     end
        -- end

        if (not self:ApplyHorizontalMotionController()) or (not self:ApplyVerticalMotionController()) then
            self:Destroy()
        end
    end
end
function modifier_Vehicle_Bezier:OnRefresh(params)
end
function modifier_Vehicle_Bezier:OnDestroy(params)
end
function modifier_Vehicle_Bezier:DeclareFunctions()
    return {
    }
end
function modifier_Vehicle_Bezier:CDeclareFunctions()
    return {
    }
end
function modifier_Vehicle_Bezier:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end
function modifier_Vehicle_Bezier:UpdateHorizontalMotion(hParent, dt)
    if self.n == 0 then
        local count = 0
        for i = 1, 100 do
            if self.Total_trip["Section"..self.current_section][i] ~= nil and IsVector(self.Total_trip["Section"..self.current_section][i]) then
                count = count + 1
            else
                break
            end
        end
        self.n = count - 1
    end
    if self.t >= 1 then
        self.current_section = self.current_section + 1
        if self.Total_trip["Section"..self.current_section] == nil then
            --已经没有路点，motion结束
            FindClearSpaceForUnit(hParent, hParent:GetAbsOrigin(), true)
            self:Destroy()
        else
            --还有下一组路点，重置分段进度
            self.t = 0
            self.n = 0
        end
    else
        local new_pos = nil
        for i = 0, self.n do
            if new_pos == nil then
                new_pos = Combinatorial(self.n, i) * self.Total_trip["Section"..self.current_section][i + 1] * math.pow(1 - self.t, self.n - i) * math.pow(self.t, i)
            else
                new_pos = new_pos + Combinatorial(self.n, i) * self.Total_trip["Section"..self.current_section][i + 1] * math.pow(1 - self.t, self.n - i) * math.pow(self.t, i)
            end
        end

        hParent:FaceTowards(new_pos)
        hParent:SetAbsOrigin(new_pos)
        self.t = self.t + 0.03
    end

end
function modifier_Vehicle_Bezier:UpdateVerticalMotion(hParent, dt)
    if self.n == 0 then
        local count = 0
        for i = 1, 100 do
            if self.Total_trip["Section"..self.current_section][i] ~= nil and IsVector(self.Total_trip["Section"..self.current_section][i]) then
                count = count + 1
            else
                break
            end
        end
        self.n = count - 1
    end
    if self.t < 1 then
        local new_pos = nil
        for i = 0, self.n do
            if new_pos == nil then
                new_pos = Combinatorial(self.n, i) * self.Total_trip["Section"..self.current_section][i + 1] * math.pow(1 - self.t, self.n - i) * math.pow(self.t, i)
            else
                new_pos = new_pos + Combinatorial(self.n, i) * self.Total_trip["Section"..self.current_section][i + 1] * math.pow(1 - self.t, self.n - i) * math.pow(self.t, i)
            end
        end
        hParent:SetForwardVector((new_pos - hParent:GetAbsOrigin()):Normalized())
        self:ApplyVerticalMotionController()
        self:ApplyHorizontalMotionController()
        hParent:SetAbsOrigin(new_pos)
    end
end