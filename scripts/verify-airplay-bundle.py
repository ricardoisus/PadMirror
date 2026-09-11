#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check the actual bundled plugin registry, not the system Homebrew registry."""
import ctypes
import os
from pathlib import Path
import subprocess
import sys
import tempfile

app = Path(sys.argv[1]).resolve()
with tempfile.TemporaryDirectory(prefix='padmirror-gst-check-') as cache:
    os.environ['GST_PLUGIN_SYSTEM_PATH_1_0'] = str(app/'Contents/PlugIns/GStreamer')
    os.environ['GST_PLUGIN_PATH_1_0'] = ''
    os.environ['GST_REGISTRY_FORK'] = 'no'
    os.environ['GST_REGISTRY_1_0'] = str(Path(cache)/'registry.bin')
    gst = ctypes.CDLL(str(app/'Contents/Frameworks/libgstreamer-1.0.0.dylib'))
    gst.gst_init_check.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p]
    gst.gst_init_check.restype = ctypes.c_int
    assert gst.gst_init_check(None, None, None), 'gst_init_check failed'
    gst.gst_element_factory_find.argtypes = [ctypes.c_char_p]
    gst.gst_element_factory_find.restype = ctypes.c_void_p
    gst.gst_object_unref.argtypes = [ctypes.c_void_p]
    required = ['appsrc', 'appsink', 'queue', 'h264parse', 'vtdec', 'videoflip',
                'videoconvert', 'videoscale', 'avdec_aac', 'avdec_alac',
                'audioconvert', 'audioresample', 'volume', 'level', 'fakesink', 'osxaudiosink', 'autoaudiosink']
    for name in required:
        factory = gst.gst_element_factory_find(name.encode())
        assert factory, f'Missing bundled factory: {name}'
        gst.gst_object_unref(factory)
    core = ctypes.CDLL(str(app/'Contents/Frameworks/uxplay-core.dylib'))
    for name in ['create', 'set_device_name', 'set_window', 'set_options', 'set_log_callback', 'start', 'stop', 'destroy']:
        getattr(core, 'airplay_core_' + name)
    print(f'PASS: {len(required)} bundled factories and 8 C ABI symbols')
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
print('PASS: nested bundle signatures')
