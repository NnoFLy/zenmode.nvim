---@return nil
local function create_autocmds()
    local state = require("zenmode.state")
    local zenmode_init = require("zenmode")
    local zenmode = require("zenmode.zenmode")
    local utils = require("zenmode.utils")

    if state.is_autocmds_created() then
        return
    end

    local group = vim.api.nvim_create_augroup("Zenmode", { clear = true })

    ---@return nil
    local function on_tab_new()
        if not state.is_enabled() then
            return
        end

        local tabid = vim.api.nvim_get_current_tabpage()
        zenmode.open_one(tabid, zenmode_init.get_opts().default_width)
    end

    ---@param args vim.api.keyset.create_autocmd.callback_args
    ---@return nil
    local function on_win_closed(args)
        if not state.is_enabled() then
            return
        end

        ---@return nil
        local function process_closed_window()
            local closed_win = tonumber(args.match)
            local tabid = vim.api.nvim_get_current_tabpage()
            local current_tab = state.get_tab_by_id(tabid)

            if not current_tab and closed_win then
                for _, tab in pairs(state.get_tabs()) do
                    if tab.H == closed_win or tab.L == closed_win then
                        current_tab = tab
                        break
                    end
                end
            end

            if not current_tab then
                return
            end

            if
                not vim.api.nvim_win_is_valid(current_tab.H)
                or not vim.api.nvim_win_is_valid(current_tab.L)
            then
                zenmode.close_one(current_tab)
                zenmode.open_one(current_tab.id, zenmode_init.get_opts().default_width)
                return
            end

            if utils.get_win_count(current_tab.id) < 3 then
                zenmode.close_one(current_tab)
            end
        end

        vim.schedule(process_closed_window)
    end

    ---@return nil
    local function on_win_enter()
        if not state.is_enabled() then
            return
        end

        local tabid = vim.api.nvim_get_current_tabpage()
        utils.hide_vertical_split_bar(tabid)

        local opts = zenmode_init.get_opts()
        if not opts.untouchable_side_bufs then
            return
        end

        local current_win = vim.api.nvim_get_current_win()
        local tab = state.get_tab_by_id(tabid)
        if not tab or not tab.H or not tab.L then
            return
        end

        if tab.H == current_win or tab.L == current_win then
            vim.cmd("wincmd p")
        end
    end

    vim.api.nvim_create_autocmd("TabNew", {
        group = group,
        callback = on_tab_new,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        callback = on_win_closed,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = on_win_enter,
    })

    state.set_autocmds_created()
end

return create_autocmds
