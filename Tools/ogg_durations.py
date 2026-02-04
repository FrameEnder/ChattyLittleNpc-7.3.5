

import os
import sys
from mutagen.oggvorbis import OggVorbis

def get_duration(filepath):
    try:
        audio = OggVorbis(filepath)
        return int(round(audio.info.length))  # duration in seconds
    except Exception as e:
        return 0

def main(folder):
    folder = os.path.abspath(folder)
    ogg_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.lower().endswith('.ogg'):
                ogg_files.append(os.path.join(root, file))

    durations = {}
    total = len(ogg_files)
    print(f"Found {total} .ogg files.")
    for idx, full_path in enumerate(ogg_files, 1):
        print(f"\rProcessing {idx}/{total}: {os.path.basename(full_path)}", end="", flush=True)
        dur = get_duration(full_path)
        rel_path = os.path.relpath(full_path, folder).replace("\\", "/")
        durations[rel_path] = dur
    print("\nWriting durations.lua...")

    with open("durations.lua", "w", encoding="utf-8") as f:
        f.write('_G["SoundDurations"] = _G["SoundDurations"] or {}\n')
        for k, v in durations.items():
            f.write(f'_G["SoundDurations"]["{k}"] = {v}\n')
    print("Done! Wrote durations.lua!\nPlease Add it to the .toc File to properly load this information!")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ogg_durations.py <folder>")
    else:
        main(sys.argv[1])