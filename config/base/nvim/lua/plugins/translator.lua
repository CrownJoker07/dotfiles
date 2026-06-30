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

local function copy_translation(text)
  vim.fn.setreg('"', text)
  vim.fn.setreg("0", text)
  pcall(vim.fn.setreg, "+", text)
end

local function get_python()
  local python = vim.g.python3_host_prog or "python3"
  if vim.fn.executable(python) == 0 then
    vim.notify("python3 is required for translation", vim.log.levels.ERROR)
    return nil
  end
  return python
end

local function get_dict_engines()
  local engines = vim.g.translator_default_engines or { "bing", "haici" }
  return vim.tbl_filter(function(engine)
    return engine ~= "google"
  end, engines)
end

local function build_dict_content(payload)
  local marker = "- "
  local content = {}
  local text = payload.text or ""

  if #text > 30 then
    text = text:sub(1, 30) .. "..."
  end
  table.insert(content, ("[ %s ]"):format(text))

  for _, result in ipairs(payload.results or {}) do
    if result.paraphrase ~= "" or #(result.explains or {}) > 0 then
      table.insert(content, "")
      table.insert(content, ("--- %s ---"):format(result.engine or "dict"))

      if result.phonetic and result.phonetic ~= "" then
        table.insert(content, marker .. "[" .. result.phonetic .. "]")
      end

      if result.paraphrase and result.paraphrase ~= "" then
        table.insert(content, marker .. result.paraphrase)
      end

      for _, explain in ipairs(result.explains or {}) do
        explain = vim.trim(explain)
        if explain ~= "" then
          table.insert(content, marker .. explain)
        end
      end
    end
  end

  return table.concat(content, "\n")
end

local function translate_google_text(text)
  text = vim.trim(text or "")
  if text == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  local python = get_python()
  if not python then
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
        copy_translation(translated)
        show_translation(translated)
        vim.notify("Translation copied", vim.log.levels.INFO)
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

local function translate_dict_word()
  local text = vim.trim(vim.fn.expand("<cword>"))
  if text == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end

  local python = get_python()
  if not python then
    return
  end

  local engines = get_dict_engines()
  if #engines == 0 then
    vim.notify("No non-Google translator engines configured", vim.log.levels.ERROR)
    return
  end

  local script = vim.fn.stdpath("data") .. "/lazy/vim-translator/script/translator.py"
  if vim.fn.filereadable(script) == 0 then
    vim.notify("vim-translator Python script not found", vim.log.levels.ERROR)
    return
  end

  local cmd = {
    python,
    script,
    "--target_lang",
    vim.g.translator_target_lang or "zh",
    "--source_lang",
    vim.g.translator_source_lang or "auto",
    text,
    "--engines",
  }
  vim.list_extend(cmd, engines)

  vim.notify("Translating...", vim.log.levels.INFO)
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local message = vim.trim(result.stderr or "")
        if message == "" then
          message = "Dictionary translation failed"
        end
        vim.notify(message, vim.log.levels.ERROR)
        return
      end

      local ok, payload = pcall(vim.json.decode, result.stdout or "")
      if not ok or type(payload) ~= "table" then
        vim.notify("Dictionary translation returned invalid data", vim.log.levels.ERROR)
        return
      end

      local content = build_dict_content(payload)
      if content ~= "" then
        copy_translation(content)
        show_translation(content)
        vim.notify("Translation copied", vim.log.levels.INFO)
      else
        vim.notify("Dictionary returned an empty translation", vim.log.levels.WARN)
      end
    end)
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
        translate_dict_word,
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
