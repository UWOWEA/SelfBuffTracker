local addonName, addon = ...

local function CreateDiacriticsFont(name, size, r, g, b)
    local font = CreateFont(name)
    font:SetFont("Fonts\\ARIALN.TTF", size, "")
    font:SetTextColor(r, g, b)
    return font
end

addon.Fonts = {
    normalLarge = CreateDiacriticsFont("SelfBuffTrackerFontNormalLarge", 16, 1, 0.82, 0),
    normal = CreateDiacriticsFont("SelfBuffTrackerFontNormal", 12, 1, 0.82, 0),
    normalSmall = CreateDiacriticsFont("SelfBuffTrackerFontNormalSmall", 10, 1, 0.82, 0),
    highlight = CreateDiacriticsFont("SelfBuffTrackerFontHighlight", 12, 1, 1, 1),
    highlightSmall = CreateDiacriticsFont("SelfBuffTrackerFontHighlightSmall", 10, 1, 1, 1),
    disableSmall = CreateDiacriticsFont("SelfBuffTrackerFontDisableSmall", 10, 0.5, 0.5, 0.5),
}

function addon.ApplyFont(fontStringOrButton, style)
    local font = addon.Fonts[style or "normal"]
    if not font then return end

    local fontString = fontStringOrButton.SetFontObject and fontStringOrButton or fontStringOrButton:GetFontString()
    if fontString then
        fontString:SetFontObject(font)
    end
end

local BASE = {
    MOVE_HINT = "SelfBuffTracker (Move by mouse)",

    OPTIONS_TITLE = "SelfBuffTracker - Settings",
    LANGUAGE_LABEL = "Language:",
    LANGUAGE_AUTO = "Automatic (client language)",
    SOUND_ENABLED = "Sound alert",
    DEBUG_ENABLED = "Enable debug",
    LOCKED_POSITION = "Locked position",
    ICON_SIZE = "Icon size",
    COLUMS_AMOUNT = "Colums amount",
    ICON_SPACING = "Icon spacing",
    SOUND_LABEL = "Alert sound:",
    REMINDER_INTERVAL = "Reminder interval (s)",
    COPY_LABEL = "Copy settings from character (same class):",
    COPY_SELECT_CHARACTER = "Select character",
    COPY_BUTTON = "Copy",
    COPY_DONE = "Settings copied.",
    TRACKED_BUFFS = "Tracked buffs",
    ADD_BUTTON = "Add",
    SPELLBOOK_BUTTON = "Choose from spellbook",
    CUSTOM_SOUND_LABEL = "Custom (ID %s)",
    RELOAD_HINT = "Language change fully applies after /reload.",

    PICKER_TITLE = "Choose a buff to track",
    PICKER_BUFFS_ONLY = "buffs only",
    PICKER_HINT_SPEC = "List matches your current specialization",
    PICKER_HINT_FAIL = "Failed to load spellbook",
    PICKER_ADDED = "Added buff: %s",

    CMD_ADDED = "Added buff: %s",
    CMD_REMOVED = "Removed buff: %s",
    CMD_TRACKED_HEADER = "Tracked buffs:",
    CMD_LOCKED = "Locked",
    CMD_UNLOCKED = "Unlocked (drag with mouse)",
    CMD_POSITION = "Position: %s",
    CMD_SOUND_ON = "On",
    CMD_SOUND_OFF = "Off",
    CMD_SOUND_STATUS = "Sound: %s",
    CMD_SIZE_INVALID = "invalid number, must be between 2-300",
    CMD_SIZE_SET = "Icon size set to: %s",
    CMD_SOUND_LIST_HEADER = "Available preset sounds:",
    CMD_SOUND_CUSTOM_HINT = "You can also set a custom sound by file ID, e.g. /sbt warning 567400",
    CMD_SOUND_UNKNOWN = "Unknown sound '%s'. Use /sbt warning list to see options.",
    CMD_SOUND_SET = "Alert sound set to: %s",
    CMD_SOUND_INVALID = "Invalid sound ID, enter a number, preset name, or /sbt warning list",
    CMD_SOUND_NOT_FOUND = "Sound with ID %s not found",
    CMD_SOUND_ID_SET = "Alert sound set to ID: %s",

    HELP_HEADER = "--- SelfBuffTracker Commands ---",
    HELP_ADD = "/sbt add [Buff Name] - Adds a buff to track (e.g. /sbt add Well Fed)",
    HELP_REMOVE = "/sbt remove [Buff Name] - Removes a buff from the list",
    HELP_LIST = "/sbt list - Shows the list of tracked buffs",
    HELP_LOCK = "/sbt lock - Locks / unlocks the window for dragging",
    HELP_SOUND = "/sbt sound - Toggles the sound alert",
    HELP_SIZE = "/sbt size [number] - Sets the icon size",
    HELP_WARNING = "/sbt warning [SOUND_ID|name|list] - Sets the alert sound (presets via 'list', custom ID at:)",
    HELP_OPTIONS = "/sbt options - Opens the settings UI",
}

local overrides = {
    csCZ = {
        OPTIONS_TITLE = "SelfBuffTracker - Nastavení",
        LANGUAGE_LABEL = "Jazyk:",
        LANGUAGE_AUTO = "Automaticky (podle hry)",
        SOUND_ENABLED = "Zvukové upozornění",
        LOCKED_POSITION = "Uzamčená pozice",
        ICON_SIZE = "Velikost ikon",
        ICON_SPACING = "Mezera mezi ikonami",
        SOUND_LABEL = "Zvuk upozornění:",
        REMINDER_INTERVAL = "Interval připomenutí (s)",
        COPY_LABEL = "Zkopírovat nastavení z postavy (stejná třída):",
        COPY_SELECT_CHARACTER = "Vyber postavu",
        COPY_BUTTON = "Kopírovat",
        COPY_DONE = "Nastavení zkopírováno.",
        TRACKED_BUFFS = "Sledované buffy",
        ADD_BUTTON = "Přidat",
        SPELLBOOK_BUTTON = "Vybrat ze spellbooku",
        CUSTOM_SOUND_LABEL = "Vlastní (ID %s)",
        RELOAD_HINT = "Změna jazyka se plně projeví po /reload.",

        PICKER_TITLE = "Vyber kouzlo ke sledování",
        PICKER_BUFFS_ONLY = "jen buffy",
        PICKER_HINT_SPEC = "Seznam odpovídá aktuální specializaci",
        PICKER_HINT_FAIL = "Spellbook se nepodařilo načíst",
        PICKER_ADDED = "Přidán buff: %s",

        CMD_ADDED = "Přidán buff: %s",
        CMD_REMOVED = "Odebrán buff: %s",
        CMD_TRACKED_HEADER = "Sledované buffy:",
        CMD_LOCKED = "Uzamčeno",
        CMD_UNLOCKED = "Odemčeno (přetáhni myší)",
        CMD_POSITION = "Pozice: %s",
        CMD_SOUND_ON = "Zapnut",
        CMD_SOUND_OFF = "Vypnut",
        CMD_SOUND_STATUS = "Zvuk: %s",
        CMD_SIZE_INVALID = "špatné číslo, musí být mezi 2-300",
        CMD_SIZE_SET = "Velikost ikon nastavena na: %s",
        CMD_SOUND_LIST_HEADER = "Dostupné přednastavené zvuky:",
        CMD_SOUND_CUSTOM_HINT = "Vlastní zvuk lze zadat i číselným file ID, např. /sbt warning 567400",
        CMD_SOUND_UNKNOWN = "Neznámý zvuk '%s'. Použij /sbt warning list pro seznam.",
        CMD_SOUND_SET = "Zvukové upozornění nastaveno na: %s",
        CMD_SOUND_INVALID = "Neplatné ID zvuku, zadej číslo, název přednastaveného zvuku nebo /sbt warning list",
        CMD_SOUND_NOT_FOUND = "Zvuk s ID %s nebyl nalezen",
        CMD_SOUND_ID_SET = "Zvukové upozornění nastaveno na ID: %s",

        HELP_HEADER = "--- SelfBuffTracker Příkazy ---",
        HELP_ADD = "/sbt add [Název Buffu] - Přidá buff ke sledování (např. /sbt add Well Fed)",
        HELP_REMOVE = "/sbt remove [Název Buffu] - Odebere buff ze seznamu",
        HELP_LIST = "/sbt list - Zobrazí seznam sledovaných buffů",
        HELP_LOCK = "/sbt lock - Odemkne / zamkne okno pro přesun myší",
        HELP_SOUND = "/sbt sound - Zapne / vypne zvukové varování",
        HELP_SIZE = "/sbt size [číslo] - Nastaví velikost ikon",
        HELP_WARNING = "/sbt warning [SOUND_ID|název|list] - Nastaví zvukové upozornění (přednastavené zvuky přes 'list', vlastní ID najdeš na:)",
        HELP_OPTIONS = "/sbt options - Otevře nastavení v UI",
    },
    deDE = {
        OPTIONS_TITLE = "SelfBuffTracker - Einstellungen",
        SOUND_ENABLED = "Soundwarnung",
        LOCKED_POSITION = "Position gesperrt",
        ICON_SIZE = "Symbolgröße",
        ICON_SPACING = "Symbolabstand",
        SOUND_LABEL = "Warnton:",
        REMINDER_INTERVAL = "Erinnerungsintervall (s)",
        COPY_LABEL = "Einstellungen von Charakter kopieren (gleiche Klasse):",
        COPY_SELECT_CHARACTER = "Charakter wählen",
        COPY_BUTTON = "Kopieren",
        COPY_DONE = "Einstellungen kopiert.",
        TRACKED_BUFFS = "Überwachte Buffs",
        ADD_BUTTON = "Hinzufügen",
        SPELLBOOK_BUTTON = "Aus Zauberbuch wählen",
        CUSTOM_SOUND_LABEL = "Eigene (ID %s)",
    },
    frFR = {
        OPTIONS_TITLE = "SelfBuffTracker - Paramètres",
        SOUND_ENABLED = "Alerte sonore",
        LOCKED_POSITION = "Position verrouillée",
        ICON_SIZE = "Taille des icônes",
        ICON_SPACING = "Espacement des icônes",
        SOUND_LABEL = "Son d'alerte :",
        REMINDER_INTERVAL = "Intervalle de rappel (s)",
        COPY_LABEL = "Copier les paramètres d'un personnage (même classe) :",
        COPY_SELECT_CHARACTER = "Choisir un personnage",
        COPY_BUTTON = "Copier",
        COPY_DONE = "Paramètres copiés.",
        TRACKED_BUFFS = "Buffs suivis",
        ADD_BUTTON = "Ajouter",
        SPELLBOOK_BUTTON = "Choisir dans le grimoire",
        CUSTOM_SOUND_LABEL = "Personnalisé (ID %s)",
    },
    esES = {
        OPTIONS_TITLE = "SelfBuffTracker - Configuración",
        SOUND_ENABLED = "Alerta de sonido",
        LOCKED_POSITION = "Posición bloqueada",
        ICON_SIZE = "Tamaño de icono",
        ICON_SPACING = "Espaciado de iconos",
        SOUND_LABEL = "Sonido de alerta:",
        REMINDER_INTERVAL = "Intervalo de recordatorio (s)",
        COPY_LABEL = "Copiar configuración de otro personaje (misma clase):",
        COPY_SELECT_CHARACTER = "Elegir personaje",
        COPY_BUTTON = "Copiar",
        COPY_DONE = "Configuración copiada.",
        TRACKED_BUFFS = "Beneficios seguidos",
        ADD_BUTTON = "Añadir",
        SPELLBOOK_BUTTON = "Elegir del libro de hechizos",
        CUSTOM_SOUND_LABEL = "Personalizado (ID %s)",
    },
    ruRU = {
        OPTIONS_TITLE = "SelfBuffTracker - Настройки",
        SOUND_ENABLED = "Звуковое оповещение",
        LOCKED_POSITION = "Позиция заблокирована",
        ICON_SIZE = "Размер значков",
        ICON_SPACING = "Расстояние между значками",
        SOUND_LABEL = "Звук оповещения:",
        REMINDER_INTERVAL = "Интервал напоминания (с)",
        COPY_LABEL = "Скопировать настройки с другого персонажа (тот же класс):",
        COPY_SELECT_CHARACTER = "Выбрать персонажа",
        COPY_BUTTON = "Скопировать",
        COPY_DONE = "Настройки скопированы.",
        TRACKED_BUFFS = "Отслеживаемые баффы",
        ADD_BUTTON = "Добавить",
        SPELLBOOK_BUTTON = "Выбрать из книги заклинаний",
        CUSTOM_SOUND_LABEL = "Свой (ID %s)",
    },
    ptBR = {
        OPTIONS_TITLE = "SelfBuffTracker - Configurações",
        SOUND_ENABLED = "Alerta sonoro",
        LOCKED_POSITION = "Posição travada",
        ICON_SIZE = "Tamanho dos ícones",
        ICON_SPACING = "Espaçamento dos ícones",
        SOUND_LABEL = "Som de alerta:",
        REMINDER_INTERVAL = "Intervalo de lembrete (s)",
        COPY_LABEL = "Copiar configurações de outro personagem (mesma classe):",
        COPY_SELECT_CHARACTER = "Escolher personagem",
        COPY_BUTTON = "Copiar",
        COPY_DONE = "Configurações copiadas.",
        TRACKED_BUFFS = "Buffs monitorados",
        ADD_BUTTON = "Adicionar",
        SPELLBOOK_BUTTON = "Escolher do livro de feitiços",
        CUSTOM_SOUND_LABEL = "Personalizado (ID %s)",
    },
}

addon.AvailableLocales = {
    { code = "auto", name = BASE.LANGUAGE_AUTO },
    { code = "enUS", name = "English" },
    { code = "csCZ", name = "Čeština" },
    { code = "deDE", name = "Deutsch" },
    { code = "frFR", name = "Français" },
    { code = "esES", name = "Español" },
    { code = "ruRU", name = "Русский" },
    { code = "ptBR", name = "Português" },
}

addon.L = addon.L or {}

function addon.RefreshLocale()
    local code = (SelfBuffTrackerDB and SelfBuffTrackerDB.locale and SelfBuffTrackerDB.locale ~= "auto")
        and SelfBuffTrackerDB.locale or GetLocale()

    for key in pairs(addon.L) do
        addon.L[key] = nil
    end

    for key, value in pairs(BASE) do
        addon.L[key] = value
    end

    if overrides[code] then
        for key, value in pairs(overrides[code]) do
            addon.L[key] = value
        end
    end
end

addon.RefreshLocale()
