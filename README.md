# ZaiiaPawn

Оценка (скоринг) предметов по нескольким наборам весов для Turtle-like серверов.

ZaiiaPawn оценивает предметы по вашим собственным наборам весов и показывает результат в тултипах предметов. Встроенный модуль рекомендаций подбирает лучшую экипировку по слотам из встроенной базы предметов.

Основан на OctoPawn: от оригинала взяты классовые пресеты и формат фильтров экипировки, остальной код переписан.

## Возможности

- **Несколько наборов весов.** Любое количество сетов (Holy, Protection, Retribution, Feral Cat, Marksmanship, Leveling и т.д.). Каждый сет — таблица `STAT = вес`.
- **Классовые пресеты.** Готовые пресеты ZaiiaPawn для Paladin, Hunter и Druid плюс классические пресеты OctoPawn для всех классов.
- **Скор в тултипах.** Активные сеты отображаются в тултипе предмета с опциональной разницей против надетого предмета.
- **Лист персонажа и осмотр.** Надетая экипировка оценивается для вашего персонажа и для других игроков (через окно осмотра).
- **Фильтры экипировки.** Для каждого сета можно заблокировать типы оружия и брони (Two-Hand, Shields, Wands, Holdables и т.д.) — они игнорируются при скоринге.
- **Мягкие капы (diminishing returns).** Капы по статам в окне Advanced: выше капа каждое дополнительное очко учитывается меньше.
- **Импорт/экспорт Pawn v1.** Обмен наборами весов через стандартный формат строк Pawn (совместим с WoWhead).
- **Полный бэкап профиля.** Экспорт всех сетов (веса + фильтры экипировки) одной переносимой строкой; импорт на другом персонаже того же класса.
- **Предпочтения по типу оружия.** Мягкий вклад в скор для 1H, 2H, Shield, Off-hand, Ranged — независимо от жёстких фильтров экипировки.
- **Рекомендатор экипировки (`/zp rec`).** Лучшие доступные предметы по каждому слоту из встроенной базы: учитываются уровень персонажа, требования источников предмета, тип брони и сет-бонусы. Слот реликвий называется по классу: Libram (Paladin), Idol (Druid), Totem (Shaman).

## Управление

- `/zp` или иконка у миникарты — главное окно.
- `/zp rec` — окно рекомендаций.
- Левый клик по имени сета — открыть его веса в боковом окне; повторный клик — закрыть.
- Правый клик по имени сета — сделать сет активным (зелёная `*`). Активный сет редактируется и экспортируется.
- Чекбокс рядом с сетом — показывать/скрывать сет в тултипах и в скоринге листа персонажа.
- `^` / `v` — изменить порядок сетов.
- `Esc` — закрыть окна.
- Кнопки справа сгруппированы в Set, Global и Options.

### Окно рекомендаций

- Вкладки слотов в два ряда: клик по вкладке — список лучших предметов для этого слота, отсортированный по скору активного сета.
- Чекбоксы типов брони сверху (Cloth / Leather / Mail / Plate — по классу); состояние запоминается для каждого персонажа.
- Метка `[Equipped]` — предмет сейчас надет; скор справа; сет-бонус отображается как `+X.X set`.
- Наведение на строку — тултип предмета со списком источников (квест, дроп, вендор).
- Shift+клик по строке — вставить ссылку предмета в активное поле ввода (например, в чат).
- `Recalc` — принудительно пересобрать рекомендации.

## Установка

1. Скачайте или клонируйте репозиторий.
2. Поместите папку в `Interface/AddOns/ZaiiaPawn/`.
3. Если папка называется `ZaiiaPawn-master` (по умолчанию на GitHub), переименуйте её в `ZaiiaPawn` — без суффикса `-master`.
4. Перезапустите клиент (или `/reload`).

## Необязательные зависимости

[ClassicAPI](https://github.com/brues-code/ClassicAPI) — определяется автоматически, установка рекомендуется: даёт числовые classID / subclassID предметов. Без него аддон работает, но точные фильтры экипировки по классу и подклассу (Wands, Maces, Shields, Librams, Idols, Totems) молча пропускаются; фильтры по слоту (Two-Hand, Ranged, Holdable, Off-hand) продолжают работать.

## Благодарности

- Оригинальный [OctoPawn by iGreed](https://github.com/iGreed1993/OctoPawn) — классовые пресеты весов и формат фильтров экипировки.
- ZaiiaPawn — переписан и расширен: новый движок тултипов, мультисет-система с активным сетом, мягкие капы, диалог фильтров экипировки, экспорт/импорт полного профиля, переработанный UI, модуль рекомендаций.

---

# ZaiiaPawn (English)

Multi-set item scoring for Turtle-like servers.

ZaiiaPawn scores items against your own weight sets and shows the result in item tooltips. A built-in recommender module picks the best available gear per slot from an embedded item database.

Based on OctoPawn: class weight presets and the equipment filter format are reused, most of the code is rewritten.

## Features

- **Multiple weight sets.** Define as many sets as you want (Holy, Protection, Retribution, Feral Cat, Marksmanship, Leveling, ...). Each set is a table of `STAT = weight`.
- **Per-class presets.** Ready-made ZaiiaPawn presets for Paladin, Hunter and Druid, plus the classic OctoPawn defaults for every class.
- **Tooltip scores.** Active sets are shown on item tooltips with an optional diff against the currently equipped item.
- **Character sheet + inspect.** Equipped gear is scored for your own character and for other players (via the inspect window).
- **Equipment filters.** Per set, block specific weapon or armour types (Two-Hand, Shields, Wands, Holdables, ...) so they are ignored during scoring.
- **Soft caps (diminishing returns).** Per-stat caps configurable from the Advanced window: past the cap, extra points count less.
- **Pawn v1 import / export.** Share or import weight sets using the standard Pawn string format (WoWhead-compatible).
- **Full profile backup.** Export every set (weights + equipment filters) into one portable string; import it on another character of the same class.
- **Weapon type preferences.** Score contribution for 1H, 2H, Shield, Off-hand, Ranged — a soft preference, independent from the hard equipment filters.
- **Gear recommender (`/zp rec`).** Best available items per slot from the embedded database: player level, item source requirements, armour type and set bonuses are all taken into account. The relic slot is named per class: Libram (Paladin), Idol (Druid), Totem (Shaman).

## Controls

- `/zp` or the minimap icon — main window.
- `/zp rec` — recommender window.
- Left-click a set name — open its weights in a side window; click again to close.
- Right-click a set name — mark it as active (green `*`). The active set is what you edit and export.
- Checkbox next to a set — show / hide the set in tooltips and in character sheet scoring.
- `^` / `v` — reorder sets.
- `Esc` — close windows.
- Buttons on the right are grouped into Set, Global and Options.

### Recommender window

- Two rows of slot tabs: click a tab to see the best items for that slot, sorted by the active set's score.
- Armour type checkboxes on top (Cloth / Leather / Mail / Plate — depending on class); the state is remembered per character.
- `[Equipped]` tag marks the currently worn item; the score is on the right; set bonuses are shown as `+X.X set`.
- Hover a row — item tooltip plus a list of sources (quest, drop, vendor).
- Shift+click a row — insert the item link into the active edit box (e.g. chat).
- `Recalc` — force rebuild of the recommendations.

## Installation

1. Download or clone this repository.
2. Place the folder into `Interface/AddOns/ZaiiaPawn/`.
3. If the folder is named `ZaiiaPawn-master` (GitHub default), rename it to `ZaiiaPawn` — without the `-master` suffix.
4. Restart the client (or `/reload`).

## Optional dependencies

[ClassicAPI](https://github.com/brues-code/ClassicAPI) — auto-detected, installing is recommended: provides numeric classID / subclassID for items. Without it the addon still runs, but exact byClassSubclass equipment filters (Wands, Maces, Shields, Librams, Idols, Totems) are silently skipped; byEquipLoc filters (Two-Hand, Ranged, Holdable, Off-hand) still work.

## Credits

- Original [OctoPawn by iGreed](https://github.com/iGreed1993/OctoPawn) — class weight presets and the equipment filter format.
- ZaiiaPawn — rewritten and extended: new tooltip engine, multi-set active system, soft caps, equipment filter dialog, full-profile export/import, UI rework, recommender module.
