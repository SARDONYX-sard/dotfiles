local M = {}

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
M.capabilities = capabilities

-- dependencies
local wk = require("which-key")
local utils = require "utils"

--- Create key options
---@param description string
---@param ... any
---@return table
local function make_options(description, ...)
    local bufopts = { noremap = true, silent = true }
    return utils.merge(bufopts, { desc = description }, ...)
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
---@diagnostic disable-next-line: unused-local
function M.on_attach(client, bufnr)
    ---@param description string
    ---@return table
    local make_opts = function(description)
        return make_options(description, { buffer = bufnr })
    end

    vim.keymap.set("n", "K", "<cmd>:Lspsaga hover_doc<CR>", make_opts("Show doc"))
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, make_opts("Show signatures"))

    wk.register({
        ["g"] = { name = "+Go to ref, decl" }
    })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, make_opts("Go to declaration"))
    vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", make_opts("Go to definition"))
    vim.keymap.set("n", "gs", "<cmd>Lspsaga lsp_finder<CR>", make_opts("Find references"))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, make_opts("Show implementation"))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, make_opts("Show references"))
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, make_opts("Show type def"))

    wk.register({
        ["<space>w"] = { name = "+workspace" }
    })
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, make_opts("Add workspace dir"))
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, make_opts("Remove workspace dir"))
    vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, make_opts("List workspace dirs"))

    vim.keymap.set("n", "<space>lr", "<cmd>Lspsaga rename<CR>", make_opts("Rename"))
    vim.keymap.set("n", "<space>la", "<cmd>Lspsaga code_action<CR>", make_opts("Code action"))
    vim.keymap.set("v", "<space>la", "<cmd><C-U>Lspsaga range_code_action<CR>", make_opts("Range code action"))
    vim.keymap.set("n", "<space>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", make_opts("Show line diagnostics"))
    vim.keymap.set("n", "<space>lf", function() vim.lsp.buf.format({ async = true }) end, make_opts("Format"))

    vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_next<CR>", make_opts("Jump next diagnostic"))
    vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", make_opts("Jump prev diagnostic"))
    vim.keymap.set("n", "[E", function()
        require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, make_opts("Show diagnostics"))
    vim.keymap.set("n", "]E", function()
        require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, make_opts("Show diagnostic"))
end

function M.add_bundle_exec(config, gem, dir)
    local ret_code = nil
    local jid = vim.fn.jobstart("bundle info " .. gem, {
        cwd = dir,
        on_exit = function(_, data)
            ret_code = data
        end,
    })
    vim.fn.jobwait({ jid }, 5000)
    if ret_code == 0 then
        table.insert(config.cmd, 1, "exec")
        table.insert(config.cmd, 1, "bundle")
    end
end

wk.register({
    ["<space>l"] = { name = "+lsp" },
})
vim.keymap.set("n", "<space>lI", ":Mason<CR>", make_options("lsp installer"))
vim.keymap.set("n", "<space>li", ":LspInfo<CR>", make_options("lsp info"))

return M
