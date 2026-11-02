"""Ambil screenshot asli Vivo tanpa redirect biner PowerShell."""
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET

root=Path(__file__).resolve().parents[1]
adb=['adb','-s','33a40574']
action=sys.argv[1] if len(sys.argv)>1 else 'tree'
if action=='capture':
    name=Path(sys.argv[2]).name
    if not name.endswith('.png'):name+='.png'
    path=root/'screenshots'/name
    path.write_bytes(subprocess.check_output(adb+['exec-out','screencap','-p']))
    print(path)
elif action=='tree':
    subprocess.run(adb+['shell','rm','-f','/sdcard/campus-window.xml'],capture_output=True,check=True)
    subprocess.run(adb+['shell','uiautomator','dump','/sdcard/campus-window.xml'],capture_output=True,check=True)
    raw=subprocess.check_output(adb+['shell','cat','/sdcard/campus-window.xml'])
    tree=ET.fromstring(raw)
    for element in tree.iter('node'):
        if element.get('package') not in ['id.ac.polinema.sahrul.campus_notify.week07','com.android.permissioncontroller','com.google.android.permissioncontroller']:continue
        text=element.get('text') or element.get('content-desc')
        if text or element.get('class')=='android.widget.EditText': print(repr(text), element.get('class'), element.get('bounds'), 'clickable='+element.get('clickable',''))
