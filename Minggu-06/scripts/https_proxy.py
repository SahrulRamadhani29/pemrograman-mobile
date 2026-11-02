"""HTTPS localhost -> Laravel localhost. Verifikasi sertifikat tetap aktif di Flutter."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError
import ssl

root = Path(__file__).resolve().parents[1]

class Proxy(BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass  # Jangan mencatat body request/token.

    def do_GET(self):
        data = self.rfile.read(int(self.headers.get('Content-Length', 0))) or None
        headers = {k:v for k,v in self.headers.items() if k.lower() not in ['host','connection','content-length']}
        request = Request('http://127.0.0.1:8006'+self.path, data=data, headers=headers, method=self.command)
        try:
            try:
                response = urlopen(request, timeout=30)
            except HTTPError as error:
                response = error
            body = response.read()
            self.send_response(response.status)
            for key,value in response.headers.items():
                if key.lower() not in ['connection','transfer-encoding','content-length']:
                    self.send_header(key,value)
            self.send_header('Content-Length',str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except Exception:
            self.send_error(502, 'API belum aktif')

    do_POST = do_GET
    do_DELETE = do_GET

server=ThreadingHTTPServer(('127.0.0.1',8446), Proxy)
context=ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(root/'assets/dev-ca.pem', root/'backend/storage/app/private/server-key.pem')
server.socket=context.wrap_socket(server.socket,server_side=True)
print('Campus Notify HTTPS aktif di https://127.0.0.1:8446', flush=True)
server.serve_forever()
