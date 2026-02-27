---@return nil
local function noop()
end

---@class Opts
---@field options table
---@field default_width integer
---@field untouchable_side_bufs boolean
---@field log_level zenmode.log_level
---@field excluded_filetypes table<string, boolean>
---@field on_before_open fun()
---@field on_after_open fun()
---@field on_before_close fun()
---@field on_after_close fun()
return {
    options = {
        number = false,
        relativenumber = false,
        cursorline = false,
        cursorcolumn = false,
        foldcolumn = "0",
        list = false,
        signcolumn = "no",
        laststatus = 0,
    },
    default_width = 120,
    untouchable_side_bufs = true,
    log_level = "warn",
    excluded_filetypes = {
        cmd = true,
        pager = true,
        qf = true,
        dialog = true,
        msg = true,
    },
    on_before_open = noop,
    on_after_open = noop,
    on_before_close = noop,
    on_after_close = noop,
}
