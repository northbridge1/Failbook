-- Failbook_UI.lua (3.3.5a) - v2.0

FailbookUI = {}

local UIL = (Failbook and Failbook.L) or {}
local function UIX(key, fallback)
  local v = UIL[key]
  if v == nil or v == "" then return fallback or key end
  return v
end

local function UIF(key, fallback, ...)
  local fmt = UIX(key, fallback)
  if select("#", ...) > 0 then
    return string.format(fmt, ...)
  end
  return fmt
end

local function SortedKeysPlayers(t)
  local keys = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      local visible = true
      if Failbook and Failbook.IsRecordVisible then
        visible = Failbook:IsRecordVisible(k)
      end
      if visible then
        table.insert(keys, k)
      end
    end
  end
  table.sort(keys)
  return keys
end

local function CreateSizer(parent, point, w, h, sizing)
  local s = CreateFrame("Button", nil, parent)
  s:SetPoint(unpack(point))
  s:SetWidth(w)
  s:SetHeight(h)
  s:EnableMouse(true)
  s:SetFrameStrata(parent:GetFrameStrata())
  s:SetFrameLevel(parent:GetFrameLevel() + 2)
  s:SetScript("OnMouseDown", function(_, btn)
    if btn == "LeftButton" then parent:StartSizing(sizing) end
  end)
  s:SetScript("OnMouseUp", function() parent:StopMovingOrSizing() end)
  -- Marca visual de redimensionado (solo esquina inferior derecha)
  if sizing == "BOTTOMRIGHT" then
    local tex = s:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(s)
    tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    s:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    s:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  end
  return s
end

local function AdjustFontSize(fs, delta)
  if not fs or not fs.GetFont or not fs.SetFont then return end
  local font, size, flags = fs:GetFont()
  if font and size then
    fs:SetFont(font, size + delta, flags)
  end
end

local THEME_OUTER_BG = { 0.06, 0.07, 0.10, 0.92 }
local THEME_OUTER_BORDER = { 0.44, 0.44, 0.50, 0.92 }
local THEME_PANEL_BG = { 0.11, 0.12, 0.16, 0.86 }
local THEME_PANEL_BORDER = { 0.46, 0.46, 0.52, 0.85 }

local function ApplyThemeBackdrop(frame, bg, border, edgeSize, inset)
  edgeSize = edgeSize or 12
  inset = inset or 3
  frame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = edgeSize,
    insets = { left = inset, right = inset, top = inset, bottom = inset }
  })
  bg = bg or THEME_PANEL_BG
  border = border or THEME_PANEL_BORDER
  frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
  if frame.SetBackdropBorderColor then
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
  end
end

local function CreateUI()
  local f = CreateFrame("Frame", "FailbookFrame", UIParent)

  -- Base (25% más estrecha aprox)
  local BASE_MIN_W, BASE_MIN_H = 465, 288
  local GAP = 14
  local NOTE_SHRINK = 20
  local LEFT_SHRINK = 40
  local MIN_LEFT_W = 150

  f:SetWidth(BASE_MIN_W)
  f:SetHeight(BASE_MIN_H)
  f:SetMinResize(BASE_MIN_W, BASE_MIN_H)
  f:SetMaxResize(1400, 900)
  f:SetResizable(true)
  f:SetPoint("CENTER", 0, -40)
  ApplyThemeBackdrop(f, THEME_OUTER_BG, THEME_OUTER_BORDER, 16, 4)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()

  local titlePlate = CreateFrame("Frame", nil, f)
  titlePlate:SetPoint("TOP", f, "TOP", 0, 10)
  titlePlate:SetFrameStrata(f:GetFrameStrata())
  titlePlate:SetFrameLevel(f:GetFrameLevel() + 2)
  titlePlate:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
  })
  titlePlate:SetBackdropColor(0.08, 0.26, 0.70, 1)
  if titlePlate.SetBackdropBorderColor then
    titlePlate:SetBackdropBorderColor(1, 1, 1, 1)
  end

  local titleFill = titlePlate:CreateTexture(nil, "BACKGROUND")
  titleFill:SetTexture(0.08, 0.26, 0.70, 1)
  titleFill:SetPoint("TOPLEFT", titlePlate, "TOPLEFT", 10, -10)
  titleFill:SetPoint("BOTTOMRIGHT", titlePlate, "BOTTOMRIGHT", -10, 10)

  local title = titlePlate:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("CENTER", titlePlate, "CENTER", 0, -1)
  title:SetTextColor(1, 1, 1)
  title:SetShadowOffset(1, -1)
  title:SetShadowColor(0, 0, 0, 1)
  AdjustFontSize(title, 1)
  title:SetText("failbook")

  local titlePlateW = math.max(180, math.ceil((title:GetStringWidth() or 0) + 58))
  if titlePlateW > 220 then titlePlateW = 220 end
  local titlePlateH = math.max(40, math.ceil((title:GetStringHeight() or 0) + 16))
  if titlePlateH > 44 then titlePlateH = 44 end
  titlePlate:SetWidth(titlePlateW)
  titlePlate:SetHeight(titlePlateH)


  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:ClearAllPoints()
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetFrameStrata(f:GetFrameStrata())
  close:SetFrameLevel(f:GetFrameLevel() + 2)

  local helpFrame = CreateFrame("Frame", nil, f)
  helpFrame:SetWidth(440)
  helpFrame:SetHeight(320)
  helpFrame:SetPoint("CENTER", f, "CENTER", 0, -4)
  helpFrame:SetFrameStrata("FULLSCREEN_DIALOG")
  helpFrame:SetFrameLevel(f:GetFrameLevel() + 30)
  ApplyThemeBackdrop(helpFrame, THEME_OUTER_BG, THEME_OUTER_BORDER, 16, 4)
  helpFrame:Hide()

  local helpTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  helpTitle:SetPoint("TOPLEFT", 14, -14)
  helpTitle:SetWidth(250)
  helpTitle:SetJustifyH("LEFT")
  helpTitle:SetTextColor(1, 0.82, 0)
  helpTitle:SetText(UIX("UI_HELP_TITLE", "Help"))

  local helpSyncTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  helpSyncTitle:SetPoint("TOP", helpFrame, "TOP", 0, -44)
  helpSyncTitle:SetWidth(382)
  helpSyncTitle:SetJustifyH("CENTER")
  helpSyncTitle:SetTextColor(1, 0.82, 0)
  helpSyncTitle:SetText(UIX("UI_HELP_SYNC_TITLE", "Character sync"))

  local helpSyncText = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  helpSyncText:SetPoint("TOPLEFT", 24, -80)
  helpSyncText:SetWidth(382)
  helpSyncText:SetJustifyH("LEFT")
  helpSyncText:SetJustifyV("TOP")
  helpSyncText:SetText(UIX("UI_HELP_SYNC_BODY", [[1. On both characters, add the other one to Sync targets.
2. The first time, one sends the request and the other accepts it.
3. After that, they stay paired and sync automatically.
4. Resend only repeats a pending request.]]))

  local helpBanTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  helpBanTitle:SetPoint("TOP", helpSyncText, "BOTTOM", 0, -16)
  helpBanTitle:SetWidth(382)
  helpBanTitle:SetJustifyH("CENTER")
  helpBanTitle:SetTextColor(1, 0.82, 0)
  helpBanTitle:SetText(UIX("UI_HELP_BAN_TITLE", "Ban rules"))

  local helpBanText = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  helpBanText:SetPoint("TOP", helpBanTitle, "BOTTOM", 0, -8)
  helpBanText:SetWidth(382)
  helpBanText:SetJustifyH("LEFT")
  helpBanText:SetJustifyV("TOP")
  helpBanText:SetText(UIX("UI_HELP_BAN_BODY", [[1. The addon alerts you with a message when a listed player joins your party or raid.
2. Normal notes last 30 days.
3. When they expire, the name disappears from the list and stops alerting, but the record can still be synced.
4. If that player signs up again, the addon offers 30 more days or a permanent ban.]]))

  local helpAckTitle = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  helpAckTitle:SetPoint("TOP", helpBanText, "BOTTOM", 0, -16)
  helpAckTitle:SetWidth(382)
  helpAckTitle:SetJustifyH("CENTER")
  helpAckTitle:SetTextColor(1, 0.82, 0)
  AdjustFontSize(helpAckTitle, -4)
  helpAckTitle:SetText(UIX("UI_HELP_ACK_TITLE", "Acknowledgements"))

  local helpAckText = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  helpAckText:SetPoint("TOP", helpAckTitle, "BOTTOM", 0, -6)
  helpAckText:SetWidth(340)
  helpAckText:SetJustifyH("CENTER")
  helpAckText:SetJustifyV("TOP")
  AdjustFontSize(helpAckText, -1)
  helpAckText:SetText(UIX("UI_HELP_ACK_BODY", "Thanks to Jenss and Tierra for their help and collaboration in the development of Failbook."))

  local helpClose = CreateFrame("Button", nil, helpFrame, "UIPanelButtonTemplate")
  helpClose:SetWidth(90)
  helpClose:SetHeight(20)
  helpClose:SetText(UIX("UI_CLOSE", "Close"))
  helpClose:SetScript("OnClick", function() helpFrame:Hide() end)

  local function RefreshHelpLayout()
    local syncH = helpSyncText:GetStringHeight() or 0
    local banTitleH = helpBanTitle:GetStringHeight() or 0
    local banH = helpBanText:GetStringHeight() or 0
    local ackTitleH = helpAckTitle:GetStringHeight() or 0
    local ackH = helpAckText:GetStringHeight() or 0
    local closeGap = 12
    local bottomPad = 16
    local totalH = 78 + syncH + 16 + banTitleH + 8 + banH + 16 + ackTitleH + 6 + ackH + closeGap + helpClose:GetHeight() + bottomPad
    if totalH < 320 then totalH = 320 end
    helpFrame:SetHeight(totalH)
    helpClose:ClearAllPoints()
    helpClose:SetPoint("TOP", helpAckText, "BOTTOM", 0, -closeGap)
  end

  RefreshHelpLayout()
  helpFrame:SetScript("OnShow", function() RefreshHelpLayout() end)

  -- Sizers
  CreateSizer(f, {"BOTTOMRIGHT", f, "BOTTOMRIGHT", -6, 6}, 18, 18, "BOTTOMRIGHT")
  CreateSizer(f, {"BOTTOMLEFT",  f, "BOTTOMLEFT",  6, 6}, 18, 18, "BOTTOMLEFT")
  -- Sin sizer en TOPRIGHT para no solapar el botón de cerrar.
  -- El redimensionado superior sigue disponible por borde TOP y RIGHT.
  CreateSizer(f, {"TOPLEFT",     f, "TOPLEFT",     6, -6}, 18, 18, "TOPLEFT")
  CreateSizer(f, {"LEFT",  f, "LEFT",  0, 0}, 10, 120, "LEFT")
  CreateSizer(f, {"RIGHT", f, "RIGHT", 0, 0}, 10, 120, "RIGHT")
  CreateSizer(f, {"TOP",   f, "TOP",   0, 0}, 120, 10, "TOP")
  CreateSizer(f, {"BOTTOM",f, "BOTTOM",0, 0}, 120, 10, "BOTTOM")

  -- Botón Opciones
  local optBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  optBtn:SetWidth(90)
  optBtn:SetHeight(22)
  optBtn:SetText(UIX("UI_OPTIONS", "Options"))
  optBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 18, 38)

  local helpBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  helpBtn:SetWidth(22)
  helpBtn:SetHeight(22)
  helpBtn:SetText("?")
  helpBtn:Hide()
  helpBtn:SetScript("OnClick", function()
    if helpFrame:IsShown() then helpFrame:Hide() else helpFrame:Show() end
  end)
  helpBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(UIX("UI_HELP", "Help"), 1, 1, 1)
    GameTooltip:Show()
  end)
  helpBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  -- ===== Persistencia tamaño (SavedVariables) =====
  FailbookDB = FailbookDB or {}
  FailbookDB.ui = FailbookDB.ui or {}
  local uiSave = FailbookDB.ui

  local function SetFrameSize(w, h)
    f._internalSizeChange = true
    if w then f:SetWidth(w) end
    if h then f:SetHeight(h) end
    f._internalSizeChange = nil
  end

  local optionsShown = false

  local function SaveCurrentSize()
    local w, h = f:GetWidth(), f:GetHeight()
    if optionsShown then
      uiSave.optW, uiSave.optH = w, h
    else
      uiSave.mainW, uiSave.mainH = w, h
    end
  end

  -- ===== Columna Izquierda: Jugador =====
  local nameLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  nameLabel:SetPoint("TOPLEFT", 38, -30)
  nameLabel:SetText(UIX("UI_PLAYER", "Player:"))
  nameLabel:SetTextColor(1.00, 0.82, 0.10)

  local nameBox = CreateFrame("EditBox", "FailbookPlayerNameBox", f, "InputBoxTemplate")
  nameBox:SetPoint("TOPLEFT", 38, -50)
  nameBox:SetHeight(20)
  nameBox:SetAutoFocus(false)

  local BTN_W, BTN_H = 68, 16

  local addBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  addBtn:SetWidth(BTN_W)
  addBtn:SetHeight(BTN_H)
  addBtn:SetText(UIX("UI_ADD", "Add"))

  local delBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  delBtn:SetWidth(BTN_W)
  delBtn:SetHeight(BTN_H)
  delBtn:SetText(UIX("UI_DELETE", "Delete"))

  local listBg = CreateFrame("Frame", nil, f)
  ApplyThemeBackdrop(listBg, THEME_PANEL_BG, THEME_PANEL_BORDER, 12, 3)

  local scroll = CreateFrame("ScrollFrame", "FailbookScroll", listBg, "FauxScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 6, -6)
  scroll:SetPoint("BOTTOMRIGHT", -28, 6)

  local rows, ROW_H, MAX_ROWS_CREATED = {}, 18, 24
  local selectedKey = nil
  local appendModeKey = nil
  local appendPrefix = nil

  local function IsBlankText(s)
    s = tostring(s or "")
    return s:gsub("%s+", "") == ""
  end

  for i=1, MAX_ROWS_CREATED do
    local row = CreateFrame("Button", nil, listBg)
    row:SetHeight(ROW_H)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetAllPoints(row)
    row.text:SetJustifyH("LEFT")
    row:SetScript("OnClick", function()
      if appendModeKey and appendModeKey ~= row.key then
        appendModeKey = nil
        appendPrefix = nil
      end
      selectedKey = row.key
      FailbookUI:Refresh()
    end)
    rows[i] = row
  end

  local function VisibleRows(bg, rowH, maxRows)
    local h = bg:GetHeight()
    if not h or h < 80 then return 5 end
    local usable = h - 16
    local n = math.floor(usable / rowH)
    if n < 5 then n = 5 end
    if n > maxRows then n = maxRows end
    return n
  end

  local function LayoutRowButtons(rowFrames, maxRows)
    for i=1, maxRows do
      local r = rowFrames[i]
      r:ClearAllPoints()
      if i == 1 then
        r:SetPoint("TOPLEFT", 8, -8)
        r:SetPoint("TOPRIGHT", -30, -8)
      else
        r:SetPoint("TOPLEFT", rowFrames[i-1], "BOTTOMLEFT", 0, 0)
        r:SetPoint("TOPRIGHT", rowFrames[i-1], "BOTTOMRIGHT", 0, 0)
      end
    end
  end
  LayoutRowButtons(rows, MAX_ROWS_CREATED)

  -- ===== Centro: Notas =====
  local noteLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  noteLabel:SetText(UIX("UI_NOTES", "Notes:"))
  noteLabel:SetTextColor(1.00, 0.82, 0.10)

  local noteBoxBg = CreateFrame("Frame", nil, f)
  ApplyThemeBackdrop(noteBoxBg, THEME_PANEL_BG, THEME_PANEL_BORDER, 12, 3)

  local noteScroll = CreateFrame("ScrollFrame", "FailbookNoteScroll", noteBoxBg, "UIPanelScrollFrameTemplate")
  noteScroll:SetPoint("TOPLEFT", 6, -6)
  noteScroll:SetPoint("BOTTOMRIGHT", -28, 6)

  local noteBox = CreateFrame("EditBox", nil, noteScroll)
  noteBox:SetMultiLine(true)
  noteBox:SetAutoFocus(false)
  noteBox:EnableMouse(true)
  noteBox:EnableKeyboard(true)
  noteBox:SetFontObject("ChatFontNormal")
  noteBox:SetTextInsets(4, 4, 4, 4)
  noteBox:SetWidth(1)
  noteBox:SetHeight(1)
  noteBox:SetText("")
  noteScroll:SetScrollChild(noteBox)

  -- Scrollbar de Notas: visible SOLO cuando hace falta (cuando el texto supera el marco)
  local noteScrollBar = _G[noteScroll:GetName() .. "ScrollBar"]
  local noteHasScroll = nil

  local function UpdateNoteScroll()
    -- Ajustar altura del EditBox al contenido (para que exista rango de scroll real)
    local visH = (noteScroll:GetHeight() or 200) - 6
    if visH < 50 then visH = 50 end

    local lines = 1
    if noteBox.GetNumLines then
      lines = noteBox:GetNumLines()
      if not lines or lines < 1 then lines = 1 end
    else
      local txt = noteBox:GetText() or ""
      local _, n = txt:gsub("\n", "\n")
      lines = (n or 0) + 1
    end

    local lineH = 14
    if noteBox.GetLineHeight then
      local lh = noteBox:GetLineHeight()
      if lh and lh > 0 then lineH = lh end
    end

    local desiredH = (lines * lineH) + 12
    if desiredH < visH then desiredH = visH end
    noteBox:SetHeight(desiredH)

    -- Actualizar rect y decidir si hay scroll
    noteScroll:UpdateScrollChildRect()
    local range = noteScroll:GetVerticalScrollRange() or 0
    local has = range > 0

    if has ~= noteHasScroll then
      noteHasScroll = has

      if noteScrollBar then
        if has then
          noteScrollBar:Show()
        else
          noteScrollBar:Hide()
          noteScroll:SetVerticalScroll(0)
        end
      end

      -- Cuando no hay scroll, ocupamos el espacio del scrollbar
      noteScroll:ClearAllPoints()
      noteScroll:SetPoint("TOPLEFT", 6, -6)
      if has then
        noteScroll:SetPoint("BOTTOMRIGHT", -28, 6)
      else
        noteScroll:SetPoint("BOTTOMRIGHT", -6, 6)
      end
    end

    -- Ajustar ancho del EditBox al ancho visible actual
    local visW = (noteScroll:GetWidth() or 200) - 6
    if visW < 50 then visW = 50 end
    noteBox:SetWidth(visW)
    noteScroll:UpdateScrollChildRect()
  end


  noteBox:SetScript("OnMouseDown", function() noteBox:SetFocus() end)
  noteBox:SetScript("OnMouseUp", function() noteBox:SetFocus() end)
  noteBox:SetScript("OnEscapePressed", function() noteBox:ClearFocus() end)
  noteBox:SetScript("OnTextChanged", function() UpdateNoteScroll() end)

  -- ===== Derecha: Targets (solo si opcionesShown) =====
  local tgtLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  tgtLabel:SetText(UIX("UI_SYNC_TARGETS", "Sync targets:"))
  tgtLabel:SetTextColor(1.00, 0.82, 0.10)

  local tgtBox = CreateFrame("EditBox", "FailbookTargetNameBox", f, "InputBoxTemplate")
  tgtBox:SetHeight(20)
  tgtBox:SetAutoFocus(false)

  local tgtAdd = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  tgtAdd:SetWidth(BTN_W)
  tgtAdd:SetHeight(BTN_H)
  tgtAdd:SetText(UIX("UI_ADD", "Add"))

  local tgtDel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  tgtDel:SetWidth(BTN_W)
  tgtDel:SetHeight(BTN_H)
  tgtDel:SetText(UIX("UI_DELETE", "Delete"))

  local tgtResend = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  tgtResend:SetWidth(BTN_W * 2 + 8)
  tgtResend:SetHeight(BTN_H)
  tgtResend:SetText(UIX("UI_RESEND", "Resend"))
  tgtResend:Disable()
  tgtResend:SetAlpha(0.5)

  local tgtListBg = CreateFrame("Frame", nil, f)
  ApplyThemeBackdrop(tgtListBg, THEME_PANEL_BG, THEME_PANEL_BORDER, 12, 3)

  local tgtScroll = CreateFrame("ScrollFrame", "FailbookTargetScroll", tgtListBg, "FauxScrollFrameTemplate")
  tgtScroll:SetPoint("TOPLEFT", 6, -6)
  tgtScroll:SetPoint("BOTTOMRIGHT", -28, 6)

  -- Mantener todos los controles del addon en el mismo strata que la ventana principal.
  -- Asi no quedan unos elementos por delante y otros por detras de otras ventanas.
  local _strata = f:GetFrameStrata()
  local _lvl = f:GetFrameLevel() + 2
  tgtBox:SetFrameStrata(_strata)
  tgtAdd:SetFrameStrata(_strata)
  tgtDel:SetFrameStrata(_strata)
  tgtResend:SetFrameStrata(_strata)
  tgtListBg:SetFrameStrata(_strata)
  tgtScroll:SetFrameStrata(_strata)
  tgtBox:SetFrameLevel(_lvl)
  tgtAdd:SetFrameLevel(_lvl)
  tgtDel:SetFrameLevel(_lvl)
  tgtResend:SetFrameLevel(_lvl)
  tgtListBg:SetFrameLevel(_lvl)
  tgtScroll:SetFrameLevel(_lvl + 1)


  local tgtRows, TROW_H, TMAX = {}, 18, 24
  local selectedTarget = nil

  for i=1, TMAX do
    local r = CreateFrame("Button", nil, tgtListBg)
    r:SetHeight(TROW_H)
    r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.text:SetAllPoints(r)
    r.text:SetJustifyH("LEFT")
    r:SetScript("OnClick", function()
      selectedTarget = r.key
      FailbookUI:Refresh()
    end)
    tgtRows[i] = r
  end
  LayoutRowButtons(tgtRows, TMAX)

  tgtLabel:Hide(); tgtBox:Hide(); tgtAdd:Hide(); tgtDel:Hide(); tgtResend:Hide(); tgtListBg:Hide()

  -- ===== Guardar =====
  local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  saveBtn:SetWidth(100)
  saveBtn:SetHeight(22)
  saveBtn:SetText(UIX("UI_SAVE", "Save"))
  saveBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -38, 38)

  helpBtn:ClearAllPoints()
  helpBtn:SetPoint("RIGHT", saveBtn, "LEFT", -6, 0)

  -- ===== Layout principal =====
  local function ApplyMinWidth(leftW)
    if optionsShown then
      -- mínimo con targets: base + (min left) + gap (aprox)
      local minW = BASE_MIN_W + math.max(MIN_LEFT_W, leftW or MIN_LEFT_W) + GAP
      f:SetMinResize(minW, BASE_MIN_H)
    else
      f:SetMinResize(BASE_MIN_W, BASE_MIN_H)
    end
  end

  local function EnsureEditFill(scrollFrame, editBox)
    local w = (scrollFrame:GetWidth() or 200) - 6
    local h = (scrollFrame:GetHeight() or 200) - 6
    if w < 50 then w = 50 end
    if h < 50 then h = 50 end
    editBox:SetWidth(w)
    editBox:SetHeight(h)
    scrollFrame:UpdateScrollChildRect()
  end

  local function ApplyLayout()
    local innerW = (f:GetWidth() or 570) - 36

    -- Left column width (variable) but shrunk
    local leftW = math.floor((innerW - GAP) / 3) - LEFT_SHRINK
    if leftW < MIN_LEFT_W then leftW = MIN_LEFT_W end

    ApplyMinWidth(leftW)

    local reserved = optionsShown and (leftW + GAP) or 0
    local notesW = innerW - leftW - GAP - reserved - NOTE_SHRINK
    if notesW < 220 then notesW = 220 end

    -- Name input aligned to buttons
    local rowW = (BTN_W * 2) + 8
    if rowW > leftW then rowW = leftW end
    nameBox:SetWidth(rowW - 20)
    if nameBox:GetWidth() < 60 then nameBox:SetWidth(60) end

    addBtn:ClearAllPoints()
    delBtn:ClearAllPoints()
    addBtn:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", -12, -6)
    delBtn:SetPoint("LEFT", addBtn, "RIGHT", 8, 0)

    -- Player list box
    listBg:ClearAllPoints()
    listBg:SetPoint("TOPLEFT", 18, -112)
    listBg:SetPoint("BOTTOMLEFT", 18, 72)
    listBg:SetWidth(leftW)

    -- Notes aligned with player list bottom
    noteLabel:ClearAllPoints()
    noteLabel:SetPoint("TOPLEFT", listBg, "TOPRIGHT", GAP, 80)

    noteBoxBg:ClearAllPoints()
    noteBoxBg:SetPoint("TOPLEFT", listBg, "TOPRIGHT", GAP, 60)
    noteBoxBg:SetPoint("BOTTOMLEFT", listBg, "BOTTOMRIGHT", GAP, 0) -- aligned bottom
    noteBoxBg:SetWidth(notesW)

    EnsureEditFill(noteScroll, noteBox)

    UpdateNoteScroll()

    -- Targets (if options shown) same size as player list
    if optionsShown then
      tgtLabel:Show(); tgtBox:Show(); tgtAdd:Show(); tgtDel:Show(); tgtResend:Show(); tgtListBg:Show()
      helpBtn:Show()

      tgtLabel:ClearAllPoints()
      tgtLabel:SetPoint("TOPLEFT", noteBoxBg, "TOPRIGHT", GAP + 20, 22)  -- align with "Jugador:"

      tgtBox:ClearAllPoints()
      tgtBox:SetPoint("TOPLEFT", noteBoxBg, "TOPRIGHT", GAP + 20, 2)    -- align with nameBox
      tgtBox:SetWidth(rowW - 20)
      if tgtBox:GetWidth() < 60 then tgtBox:SetWidth(60) end

      tgtAdd:ClearAllPoints()
      tgtDel:ClearAllPoints()
      tgtAdd:SetPoint("TOPLEFT", tgtBox, "BOTTOMLEFT", -12, -6)
      tgtDel:SetPoint("LEFT", tgtAdd, "RIGHT", 8, 0)

      tgtResend:ClearAllPoints()
      tgtResend:SetPoint("TOPLEFT", tgtAdd, "BOTTOMLEFT", 0, -2)
      tgtResend:SetWidth(BTN_W * 2 + 8)

      tgtListBg:ClearAllPoints()
      tgtListBg:SetPoint("TOPLEFT", noteBoxBg, "TOPRIGHT", GAP, -60)   -- align TOP with player list
      tgtListBg:SetPoint("BOTTOMLEFT", noteBoxBg, "BOTTOMRIGHT", GAP, 0)
      tgtListBg:SetWidth(leftW)
    else
      tgtLabel:Hide(); tgtBox:Hide(); tgtAdd:Hide(); tgtDel:Hide(); tgtResend:Hide(); tgtListBg:Hide()
      helpBtn:Hide()
      helpFrame:Hide()
    end
  end

  -- ===== Actions =====
  local function BeginReactivation(key, permanent)
    local players = Failbook and Failbook.GetPlayers and Failbook:GetPlayers() or {}
    local rec = players and players[key]
    local oldNote = (rec and rec.note) or ""
    local stamp = date("%Y-%m-%d %H:%M:%S")

    local ok = Failbook and Failbook.ReactivatePlayer and Failbook:ReactivatePlayer(key, permanent)
    if not ok then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. UIX("UI_REACTIVATE_FAILED", "Could not reactivate the record."))
      return
    end

    if oldNote ~= "" then
      appendPrefix = oldNote .. "\n\n----- [" .. stamp .. "] -----\n"
    else
      appendPrefix = "[" .. stamp .. "]\n"
    end
    appendModeKey = key
    selectedKey = key

    FailbookUI:Refresh()
    noteBox:SetText(appendPrefix)
    noteBox:SetFocus()
    noteBox:SetCursorPosition(string.len(appendPrefix))
  end

  StaticPopupDialogs["FAILBOOK_REACTIVATE_RECORD"] = {
    text = UIX("UI_REACTIVATE_TEXT", "This player has an archived note.\nReactivate for 30 days or mark permanent?\n\n%s"),
    button1 = UIX("UI_30_DAYS", "30 days"),
    button2 = UIX("UI_PERMANENT", "Permanent"),
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function(self, data)
      if not data or not data.key then return end
      BeginReactivation(data.key, false)
    end,
    OnCancel = function(self, data, reason)
      if reason ~= "clicked" then return end
      if not data or not data.key then return end
      BeginReactivation(data.key, true)
    end,
  }

  -- ===== Actions =====
  local function AddFromNameBox()
    local name = nameBox:GetText() or ""
    local ok, info, status = Failbook:AddPlayer(name, "")
    if ok then
      appendModeKey = nil
      appendPrefix = nil
      selectedKey = info
      FailbookUI:Refresh()
    else
      if status == "archived" and info then
        StaticPopup_Show("FAILBOOK_REACTIVATE_RECORD", info, nil, { key = info })
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. (info or UIX("UI_ERROR", "Error")))
      end
    end
  end

  nameBox:SetScript("OnEnterPressed", function() AddFromNameBox(); nameBox:ClearFocus() end)
  nameBox:SetScript("OnEscapePressed", function() nameBox:ClearFocus() end)
  addBtn:SetScript("OnClick", function() AddFromNameBox() end)

  delBtn:SetScript("OnClick", function()
    local target = selectedKey or nameBox:GetText()
    local ok, info = Failbook:RemovePlayer(target)
    if ok then selectedKey = nil; FailbookUI:Refresh()
    else DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. (info or UIX("UI_ERROR", "Error"))) end
  end)

  saveBtn:SetScript("OnClick", function()
    if not selectedKey then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. UIX("UI_SELECT_PLAYER", "Select a player from the list."))
      return
    end

    local finalText = noteBox:GetText() or ""
    if appendModeKey == selectedKey and appendPrefix then
      if string.sub(finalText, 1, string.len(appendPrefix)) == appendPrefix then
        finalText = appendPrefix .. string.sub(finalText, string.len(appendPrefix) + 1)
      else
        finalText = appendPrefix .. finalText
      end

      local suffix = string.sub(finalText, string.len(appendPrefix) + 1)
      if IsBlankText(suffix) then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. UIX("UI_WRITE_NEW_REASON", "Write a new reason below the separator."))
        return
      end
    end

    Failbook:SetNote(selectedKey, finalText)
    appendModeKey = nil
    appendPrefix = nil
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. UIF("UI_NOTE_SAVED_FOR", "Note saved for %s", selectedKey))
    noteBox:ClearFocus()
    FailbookUI:Refresh()
  end)

  local function AddTarget()
    local name = tgtBox:GetText() or ""
    local ok, info = Failbook:AddTarget(name)
    if ok then selectedTarget = info; FailbookUI:Refresh()
    else DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. (info or UIX("UI_ERROR", "Error"))) end
  end

  tgtBox:SetScript("OnEnterPressed", function() AddTarget(); tgtBox:ClearFocus() end)
  tgtBox:SetScript("OnEscapePressed", function() tgtBox:ClearFocus() end)
  tgtAdd:SetScript("OnClick", function() AddTarget() end)

  tgtDel:SetScript("OnClick", function()
    local t = selectedTarget or (tgtBox:GetText() or "")
    local ok, info = Failbook:RemoveTarget(t)
    if ok then selectedTarget = nil; FailbookUI:Refresh()
    else DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. (info or UIX("UI_ERROR", "Error"))) end
  end)

  tgtResend:SetScript("OnClick", function()
    local t = selectedTarget or (tgtBox:GetText() or "")
    if not t or t == "" then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. UIX("UI_SELECT_PENDING_TARGET", "Select a pending target."))
      return
    end
    if Failbook and Failbook.ResendPair then
      local ok, msg = Failbook:ResendPair(t)
      if msg and msg ~= "" then
        DEFAULT_CHAT_FRAME:AddMessage((ok and "|cff33ff99[Failbook]|r " or "|cffff3333[Failbook]|r ") .. msg)
      end
    end
    FailbookUI:Refresh()
  end)


  -- Toggle opciones con restauración de tamaño
  optBtn:SetScript("OnClick", function()
    if not optionsShown then
      uiSave.mainW, uiSave.mainH = f:GetWidth(), f:GetHeight()
      optionsShown = true
      local w = uiSave.optW or f:GetWidth()
      local h = uiSave.optH or f:GetHeight()
      -- asegurar mínimo al abrir
      local minW = BASE_MIN_W + MIN_LEFT_W + GAP
      if w < minW then w = minW end
      SetFrameSize(w, h)
    else
      uiSave.optW, uiSave.optH = f:GetWidth(), f:GetHeight()
      optionsShown = false
      helpFrame:Hide()
      local w = uiSave.mainW or f:GetWidth()
      local h = uiSave.mainH or f:GetHeight()
      if w < BASE_MIN_W then w = BASE_MIN_W end
      SetFrameSize(w, h)
    end
    FailbookUI:Refresh()
  end)

  -- ===== Refresh =====
  function f:Refresh()
    optBtn:SetText(UIX("UI_OPTIONS", "Options"))
    helpBtn:SetText("?")
    helpTitle:SetText(UIX("UI_HELP_TITLE", "Help"))
    helpSyncTitle:SetText(UIX("UI_HELP_SYNC_TITLE", "Character sync"))
    helpSyncText:SetText(UIX("UI_HELP_SYNC_BODY", [[1. On both characters, add the other one to Sync targets.
2. The first time, one sends the request and the other accepts it.
3. After that, they stay paired and sync automatically.
4. Resend only repeats a pending request.]]))
    helpBanTitle:SetText(UIX("UI_HELP_BAN_TITLE", "Ban rules"))
    helpBanText:SetText(UIX("UI_HELP_BAN_BODY", [[1. The addon alerts you with a message when a listed player joins your party or raid.
2. Normal notes last 30 days.
3. When they expire, the name disappears from the list and stops alerting, but the record can still be synced.
4. If that player signs up again, the addon offers 30 more days or a permanent ban.]]))
    helpAckTitle:SetText(UIX("UI_HELP_ACK_TITLE", "Acknowledgements"))
    helpAckText:SetText(UIX("UI_HELP_ACK_BODY", "Thanks to Jenss and Tierra for their help and collaboration in the development of Failbook."))
    helpClose:SetText(UIX("UI_CLOSE", "Close"))
    RefreshHelpLayout()
    ApplyLayout()

    -- Players
    local players = Failbook:GetPlayers()
    local keys = SortedKeysPlayers(players)

    local vis = VisibleRows(listBg, ROW_H, MAX_ROWS_CREATED)
    FauxScrollFrame_Update(scroll, #keys, vis, ROW_H)
    local offset = FauxScrollFrame_GetOffset(scroll)

    for i=1, vis do
      local idx = offset + i
      local row = rows[i]
      local key = keys[idx]
      if key then
        row:Show(); row.key = key
        if key == selectedKey then
          row.text:SetText("|cffffff00" .. key .. "|r")
        else
          row.text:SetText(key)
        end
      else
        row:Hide(); row.key = nil
      end
    end
    for i=vis+1, MAX_ROWS_CREATED do rows[i]:Hide(); rows[i].key=nil end

    if selectedKey and players[selectedKey] then
      local rec = players[selectedKey]
      nameBox:SetText(selectedKey)

      if appendModeKey == selectedKey and appendPrefix then
        local curTxt = noteBox:GetText() or ""
        if curTxt == "" or curTxt == (rec.note or "") or string.sub(curTxt, 1, string.len(appendPrefix)) ~= appendPrefix then
          noteBox:SetText(appendPrefix)
        end
        noteBox:EnableKeyboard(true)
        saveBtn:Enable()
      else
        noteBox:SetText(rec.note or "")
        local editable = true
        if Failbook and Failbook.IsRecordArchived and Failbook:IsRecordArchived(selectedKey) then
          editable = false
        end
        noteBox:EnableKeyboard(editable)
        if editable then
          saveBtn:Enable()
        else
          saveBtn:Disable()
        end
      end

      noteScroll:SetVerticalScroll(0)
      noteScroll:UpdateScrollChildRect()
      UpdateNoteScroll()
    else
      noteBox:SetText("")
      noteBox:EnableKeyboard(false)
      saveBtn:Disable()
    end

    UpdateNoteScroll()


    -- Targets (con scroll)
    if optionsShown then
      local targets = Failbook:GetTargets()
      local tkeys = {}
      for i, v in ipairs(targets) do tkeys[i] = v end
      table.sort(tkeys)

      -- Botón Reenviar: solo cuando el target seleccionado está pendiente (no emparejado)
      if selectedTarget and Failbook and Failbook.IsPending and Failbook:IsPending(selectedTarget) and (not Failbook.IsPaired or not Failbook:IsPaired(selectedTarget)) then
        tgtResend:Enable()
        tgtResend:SetAlpha(1)
      else
        tgtResend:Disable()
        tgtResend:SetAlpha(0.5)
      end

      local tvis = VisibleRows(tgtListBg, TROW_H, TMAX)
      FauxScrollFrame_Update(tgtScroll, #tkeys, tvis, TROW_H)
      local toff = FauxScrollFrame_GetOffset(tgtScroll)

      for i=1, tvis do
        local idx = toff + i
        local r = tgtRows[i]
        local key = tkeys[idx]
        if key then
          r:Show(); r.key = key
          if key == selectedTarget then
          r.text:SetText("|cffffff00" .. key .. "|r")
        else
          r.text:SetText(key)
        end
        else
          r:Hide(); r.key = nil
        end
      end
      for i=tvis+1, TMAX do tgtRows[i]:Hide(); tgtRows[i].key=nil end
    end
  end

  -- Scroll scripts
  scroll:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, ROW_H, function() f:Refresh() end)
  end)
  tgtScroll:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, TROW_H, function() f:Refresh() end)
  end)

  f:SetScript("OnShow", function()
    optionsShown = false
    helpBtn:Hide()
    helpFrame:Hide()
    SetFrameSize(BASE_MIN_W, BASE_MIN_H)
    uiSave.mainW, uiSave.mainH = BASE_MIN_W, BASE_MIN_H
    f:Refresh()
    if Failbook and Failbook.SyncNow then Failbook:SyncNow("ui_open") end
    if Failbook and Failbook.AlertOnUIOpen then Failbook:AlertOnUIOpen() end
  end)

  f:SetScript("OnHide", function()
    SaveCurrentSize()
    if Failbook and Failbook.SyncNow then Failbook:SyncNow("ui_close") end
  end)

  f:SetScript("OnSizeChanged", function()
    if not f._internalSizeChange then SaveCurrentSize() end
    f:Refresh()
  end)

  return f
end

local frame = CreateUI()

function FailbookUI:Toggle()
  if frame:IsShown() then frame:Hide() else frame:Show() end
end

function FailbookUI:Refresh()
  if frame and frame.Refresh then frame:Refresh() end
end
