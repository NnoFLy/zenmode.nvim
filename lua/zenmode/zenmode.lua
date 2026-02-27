local M = {}

local utils = require("zenmode.utils")
local state = require("zenmode.state")
local logger = require("zenmode.logger")

---@param tabid integer
---@param main_width integer
---@return nil
function M.open_one(tabid, main_width)
    local cur_win = vim.fn.win_getid()

    local screen_width = vim.o.columns - 2
    local side_width = math.floor((screen_width - main_width) / 2)

    local H_win = utils.create_scratch_window(side_width, "H")
    local L_win = utils.create_scratch_window(side_width, "L")

    logger.debug("H_win: " .. vim.inspect(H_win))
    logger.debug("L_win: " .. vim.inspect(L_win))

    vim.api.nvim_set_current_win(cur_win)

    state.add_tab(tabid, H_win, L_win)

    utils.hide_vertical_split_bar(tabid)
end

---@param tab zenmode.Tab
---@return nil
function M.close_one(tab)
    if vim.api.nvim_win_is_valid(tab.H) then
        pcall(vim.api.nvim_win_close, tab.H, true)
    end
    if vim.api.nvim_win_is_valid(tab.L) then
        pcall(vim.api.nvim_win_close, tab.L, true)
    end
    state.remove_tab_by_id(tab.id)
end

---@param input_width integer | nil
---@return nil
function M.open(input_width)
    if state.is_enabled() then return end

    local zenmode = require("zenmode")

    local opts = zenmode.get_opts()
    local user_opts = opts.options
    local opts_to_save = vim.tbl_deep_extend("force", { fillchars = true }, user_opts)
    local saved_opts = utils.save_opts(opts_to_save)
    state.set_saved_opts(saved_opts)

    opts.on_before_open()

    local start_tab = vim.api.nvim_get_current_tabpage()
    local editor_tabs = vim.api.nvim_list_tabpages()
    local width = input_width or opts.default_width

    for _, tabid in pairs(editor_tabs) do
        vim.api.nvim_set_current_tabpage(tabid)
        M.open_one(tabid, width)
    end

    utils.apply_opts(user_opts)

    vim.api.nvim_set_current_tabpage(start_tab)

    opts.on_after_open()

    state.set_enabled()
end

---@return nil
function M.close()
    if not state.is_enabled() then return end

    local zenmode = require("zenmode")

    local opts = zenmode.get_opts()
    opts.on_before_close()

    local start_tab = vim.api.nvim_get_current_tabpage()
    local editor_tabs = vim.api.nvim_list_tabpages()

    for _, current_tab in pairs(editor_tabs) do
        local tab = state.get_tab_by_id(current_tab)
        if not tab then
            goto continue
        end

        vim.api.nvim_set_current_tabpage(current_tab)
        M.close_one(tab)
        state.remove_tab_by_id(tab.id)

        ::continue::
    end

    if #state.get_tabs() ~= 0 then
        logger.warn("Some tabs were not closed")
    end

    local saved_opts = state.get_saved_opts()
    utils.apply_opts(saved_opts)

    vim.api.nvim_set_current_tabpage(start_tab)

    opts.on_after_close()

    state.set_disabled()
end

---@return nil
---@param input_width integer | nil
function M.toggle(input_width)
    if state.is_enabled() then
        M.close()
    else
        M.open(input_width)
    end
end

return M
