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

        local args = { "--side-by-side", "--paging=never", "--line-numbers" }
        local output, err = Command("delta"):arg(args):arg(tostring(a)):arg(tostring(b)):output()
        if not output then
            return info("Failed to run diff, error: " .. tostring(err))
        elseif output.stdout == "" then
            return info("No differences found")
        end

        local tmpfile = os.tmpname()
        local file, open_err = io.open(tmpfile, "w")
        if not file then
            return info("Failed to create temporary diff file, error: " .. tostring(open_err))
        end
        file:write(output.stdout)
        file:close()
        if is_inside_tmux() then
            local status, tmux_err = Command("tmux")
                :arg({
                    "new-window",
                    "sh",
                    "-c",
                    'less -R "$1"; code=$?; rm -f "$1"; exit $code',
                    "sh",
                    tmpfile,
                })
                :status()
            if not status then
                return info("Failed to open diff in tmux, error: " .. tostring(tmux_err))
            elseif not status.success then
                return info("Failed to open diff in tmux, exit code: " .. tostring(status.code))
            end
        else
            ya.clipboard(output.stdout)
            info("Not inside Tmux, diff copied to clipboard")
        end
    end,
}
