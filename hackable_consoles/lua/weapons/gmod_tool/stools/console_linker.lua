TOOL.Category = "Supptest"
TOOL.Name = "#tool.console_linker.name"

TOOL.Information = {
    { name = "left", text = "Left Click: Select console, then link props" },
    { name = "reload", text = "Reload: Clear all links" }
}

if CLIENT then
    language.Add("tool.console_linker.name", "Console Linker")
    language.Add("tool.console_linker.desc", "Link hackable consoles to props")
    language.Add("tool.console_linker.0", "Left Click: Select console, then props. Reload to clear.")
end

TOOL.SelectedConsoles = TOOL.SelectedConsoles or {}

function TOOL:LeftClick(trace)
    local ply = self:GetOwner()
    if not trace.Entity or not IsValid(trace.Entity) then return false end

    local ent = trace.Entity

    if ent:GetClass() == "ent_hack_console" then
        self.SelectedConsoles[ply] = ent
        ply:ChatPrint("[Console Linker] Selected console: " .. tostring(ent))
    else
        local console = self.SelectedConsoles[ply]
        if IsValid(console) then
            console.LinkedProps = console.LinkedProps or {}
            table.insert(console.LinkedProps, ent)
            ply:ChatPrint("[Console Linker] Linked prop to console.")
        else
            ply:ChatPrint("[Console Linker] No console selected!")
        end
    end

    return true
end

function TOOL:Reload(trace)
    local ply = self:GetOwner()
    local console = self.SelectedConsoles[ply]
    if IsValid(console) then
        console.LinkedProps = {}
        ply:ChatPrint("[Console Linker] Cleared all linked props.")
    end
    return true
end
