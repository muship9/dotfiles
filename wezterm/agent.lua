-- agent.lua — Claude Code セッションの状態を WezTerm 右ステータスに表示する。
--
-- 思想: WezTerm 本体はフォークしない。Claude Code のフックが OSC 1337 SetUserVar で
--   各ペインに push する CLAUDE_STATUS を pane:get_user_vars() で読むだけ。
--   (push 側: ~/.claude/notify-wezterm.sh + ~/.claude/settings.json の hooks)
--
--   CLAUDE_STATUS の値 -> 表示状態:
--     "working" -> working  処理中      (UserPromptSubmit / PostToolUse)
--     "pending" -> blocked  入力待ち    (Notification)
--     "done"    -> idle     応答完了    (Stop)
--     ""/未設定 -> エージェント無し       (SessionEnd で clear)
--
-- 旧実装は `claude` プロセスと `caffeinate` 副作用を ps で観測していたが、
-- フック (公式 API) ベースに置き換え、running/idle の2値から
-- blocked/working/idle の3値へ格上げした。デスクトップ通知は
-- notify-wezterm.sh 側の OSC9 が担うため、ここでは通知を出さない。

local wezterm = require("wezterm")

local M = {}

-- CLAUDE_STATUS の生値 -> 正規化した状態名
local function normalize(raw)
  if raw == "working" then return "working" end
  if raw == "pending" then return "blocked" end
  if raw == "done" then return "idle" end
  return nil
end

-- 全 mux ペインを走査して、CLAUDE_STATUS を持つペインの一覧を返す。
--   { { pane_id, workspace, state, title }, ... }
function M.scan()
  local agents = {}

  for _, win in ipairs(wezterm.mux.all_windows()) do
    local ws = win:get_workspace()
    for _, tab in ipairs(win:tabs()) do
      for _, pane in ipairs(tab:panes()) do
        local ok, vars = pcall(function()
          return pane:get_user_vars()
        end)
        if ok and vars then
          local state = normalize(vars.CLAUDE_STATUS)
          if state then
            local got_title, title = pcall(function() return pane:get_title() end)
            agents[#agents + 1] = {
              pane_id = pane:pane_id(),
              workspace = ws,
              state = state,
              title = (got_title and title) or "",
            }
          end
        end
      end
    end
  end

  return agents
end

-- workspace 名を重複なく順序維持で集める小道具
local function push_unique(list, seen, name)
  if not seen[name] then
    seen[name] = true
    list[#list + 1] = name
  end
end

-- right-status 用の整形済みテキストを返す。
-- 例: " ⏳ voc  🟢 biz-voc infra  💤 2 "
function M.render(_window)
  local agents = M.scan()
  if #agents == 0 then
    return ""
  end

  local blocked, working = {}, {}
  local blocked_seen, working_seen = {}, {}
  local idle = 0
  for _, a in ipairs(agents) do
    if a.state == "blocked" then
      push_unique(blocked, blocked_seen, a.workspace)
    elseif a.state == "working" then
      push_unique(working, working_seen, a.workspace)
    else
      idle = idle + 1
    end
  end

  local elems = {}
  -- blocked (要対応) を先頭に。黄色で目立たせる。
  if #blocked > 0 then
    table.insert(elems, { Foreground = { Color = "#e0c888" } })
    table.insert(elems, { Text = "⏳ " .. table.concat(blocked, " ") .. "  " })
  end
  if #working > 0 then
    table.insert(elems, { Foreground = { Color = "#90c8a0" } }) -- green
    table.insert(elems, { Text = "🟢 " .. table.concat(working, " ") .. "  " })
  end
  if idle > 0 then
    table.insert(elems, { Foreground = { Color = "#6b7280" } }) -- dim
    table.insert(elems, { Text = "💤 " .. idle .. "  " })
  end

  return wezterm.format(elems)
end

-- pane_id から mux の window/tab/pane を引く
local function find_pane(pane_id)
  for _, win in ipairs(wezterm.mux.all_windows()) do
    for _, tab in ipairs(win:tabs()) do
      for _, p in ipairs(tab:panes()) do
        if p:pane_id() == pane_id then
          return win, tab, p
        end
      end
    end
  end
  return nil
end

local STATE_ORDER = { working = 1, blocked = 2, idle = 3 }
local STATE_MARK = { blocked = "⏳", working = "🟢", idle = "💤" }

-- 全エージェントを一覧 (blocked→working→idle 順) し、選んだペインへジャンプする。
-- herdr のサイドバー相当を InputSelector で軽量に再現したもの。
function M.switcher(window, pane)
  local agents = M.scan()
  if #agents == 0 then
    window:toast_notification("Claude Code", "稼働中のエージェントはありません", nil, 3000)
    return
  end

  table.sort(agents, function(a, b)
    local oa, ob = STATE_ORDER[a.state] or 9, STATE_ORDER[b.state] or 9
    if oa ~= ob then return oa < ob end
    return a.workspace < b.workspace
  end)

  local choices = {}
  for _, a in ipairs(agents) do
    local label = a.title ~= "" and a.title or ("pane " .. a.pane_id)
    choices[#choices + 1] = {
      id = tostring(a.pane_id),
      label = (STATE_MARK[a.state] or "") .. " [" .. a.workspace .. "] " .. label,
    }
  end

  window:perform_action(
    wezterm.action.InputSelector({
      title = "Claude agents",
      fuzzy = true,
      choices = choices,
      action = wezterm.action_callback(function(win, p, id, _label)
        if not id then return end -- キャンセル
        local mwin, mtab, mpane = find_pane(tonumber(id))
        if not mpane then
          win:toast_notification("Claude Code", "ペインが見つかりません", nil, 3000)
          return
        end
        -- そのペインのある workspace に切替えてから tab/pane をアクティブ化
        win:perform_action(wezterm.action.SwitchToWorkspace({ name = mwin:get_workspace() }), p)
        mtab:activate()
        mpane:activate()
      end),
    }),
    pane
  )
end

-- 全エージェントの状態を toast で一覧表示する (キーバインドから呼ぶ用)
function M.show_summary(window)
  local agents = M.scan()
  if #agents == 0 then
    window:toast_notification("Claude Code", "稼働中のエージェントはありません", nil, 3000)
    return
  end
  local mark = { blocked = "⏳ blocked", working = "🟢 working", idle = "💤 idle" }
  local lines = {}
  for _, a in ipairs(agents) do
    local label = a.title ~= "" and a.title or ("pane " .. a.pane_id)
    lines[#lines + 1] = (mark[a.state] or a.state) .. "  [" .. a.workspace .. "]  " .. label
  end
  window:toast_notification("Claude Code agents", table.concat(lines, "\n"), nil, 5000)
end

return M
