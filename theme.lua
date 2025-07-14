-- ~/.config/nvim/lua/theme.lua
local M = {}

-- Кольорова схема
local colors = {
  bg = "#1a1b26",
  fg = "#c0caf5",
  accent = "#7aa2f7",
  dim = "#565f89",
}

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  
  vim.o.background = "dark"
  vim.g.colors_name = "centered_theme"
  
  local set = vim.api.nvim_set_hl
  local c = colors

  -- Базові налаштування
  set(0, "Normal", { fg = c.fg, bg = c.bg })
  
  -- Стилі для стартового екрану
  set(0, "StartLogo", { fg = c.accent })
  set(0, "StartTitle", { fg = c.fg, bold = true })
  set(0, "StartButton", { fg = c.fg })
  set(0, "StartButtonIcon", { fg = c.accent })
  set(0, "StartFooter", { fg = c.dim })
end

-- Функція для центрування тексту (додано на початок модуля)
local function center_text(text, width)
  local padding = math.floor((width - #text) / 2)
  if padding < 0 then padding = 0 end
  return string.rep(" ", padding) .. text
end

-- Функція для створення центрованого блоку з лівим вирівнюванням
local function centered_block(text_lines, total_width)
  local max_len = 0
  for _, line in ipairs(text_lines) do
    max_len = math.max(max_len, #line)
  end
  
  local padding = math.floor((total_width - max_len) / 2)
  if padding < 0 then padding = 0 end
  
  local result = {}
  for _, line in ipairs(text_lines) do
    table.insert(result, string.rep(" ", padding) .. line)
  end
  
  return result, padding
end

function M.create_start_screen()
  local start_time = os.clock()

  -- Кнопки меню (ліве вирівнювання в центрованому блоці)
  local menu_items = {
    "󰈔  New",
    "󰈞  Search",
    "󰋚  Recent",
    "󰈬  Search in file",
    "  Config",
    "  Exit",
  }

  -- Дії для кнопок
  local menu_actions = {
    "enew",
    "Telescope find_files",
    "Telescope oldfiles",
    "Telescope live_grep",
    "e ~/.config/nvim/init.lua",
    "qa"
  }

  -- Статистика (ліве вирівнювання в центрованому блоці)
  local stats = {
    "󰂖 " .. vim.fn.len(vim.v.oldfiles) .. " Files open",
    "󱫋 " .. string.format("%.2fms start", (os.clock() - start_time) * 1000),
  }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  -- Налаштування буфера
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local win_width = vim.api.nvim_win_get_width(win)
  local win_height = vim.api.nvim_win_get_height(win)
  local lines = {}
  local highlights = {}

  -- Вираховуємо кількість контенту
  local content_lines = #menu_items + 1 + #stats -- меню + пустий рядок + статистика
  local vertical_padding = math.floor((win_height - content_lines) / 2)
  
  -- Додаємо пусті рядки зверху для вертикального центрування
  for i = 1, vertical_padding do
    table.insert(lines, "")
  end

  -- Додаємо меню (ліве вирівнювання в центрованому блоці)
  local menu_block, menu_padding = centered_block(menu_items, win_width)
  for i, line in ipairs(menu_block) do
    table.insert(lines, line)
    -- Підсвітка іконки
    table.insert(highlights, {
      line = #lines - 1,
      col_start = menu_padding,
      col_end = menu_padding + 2,
      hl_group = "StartButtonIcon"
    })
    -- Підсвітка тексту
    table.insert(highlights, {
      line = #lines - 1,
      col_start = menu_padding + 2,
      col_end = menu_padding + #menu_items[i],
      hl_group = "StartButton"
    })
  end

  table.insert(lines, "") -- Пустий рядок

  -- Додаємо статистику (ліве вирівнювання в центрованому блоці)
  local stats_block, stats_padding = centered_block(stats, win_width)
  for _, line in ipairs(stats_block) do
    table.insert(lines, line)
    table.insert(highlights, {
      line = #lines - 1,
      col_start = stats_padding,
      col_end = stats_padding + #line,
      hl_group = "StartFooter"
    })
  end

  -- Встановлюємо текст у буфер
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Застосовуємо підсвічування
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.hl_group, hl.line, hl.col_start, hl.col_end)
  end

  -- Навігація по меню
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local menu_start = vertical_padding + 1 -- Меню починається після вертикального відступу
    if line >= menu_start and line < menu_start + #menu_items then
      vim.cmd(menu_actions[line - menu_start + 1])
    end
  end, { buffer = buf })

  vim.keymap.set("n", "<Esc>", function() vim.cmd("enew") end, { buffer = buf })
end

function M.setup_autocmds()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.argc() == 0 then
        M.create_start_screen()
      end
    end
  })
end

return M