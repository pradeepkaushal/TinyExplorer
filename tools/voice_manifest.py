#!/usr/bin/env python3
"""Voice-clip coverage audit for TinyExplorers.

SpeechHelper plays a pre-rendered neural clip when BundledVoice contains a
file named sha256(phrase)[0:20].m4a, and falls back to robotic live TTS
otherwise. This tool enumerates every phrase the app can speak — static
strings plus expansions of the dynamic templates — and reports which ones
have no bundled clip, so the TTS pipeline can batch-generate exactly the
missing set.

Usage:  python3 tools/voice_manifest.py
Output: tools/missing_voice_phrases.tsv   (hash <TAB> phrase)
"""

import hashlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "TinyExplorers"
VOICE_DIR = SRC / "BundledVoice"


def clip_hash(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()[:20]


def existing_clip_hashes() -> set[str]:
    return {p.stem for p in VOICE_DIR.glob("*.m4a")}


# ---------------------------------------------------------------------------
# 1. Static phrases: every non-interpolated string literal passed to
#    SpeechHelper.speak / SpeechHelper.cheer anywhere in the sources.
# ---------------------------------------------------------------------------

SPEAK_CALL = re.compile(r'SpeechHelper\.(?:speak|cheer)\(\s*"((?:[^"\\]|\\.)*)"')


def static_phrases() -> set[str]:
    phrases = set()
    for swift in SRC.rglob("*.swift"):
        for match in SPEAK_CALL.finditer(swift.read_text()):
            text = match.group(1)
            if "\\(" in text:  # interpolated — handled by template expansion
                continue
            phrases.add(text.replace('\\"', '"'))
    return phrases


# ---------------------------------------------------------------------------
# 2. Dynamic templates with finite expansions. Keep these lists in sync with
#    the Swift sources they mirror (file noted on each block).
# ---------------------------------------------------------------------------

def dynamic_phrases() -> set[str]:
    phrases = set()

    # Games/OddOneOutGameView.swift — OddCategory.all
    odd_categories = {
        "fruit": ["apple", "orange", "lemon", "strawberry", "grapes", "banana", "watermelon", "peach"],
        "animal": ["dog", "cat", "frog", "bunny", "bear", "cow", "pig", "lion"],
        "vehicle": ["car", "bus", "train", "plane", "helicopter", "tractor", "scooter"],
        "flower": ["blossom", "sunflower", "hibiscus", "tulip", "rose"],
        "sky thing": ["sun", "moon", "star", "cloud", "rainbow"],
        "sea friend": ["fish", "dolphin", "octopus", "crab", "whale", "seashell"],
        "sweet treat": ["ice cream", "cupcake", "cake", "lollipop", "donut", "cookie"],
        "vegetable": ["broccoli", "carrot", "corn", "tomato", "cucumber"],
        "piece of clothing": ["sneaker", "cap", "glove", "sock", "dress", "coat"],
        "instrument": ["piano", "guitar", "trumpet", "drum", "violin"],
        "bug": ["bee", "ladybug", "butterfly", "caterpillar", "ant"],
        "ball": ["soccer ball", "basketball", "tennis ball", "baseball"],
        "food": ["pizza", "burger", "taco", "sandwich", "spaghetti"],
    }
    for base_singular in odd_categories:
        article = "an" if base_singular[0] in "aeiou" else "a"
        for other, items in odd_categories.items():
            if other == base_singular:
                continue
            for item in items:
                phrases.add(f"The {item} is not {article} {base_singular}!")

    # Games/ClockGameView.swift — spoken answer options (SpeakOptionButton)
    for h in range(1, 13):
        phrases.add(f"{h} o'clock")
        phrases.add(f"Half past {h}")

    # Games/SocialGameView.swift — option sentences, extracted from source so
    # the manifest can't drift from the scenario data.
    social_src = (SRC / "Games" / "SocialGameView.swift").read_text()
    for m in re.finditer(r'text:\s*"((?:[^"\\]|\\.)*)"', social_src):
        phrases.add(m.group(1).replace('\\"', '"'))

    # Games/ImaginationGameView.swift — Story Land
    backdrops = ["Sunny Meadow", "Deep Blue Sea", "Starry Space", "Magic Castle"]
    stickers = [
        "puppy", "kitten", "bunny", "unicorn", "dinosaur", "robot",
        "tree", "flower", "mushroom", "rainbow", "butterfly", "star",
        "balloon", "ball", "kite", "crown", "present", "drum",
        "apple", "cake", "ice cream", "cookie", "lollipop", "cupcake",
    ]
    phrases.add("Tap a sticker to build your story!")
    for b in backdrops:
        phrases.add(b)
    for s in stickers:
        phrases.add(s.capitalize())
        phrases.add(f"Bye bye, {s}!")
    # One- and two-character stories are enumerable; three-character
    # stories explode combinatorially (~50k) and stay on live TTS until
    # the story engine is reworked to stitch shorter clip-backed lines.
    # Article mirrors tellStory()'s an() helper ("an apple", "a unicorn").
    def an(name: str) -> str:
        return f"an {name}" if name in ("apple", "ice cream") else f"a {name}"

    for b in backdrops:
        place = b.lower()
        for a in stickers:
            phrases.add(f"Once upon a time, a happy {a} went on a big adventure in the {place}!")
            for c in stickers:
                phrases.add(f"Once upon a time, {an(a)} met {an(c)} in the {place}, and they became best friends!")

    return phrases


# ---------------------------------------------------------------------------
# 3. Snapshot lists: exhaustive per-game expansions of the interpolated
#    speak() calls (math operand cross-products, animal stories, listen-find
#    corrections, ...) extracted from the Swift sources. Regenerate the
#    affected file whenever a game's spoken vocabulary or templates change.
# ---------------------------------------------------------------------------

def snapshot_phrases() -> set[str]:
    phrases = set()
    for txt in sorted((ROOT / "tools" / "phrases").glob("*.txt")):
        phrases.update(line for line in txt.read_text().splitlines() if line.strip())
    return phrases


def main() -> None:
    have = existing_clip_hashes()
    all_phrases = sorted(static_phrases() | dynamic_phrases() | snapshot_phrases())
    missing = [(clip_hash(p), p) for p in all_phrases if clip_hash(p) not in have]

    out = ROOT / "tools" / "missing_voice_phrases.tsv"
    out.write_text("".join(f"{h}\t{p}\n" for h, p in missing))

    print(f"bundled clips:      {len(have)}")
    print(f"phrases enumerated: {len(all_phrases)}")
    print(f"missing clips:      {len(missing)}  ->  {out.relative_to(ROOT)}")
    for h, p in missing[:15]:
        print(f"  {h}  {p}")
    if len(missing) > 15:
        print(f"  ... and {len(missing) - 15} more")


if __name__ == "__main__":
    main()
