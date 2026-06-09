-- agent.lua — Claude Code セッションの running/idle を監視する外付けモジュール
--
-- 思想: WezTerm 本体はフォークしない。素の WezTerm + Lua で「盗み見」する。
--   検出ロジック:
--     1. 各ペインのフォアグラウンドプロセスが `claude` かどうかを ps で判定
--     2. その claude が `caffeinate` 子プロセスを spawn しているか → running / idle
--        (Claude Code はタスク実行中、スリープ抑止のため caffeinate を起動する副作用がある)
--
-- 注意: これは Claude Code の「実装詳細(副作用)」に乗っかっている。
--       Claude 側が caffeinate をやめたら検出は壊れる。規約(OSC等)ではなく観測ベース。

local wezterm = require("wezterm")

local M = {}

-- ps の結果を 3 秒キャッシュ (GUI スレッドで毎フレーム ps を叩かないため)
local TTL = 3
local cache = { t = 0, procs = nil }

-- pid -> "running"/"idle" の前回状態。running→idle 遷移の検出に使う
local prev_state = {}

local function basename(path)
  return path:match("([^/]+)$") or path
end

-- ps を 1 回だけ走らせて、プロセス表を作る (TTL キャッシュ付き)
--   返り値: { by_pid = { [pid] = { ppid, is_claude } }, caffeinate_parents = { [ppid]=true } }
local function read_procs()
  local t = os.time()
  if cache.procs and (t - cache.t) < TTL then
    return cache.procs
  end

  local procs = { by_pid = {}, caffeinate_parents = {} }
  local ok, stdout = wezterm.run_child_process({ "ps", "-axo", "pid=,ppid=,command=" })
  if ok and stdout then
    for line in stdout:gmatch("[^\n]+") do
      local pid, ppid, command = line:match("^%s*(%d+)%s+(%d+)%s+(.+)$")
      if pid then
        pid = tonumber(pid)
        ppid = tonumber(ppid)
        local first_tok = command:match("^(%S+)") or command
        local is_claude = (basename(first_tok) == "claude")
        procs.by_pid[pid] = { ppid = ppid, is_claude = is_claude }
        if command:find("caffeinate", 1, true) then
          procs.caffeinate_parents[ppid] = true
        end
      end
    end
  end

  cache.t = t
  cache.procs = procs
  return procs
end

-- 与えられた pid から祖先方向に claude プロセスを探す (ペインの fg が claude の子の場合に備える)
local function find_claude_ancestor(procs, pid)
  local cur = pid
  local guard = 0
  while cur and procs.by_pid[cur] and guard < 20 do
    if procs.by_pid[cur].is_claude then
      return cur
    end
    cur = procs.by_pid[cur].ppid
    guard = guard + 1
  end
  return nil
end

-- 全 mux ペインを走査して、agent ペインの一覧を返す
--   { { pane_id, workspace, pid, running }, ... }
function M.scan()
  local procs = read_procs()
  local agents = {}

  for _, win in ipairs(wezterm.mux.all_windows()) do
    local ws = win:get_workspace()
    for _, tab in ipairs(win:tabs()) do
      for _, pane in ipairs(tab:panes()) do
        local got, info = pcall(function()
          return pane:get_foreground_process_info()
        end)
        if got and info and info.pid then
          local cpid = find_claude_ancestor(procs, info.pid)
          if cpid then
            agents[#agents + 1] = {
              pane_id = pane:pane_id(),
              workspace = ws,
              pid = cpid,
              running = procs.caffeinate_parents[cpid] == true,
            }
          end
        end
      end
    end
  end

  return agents
end

-- running→idle 遷移を検出してデスクトップ通知を出す。
-- update-right-status は window ごとに呼ばれるが、prev_state を即更新するので
-- 同一スキャンサイクルでの二重通知は起きない。
local function detect_transitions(window, agents)
  local seen = {}
  for _, a in ipairs(agents) do
    seen[a.pid] = true
    local cur = a.running and "running" or "idle"
    local was = prev_state[a.pid]
    if was == "running" and cur == "idle" then
      window:toast_notification(
        "Claude Code",
        "🟢→💤 [" .. a.workspace .. "] のエージェントが手空きになりました",
        nil,
        4000
      )
    end
    prev_state[a.pid] = cur
  end
  -- 死んだ claude pid を掃除 (メモリリーク防止)
  for pid in pairs(prev_state) do
    if not seen[pid] then
      prev_state[pid] = nil
    end
  end
end

-- right-status 用の整形済みテキストを返す。副作用で通知も発火する。
function M.render(window)
  local agents = M.scan()
  detect_transitions(window, agents)

  if #agents == 0 then
    return ""
  end

  local running, idle = {}, 0
  for _, a in ipairs(agents) do
    if a.running then
      running[#running + 1] = a.workspace
    else
      idle = idle + 1
    end
  end

  local elems = {}
  if #running > 0 then
    table.insert(elems, { Foreground = { Color = "#90c8a0" } }) -- green
    table.insert(elems, { Text = "🟢 " .. table.concat(running, " ") .. "  " })
  end
  if idle > 0 then
    table.insert(elems, { Foreground = { Color = "#6b7280" } }) -- dim
    table.insert(elems, { Text = "💤 " .. idle .. "  " })
  end

  return wezterm.format(elems)
end

-- 全エージェントの状態を toast で一覧表示する (キーバインドから呼ぶ用)
function M.show_summary(window)
  local agents = M.scan()
  if #agents == 0 then
    window:toast_notification("Claude Code", "稼働中のエージェントはありません", nil, 3000)
    return
  end
  local lines = {}
  for _, a in ipairs(agents) do
    local mark = a.running and "🟢 running" or "💤 idle"
    lines[#lines + 1] = mark .. "  [" .. a.workspace .. "]  pid=" .. a.pid
  end
  window:toast_notification("Claude Code agents", table.concat(lines, "\n"), nil, 5000)
end

return M
