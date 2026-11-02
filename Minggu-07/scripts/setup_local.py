"""Siapkan HTTPS lokal dan akun demo tanpa menulis secret ke source code."""
from pathlib import Path
from datetime import datetime, timedelta, timezone
import base64
import ipaddress
import secrets
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa

root = Path(__file__).resolve().parents[1]
private = root / 'backend/storage/app/private'
private.mkdir(parents=True, exist_ok=True)
(root / 'assets').mkdir(exist_ok=True)
if not (private / 'server-key.pem').exists():
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, 'Campus Notify Local Development')])
    now = datetime.now(timezone.utc)
    cert = (x509.CertificateBuilder().subject_name(name).issuer_name(name)
        .public_key(key.public_key()).serial_number(x509.random_serial_number())
        .not_valid_before(now-timedelta(days=1)).not_valid_after(now+timedelta(days=365))
        .add_extension(x509.BasicConstraints(ca=True, path_length=None), critical=True)
        .add_extension(x509.SubjectAlternativeName([x509.DNSName('localhost'), x509.IPAddress(ipaddress.ip_address('127.0.0.1'))]), critical=False)
        .sign(key, hashes.SHA256()))
    (private / 'server-key.pem').write_bytes(key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption()))
    (root / 'assets/dev-ca.pem').write_bytes(cert.public_bytes(serialization.Encoding.PEM))
env = root / 'backend/.env'
if not env.exists():
    password = secrets.token_urlsafe(12)
    text = (root / 'backend/.env.example').read_text()
    text = text.replace('APP_NAME=Laravel', 'APP_NAME="Campus Notify"').replace('APP_DEBUG=true', 'APP_DEBUG=false')
    text = text.replace('APP_KEY=', 'APP_KEY=base64:'+base64.b64encode(secrets.token_bytes(32)).decode())
    text = text.replace('APP_URL=http://localhost:8000', 'APP_URL=https://127.0.0.1:8447')
    text += '\nCAMPUS_DEMO_EMAIL=rama@polinema.ac.id\nCAMPUS_DEMO_PASSWORD='+password+'\nACCESS_TOKEN_TTL=900\nFIREBASE_PROJECT_ID=\nFIREBASE_CREDENTIALS=\n'
    env.write_text(text)
    (root/'login-lokal.txt').write_text('Email: rama@polinema.ac.id\nPassword: '+password+'\n', encoding='utf-8')
(root/'backend/database/database.sqlite').touch(exist_ok=True)
commands=root/'backend/routes/console.php'
if 'campus_commands.php' not in commands.read_text():
    commands.write_text(commands.read_text()+"\nrequire __DIR__.'/campus_commands.php';\n")
print('HTTPS lokal dan akun demo siap. Kredensial ada di login-lokal.txt (diabaikan Git).')
