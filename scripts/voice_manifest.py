#!/usr/bin/env python3
"""Audit the bundled child-voice clips against every phrase the app can speak.

SpeechHelper plays BundledVoice/<sha256(text)[0:20]>.m4a when it exists and
falls back to live TTS (robotic) when it doesn't. Any new or changed spoken
string therefore needs a new clip. This script enumerates the phrases the
current code can produce — including generated cross-products like the
Odd One Out explanations — and prints the ones with no clip, plus a
missing-clips manifest (text<TAB>filename) to feed the clip-generation
pipeline (en-US-AnaNeural).

Usage:  python3 scripts/voice_manifest.py [--all]
        --all  print every phrase with its status, not just missing ones
"""

import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VOICE_DIR = ROOT / "TinyExplorers" / "BundledVoice"

# --- Odd One Out generator vocabulary (keep in sync with OddOneOutGameView.swift)
ODD_CATEGORIES = {
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


def phrases():
    # Odd One Out: every intruder x every other base category
    for base, _ in ODD_CATEGORIES.items():
        for other, items in ODD_CATEGORIES.items():
            if other == base:
                continue
            for item in items:
                yield f"The {item} is not a {base}!"

    # Adventure flow
    yield "You did it!"
    yield "Oops! Try again!"
    yield "Find the odd one out!"


def clip_name(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:20]


def main() -> None:
    show_all = "--all" in sys.argv
    existing = {p.stem for p in VOICE_DIR.glob("*.m4a")}
    missing = []
    total = 0
    for text in phrases():
        total += 1
        name = clip_name(text)
        have = name in existing
        if show_all:
            print(("HAVE " if have else "MISS "), text)
        if not have:
            missing.append((text, name))

    print(f"\n{total} phrases checked, {len(missing)} missing clips", file=sys.stderr)
    if missing:
        out = ROOT / "scripts" / "missing_clips.tsv"
        with open(out, "w") as f:
            for text, name in missing:
                f.write(f"{text}\t{name}.m4a\n")
        print(f"manifest written to {out}", file=sys.stderr)


if __name__ == "__main__":
    main()
