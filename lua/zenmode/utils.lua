local M = {}

---@param win integer
---@param fillchars table<string, string>
---@return nil
local function append_fillchars(win, fillchars)
    pcall(vim.api.nvim_win_call, win, function()
        vim.opt_local.fillchars:append(fillchars)
    end)
end

---@class zenmode.SavedOpts
---@field global table<string, any>
---@field win table<integer, table<string, any>>

---@param opt string
---@return vim.api.keyset.get_option_info
local function get_option_info(opt)
    return vim.api.nvim_get_option_info2(opt, {})
end

---@param opt string
---@param win integer
---@return any
local function get_win_option_value(opt, win)
    local info = get_option_info(opt)
    if info.scope == "global" then
        return vim.api.nvim_get_option_value(opt, { scope = "global" })
    end
    if info.scope == "buf" then
        return vim.api.nvim_get_option_value(opt, { buf = vim.api.nvim_win_get_buf(win) })
    end

    return vim.api.nvim_get_option_value(opt, { win = win })
end

---@param opt string
---@param value any
---@param win integer
---@return nil
local function set_option_value(opt, value, win)
    local info = get_option_info(opt)
    if info.scope == "global" then
        vim.api.nvim_set_option_value(opt, value, { scope = "global" })
        return
    end
    if info.scope == "buf" then
        vim.api.nvim_set_option_value(opt, value, { buf = vim.api.nvim_win_get_buf(win) })
        return
    end

    vim.api.nvim_set_option_value(opt, value, { win = win })
end

---@param opts table<string, any>
---@return zenmode.SavedOpts
function M.save_opts(opts)
    local saved_opts = {
        global = {},
        win = {},
    }

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if M.is_excluded(win) then
            goto continue
        end

        saved_opts.win[win] = {}
        for opt, _ in pairs(opts) do
            local ok, value = pcall(get_win_option_value, opt, win)
            if ok then
                saved_opts.win[win][opt] = value
            end
        end

        ::continue::
    end

    for opt, _ in pairs(opts) do
        local ok, info = pcall(get_option_info, opt)
        if ok and info.scope == "global" then
            saved_opts.global[opt] = vim.api.nvim_get_option_value(opt, { scope = "global" })
        end
    end

    return saved_opts
end

---@param tab integer
---@return integer
function M.get_win_count(tab)
    local total_count = 0
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    for _, win in pairs(wins) do
        if not M.is_excluded(win) then
            total_count = total_count + 1
        end
    end
    return total_count
end

---@param opts table<string, any>
---@return nil
function M.apply_opts(opts)
    if opts.global and opts.win then
        for opt, value in pairs(opts.global) do
            pcall(vim.api.nvim_set_option_value, opt, value, { scope = "global" })
        end

        for win, win_opts in pairs(opts.win) do
            if not vim.api.nvim_win_is_valid(win) then
                goto continue
            end

            for opt, value in pairs(win_opts) do
                pcall(set_option_value, opt, value, win)
            end

            ::continue::
        end

        return
    end

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if M.is_excluded(win) then
            goto continue
        end

        for opt, value in pairs(opts) do
            pcall(set_option_value, opt, value, win)
        end

        ::continue::
    end
end

---@param width integer
---@param direction string
---@return integer
function M.create_scratch_window(width, direction)
    vim.cmd("vsp")
    vim.cmd("wincmd " .. direction)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)

    local win = vim.api.nvim_get_current_win()

    local opts = {
        scope = "local",
        win = win,
    }

    vim.api.nvim_win_set_width(win, width)
    vim.api.nvim_set_option_value("winfixwidth", true, opts)
    vim.api.nvim_set_option_value("cursorline", false, opts)
    vim.api.nvim_set_option_value("winfixbuf", true, opts)
    vim.api.nvim_set_option_value("numberwidth", 1, opts)
    vim.api.nvim_set_option_value("number", false, opts)
    vim.api.nvim_set_option_value("relativenumber", false, opts)
    append_fillchars(win, { eob = " ", vert = " " })

    return win
end

---@param tabid integer
---@return nil
function M.hide_vertical_split_bar(tabid)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
        if M.is_excluded(win) then
            goto continue
        end

        append_fillchars(win, { vert = " " })

        ::continue::
    end
end

---@param win integer
---@return boolean
function M.is_excluded(win)
    local excluded_filetypes = require("zenmode.nvim").get_opts().excluded_filetypes or {}
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(win) })
    return not not excluded_filetypes[filetype]
end

return M
