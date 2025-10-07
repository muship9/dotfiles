local M = {}

local ignore_filename = "search-ignore"

local function trim(text)
  return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function glob_to_lua_pattern(pattern)
  local escaped = pattern:gsub("([%^%$%(%)%%%.%[%]%+%-])", "%%%1")
  escaped = escaped:gsub("%*", ".*")
  escaped = escaped:gsub("%?", ".")
  return escaped
end

local function read_entries()
  local path = vim.fn.stdpath("config") .. "/" .. ignore_filename
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return {}
  end

  local entries = {}
  for _, line in ipairs(lines) do
    local text = trim(line)
    if text ~= "" and text:sub(1, 1) ~= "#" then
      local is_dir = false
      if text:sub(-1) == "/" then
        text = text:sub(1, -2)
        is_dir = true
      end

      if text ~= "" then
        local has_magic = text:find("[%*%?%[]") ~= nil
        table.insert(entries, {
          pattern = text,
          is_dir = is_dir,
          has_magic = has_magic,
          lua_pattern = has_magic and glob_to_lua_pattern(text) or text,
        })
      end
    end
  end

  return entries
end

function M.entries()
  return read_entries()
end

function M.patterns(entries)
  entries = entries or M.entries()
  local patterns = {}
  for _, entry in ipairs(entries) do
    table.insert(patterns, entry.lua_pattern or entry.pattern)
  end
  return patterns
end

function M.fd_exclude_args(entries)
  entries = entries or M.entries()
  local args = {}
  for _, entry in ipairs(entries) do
    table.insert(args, "--exclude")
    table.insert(args, entry.pattern)
  end
  return args
end

function M.rg_ignore_globs(entries)
  entries = entries or M.entries()
  local args = {}
  for _, entry in ipairs(entries) do
    local suffix = entry.is_dir and "/**" or ""
    table.insert(args, "-g")
    table.insert(args, "!" .. entry.pattern .. suffix)
  end
  return args
end

return M
