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

---@class Builtin
---@field toggle fun(input_width: integer | nil)
---@field open fun(input_width: integer | nil)
---@field close fun()

local M = {}

---@return nil
local function noop()
end

---@type Opts
local defaults = {
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
    log_level = "debug",
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

M.opts = vim.deepcopy(defaults)

local zenmode = require("zenmode.zenmode")
local create_autocmd = require("zenmode.autocmd")

---@param user_opts Opts | {}
---@return nil
function M.setup(user_opts)
    user_opts = user_opts or {}

    M.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_opts)
    M.opts.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults.options), user_opts.options or {})

    ---@param command_opts vim.api.keyset.create_user_command.command_args
    ---@return integer | nil
    local function parse_width_from_args(command_opts)
        local width_arg = vim.trim(command_opts.args or "")
        if width_arg == "" then
            return nil
        end

        local width = tonumber(width_arg)
        if not width or width < 1 then
            error("Zenmode width must be a positive number")
        end

        return math.floor(width)
    end

    ---@param command_opts vim.api.keyset.create_user_command.command_args
    ---@return nil
    local function zenmode_toggle_command(command_opts)
        zenmode.toggle(parse_width_from_args(command_opts))
    end

    ---@return nil
    local function zenmode_close_command()
        zenmode.close()
    end

    ---@param command_opts vim.api.keyset.create_user_command.command_args
    ---@return nil
    local function zenmode_open_command(command_opts)
        zenmode.open(parse_width_from_args(command_opts))
    end

    vim.api.nvim_create_user_command("ZenmodeToggle", zenmode_toggle_command, { nargs = "?" })
    vim.api.nvim_create_user_command("ZenmodeClose", zenmode_close_command, { nargs = 0 })
    vim.api.nvim_create_user_command("ZenmodeOpen", zenmode_open_command, { nargs = "?" })

    create_autocmd()
end

---@return Opts
function M.get_opts()
    return M.opts
end

---@return Builtin
function M.builtin()
    ---@param input_width integer | nil
    ---@return nil
    local function toggle(input_width)
        return zenmode.toggle(input_width)
    end

    ---@param input_width integer | nil
    ---@return nil
    local function open(input_width)
        return zenmode.open(input_width)
    end

    ---@return nil
    local function close()
        return zenmode.close()
    end

    return {
        toggle = toggle,
        open = open,
        close = close,
    }
end

return M
