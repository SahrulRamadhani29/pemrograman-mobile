"""Simpan potongan notifikasi Campus saja; notifikasi aplikasi lain tidak disimpan."""
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET
import re
import io
import argparse
from PIL import Image

root=Path(__file__).resolve().parents[1]
adb=['adb','-s','33a40574']
parser=argparse.ArgumentParser()
parser.add_argument('name')
parser.add_argument('--title',default='Jadwal kuliah berubah')
parser.add_argument('--tap',action='store_true')
parser.add_argument('--package',default='id.ac.polinema.sahrul.campus_notify.week07')
args=parser.parse_args()
name=Path(args.name).stem
subprocess.run(adb+['shell','cmd','statusbar','expand-notifications'],capture_output=True,check=True)
for _ in range(3):
    subprocess.run(adb+['shell','rm','-f','/sdcard/campus-notification.xml'],capture_output=True,check=True)
    result=subprocess.run(adb+['shell','uiautomator','dump','/sdcard/campus-notification.xml'],capture_output=True)
    xml=subprocess.run(adb+['shell','cat','/sdcard/campus-notification.xml'],capture_output=True)
    try:
        tree=ET.fromstring(xml.stdout)
        break
    except ET.ParseError:
        continue
else:
    raise RuntimeError('Belum dapat membaca notification shade')
parents={child:parent for parent in tree.iter() for child in parent}
target=next((node for node in tree.iter('node') if node.get('text')==args.title),None)
if target is None:raise RuntimeError('Notifikasi Campus belum ditemukan')
click_bounds=[int(x) for x in re.findall(r'\d+',target.get('bounds'))]
card=target
while card is not None and card.get('resource-id')!='android:id/status_bar_latest_event_content':card=parents.get(card)
if card is None:
    # Vivo memakai layout sendiri ketika beberapa notifikasi dikelompokkan.
    card=target
    while card is not None and card.get('resource-id')!='com.android.systemui:id/expanded':card=parents.get(card)
if card is None:raise RuntimeError('Batas kartu notifikasi belum ditemukan')
bounds=[int(x) for x in re.findall(r'\d+',card.get('bounds'))]
raw=subprocess.check_output(adb+['exec-out','screencap','-p'])
Image.open(io.BytesIO(raw)).crop(tuple(bounds)).save(root/'screenshots'/f'{name}.png')
dump=subprocess.check_output(adb+['shell','dumpsys','notification'],text=True,encoding='utf-8',errors='replace')
blocks=re.findall(r'(?ms)^    NotificationRecord\([^\n]*pkg='+re.escape(args.package)+r'\s.*?(?=^    NotificationRecord|^  \S|\Z)',dump)
(root/'docs'/f'evidence-{name}.txt').write_text('\n'.join(blocks),encoding='utf-8')
print('Kartu notifikasi tersimpan:',name,'records:',len(blocks))
for line in '\n'.join(blocks).splitlines():
    if any(s in line for s in ['NotificationRecord(', 'mSound=', 'mShowBadge=', 'mImportance=', 'mInterruptionTimeMs=']):print(line.strip()[:600])
if args.tap:
    x=(click_bounds[0]+click_bounds[2])//2;y=(click_bounds[1]+click_bounds[3])//2
    subprocess.run(adb+['shell','input','tap',str(x),str(y)],check=True,capture_output=True)
