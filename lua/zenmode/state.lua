local M = {}

---@class zenmode.Win
---@field bufid integer
---@field winid integer

---@class zenmode.Tab
---@field H integer
---@field L integer
---@field id integer

---@class zenmode.State
---@field tabs table<integer, zenmode.Tab>
---@field enabled boolean
---@field saved_opts table<string, any>
---@field autocmds_created boolean

---@type zenmode.State
local state = {
    enabled = false,
    autocmds_created = false,
    tabs = {},
    saved_opts = {},
}

---@return boolean
function M.is_enabled()
    return state.enabled
end

---@return nil
function M.set_enabled()
    state.enabled = true
end

---@return nil
function M.set_disabled()
    state.enabled = false
end

---@return boolean
function M.is_autocmds_created()
    return state.autocmds_created
end

---@return nil
function M.set_autocmds_created()
    state.autocmds_created = true
end

---@return zenmode.State
function M.get_state()
    return state
end

---@return table<string, any>
function M.get_saved_opts()
    return state.saved_opts
end

---@param saved_opts table<string, any>
---@return nil
function M.set_saved_opts(saved_opts)
    state.saved_opts = saved_opts
end

---@return table<integer, zenmode.Tab>
function M.get_tabs()
    return state.tabs
end

---@param tabid integer
---@return zenmode.Tab | nil
function M.get_tab_by_id(tabid)
    for _, tab in pairs(state.tabs) do
        if tab.id == tabid then
            return tab
        end
    end
end

---@param tabs table<integer, zenmode.Tab>
---@return nil
function M.set_tabs(tabs)
    if not tabs then
        return
    end
    state.tabs = tabs
end

---@param tabid integer | nil
---@param H_win integer
---@param L_win integer
---@return nil
function M.add_tab(tabid, H_win, L_win)
    if not tabid then
        return
    end
    table.insert(state.tabs, { H = H_win, L = L_win, id = tabid })
end

---@param tabid integer
---@return nil
function M.remove_tab_by_id(tabid)
    for idx, tab in ipairs(state.tabs) do
        if tab.id == tabid then
            table.remove(state.tabs, idx)
            break
        end
    end
end

---@return nil
function M.remove_tabs()
    state.tabs = {}
end

return M
