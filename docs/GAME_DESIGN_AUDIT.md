# TinyExplorers — Game Design & Engagement Audit

*Roles applied: Kids Game Designer · Child Psychologist · UX Designer · Game Artist · Gameplay Engineer.*
*Scope: all 17 games, Home, Sticker Book, Buddy Picker, and shared systems (DesignSystem, Rewards, SoundEngine, SpeechHelper).*

---

## 0. Executive diagnosis

The app does not lack a progression system — it has **three** (per-game `GameProgression`, global `LevelSystem`, per-game star medals), and **none of them changes what the child experiences**:

1. **`GameProgression` resets to Level 1 every time a game is opened.** It is `@State private var progression = GameProgression()` (a value struct, never persisted) in every game. Any difficulty a child earns evaporates when they leave the screen. `DesignSystem.swift:1084-1119`.
2. **Most games never read `progression.level` to change the task.** Only 5 of 17 consume it at all (I Spy item count, Pattern length, ABC option count, Spell It word length, Clock half-past). Shapes, Odd One Out, Animals, Social, Emotions, Memory, Puzzle, Numbers, Counting: the level badge is a dressed-up correct-answer counter.
3. **`MathGameView` has a real bug that freezes difficulty on Easy forever.** `range(for:)` computes `let diff = currentDifficulty()` and then switches on the never-updated `difficulty` @State property instead. The 1–50 ranges and times tables are dead code. `MathGameView.swift:61-83`.
4. **Global `LevelSystem` (stars → level 1-20, titles, XP bar) unlocks nothing.** No game, theme, category, or sticker is gated by level anywhere in the codebase. It is a vanity meter.
5. **Content pools are tiny and fully hardcoded**: Social **8** scenarios, Shapes **6** shapes (all shown every round), Pattern **12** patterns, Odd One Out **16** rounds, Memory **16** emojis, Emotions **12**, Animals **24**, I Spy **40**. A daily player memorizes most games within a week.
6. **No game has an end state.** Every quiz loops infinitely; no "you finished today's set!", no session summary, no closure. (Only NumberLine has a per-round "Count Again".)
7. **The only reward sink (stickers) has no play value after purchase** — the sticker book is a static album; there is no scene to place stickers on.
8. **Pre-reader accessibility is inconsistent**: Clock Time is a hard wall (text-only answer options, never spoken); Social's 3 answer options are never read aloud; Emotions' faceToName options are text pills; Puzzle's how-to-play and error feedback are text-only; every mode/difficulty picker and button ("Next Round", "Record", "Easy (6)") is unnarrated text.

**Verdict:** the repetition/boredom complaint traces to a small number of load-bearing defects, not to the individual games (which are mechanically fine). Fixing persistence + real difficulty consumption + session structure + level-gated unlocks converts the existing content into a progression game without rewriting the games.

---

## 1. Screen-by-screen UX audit

Checklist key: ✅ good · ⚠️ partial · ❌ failing. Columns: Visually exciting / Objective clear / Intuitive / Immediate feedback / Motivating progression / Simple nav / Novelty / Would a child continue?

| Screen | Vis | Obj | Int | FB | Prog | Nav | Nov | Continue? | Top issues |
|---|---|---|---|---|---|---|---|---|---|
| **Home** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ❌ | ⚠️ | 17 equal-weight cards = choice overload for 4-6yo; level/XP unlock nothing; screen never changes as child advances |
| **Sticker Book** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ❌ | ⚠️ | No post-purchase play (no placement scene); collection is the whole loop |
| **Buddy Picker** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | — | Not part of first-run; buddy never appears inside games |
| **ABC Letters** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ | Options scale 4→6 then stop; 7-col explore grid dense; no stuck-child hint escalation |
| **Spell It** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | Best progression in app, but 26-word pool; 8 tiles can overflow narrow screens |
| **123 Numbers** | ✅ | ⚠️ | ⚠️ | ✅ | ❌ | ✅ | ❌ | ⚠️ | Free-play only; arrows-only number change; disabled state unexplained |
| **Math Fun** | ✅ | ⚠️ | ✅ | ✅ | ❌ | ⚠️ | ❌ | ❌ | **Difficulty bug (stuck Easy)**; multiplication ungated; text-only operation picker |
| **Counting** | ✅ | ⚠️ | ⚠️ | ✅ | ❌ | ❌ | ⚠️ | ⚠️ | 4 sub-modes behind text-only picker; inconsistent wrong-answer models; 1-50 grid = 62pt tiles |
| **Colors & Shapes** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | All 6 shapes every round, zero scaling; fixed color↔shape pairing teaches "tap the red one" |
| **Clock Time** | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ✅ | ⚠️ | ❌ (pre-readers) | **Text-only answers, never spoken** — unplayable under ~6; caps at half-past |
| **Memory Match** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ⚠️ | ⚠️ | Peek times implausible (12 pairs/12s); moves-count framing is adult; sub-44pt cards on Hard |
| **I Spy** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ✅ | Best pre-reader design; but ~10 items/category = near-identical rounds; scaling caps at 9 by L9 |
| **Puzzle Time** | ✅ | ⚠️ | ⚠️ | ✅ | ❌ | ⚠️ | ⚠️ | ⚠️ | Two-tap place model never explained by voice; Easy always the same 6 pieces; text-only error feedback |
| **Pattern Fun** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ❌ | ⚠️ | 12 fixed patterns; long-pattern wrap answers non-inferable for 4yo; no audio replay button |
| **Odd One Out** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ⚠️ | 16 rounds then loops; zero scaling; wrong answer = dead end with contradictory "Try again!" voice; 2 rounds are text glyphs |
| **Drawing Fun** | ⚠️ | ✅ | ⚠️ | ✅ | ❌ | ⚠️ | ⚠️ | ⚠️ | **Dead progression header (never advances)**; ~12pt brush targets; destructive Clear plays "wrong" buzzer; stickers land randomly, not where tapped |
| **Music Maker** | ✅ | ⚠️ | ✅ | ✅ | ❌ | ⚠️ | ⚠️ | ⚠️ | Only star locked behind text-heavy Record→Stop→Play Back flow a pre-reader can't discover |
| **Animal Friends** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ⚠️ | ✅ | Strongest content pool (24); distractors never get confusable; back-to-back repeats possible |
| **Social Skills** | ⚠️ | ⚠️ | ⚠️ | ✅ | ❌ | ✅ | ❌ | ❌ | **8 scenarios total**; answer options never spoken (pre-readers guess from one emoji); options not position-shuffled |
| **Emotions** | ✅ | ✅ | ⚠️ | ✅ | ❌ | ⚠️ | ⚠️ | ⚠️ | faceToName options text-only; Mirror mode has zero feedback/reward; detail card = 4 dense text bubbles |

---

## 2. Gameplay repetition analysis

**What repeats identically every session:**

| Game | Fixed pool | Exhausted in | Scaling that exists |
|---|---|---|---|
| Social Skills | 8 scenarios | ~5 min | none |
| Colors & Shapes | 6 shapes, all shown each round | ~2 min | none |
| Pattern Fun | 12 patterns | ~10 min | length 4→8 only |
| Odd One Out | 16 rounds (odd item always index 3 in data) | ~10 min | none |
| Memory | 16 emojis | layout-only variety | manual picker only |
| Emotions | 12 emotions | ~15 min | none |
| Puzzle | 6 themes × 12; Easy always the *same first 6* | ~15 min | manual picker only |
| I Spy | 4×10 items; round = 6-9 of the same 10 | ~15 min/category | items 6→9 |
| Animals | 24 animals | ~30 min | none |
| Math | infinite generation **but bugged to operands 1-5** | ~15 distinct addition facts | broken |

**Root causes**, in order of leverage:
1. Progression state not persisted → even working scaling restarts at easiest every session.
2. Level not consumed → no reason for round N+1 to differ from round N.
3. Hand-authored content where generation is cheap (patterns, odd-one-out, math, compare) or where the pool is far too small (social, shapes).
4. No anti-repeat guard: `randomElement()` everywhere allows identical back-to-back prompts (Animals, Emotions, ABC, Clock, Mirror).
5. Nothing ever *unlocks* — no new category, theme, world, character, or mechanic appears at any point in the child's lifetime with the app.

---

## 3. Progression redesign plan

### 3.1 Persist and unify progression (the keystone)
- Convert `GameProgression` to a persisted per-game model (`UserDefaults` key `TinyExplorers.progress.<gameKey>`): level, totalCorrect, recent-accuracy window.
- One shared component: every game reads `level` through a single `DifficultyCurve` API so scaling is consistent and testable, e.g. `curve.optionCount(base: 4, max: 8)`, `curve.range(easy: 1...5, hard: 1...50)`.
- Replace the two manual difficulty pickers (Memory, Puzzle) with the same auto-curve; keep a parent-facing override hidden behind a long-press.

### 3.2 Make every game consume level (per-game curves)
- **Math** — fix the bug; then easy 1-5 → medium 1-12 → hard 1-50; introduce missing-operand form (`3 + ? = 8`) at L6; multiplication only unlocks at L8.
- **Shapes** — L1: 3 options; +1 per 2 levels; L4+: decouple color from shape (random colors); L6+: rotated shapes, size variants; L8+: "find all the triangles" multi-select rounds.
- **Odd One Out** — generate rounds from category pools (animals/food/vehicles/sky/sea…) instead of 16 fixed rows; L1: 3 items with a gross category break; scale to 6 items with subtler breaks (big vs small, hot vs cold).
- **Memory** — auto board size from level (4→6→8→10→12 pairs); peek time = pairs × 1.5s (fixes the implausible 12s/24-card peek); themed card packs unlock with level.
- **Pattern** — procedural generator: AB → AAB → ABC → ABB → AABB → growing patterns; option count 3→4; occasional "build the whole next block" rounds at high level.
- **I Spy** — scaled scenes: L5+ hides the target among visually similar distractors; L8+ "find two things"; new categories unlock by level.
- **Social/Emotions** — expand scenario pool (24+ each), tier scenarios by subtlety, shuffle option positions, and *speak every option aloud*.
- **Clock** — quarter past/to at L4, five-minute reads at L7; spoken answer options.
- **Counting** — the four sub-modes become level-gated stages of one journey instead of a text picker.

### 3.3 Adaptive difficulty (both directions)
- Keep a rolling window of the last 6 answers per game. ≥5 correct → accelerate (skip a level step, bigger star bonus). ≤2 correct → quietly step down one level and inject a scaffold (highlight, eliminate one distractor, slower speech). Never announce a step-down.

### 3.4 Session structure — "adventures," not infinite loops
- Every game becomes rounds of **5 questions = 1 adventure**. Progress shown as 5 footprints/balloons filling. Adventure end: star summary, buddy celebration, choice of "Play again!" / "New game!" (both spoken, icon-first).
- This creates closure, natural stopping points (healthy engagement), and a unit to hang variable rewards on.

### 3.5 Make levels unlock real things
- **Sticker packs** gate by global level (Space at L3, Ocean at L5, Treats at L8) — collection now has a horizon, not just a price list.
- **Game content** unlocks by per-game level (new I Spy categories, Memory card packs, Puzzle themes, Math operations).
- **Home scenery evolves with global level** (see §4): the world visibly grows because the child played.
- **Buddies**: 4 free at start; the rest unlock at level milestones — the level badge finally *means* something.

---

## 4. Visual design improvements

1. **Evolving home world.** Keep the sky scene, but make it level-reactive: L1 a sapling and one balloon; each level adds an element (flowers, treehouse, pond, rainbow, hot-air balloon, fireworks at L10). Cheap to build — the scene is already layered SwiftUI shapes — and it is the single highest-visibility "the game grows with me" signal.
2. **Journey map framing.** Reframe the 4 sections as themed lands (Letter Forest, Number Mountain, Puzzle Cove, Friendship Village) along a winding path; new lands "wake up" (color in from silhouette) at level gates. The flat 17-card grid overloads 4-6yos; a path gives spatial memory and a next-thing-to-want.
3. **Buddy as a character, not an avatar.** The chosen buddy appears *inside* games: idles in a corner, gasps at wrong answers, cartwheels on streaks, sleeps if the child idles 30s (tap to wake = re-engagement nudge). One reusable `BuddyReactor` view.
4. **Card-level richness by mastery**: game cards gain medals ribbons/sparkle borders as per-game stars grow (the medal system already exists — surface it on Home).
5. **Micro-delight pass**: shared `TapGlowBurst` on every correct tap (exists in Music — reuse everywhere); answer tiles do a tiny idle breathe; screen transitions use a themed wipe (clouds/leaves/bubbles) instead of the default push.
6. **Sticker scenes** (see §6.3) turn the static album into a play surface — the biggest visual payoff per line of code after the home scenery.

## 5. Neuroscience-based engagement recommendations

Healthy patterns only — bounded sessions, effort-contingent rewards, no timers/pressure/streak-loss anxiety:

- **Immediate feedback** (already strong: haptic+sound+voice <100ms) — keep.
- **Small wins**: 5-question adventures create a win every ~90 seconds.
- **Variable reward**: adventure-end chest gives 1-3 stars weighted by accuracy, with an occasional (≈1 in 6) surprise sticker-discount coupon or confetti-storm — variability without loss-framing.
- **Visible short/long goals**: footprints (this adventure) → per-game medal ring (this game) → level/scenery (whole world) → sticker packs (collection). All four already partially exist; they need to be *connected*.
- **Competence signaling**: adaptive step-downs are silent; celebrations name the skill ("You know your shapes!") not the child's speed; failure feedback is always warm and actionable ("Look at the little hand!" is the model — replicate it everywhere).
- **Curiosity hooks**: silhouetted locked content ("???" sticker pack, greyed-out land) visible but not nagging; the daily gift already does the return-visit hook — keep it once daily, no streak counter.
- **Avoid**: countdown timers for under-7s, leaderboards, "you lost your streak" messaging, and gating core play behind the daily clock.

## 6. Interaction enhancement recommendations

1. **Speak everything actionable.** Every answer option, button, and picker segment gets audio on tap-and-hold or first display: Clock answers, Social options, Emotions name-pills, all "Next/Play Again/Record" buttons (icon + spoken label). The 4,975 pre-rendered voice clips are keyed `sha256(text)[0:20].m4a` — **new strings need new clips or they silently fall back to robot TTS**; batch-generate clips for all new UI strings.
2. **Consistent wrong-answer contract app-wide**: first miss → warm hint + retry (shrink to fewer options for 4-6yo); second miss → reveal with explanation, celebrate the *reveal* ("Now you know!"), auto-advance. Kills both the Odd One Out dead end and the Math reveal-vs-ABC retry inconsistency.
3. **Touch targets ≥ 60pt** everywhere: Drawing brush dots (currently ~12pt) and color swatches (36pt), Memory Hard cards, NumberLine 1-50 tiles, xylophone bars.
4. **Drawing fixes**: tap-to-place stickers at the tapped point; undo button instead of destructive Clear (Clear moves behind a wobble-confirm and loses the `.wrong` buzzer); merge duplicate white/eraser swatches.
5. **Music**: replace Record/Stop/Play Back text capsules with one big pulsing mic character that narrates itself; auto-playback on stop; award the star on playback.
6. **Puzzle**: spoken instructions on appear, spoken error feedback, and drag-to-place as the primary gesture (keep tap-tap as fallback).
7. **Anti-repeat guard**: shared `NonRepeatingPicker` wrapper so no prompt repeats within its last 3 draws.
8. **Mirror mode**: buddy mirrors the emotion with the child, then a big "I did it! 🎉" self-report button awards a star — closes the only zero-feedback loop in the app.

## 7. Child playtesting simulation findings

**Age 4–6 (pre-readers — the core audience):**
- *Blocked entirely*: Clock Time (text answers), 2 Odd One Out rounds (letter/number glyphs), Social options (guessing from one emoji), Emotions faceToName, Math arithmetic modes, all text pickers ("Easy (6)", "Skip Count", "Record").
- *Confusion*: Puzzle's unexplained two-tap model; Odd One Out saying "Try again!" while showing "Next Round"; Numbers' greyed arrow at 1; Drawing's two white swatches.
- *Frustration*: Memory peek too short beyond Easy; ABC 6-option rounds with no hint escalation; accidental Clear destroying artwork.
- *Boredom*: Shapes after ~3 rounds (same 6 shapes); nothing new ever appears on Home.
- *Delight (keep!)*: I Spy's voice-first loop; Spell It's letter-by-letter audio; poppable balloons and giggling sun; buddy hellos; star rain.

**Age 7–9:**
- *Boredom is the dominant failure*: Math stuck at 1-5 sums (bug) is insulting within minutes; Shapes/Pattern/Odd One Out trivially easy with no growth; Social memorized in one sitting (answers don't even shuffle position).
- *Would respond to*: real difficulty curves, medals surfaced on Home, Memory 10-12 pair boards with fair peek, multiplication/quarter-hours unlocking as visible achievements, "find two things" I Spy.

**Age 10–12:**
- Outside the app's realistic design center (content tops out at ~7yo skills). Recommendation: don't chase this band; a "challenge mode" toggle (timed memory, 3-digit math) is the ceiling worth building. Stretching further would compromise the 4-6 experience.

## 8. Prioritized implementation roadmap

**HIGH impact (Phase 1 — makes progression real):**
1. Fix `MathGameView` difficulty bug (`range(for:)` uses discarded `currentDifficulty()`), and gate multiplication by level.
2. Persist `GameProgression` per game; add shared `DifficultyCurve` + rolling-accuracy adaptive step-up/step-down.
3. Consume level in every game (per-game curves, §3.2) — replaces manual pickers in Memory/Puzzle.
4. 5-question adventure structure with end-of-adventure celebration + variable star chest, app-wide.
5. Pre-reader accessibility pass: speak all options/buttons (incl. new voice clips), fix Clock/Social/Emotions/Puzzle walls.
6. Unified wrong-answer contract (hint→retry→reveal), fixing Odd One Out's dead end.

**MEDIUM impact (Phase 2 — makes the world grow):**
7. Level-gated unlocks: sticker packs, game categories/themes, buddies; silhouetted locked-content teasers.
8. Evolving home scenery by global level + journey-map reframing of sections.
9. Procedural content: Pattern generator, Odd One Out generator, Social/Emotions pool expansion to 24+, anti-repeat guard everywhere.
10. Buddy-in-game reactions (`BuddyReactor`); first-run buddy-picker onboarding.
11. Sticker scenes: drag owned stickers onto themed backdrops (turns the album into a toy).

**LOW impact (Phase 3 — polish):**
12. Drawing tool fixes (targets, undo, tap-placed stickers, eraser merge).
13. Music record-flow simplification; Mirror-mode self-report star; Memory peek-time formula and kid-friendly win copy.
14. Transition wipes, idle-breathe tiles, per-game `TapGlowBurst` reuse, card medal ribbons on Home.

## 9. Before vs After

**Before:** a beautiful but frozen toy box. Seventeen doors, all open on day one, each leading to an infinite, unchanging quiz loop that restarts at its easiest every visit. Stars accumulate toward a level badge that changes only its own color. The one thing stars buy — stickers — goes into a display case you can't play with. A 5-year-old is charmed for two days; a 7-year-old solves the whole app in one sitting; the Math game is broken in a way that guarantees boredom.

**After:** a world that grows because the child plays. Games come in short adventures with a beginning, a celebration, and a surprise at the end. Each visit picks up where the child's skill actually is — a little harder when they're cruising, quietly gentler when they're struggling. The home hillside sprouts a treehouse, then a pond, then fireworks as their level climbs; new lands, card packs, categories, and buddies wake up at milestones they can see coming. Their buddy plays alongside them, every button talks, no screen dead-ends a pre-reader, and the stickers they earn become scenes they build. Same 17 games — but now there's always a reason the next round is different from the last one, and always one more visible thing to grow toward.

---
*Generated from full-code analysis on 2026-07-08. Line references are to the current `main` (commit 8827ade).*
