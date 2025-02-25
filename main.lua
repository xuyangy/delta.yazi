--- @since 25.2.7

local function info(content)
    return ya.notify({
        title = "Diff",
        content = content,
        timeout = 5,
    })
end

local function is_inside_tmux()
    return os.getenv("TMUX") ~= nil
end

local selected_url = ya.sync(function()
    for _, u in pairs(cx.active.selected) do
        return u
    end
end)

local hovered_url = ya.sync(function()
    local h = cx.active.current.hovered
    return h and h.url
end)

return {
    entry = function()
        local a, b = selected_url(), hovered_url()
        if not a then
            return info("No file selected")
        elseif not b then
            return info("No file hovered")
        end

        local function get_terminal_width()
            local handle = io.popen("tput cols")
            local result = handle:read("*a")
            handle:close()
            return tonumber(result)
        end
        local args = { "--side-by-side", "--paging=never", "--line-numbers", "-w", get_terminal_width() }
        local output, err = Command("delta"):args(args):arg(tostring(a)):arg(tostring(b)):output()
        if not output then
            return info("Failed to run diff, error: " .. err)
        elseif output.stdout == "" then
            return info("No differences found")
        end

        local tmpfile = os.tmpname()
        local file = io.open(tmpfile, "w")
        file:write(output.stdout)
        file:close()
        if is_inside_tmux() then
            os.execute("tmux new-window 'less " .. tmpfile .. " && rm -f " .. tmpfile .. " || rm -f " .. tmpfile .. "'")
        else
            ya.clipboard(output.stdout)
            info("Not inside Tmux, diff copied to clipboard")
        end
    end,
}
