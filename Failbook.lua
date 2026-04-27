-- Failbook.lua (3.3.5a) - v1.0

local ADDON = "Failbook"
FailbookDB = FailbookDB or {}

local PREFIX = "FAILBOOK"

local GAME_LOCALE = (GetLocale and GetLocale()) or "enUS"
local IS_SPANISH = (GAME_LOCALE == "esES" or GAME_LOCALE == "esMX")

local L = IS_SPANISH and {
  ALERT_IN_FAILBOOK = "%s está en Failbook. %s",
  ALERT_NOTE = "Nota: %s",
  PAIR_REQ_TEXT = "Failbook: %s quiere sincronizar contigo.\n¿Permitir emparejamiento?",
  PAIR_ALLOW = "Permitir",
  PAIR_REJECT = "Rechazar",
  PAIRED_WITH = "Emparejado con %s (cluster personal vinculado)",
  PAIR_REJECTED = "Emparejamiento rechazado: %s",
  INVALID_NAME = "Nombre inválido.",
  ALREADY_PAIRED = "Ya emparejado.",
  REQUEST_SENT = "Solicitud enviada a %s",
  SYNC_RECEIVED = "Sync recibido de %s (%d cambios)",
  ALREADY_LISTED = "Ya está en la lista.",
  NOT_IN_LIST = "No existe en la lista.",
  NOT_IN_HISTORY = "No existe en el historial.",
  PAIR_AUTO = "Emparejamiento automático con %s",
  PAIR_DONE = "Emparejamiento completado con %s",
  PAIR_REJECTED_BY = "Emparejamiento rechazado por %s",
  CLUSTER_NOT_SET = "Clave multicuenta no configurada.",
  CLUSTER_SET = "Clave multicuenta configurada.",
  CLUSTER_CLEARED = "Clave multicuenta borrada.",
  CLUSTER_SAVED = "Clave multicuenta guardada.",
  UI_OPTIONS = "Opciones",
  UI_PLAYER = "Jugador:",
  UI_ADD = "Añadir",
  UI_DELETE = "Borrar",
  UI_NOTES = "Notas:",
  UI_SYNC_TARGETS = "Sync targets:",
  UI_RESEND = "Reenviar",
  UI_SAVE = "Guardar",
  UI_REACTIVATE_FAILED = "No se pudo reactivar el registro.",
  UI_REACTIVATE_TEXT = "Este jugador tiene una nota archivada.\n¿Reactivar 30 días o marcar permanente?\n\n%s",
  UI_30_DAYS = "30 días",
  UI_PERMANENT = "Permanente",
  UI_ERROR = "Error",
  UI_SELECT_PLAYER = "Selecciona un jugador en la lista.",
  UI_WRITE_NEW_REASON = "Escribe un nuevo motivo debajo de la separación.",
  UI_NOTE_SAVED_FOR = "Nota guardada para %s",
  UI_SELECT_PENDING_TARGET = "Selecciona un target pendiente.",
  UI_HELP = "Ayuda",
  UI_HELP_TITLE = "Ayuda",
  UI_HELP_SYNC_TITLE = "Sincronización entre personajes",
  UI_HELP_SYNC_BODY = [[1. En ambos personajes, añade al otro en Sync targets.
2. La primera vez, uno envía la solicitud y el otro la acepta.
3. Después quedarán emparejados y se sincronizarán automáticamente.
4. Reenviar solo repite una solicitud pendiente.]],
  UI_HELP_BAN_TITLE = "Reglas de ban",
  UI_HELP_BAN_BODY = [[1. El addon avisa con un mensaje cuando entra en tu grupo o raid un jugador que está en la lista.
2. Las notas normales duran 30 días.
3. Al caducar, el nombre desaparece de la lista y deja de alertar, pero el registro sigue pudiendo sincronizarse.
4. Si ese jugador vuelve a inscribirse, el addon ofrece reactivarlo 30 días más o marcarlo como permanente.]],
  UI_HELP_ACK_TITLE = "Agradecimientos",
  UI_HELP_ACK_BODY = "Gracias a Jenss y Tierra por su ayuda y colaboración en el desarrollo de Failbook.",
  UI_CLOSE = "Cerrar",
} or {
  ALERT_IN_FAILBOOK = "%s is in Failbook. %s",
  ALERT_NOTE = "Note: %s",
  PAIR_REQ_TEXT = "Failbook: %s wants to sync with you.\nAllow pairing?",
  PAIR_ALLOW = "Allow",
  PAIR_REJECT = "Decline",
  PAIRED_WITH = "Paired with %s (personal cluster linked)",
  PAIR_REJECTED = "Pairing declined: %s",
  INVALID_NAME = "Invalid name.",
  ALREADY_PAIRED = "Already paired.",
  REQUEST_SENT = "Request sent to %s",
  SYNC_RECEIVED = "Sync received from %s (%d changes)",
  ALREADY_LISTED = "Already in the list.",
  NOT_IN_LIST = "Not found in the list.",
  NOT_IN_HISTORY = "Not found in history.",
  PAIR_AUTO = "Automatic pairing with %s",
  PAIR_DONE = "Pairing completed with %s",
  PAIR_REJECTED_BY = "Pairing declined by %s",
  CLUSTER_NOT_SET = "Multi-account key not configured.",
  CLUSTER_SET = "Multi-account key configured.",
  CLUSTER_CLEARED = "Multi-account key cleared.",
  CLUSTER_SAVED = "Multi-account key saved.",
  UI_OPTIONS = "Options",
  UI_PLAYER = "Player:",
  UI_ADD = "Add",
  UI_DELETE = "Delete",
  UI_NOTES = "Notes:",
  UI_SYNC_TARGETS = "Sync targets:",
  UI_RESEND = "Resend",
  UI_SAVE = "Save",
  UI_REACTIVATE_FAILED = "Could not reactivate the record.",
  UI_REACTIVATE_TEXT = "This player has an archived note.\nReactivate for 30 days or mark permanent?\n\n%s",
  UI_30_DAYS = "30 days",
  UI_PERMANENT = "Permanent",
  UI_ERROR = "Error",
  UI_SELECT_PLAYER = "Select a player from the list.",
  UI_WRITE_NEW_REASON = "Write a new reason below the separator.",
  UI_NOTE_SAVED_FOR = "Note saved for %s",
  UI_SELECT_PENDING_TARGET = "Select a pending target.",
  UI_HELP = "Help",
  UI_HELP_TITLE = "Help",
  UI_HELP_SYNC_TITLE = "Character sync",
  UI_HELP_SYNC_BODY = [[1. On both characters, add the other one to Sync targets.
2. The first time, one sends the request and the other accepts it.
3. After that, they stay paired and sync automatically.
4. Resend only repeats a pending request.]],
  UI_HELP_BAN_TITLE = "Ban rules",
  UI_HELP_BAN_BODY = [[1. The addon alerts you with a message when a listed player joins your party or raid.
2. Normal notes last 30 days.
3. When they expire, the name disappears from the list and stops alerting, but the record can still be synced.
4. If that player signs up again, the addon offers 30 more days or a permanent ban.]],
  UI_HELP_ACK_TITLE = "Acknowledgements",
  UI_HELP_ACK_BODY = "Thanks to Jenss and Tierra for their help and collaboration in the development of Failbook.",
  UI_CLOSE = "Close",
}

local function T(key, ...)
  local s = L[key] or key
  if select("#", ...) > 0 then
    return string.format(s, ...)
  end
  return s
end

local random = math.random
local floor = math.floor

if math and math.randomseed then
  math.randomseed((time and time()) or 1)
elseif randomseed then
  randomseed((time and time()) or 1)
end

local function Trim(s)
  if not s then return nil end
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function StripRealm(name)
  if not name then return nil end
  return name:gsub("%-.*$", "")
end

local function PrettyCap(name)
  if not name or name == "" then return nil end
  name = string.lower(name)
  local first = string.sub(name, 1, 1)
  local rest = string.sub(name, 2)
  return string.upper(first) .. rest
end

local function MakeKey(name)
  name = Trim(name)
  if not name or name == "" then return nil end
  name = StripRealm(name)
  name = Trim(name)
  if not name or name == "" then return nil end
  return PrettyCap(name)
end

local function GetSelfKey()
  local n = UnitName("player")
  return n and MakeKey(n) or "__unknown"
end

local function NowEpoch()
  local t = (time and time()) or 0
  local ms = 0
  if GetTime then
    local gt = GetTime()
    ms = floor((gt - floor(gt)) * 1000)
  end
  local stamp = (t * 1000) + ms
  local last = tonumber(FailbookDB._clock or 0) or 0
  if stamp <= last then stamp = last + 1 end
  FailbookDB._clock = stamp
  return stamp
end

local function CurrentStamp()
  local t = (time and time()) or 0
  local ms = 0
  if GetTime then
    local gt = GetTime()
    ms = floor((gt - floor(gt)) * 1000)
  end
  return (t * 1000) + ms
end

local ALERT_DAYS_DEFAULT = 30
local ALERT_WINDOW_MS = ALERT_DAYS_DEFAULT * 24 * 60 * 60 * 1000
local DELETED_TOMBSTONE_RETENTION_DAYS = 90
local DELETED_TOMBSTONE_RETENTION_MS = DELETED_TOMBSTONE_RETENTION_DAYS * 24 * 60 * 60 * 1000

local function DefaultExpiresAt()
  return CurrentStamp() + ALERT_WINDOW_MS
end

local function IsRecordActive(rec)
  if type(rec) ~= "table" then return false end
  if tonumber(rec.deletedAt or 0) > 0 then return false end
  if rec.permanent then return true end
  local ex = tonumber(rec.expiresAt or 0) or 0
  return ex > 0 and ex > CurrentStamp()
end

local function IsRecordArchived(rec)
  if type(rec) ~= "table" then return false end
  if tonumber(rec.deletedAt or 0) > 0 then return false end
  if rec.permanent then return false end
  local ex = tonumber(rec.expiresAt or 0) or 0
  return ex > 0 and ex <= CurrentStamp()
end

local EnsurePairing
local InferClusterCreatedAt
EnsurePairing = function()
  if type(FailbookDB.pairing) ~= "table" then FailbookDB.pairing = {} end
  local P = FailbookDB.pairing
  if type(P.pairs) ~= "table" then P.pairs = {} end
  if type(P.pendingOut) ~= "table" then P.pendingOut = {} end
  if type(P.pendingIn) ~= "table" then P.pendingIn = {} end
  if type(P.lastSync) ~= "table" then P.lastSync = {} end

  local selfKey = GetSelfKey()
  if type(P.pairs[selfKey]) ~= "table" then P.pairs[selfKey] = {} end
  if type(P.pendingOut[selfKey]) ~= "table" then P.pendingOut[selfKey] = {} end
  if type(P.pendingIn[selfKey]) ~= "table" then P.pendingIn[selfKey] = {} end
  if type(P.lastSync[selfKey]) ~= "table" then P.lastSync[selfKey] = {} end

  if type(FailbookDB.pairs) == "table" then
    for k, v in pairs(FailbookDB.pairs) do
      if type(v) == "table" and v.key then
        P.pairs[selfKey][k] = P.pairs[selfKey][k] or { key = v.key }
      end
    end
    FailbookDB.pairs = nil
  end
  if type(FailbookDB.pendingPairs) == "table" then
    for k, v in pairs(FailbookDB.pendingPairs) do
      P.pendingOut[selfKey][k] = v
    end
    FailbookDB.pendingPairs = nil
  end
  if type(FailbookDB.pendingInbound) == "table" then
    for k, v in pairs(FailbookDB.pendingInbound) do
      P.pendingIn[selfKey][k] = v
    end
    FailbookDB.pendingInbound = nil
  end
  if type(FailbookDB.lastSync) == "table" then
    for k, v in pairs(FailbookDB.lastSync) do
      P.lastSync[selfKey][k] = v
    end
    FailbookDB.lastSync = nil
  end

  return P, selfKey
end

local function EnsureDB()
  if type(FailbookDB) ~= "table" then FailbookDB = {} end
  if type(FailbookDB.players) ~= "table" then FailbookDB.players = {} end
  if type(FailbookDB.settings) ~= "table" then
    FailbookDB.settings = { alertRW = true, alertChat = true, alertSound = true, leaderOnly = false, clusterKey = "", clusterCreatedAt = 0 }
  end
  if FailbookDB.settings.clusterKey == nil then FailbookDB.settings.clusterKey = "" end
  if FailbookDB.settings.clusterCreatedAt == nil then FailbookDB.settings.clusterCreatedAt = 0 end
  if type(FailbookDB.syncTargets) ~= "table" then FailbookDB.syncTargets = {} end
  EnsurePairing()

  local function FixTs(v)
    v = tonumber(v or 0) or 0
    if v > 0 and v < 10000000000 then return v * 1000 end
    return v
  end

  for _, rec in pairs(FailbookDB.players) do
    if type(rec) == "table" then
      rec.updatedAt = FixTs(rec.updatedAt)
      rec.deletedAt = FixTs(rec.deletedAt)
      rec.expiresAt = FixTs(rec.expiresAt)
      if rec.permanent == nil then rec.permanent = false end
      if (not rec.permanent) and (tonumber(rec.deletedAt or 0) == 0) and ((tonumber(rec.expiresAt or 0) or 0) == 0) then
        local base = tonumber(rec.updatedAt or 0) or 0
        if base <= 0 then base = CurrentStamp() end
        rec.expiresAt = base + ALERT_WINDOW_MS
      end
    end
  end

  if type(FailbookDB.pairing) == "table" and type(FailbookDB.pairing.lastSync) == "table" then
    for _, tbl in pairs(FailbookDB.pairing.lastSync) do
      if type(tbl) == "table" then
        for k, v in pairs(tbl) do tbl[k] = FixTs(v) end
      end
    end
  end

  FailbookDB._clock = FixTs(FailbookDB._clock)
  FailbookDB.settings.clusterCreatedAt = FixTs(FailbookDB.settings.clusterCreatedAt)

  local clusterKey = tostring(FailbookDB.settings.clusterKey or "")
  clusterKey = clusterKey:gsub("^%s+", ""):gsub("%s+$", "")
  FailbookDB.settings.clusterKey = clusterKey

  if clusterKey == "" then
    FailbookDB.settings.clusterCreatedAt = 0
  elseif (tonumber(FailbookDB.settings.clusterCreatedAt or 0) or 0) <= 0 then
    FailbookDB.settings.clusterCreatedAt = InferClusterCreatedAt()
  end
end

InferClusterCreatedAt = function()
  local earliest = 0
  local function Consider(v)
    v = tonumber(v or 0) or 0
    if v > 0 and (earliest == 0 or v < earliest) then earliest = v end
  end

  if type(FailbookDB) == "table" then
    Consider(FailbookDB._clock)

    if type(FailbookDB.players) == "table" then
      for _, rec in pairs(FailbookDB.players) do
        if type(rec) == "table" then
          Consider(rec.updatedAt)
          Consider(rec.deletedAt)
        end
      end
    end

    if type(FailbookDB.pairing) == "table" and type(FailbookDB.pairing.lastSync) == "table" then
      for _, bucket in pairs(FailbookDB.pairing.lastSync) do
        if type(bucket) == "table" then
          for _, ts in pairs(bucket) do Consider(ts) end
        end
      end
    end
  end

  if earliest > 0 then return earliest end
  return CurrentStamp()
end

local function PurgeOldDeletedRecords()
  local players = FailbookDB and FailbookDB.players
  if type(players) ~= "table" then return 0 end

  local now = CurrentStamp()
  local cutoff = now - DELETED_TOMBSTONE_RETENTION_MS
  local purgeKeys = nil

  for key, rec in pairs(players) do
    if type(rec) == "table" then
      local deletedAt = tonumber(rec.deletedAt or 0) or 0
      if deletedAt > 0 and deletedAt <= cutoff then
        if not purgeKeys then purgeKeys = {} end
        purgeKeys[#purgeKeys + 1] = key
      end
    end
  end

  if not purgeKeys then return 0 end

  for _, key in ipairs(purgeKeys) do
    players[key] = nil
  end

  return #purgeKeys
end

local function NormalizeClusterKey(s)
  s = tostring(s or "")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  return s
end

local function GetClusterKey()
  EnsureDB()
  return NormalizeClusterKey(FailbookDB.settings.clusterKey or "")
end

local function GetClusterCreatedAt()
  EnsureDB()
  local key = NormalizeClusterKey(FailbookDB.settings.clusterKey or "")
  if key == "" then return 0 end
  return tonumber(FailbookDB.settings.clusterCreatedAt or 0) or 0
end

local RefreshAllPairKeys

local function SetClusterIdentity(key, createdAt)
  EnsureDB()
  key = NormalizeClusterKey(key)
  local oldKey = NormalizeClusterKey(FailbookDB.settings.clusterKey or "")
  local oldCreatedAt = tonumber(FailbookDB.settings.clusterCreatedAt or 0) or 0
  if key == "" then
    FailbookDB.settings.clusterKey = ""
    FailbookDB.settings.clusterCreatedAt = 0
    return false
  end
  createdAt = tonumber(createdAt or 0) or 0
  if createdAt <= 0 then createdAt = CurrentStamp() end
  FailbookDB.settings.clusterKey = key
  FailbookDB.settings.clusterCreatedAt = createdAt
  if oldKey ~= key and RefreshAllPairKeys then
    RefreshAllPairKeys()
  elseif oldKey == key and oldCreatedAt <= 0 and createdAt > 0 and RefreshAllPairKeys then
    RefreshAllPairKeys()
  end
  return true
end

local function EnsureClusterKey()
  EnsureDB()
  local cur = GetClusterKey()
  if cur ~= "" then
    if GetClusterCreatedAt() <= 0 then SetClusterIdentity(cur, InferClusterCreatedAt()) end
    return cur
  end
  local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  local t = {}
  for i = 1, 24 do
    local idx = random(1, string.len(chars))
    t[i] = string.sub(chars, idx, idx)
  end
  cur = table.concat(t)
  SetClusterIdentity(cur, NowEpoch())
  return cur
end

local IsPaired
local SendToTarget

local function DoesRemoteClusterWin(localKey, localCreatedAt, remoteKey, remoteCreatedAt)
  localKey = NormalizeClusterKey(localKey)
  remoteKey = NormalizeClusterKey(remoteKey)
  localCreatedAt = tonumber(localCreatedAt or 0) or 0
  remoteCreatedAt = tonumber(remoteCreatedAt or 0) or 0

  if remoteKey == "" then return false end
  if localKey == "" then return true end
  if localKey == remoteKey then
    if localCreatedAt <= 0 and remoteCreatedAt > 0 then return true end
    if remoteCreatedAt > 0 and localCreatedAt > 0 and remoteCreatedAt < localCreatedAt then return true end
    return false
  end
  if remoteCreatedAt > 0 and localCreatedAt > 0 then
    if remoteCreatedAt < localCreatedAt then return true end
    if remoteCreatedAt > localCreatedAt then return false end
  elseif remoteCreatedAt > 0 and localCreatedAt <= 0 then
    return true
  elseif remoteCreatedAt <= 0 and localCreatedAt > 0 then
    return false
  end
  return tostring(remoteKey) < tostring(localKey)
end

local function SendClusterCorrection(targetKey, clusterKey, clusterCreatedAt)
  if not targetKey or targetKey == "" then return end
  clusterKey = NormalizeClusterKey(clusterKey)
  clusterCreatedAt = tonumber(clusterCreatedAt or 0) or 0
  if clusterKey == "" or clusterCreatedAt <= 0 then return end
  SendToTarget(targetKey, "CU	" .. clusterKey .. "	" .. tostring(clusterCreatedAt))
end

local function MaybeResolveClusterConflict(senderKey, remoteCluster, remoteCreatedAt, source)
  remoteCluster = NormalizeClusterKey(remoteCluster)
  remoteCreatedAt = tonumber(remoteCreatedAt or 0) or 0
  if remoteCluster == "" then return false end

  local localCluster = GetClusterKey()
  local localCreatedAt = GetClusterCreatedAt()

  if localCluster == "" then
    SetClusterIdentity(remoteCluster, remoteCreatedAt)
    if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
    return true
  end

  if localCluster == remoteCluster then
    if remoteCreatedAt > 0 and (localCreatedAt <= 0 or remoteCreatedAt < localCreatedAt) then
      FailbookDB.settings.clusterCreatedAt = remoteCreatedAt
    end
    return false
  end

  if DoesRemoteClusterWin(localCluster, localCreatedAt, remoteCluster, remoteCreatedAt) then
    SetClusterIdentity(remoteCluster, remoteCreatedAt)
    if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
    return true
  end

  if source ~= "correction" and IsPaired(senderKey) then
    SendClusterCorrection(senderKey, localCluster, localCreatedAt)
  end
  return false
end

local function IsTargetListed(nameKey)
  EnsureDB()
  if not nameKey or nameKey == "" then return false end
  for _, t in ipairs(FailbookDB.syncTargets) do
    if t == nameKey then return true end
  end
  return false
end

local function GetPair(remoteKey)
  local P, selfKey = EnsurePairing()
  return (P.pairs[selfKey] and P.pairs[selfKey][remoteKey]) or nil
end

IsPaired = function(remoteKey)
  local p = GetPair(remoteKey)
  return p and p.key
end

local function Hash32(str)
  local h = 2166136261
  for i = 1, string.len(str or "") do
    h = (h * 16777619) % 4294967296
    h = (h + string.byte(str, i)) % 4294967296
  end
  return tostring(h)
end

local function MakeAutoSig(nonce, senderKey, clusterKey)
  return Hash32("FBK1:" .. tostring(nonce or "") .. ":" .. tostring(senderKey or "") .. ":" .. tostring(clusterKey or ""))
end

local function MakeClusterPairKey(remoteKey)
  local ck = GetClusterKey()
  if ck == "" then return nil end
  local selfKey = GetSelfKey()
  local a, b = selfKey, remoteKey or ""
  if a > b then a, b = b, a end
  return "CK" .. Hash32("PAIR:" .. ck .. ":" .. a .. ":" .. b)
end

RefreshAllPairKeys = function()
  local cluster = GetClusterKey()
  if cluster == "" then return end
  local P, selfKey = EnsurePairing()
  local bucket = P.pairs[selfKey]
  if type(bucket) ~= "table" then return end
  for remoteKey, pair in pairs(bucket) do
    local pairKey = MakeClusterPairKey(remoteKey)
    if pairKey and pairKey ~= "" then
      if type(pair) ~= "table" then
        bucket[remoteKey] = { key = pairKey }
      else
        pair.key = pairKey
      end
    end
  end
end

local function IsInRaid()
  return UnitInRaid("player") ~= nil
end

local function IsLeaderOrAssistant()
  if IsInRaid() then
    if IsRaidLeader and IsRaidLeader() then return true end
    if IsRaidOfficer and IsRaidOfficer() then return true end
    return false
  end
  if GetPartyLeaderIndex then return (GetPartyLeaderIndex() == 0) end
  return true
end

local function ShouldAlert()
  if not FailbookDB.settings.leaderOnly then return true end
  return IsLeaderOrAssistant()
end

local function LocalAlert(msg)
  if not ShouldAlert() then return end
  if FailbookDB.settings.alertRW and RaidWarningFrame then
    RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
  end
  if FailbookDB.settings.alertChat then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. msg)
  end
  if FailbookDB.settings.alertSound then
    PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
  end
end

local lastPresent = {}

local function BuildCurrentPresent()
  local cur = {}
  local selfKey = GetSelfKey()
  if IsInRaid() then
    for i = 1, GetNumRaidMembers() do
      local name = GetRaidRosterInfo(i)
      if name then
        local key = MakeKey(name)
        if key and key ~= selfKey and IsRecordActive(FailbookDB.players[key]) then cur[key] = true end
      end
    end
  else
    for i = 1, 4 do
      local unit = "party" .. i
      if UnitExists(unit) then
        local name = UnitName(unit)
        if name then
          local key = MakeKey(name)
          if key and key ~= selfKey and IsRecordActive(FailbookDB.players[key]) then cur[key] = true end
        end
      end
    end
  end
  return cur
end

local function AlertBlacklisted(key)
  local data = FailbookDB.players[key]
  if not data or not IsRecordActive(data) then return end
  local note = data.note or ""
  LocalAlert(T("ALERT_IN_FAILBOOK", key, (note ~= "" and T("ALERT_NOTE", note) or "")))
end

local function UpdateAlerts(reason)
  EnsureDB()
  local inRaid = IsInRaid()
  local inParty = (GetNumPartyMembers and GetNumPartyMembers() or 0) > 0
  if not inRaid and not inParty then
    lastPresent = {}
    return
  end
  local cur = BuildCurrentPresent()
  if reason == "ui_open" then
    for k in pairs(cur) do AlertBlacklisted(k) end
  else
    for k in pairs(cur) do
      if not lastPresent[k] then AlertBlacklisted(k) end
    end
  end
  lastPresent = cur
end

local function MigrateOldKeys()
  local p = FailbookDB.players
  if type(p) ~= "table" then return end
  local toMove = {}
  for k, v in pairs(p) do
    if type(k) == "string" then
      local nk = MakeKey(k)
      if nk and nk ~= k then toMove[#toMove + 1] = { old = k, new = nk, val = v } end
    end
  end
  for _, item in ipairs(toMove) do
    local oldK, newK, val = item.old, item.new, item.val
    if not p[newK] then
      p[newK] = val
    else
      if (p[newK].note == nil or p[newK].note == "") and val and val.note and val.note ~= "" then p[newK].note = val.note end
      if p[newK].addedAt == nil and val and val.addedAt then p[newK].addedAt = val.addedAt end
      local a = tonumber(p[newK].updatedAt or 0) or 0
      local b = tonumber(val and val.updatedAt or 0) or 0
      if b > a then p[newK].updatedAt = b end
    end
    p[oldK] = nil
  end
  local nt = {}
  for _, name in ipairs(FailbookDB.syncTargets) do
    local k = MakeKey(name)
    if k then nt[#nt + 1] = k end
  end
  FailbookDB.syncTargets = nt
end

local function EscapeField(s)
  if not s then return "" end
  s = tostring(s)
  s = s:gsub("\t", " "):gsub("\r", " "):gsub("\n", " ")
  return s
end

local function EscapeNote(s)
  if not s then return "" end
  s = tostring(s)
  s = s:gsub("\\", "\\\\")
  s = s:gsub("\t", "\\t")
  s = s:gsub("\r", "\\r")
  s = s:gsub("\n", "\\n")
  return s
end

local function UnescapeNote(s)
  if not s then return "" end
  s = tostring(s)
  s = s:gsub("\\n", "\n")
  s = s:gsub("\\r", "\r")
  s = s:gsub("\\t", "\t")
  s = s:gsub("\\\\", "\\")
  return s
end

local MSG_PR = "PR"
local MSG_PA = "PA"
local MSG_PD = "PD"
local MSG_CU = "CU"

local function RandomKey(len)
  local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  local t = {}
  for i = 1, (len or 16) do
    local idx = random(1, string.len(chars))
    t[i] = string.sub(chars, idx, idx)
  end
  return table.concat(t)
end

local function MakeNonce()
  return tostring(time()) .. "-" .. tostring(random(1000, 9999))
end

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64encMap, b64decMap = {}, {}
do
  for i = 1, #b64chars do
    local c = b64chars:sub(i, i)
    b64encMap[i - 1] = c
    b64decMap[c] = i - 1
  end
end

local function Base64Encode(bytes)
  local out = {}
  local len = #bytes
  local i = 1
  while i <= len do
    local b1 = bytes:byte(i) or 0
    local b2 = bytes:byte(i + 1) or 0
    local b3 = bytes:byte(i + 2) or 0
    local n = b1 * 65536 + b2 * 256 + b3
    local c1 = floor(n / 262144) % 64
    local c2 = floor(n / 4096) % 64
    local c3 = floor(n / 64) % 64
    local c4 = n % 64
    out[#out + 1] = b64encMap[c1]
    out[#out + 1] = b64encMap[c2]
    out[#out + 1] = (i + 1 <= len) and b64encMap[c3] or "="
    out[#out + 1] = (i + 2 <= len) and b64encMap[c4] or "="
    i = i + 3
  end
  return table.concat(out)
end

local function Base64Decode(str)
  if not str or str == "" then return "" end
  str = str:gsub("%s+", "")
  local out = {}
  local i = 1
  while i <= #str do
    local c1 = str:sub(i, i); i = i + 1
    local c2 = str:sub(i, i); i = i + 1
    local c3 = str:sub(i, i); i = i + 1
    local c4 = str:sub(i, i); i = i + 1
    if not c1 or c1 == "" then break end
    local v1 = b64decMap[c1]
    local v2 = b64decMap[c2]
    if v1 == nil or v2 == nil then return nil end
    local v3 = (c3 == "=") and nil or b64decMap[c3]
    local v4 = (c4 == "=") and nil or b64decMap[c4]
    if (c3 ~= "=" and v3 == nil) or (c4 ~= "=" and v4 == nil) then return nil end
    local n = v1 * 262144 + v2 * 4096 + (v3 or 0) * 64 + (v4 or 0)
    local b1 = floor(n / 65536) % 256
    local b2 = floor(n / 256) % 256
    local b3 = n % 256
    out[#out + 1] = string.char(b1)
    if c3 ~= "=" then out[#out + 1] = string.char(b2) end
    if c4 ~= "=" then out[#out + 1] = string.char(b3) end
  end
  return table.concat(out)
end

local function Crypt(key, data, decrypt)
  if not key or key == "" then return data end
  local out = {}
  local klen = #key
  local sign = decrypt and -1 or 1
  for i = 1, #data do
    local b = data:byte(i)
    local kb = key:byte(((i - 1) % klen) + 1)
    local nb = (b + sign * kb) % 256
    out[i] = string.char(nb)
  end
  return table.concat(out)
end

local function EncryptFor(targetKey, plain)
  local pk = GetPair(targetKey)
  if not pk or not pk.key then return nil end
  return Base64Encode(Crypt(pk.key, plain, false))
end

local function DecryptFrom(senderKey, b64)
  local pk = GetPair(senderKey)
  if not pk or not pk.key then return nil end
  local bytes = Base64Decode(b64)
  if not bytes then return nil end
  return Crypt(pk.key, bytes, true)
end

SendToTarget = function(target, msg)
  if not target or target == "" then return end
  if SendAddonMessage then SendAddonMessage(PREFIX, msg, "WHISPER", target) end
end

local popupReady = false
local SyncSingleTarget
local function RaisePairPopup(frame)
  if not frame then return end
  frame:SetFrameStrata("TOOLTIP")
  frame:SetFrameLevel(1000)
  if frame.SetToplevel then frame:SetToplevel(true) end
  if frame.Raise then frame:Raise() end
end

local function SetupPairPopup()
  if popupReady then return end
  popupReady = true
  StaticPopupDialogs["FAILBOOK_PAIR_REQ"] = {
    text = T("PAIR_REQ_TEXT"),
    button1 = T("PAIR_ALLOW"),
    button2 = T("PAIR_REJECT"),
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnShow = function(self)
      RaisePairPopup(self)
    end,
    OnAccept = function(self, data)
      if not data or not data.sender or not data.nonce then return end
      EnsureDB()
      local P, selfKey = EnsurePairing()
      local sKey = MakeKey(data.sender) or data.sender
      local cluster = EnsureClusterKey()
      local clusterCreatedAt = GetClusterCreatedAt()
      local key = MakeClusterPairKey(sKey) or RandomKey(18)
      P.pairs[selfKey][sKey] = { key = key }
      P.lastSync[selfKey][sKey] = 0
      P.pendingIn[selfKey][sKey] = nil
      local exists = false
      for _, t in ipairs(FailbookDB.syncTargets) do if t == sKey then exists = true break end end
      if not exists then table.insert(FailbookDB.syncTargets, sKey) end
      SendToTarget(data.sender, MSG_PA .. "\t" .. data.nonce .. "\t" .. key .. "\t" .. cluster .. "\t" .. tostring(clusterCreatedAt))
      SyncSingleTarget(sKey, "pair_accept")
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. T("PAIRED_WITH", sKey))
      if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
    end,
    OnCancel = function(self, data)
      if not data or not data.sender or not data.nonce then return end
      EnsureDB()
      local P, selfKey = EnsurePairing()
      local sKey = MakeKey(data.sender) or data.sender
      P.pendingIn[selfKey][sKey] = nil
      SendToTarget(data.sender, MSG_PD .. "\t" .. data.nonce)
      DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. T("PAIR_REJECTED", sKey))
    end,
  }
end

local function RequestPair(targetName)
  EnsureDB()
  local P, selfKey = EnsurePairing()
  local tKey = MakeKey(targetName)
  if not tKey then return false, T("INVALID_NAME") end
  if IsPaired(tKey) then return true, T("ALREADY_PAIRED") end
  local nonce = P.pendingOut[selfKey][tKey] or MakeNonce()
  P.pendingOut[selfKey][tKey] = nonce
  SetupPairPopup()
  local ckey = GetClusterKey()
  if ckey ~= "" then
    local sig = MakeAutoSig(nonce, GetSelfKey(), ckey)
    SendToTarget(tKey, MSG_PR .. "\t" .. nonce .. "\t" .. sig)
  else
    SendToTarget(tKey, MSG_PR .. "\t" .. nonce)
  end
  return true, T("REQUEST_SENT", tKey)
end

local outQueue = {}
local incoming = {}
local SEND_EVERY = 0.06
local SEND_BURST = 2

local function Enqueue(to, msg)
  if not to or to == "" or not msg or msg == "" then return end
  outQueue[#outQueue + 1] = { to = to, msg = msg }
end

local senderFrame = CreateFrame("Frame")
senderFrame:SetScript("OnUpdate", function(self, elapsed)
  self._t = (self._t or 0) + elapsed
  if self._t < SEND_EVERY then return end
  self._t = 0
  local n = 0
  while n < SEND_BURST and #outQueue > 0 do
    local item = table.remove(outQueue, 1)
    SendToTarget(item.to, item.msg)
    n = n + 1
  end
end)

local function SplitChunks(s, maxLen)
  local chunks = {}
  local i = 1
  while i <= #s do
    chunks[#chunks + 1] = s:sub(i, i + maxLen - 1)
    i = i + maxLen
  end
  return chunks
end

local function ParsePayload(senderKey, enc)
  local plain = DecryptFrom(senderKey, enc)
  if not plain then return nil end
  local n, ts, delAt, exAt, perm, noteEsc = plain:match("^(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.*)$")
  if not (n and ts and delAt and exAt and perm) then return nil end
  return MakeKey(n) or n, {
    note = UnescapeNote(noteEsc or ""),
    updatedAt = tonumber(ts) or 0,
    deletedAt = tonumber(delAt) or 0,
    expiresAt = tonumber(exAt) or 0,
    permanent = (tonumber(perm) or 0) == 1,
  }
end

local function MergeIncoming(fromKey)
  local buf = incoming[fromKey]
  if not buf or type(buf.players) ~= "table" then return end
  local p = FailbookDB.players
  local changed = 0
  for name, payload in pairs(buf.players) do
    local key = MakeKey(name)
    if key then
      p[key] = p[key] or {}
      local incUp = tonumber(payload.updatedAt or 0) or 0
      local incDel = tonumber(payload.deletedAt or 0) or 0
      local curUp = tonumber(p[key].updatedAt or 0) or 0
      local curDel = tonumber(p[key].deletedAt or 0) or 0
      local incVer = incUp
      local curVer = curUp
      if incDel > incVer then incVer = incDel end
      if curDel > curVer then curVer = curDel end

      if incVer > curVer then
        p[key].note = payload.note or ""
        p[key].updatedAt = (incUp > 0) and incUp or incDel
        p[key].expiresAt = tonumber(payload.expiresAt or 0) or 0
        p[key].permanent = payload.permanent and true or false
        if incDel > 0 then
          p[key].deletedAt = incDel
        else
          p[key].deletedAt = nil
        end
        changed = changed + 1
      end

      if not p[key].addedAt then p[key].addedAt = date("%Y-%m-%d %H:%M:%S") end
    end
  end
  if FailbookDB.settings.alertChat then
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. T("SYNC_RECEIVED", fromKey, changed))
  end
  incoming[fromKey] = nil
  if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
end

SyncSingleTarget = function(targetKey, reason)
  EnsureDB()
  if not targetKey or targetKey == "" then return end
  if not IsPaired(targetKey) then return end
  local syncId = tostring(time()) .. "-" .. tostring(random(1000, 9999))
  local cluster = GetClusterKey()
  local clusterCreatedAt = GetClusterCreatedAt()
  Enqueue(targetKey, "S\t" .. syncId .. "\t" .. EscapeField(reason or "") .. "\t" .. cluster .. "\t" .. tostring(clusterCreatedAt))
  for name, data in pairs(FailbookDB.players) do
    if type(data) == "table" then
      local up = tonumber(data.updatedAt or 0) or 0
      local del = tonumber(data.deletedAt or 0) or 0
      local ex = tonumber(data.expiresAt or 0) or 0
      local perm = data.permanent and 1 or 0
      local note = data.note or ""
      local plain = (name or "") .. "\t" .. tostring(up) .. "\t" .. tostring(del) .. "\t" .. tostring(ex) .. "\t" .. tostring(perm) .. "\t" .. EscapeNote(note)
      local enc = EncryptFor(targetKey, plain)
      if enc then
        local parts = SplitChunks(enc, 180)
        local total = #parts
        Enqueue(targetKey, "B\t" .. syncId .. "\t" .. EscapeField(name or "") .. "\t" .. tostring(total) .. "\t" .. parts[1])
        for i = 2, total do
          Enqueue(targetKey, "C\t" .. syncId .. "\t" .. EscapeField(name or "") .. "\t" .. tostring(i) .. "\t" .. parts[i])
        end
      end
    end
  end
  Enqueue(targetKey, "E\t" .. syncId)
end

local function SyncToTargets(reason)
  EnsureDB()
  for _, t in ipairs(FailbookDB.syncTargets) do
    local k = MakeKey(t) or t
    if IsPaired(k) then SyncSingleTarget(k, reason) end
  end
end

local function AutoSync(reason)
  SyncToTargets(reason or "auto")
end

Failbook = {}
Failbook.L = L
Failbook.T = T
Failbook.GetGameLocale = function() return GAME_LOCALE end

function Failbook:NormalizeName(name) return MakeKey(name) end

function Failbook:SetClusterKey(key)
  EnsureDB()
  key = NormalizeClusterKey(key)
  if key == "" then
    SetClusterIdentity("", 0)
  elseif key == GetClusterKey() and GetClusterCreatedAt() > 0 then
    -- mantener timestamp existente
  else
    SetClusterIdentity(key, NowEpoch())
  end
  return true
end

function Failbook:GetClusterKey() return GetClusterKey() end
function Failbook:RequestPair(name) return RequestPair(name) end
function Failbook:ResendPair(name) return RequestPair(name) end

function Failbook:IsPaired(name)
  local k = MakeKey(name) or name
  return (k and IsPaired(k)) and true or false
end

function Failbook:IsPending(name)
  EnsureDB()
  local P, selfKey = EnsurePairing()
  local k = MakeKey(name) or name
  return (k and P.pendingOut[selfKey][k]) and true or false
end

function Failbook:AddPlayer(name, note)
  EnsureDB()
  local key = MakeKey(name)
  if not key then return false, T("INVALID_NAME") end
  local rec = FailbookDB.players[key]
  if type(rec) == "table" and (tonumber(rec.deletedAt or 0) == 0) then
    if IsRecordActive(rec) then return false, T("ALREADY_LISTED"), "active" end
    if IsRecordArchived(rec) then return false, key, "archived" end
  end
  local ts = NowEpoch()
  FailbookDB.players[key] = FailbookDB.players[key] or {}
  FailbookDB.players[key].note = note or FailbookDB.players[key].note or ""
  FailbookDB.players[key].addedAt = FailbookDB.players[key].addedAt or date("%Y-%m-%d %H:%M:%S")
  FailbookDB.players[key].deletedAt = nil
  FailbookDB.players[key].permanent = false
  FailbookDB.players[key].expiresAt = ts + ALERT_WINDOW_MS
  FailbookDB.players[key].updatedAt = ts
  AutoSync("add_player")
  return true, key, "created"
end

function Failbook:RemovePlayer(keyOrName)
  EnsureDB()
  if not keyOrName or keyOrName == "" then return false, T("INVALID_NAME") end
  local candidates = { keyOrName, MakeKey(keyOrName), StripRealm(Trim(keyOrName) or "") }
  for _, cand in ipairs(candidates) do
    if cand and FailbookDB.players[cand] then
      local ts = NowEpoch()
      FailbookDB.players[cand].deletedAt = ts
      FailbookDB.players[cand].updatedAt = ts
      FailbookDB.players[cand].permanent = false
      AutoSync("remove_player")
      return true, cand
    end
  end
  return false, T("NOT_IN_LIST")
end

function Failbook:SetNote(keyOrName, note)
  EnsureDB()
  local key = MakeKey(keyOrName) or keyOrName
  if not key or not FailbookDB.players[key] then return false, T("NOT_IN_LIST") end
  local rec = FailbookDB.players[key]
  rec.note = note or ""
  rec.updatedAt = NowEpoch()
  rec.deletedAt = nil
  if rec.permanent == nil then rec.permanent = false end
  if (not rec.permanent) and ((tonumber(rec.expiresAt or 0) or 0) == 0) then rec.expiresAt = DefaultExpiresAt() end
  AutoSync("set_note")
  return true, key
end

function Failbook:GetPlayers()
  EnsureDB()
  return FailbookDB.players
end

function Failbook:IsRecordVisible(keyOrName)
  EnsureDB()
  local key = MakeKey(keyOrName) or keyOrName
  return IsRecordActive(key and FailbookDB.players[key] or nil) and true or false
end

function Failbook:IsRecordArchived(keyOrName)
  EnsureDB()
  local key = MakeKey(keyOrName) or keyOrName
  return IsRecordArchived(key and FailbookDB.players[key] or nil) and true or false
end

function Failbook:ReactivatePlayer(keyOrName, permanent)
  EnsureDB()
  local key = MakeKey(keyOrName) or keyOrName
  local rec = key and FailbookDB.players[key] or nil
  if not key or not rec or tonumber(rec.deletedAt or 0) > 0 then return false, T("NOT_IN_HISTORY") end
  rec.permanent = permanent and true or false
  rec.expiresAt = rec.permanent and 0 or DefaultExpiresAt()
  rec.updatedAt = NowEpoch()
  AutoSync(rec.permanent and "reactivate_permanent" or "reactivate_30d")
  return true, key
end

function Failbook:GetTargets()
  EnsureDB()
  return FailbookDB.syncTargets
end

function Failbook:AddTarget(name)
  EnsureDB()
  local key = MakeKey(name)
  if not key then return false, T("INVALID_NAME") end
  local exists = false
  for _, t in ipairs(FailbookDB.syncTargets) do if t == key then exists = true break end end
  if not exists then table.insert(FailbookDB.syncTargets, key) end
  if IsPaired(key) then return true, key end
  local ok, msg = RequestPair(key)
  if ok then
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. (msg or ""))
    return true, key
  end
  return false, msg
end

function Failbook:RemoveTarget(name)
  EnsureDB()
  local key = MakeKey(name) or name
  if not key or key == "" then return false, T("INVALID_NAME") end
  for i, t in ipairs(FailbookDB.syncTargets) do
    if t == key then table.remove(FailbookDB.syncTargets, i) break end
  end
  local P = FailbookDB.pairing
  if type(P) == "table" then
    for _, bucket in pairs({ P.pairs, P.pendingOut, P.pendingIn, P.lastSync }) do
      if type(bucket) == "table" then
        for _, tbl in pairs(bucket) do
          if type(tbl) == "table" then tbl[key] = nil end
        end
      end
    end
  end
  return true, key
end

function Failbook:SyncNow(reason) SyncToTargets(reason or "manual") end
function Failbook:AlertOnUIOpen() UpdateAlerts("ui_open") end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("CHAT_MSG_ADDON")

local function RegisterPrefix()
  if RegisterAddonMessagePrefix then RegisterAddonMessagePrefix(PREFIX) end
end

f:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
  if event == "ADDON_LOADED" and arg1 == ADDON then
    EnsureDB()
    MigrateOldKeys()
    PurgeOldDeletedRecords()
    if GetClusterKey() ~= "" then RefreshAllPairKeys() end
    RegisterPrefix()
    SetupPairPopup()
    if FailbookDB.settings then FailbookDB.settings.leaderOnly = false end

  elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
    EnsureDB()
    if f._scanPending then return end
    f._scanPending = true
    f:SetScript("OnUpdate", function(self, elapsed)
      self._t = (self._t or 0) + elapsed
      if self._t > 1.0 then
        self._t = 0
        self._scanPending = nil
        self:SetScript("OnUpdate", nil)
        UpdateAlerts("roster")
      end
    end)

  elseif event == "CHAT_MSG_ADDON" then
    local prefix, msg, channel, sender = arg1, arg2, arg3, arg4
    if prefix ~= PREFIX or type(msg) ~= "string" then return end
    EnsureDB()
    local P, selfKey = EnsurePairing()
    local senderKey = MakeKey(sender) or sender
    local kind = msg:match("^(%S+)\t")
    if not kind then kind = msg end

    if kind == MSG_PR then
      local _, nonce, sig = msg:match("^(%S+)\t(%S+)\t?(.*)$")
      if not nonce then return end
      if IsPaired(senderKey) then
        local pairKey = MakeClusterPairKey(senderKey)
        if pairKey and pairKey ~= "" then
          P.pairs[selfKey][senderKey] = P.pairs[selfKey][senderKey] or {}
          P.pairs[selfKey][senderKey].key = pairKey
        else
          local curPair = GetPair(senderKey)
          pairKey = curPair and curPair.key or nil
        end
        local exists = false
        for _, t in ipairs(FailbookDB.syncTargets) do if t == senderKey then exists = true break end end
        if not exists then table.insert(FailbookDB.syncTargets, senderKey) end
        if pairKey and pairKey ~= "" then
          SendToTarget(sender, MSG_PA .. "\t" .. nonce .. "\t" .. pairKey .. "\t" .. GetClusterKey() .. "\t" .. tostring(GetClusterCreatedAt()))
          SyncSingleTarget(senderKey, "pair_repair")
        end
        if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
        return
      end
      local ckey = GetClusterKey()
      if ckey ~= "" and IsTargetListed(senderKey) then
        local expected = MakeAutoSig(nonce, senderKey, ckey)
        if sig and sig ~= "" and sig == expected then
          local pairKey = MakeClusterPairKey(senderKey)
          if pairKey and pairKey ~= "" then
            P.pairs[selfKey][senderKey] = { key = pairKey, auto = true }
            P.lastSync[selfKey][senderKey] = 0
            P.pendingIn[selfKey][senderKey] = nil
            local exists = false
            for _, t in ipairs(FailbookDB.syncTargets) do if t == senderKey then exists = true break end end
            if not exists then table.insert(FailbookDB.syncTargets, senderKey) end
            SendToTarget(sender, MSG_PA .. "\t" .. nonce .. "\t" .. pairKey .. "\t" .. ckey .. "\t" .. tostring(GetClusterCreatedAt()))
            SyncSingleTarget(senderKey, "pair_auto")
            DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. T("PAIR_AUTO", senderKey))
            if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
            return
          end
        end
      end
      SetupPairPopup()
      P.pendingIn[selfKey][senderKey] = nonce
      local popup = StaticPopup_Show("FAILBOOK_PAIR_REQ", senderKey, nil, { sender = sender, nonce = nonce })
      RaisePairPopup(popup)
      return

    elseif kind == MSG_PA then
      local _, nonce, key, cluster, clusterCreatedAt = msg:match("^(%S+)	(%S+)	([^	]+)	([^	]*)	?(%d*)$")
      if not nonce or not key then return end
      local pending = P.pendingOut[selfKey][senderKey]
      if not pending or pending ~= nonce then return end
      P.pendingOut[selfKey][senderKey] = nil
      P.pairs[selfKey][senderKey] = { key = key }
      P.lastSync[selfKey][senderKey] = 0
      cluster = NormalizeClusterKey(cluster)
      clusterCreatedAt = tonumber(clusterCreatedAt or 0) or 0
      if cluster ~= "" then
        if GetClusterKey() == "" then
          SetClusterIdentity(cluster, clusterCreatedAt)
        else
          MaybeResolveClusterConflict(senderKey, cluster, clusterCreatedAt, "pair_accept")
        end
        if GetClusterKey() == cluster then
          local pairKey = MakeClusterPairKey(senderKey)
          if pairKey and pairKey ~= "" then
            P.pairs[selfKey][senderKey].key = pairKey
          end
        end
      end
      local exists = false
      for _, t in ipairs(FailbookDB.syncTargets) do if t == senderKey then exists = true break end end
      if not exists then table.insert(FailbookDB.syncTargets, senderKey) end
      SyncSingleTarget(senderKey, "pair_complete")
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. T("PAIR_DONE", senderKey))
      if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
      return

    elseif kind == MSG_PD then
      local _, nonce = msg:match("^(%S+)	(%S+)$")
      if not nonce then return end
      local pending = P.pendingOut[selfKey][senderKey]
      if pending and pending == nonce then
        P.pendingOut[selfKey][senderKey] = nil
        DEFAULT_CHAT_FRAME:AddMessage("|cffff3333[Failbook]|r " .. T("PAIR_REJECTED_BY", senderKey))
        if FailbookUI and FailbookUI.Refresh then FailbookUI:Refresh() end
      end
      return

    elseif kind == MSG_CU then
      if not IsPaired(senderKey) then return end
      local _, cluster, clusterCreatedAt = msg:match("^(%S+)	([^	]+)	(%d+)$")
      if not cluster or not clusterCreatedAt then return end
      MaybeResolveClusterConflict(senderKey, cluster, clusterCreatedAt, "correction")
      return
    end

    if not IsPaired(senderKey) then return end

    if kind == "S" then
      local _, sid, _, cluster, clusterCreatedAt = msg:match("^(%S+)	(%S+)	([^	]*)	([^	]*)	?(%d*)$")
      if not sid then return end
      cluster = NormalizeClusterKey(cluster)
      clusterCreatedAt = tonumber(clusterCreatedAt or 0) or 0
      if cluster ~= "" then
        if GetClusterKey() == "" then
          SetClusterIdentity(cluster, clusterCreatedAt)
        else
          MaybeResolveClusterConflict(senderKey, cluster, clusterCreatedAt, "sync_start")
        end
      end
      incoming[senderKey] = { id = sid, players = {}, chunks = {} }

    elseif kind == "B" then
      local _, sid, pname, total, chunk = msg:match("^(%S+)\t(%S+)\t(.-)\t(%d+)\t(.+)$")
      if not sid or not pname or not total or not chunk then return end
      local buf = incoming[senderKey]
      if not buf or buf.id ~= sid then return end
      pname = MakeKey(pname) or pname
      total = tonumber(total) or 0
      buf.chunks[pname] = { total = total, parts = {} }
      buf.chunks[pname].parts[1] = chunk
      if total == 1 then
        local n, payload = ParsePayload(senderKey, chunk)
        if n and payload then buf.players[n] = payload end
        buf.chunks[pname] = nil
      end

    elseif kind == "C" then
      local _, sid, pname, idx, chunk = msg:match("^(%S+)\t(%S+)\t(.-)\t(%d+)\t(.+)$")
      if not sid or not pname or not idx or not chunk then return end
      local buf = incoming[senderKey]
      if not buf or buf.id ~= sid then return end
      pname = MakeKey(pname) or pname
      idx = tonumber(idx) or 0
      local rec = buf.chunks[pname]
      if not rec then return end
      rec.parts[idx] = chunk
      local ok = true
      for i = 1, (rec.total or 0) do
        if not rec.parts[i] then ok = false break end
      end
      if ok then
        local enc = table.concat(rec.parts, "")
        local n, payload = ParsePayload(senderKey, enc)
        if n and payload then buf.players[n] = payload end
        buf.chunks[pname] = nil
      end

    elseif kind == "E" then
      local _, sid = msg:match("^(%S+)\t(%S+)$")
      local buf = incoming[senderKey]
      if buf and buf.id == sid then MergeIncoming(senderKey) end
    end
  end
end)

SLASH_FAILBOOK1 = "/failbook"
SLASH_FAILBOOK2 = "/fb"
SlashCmdList["FAILBOOK"] = function(msg)
  msg = msg or ""
  local cmd, rest = msg:match("^(%S+)%s*(.-)$")
  cmd = cmd and cmd:lower() or ""
  if cmd == "sync" then
    Failbook:SyncNow("slash")
  elseif cmd == "key" then
    local sub = tostring(rest or "")
    sub = sub:gsub("^%s+", ""):gsub("%s+$", "")
    EnsureDB()
    if sub == "" or sub == "show" then
      local cur = NormalizeClusterKey(FailbookDB.settings.clusterKey or "")
      if cur == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[Failbook]|r " .. T("CLUSTER_NOT_SET"))
      else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. T("CLUSTER_SET"))
      end
    elseif sub == "clear" or sub == "off" then
      SetClusterIdentity("", 0)
      DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[Failbook]|r " .. T("CLUSTER_CLEARED"))
    else
      SetClusterIdentity(sub, NowEpoch())
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Failbook]|r " .. T("CLUSTER_SAVED"))
    end
  elseif cmd == "show" or cmd == "" then
    if FailbookUI and FailbookUI.Toggle then FailbookUI:Toggle() end
  end
end
