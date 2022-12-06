-- @module utils
-- @alias M

local M = {}

---Returns merged multi tables.
-- - [merge two tables in lua](https://gist.github.com/qizhihere/cb2a14432d9bf65693ad)
--
--# Example
---```lua
-- merge({ prefix = "hello" }, { suffix = "world" })
-- --> { prefix = "hello", suffix = "world" }
---```
--
---@param ... any tables
---@return table
function M.merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for k, t in ipairs(tables_to_merge) do
        assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
    end

    local result = tables_to_merge[1]

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for k, v in pairs(from) do
            if type(k) == "number" then
                table.insert(result, v)
            elseif type(k) == "string" then
                if type(v) == "table" then
                    result[k] = result[k] or {}
                    result[k] = M.merge(result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end

    return result
end

return M
