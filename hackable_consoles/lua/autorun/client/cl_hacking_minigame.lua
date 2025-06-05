local function SendResult(success)
    net.Start("HackingMinigameResult")
    net.WriteBool(success)
    net.SendToServer()
end

-- ===================
-- SKILLBAR MINIGAME
-- ===================
local PANEL = {}

function PANEL:Init()
    self:SetSize(400, 100)
    self:Center()
    self:MakePopup()
    self:SetTitle("Skillbar")

    self.barX = 0
    self.barSpeed = 2
    self.successZone = {start = 150, stop = 250}
    self.resultSent = false
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 50, 40, 300, 20, Color(50, 50, 50))
    draw.RoundedBox(6, 50 + self.successZone.start, 40, self.successZone.stop - self.successZone.start, 20, Color(0, 255, 0))
    draw.RoundedBox(6, 50 + self.barX, 35, 10, 30, Color(255, 0, 0))
end

function PANEL:Think()
    self.barX = self.barX + self.barSpeed
    if self.barX > 300 then self.barX = 0 end
end

function PANEL:OnKeyCodePressed(key)
    if key == KEY_SPACE and not self.resultSent then
        local barPos = self.barX
        local success = barPos >= self.successZone.start and barPos <= self.successZone.stop
        self.resultSent = true
        self:Close()
        SendResult(success)
    end
end

vgui.Register("Hacking_Skillbar", PANEL, "DFrame")

-- ===================
-- CIRCLE CLICK MINIGAME
-- ===================
net.Receive("OpenHackingMinigame", function()
    local choice = math.random(1, 4)
    if choice == 1 then vgui.Create("Hacking_Skillbar") end
    if choice == 2 then RunCircleClick() end
    if choice == 3 then RunMemoryGame() end
    if choice == 4 then RunKeypadGame() end
end)

-- ===================
-- CIRCLE CLICK
-- ===================
function RunCircleClick()
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 300)
    frame:Center()
    frame:SetTitle("Click the Circle!")
    frame:MakePopup()

    local circle = vgui.Create("DButton", frame)
    local x, y = math.random(50, 250), math.random(50, 250)
    circle:SetPos(x, y)
    circle:SetSize(30, 30)
    circle:SetText("")

    circle.Paint = function(self, w, h)
        draw.RoundedBox(w / 2, 0, 0, w, h, Color(0, 150, 255))
    end

    local failed = false
    timer.Simple(3, function()
        if IsValid(frame) and not failed then
            failed = true
            frame:Close()
            SendResult(false)
        end
    end)

    circle.DoClick = function()
        if failed then return end
        frame:Close()
        SendResult(true)
    end
end

-- ===================
-- MEMORY MATCH (Simple Version)
-- ===================
function RunMemoryGame()
    local sequence = {}
    for i = 1, 3 do sequence[i] = math.random(1, 4) end

    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 200)
    frame:Center()
    frame:SetTitle("Memory Match")
    frame:MakePopup()

    local input = {}
    for i = 1, 4 do
        local btn = vgui.Create("DButton", frame)
        btn:SetSize(80, 50)
        btn:SetPos(20 + (i - 1) * 90, 100)
        btn:SetText("[" .. i .. "]")
        btn.DoClick = function()
            table.insert(input, i)
            if #input == #sequence then
                local match = true
                for j = 1, #sequence do
                    if input[j] ~= sequence[j] then match = false break end
                end
                frame:Close()
                SendResult(match)
            end
        end
    end

    local seqStr = table.concat(sequence, " - ")
    local lbl = vgui.Create("DLabel", frame)
    lbl:SetText("Memorize: " .. seqStr)
    lbl:SizeToContents()
    lbl:SetPos(20, 50)
end

-- ===================
-- KEYPAD ORDER
-- ===================
function RunKeypadGame()
    local nums = {1, 2, 3, 4}
    table.Shuffle(nums)

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 200)
    frame:Center()
    frame:SetTitle("Press in Order!")
    frame:MakePopup()

    local next = 1
    for i, num in ipairs(nums) do
        local btn = vgui.Create("DButton", frame)
        btn:SetSize(50, 50)
        btn:SetPos(30 + ((i - 1) * 60), 100)
        btn:SetText(tostring(num))
        btn.DoClick = function()
            if num == next then
                next = next + 1
                if next > #nums then
                    frame:Close()
                    SendResult(true)
                end
            else
                frame:Close()
                SendResult(false)
            end
        end
    end
end
