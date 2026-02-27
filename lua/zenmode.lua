local M = {}

local defaults = require("zenmode.default_opts")
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

return M
