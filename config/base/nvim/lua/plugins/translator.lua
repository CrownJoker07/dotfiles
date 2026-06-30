local function get_visual_text()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local lines = vim.fn.getline(start_line, end_line)
  if #lines == 0 then
    return ""
  end

  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col, end_col)
  else
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  return vim.trim(table.concat(lines, "\n"))
end

local function show_translation(text)
  local lines = vim.split(text, "\n", { plain = true })
  vim.lsp.util.open_floating_preview(lines, "text", {
    border = "rounded",
    max_width = 80,
  })
end

local function translate_google_text(text)
  text = vim.trim(text or "")
  if text == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  local python = vim.g.python3_host_prog or "python3"
  if vim.fn.executable(python) == 0 then
    vim.notify("python3 is required for Google translation", vim.log.levels.ERROR)
    return
  end

  vim.notify("Translating...", vim.log.levels.INFO)

  local script = [[
import json
import socket
import sys
import urllib.parse
import urllib.error
import urllib.request

source_lang, target_lang = sys.argv[1], sys.argv[2]
text = sys.stdin.read()
# Request only the main translation. vim-translator's Google alternative parser
# can crash on some multi-line selections because Google returns sparse entries.
data = urllib.parse.urlencode({
    "client": "gtx",
    "sl": source_lang,
    "tl": target_lang,
    "dt": "t",
    "q": text,
}).encode("utf-8")
request = urllib.request.Request(
    "https://translate.googleapis.com/translate_a/single",
    data=data,
    headers={"Content-Type": "application/x-www-form-urlencoded; charset=utf-8"},
    method="POST",
)
try:
    with urllib.request.urlopen(request, timeout=8) as response:
        payload = json.loads(response.read().decode("utf-8"))
except urllib.error.URLError as exc:
    reason = getattr(exc, "reason", exc)
    print(f"Google translation failed: {reason}", file=sys.stderr)
    raise SystemExit(1)
except (TimeoutError, socket.timeout):
    print("Google translation failed: request timed out", file=sys.stderr)
    raise SystemExit(1)

print("".join(part[0] for part in payload[0] if part and part[0]))
]]

  vim.system({ python, "-c", script, "auto", vim.g.translator_target_lang or "zh" }, { text = true, stdin = text }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local message = vim.trim(result.stderr or "")
        if message == "" then
          message = "Google translation failed"
        end
        vim.notify(message, vim.log.levels.ERROR)
        return
      end

      local translated = vim.trim(result.stdout or "")
      if translated ~= "" then
        show_translation(translated)
      else
        vim.notify("Google returned an empty translation", vim.log.levels.WARN)
      end
    end)
  end)
end

local function translate_google_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  vim.schedule(function()
    translate_google_text(get_visual_text())
  end)
end

return {
  {
    "voldikss/vim-translator",
    cmd = {
      "Translate",
      "TranslateW",
      "TranslateR",
      "TranslateX",
    },
    init = function()
      vim.g.translator_target_lang = "zh"
      vim.g.translator_source_lang = "auto"
      vim.g.translator_default_engines = { "bing", "haici" }
    end,
    keys = {
      {
        "<leader>tw",
        "<cmd>TranslateW<CR>",
        mode = "n",
        desc = "Translate word",
      },
      {
        "<leader>tw",
        translate_google_selection,
        mode = "x",
        desc = "Translate selection",
      },
    },
  },
}
