#!/usr/bin/env python3
"""Bundle a closed Mach-O dependency graph; no runtime Homebrew requirement.
SPDX-License-Identifier: GPL-3.0-or-later
"""
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
app = Path(sys.argv[1]).resolve()
frameworks = app / 'Contents/Frameworks'
plugins = app / 'Contents/PlugIns/GStreamer'
notices = app / 'Contents/Resources/ThirdPartyNotices'
for directory in (frameworks, plugins, notices):
    directory.mkdir(parents=True, exist_ok=True)

def output(*args):
    return subprocess.check_output(args, text=True).strip()

prefix = Path(output('brew', '--prefix', 'gstreamer'))
# Only mirroring and audio plugins, no HLS/HTTP/RTMP/cloud playback plugins.
names = ['coreelements', 'app', 'playback', 'typefindfunctions', 'videoparsersbad',
         'applemedia', 'videoconvertscale', 'audioparsers', 'audioconvert',
         'audioresample', 'volume', 'libav', 'osxaudio', 'level', 'videofilter', 'autodetect']
queue = [(root / '.build/airplay-engine/uxplay-core.dylib', frameworks / 'uxplay-core.dylib')]
for name in names:
    src = prefix / 'lib/gstreamer-1.0' / f'libgst{name}.dylib'
    if not src.is_file():
        raise SystemExit(f'Required GStreamer plugin is missing: {src}')
    queue.append((src, plugins / src.name))

copied = {}
owners = set()
manifest = []
while queue:
    src, dest = queue.pop(0)
    src = src.resolve()
    if dest in copied:
        if copied[dest] != src:
            raise SystemExit(f'Dependency filename collision: {dest.name}')
        continue
    copied[dest] = src
    shutil.copy2(src, dest)
    dest.chmod(0o755)
    parts = src.parts
    if 'Cellar' in parts:
        i = parts.index('Cellar')
        owners.add(Path(*parts[:i + 3]))
    lines = output('otool', '-L', str(src)).splitlines()[1:]
    commands = ['install_name_tool', '-id', '@loader_path/' + dest.name]
    for line in lines:
        dep = line.strip().split(' (compatibility')[0]
        if dep.startswith(('/System/Library/', '/usr/lib/')):
            continue
        if dep == '@rpath/' + src.name or dep == str(src):
            continue  # install ID, not an imported dependency
        if dep.startswith('@loader_path/'):
            dependency = src.parent / dep.removeprefix('@loader_path/')
        elif dep.startswith('/'):
            dependency = Path(dep)
        else:
            raise SystemExit(f'Unresolved dependency {dep} in {src.name}')
        target = frameworks / dependency.name
        if dependency.resolve() == src:
            continue
        queue.append((dependency, target))
        relative = os.path.relpath(target, dest.parent)
        commands += ['-change', dep, '@loader_path/' + relative]
    subprocess.run(commands + [str(dest)], check=True, capture_output=True)
    manifest.append({'file': str(dest.relative_to(app)), 'source': str(src)})

# Include static engine dependencies in the same source/license inventory.
for formula in ('libplist', 'openssl@3'):
    owners.add(Path(output('brew', '--prefix', formula)).resolve())
# Preserve all available package license texts alongside exact formula versions.
for owner in sorted(owners):
    target = notices / (owner.parent.name + '-' + owner.name)
    target.mkdir(exist_ok=True)
    for path in owner.rglob('*'):
        if path.is_file() and any(path.name.upper().startswith(x) for x in ('LICENSE', 'COPYING', 'COPYRIGHT', 'NOTICE')):
            relative = path.relative_to(owner)
            (target / relative).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target / relative)
    receipt = owner / 'INSTALL_RECEIPT.json'
    if receipt.exists():
        data = json.loads(receipt.read_text())
        (target / 'build-source.json').write_text(json.dumps({
            'formula': owner.parent.name, 'version': owner.name,
            'source': {key: value for key, value in data.get('source', {}).items() if key != 'path'}
        }, indent=2))
    recipe = owner / '.brew' / (owner.parent.name + '.rb')
    if recipe.is_file():
        shutil.copy2(recipe, target / recipe.name)
for path in [root/'LICENSE', root/'THIRD_PARTY_NOTICES.md',
             root/'ThirdParty/Popyachsa-AirPlay/NOTICE',
             root/'ThirdParty/Popyachsa-AirPlay/LICENSE',
             root/'ThirdParty/Popyachsa-AirPlay/third_party/uxplay/LICENSE']:
    shutil.copy2(path, notices / (path.parent.name + '-' + path.name))
for dest in copied:
    for line in output('otool', '-L', str(dest)).splitlines()[1:]:
        dep = line.strip().split(' (compatibility')[0]
        if not dep.startswith(('@loader_path/', '/System/Library/', '/usr/lib/')):
            raise SystemExit(f'Non-bundled dependency remains: {dep}')
    subprocess.run(['codesign', '--force', '--sign', '-', str(dest)], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
# A Homebrew build must not falsely claim a deployment floor older than its host.
plist = app/'Contents/Info.plist'
data = plistlib.loads(plist.read_bytes())
data['LSMinimumSystemVersion'] = output('sw_vers', '-productVersion')
plist.write_bytes(plistlib.dumps(data))
(app/'Contents/Resources/airplay-build.json').write_text(json.dumps({
    'popyachsa': output('git', '-C', str(root/'ThirdParty/Popyachsa-AirPlay'), 'rev-parse', 'HEAD'),
    'uxplay': output('git', '-C', str(root/'ThirdParty/Popyachsa-AirPlay/third_party/uxplay'), 'rev-parse', 'HEAD'),
    'minimumSystemVersion': data['LSMinimumSystemVersion'],
    'libraries': [{ 'file': item['file'] } for item in manifest],
    'formulas': [p.parent.name + '@' + p.name for p in sorted(owners)]
}, indent=2))
print(f'Bundled {len(copied)} Mach-O libraries/plugins. Local minimum macOS: {data["LSMinimumSystemVersion"]}.')
