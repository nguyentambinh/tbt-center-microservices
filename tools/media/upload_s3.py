"""
Họ tên: Nguyễn Tâm Bình
MSSV:   2324801030003
Môn:    Kiến trúc và thiết kế phần mềm
Bài:    Đồ án TBT Center đa quốc gia
Ngày:   2026-10-25

Tải ảnh, hợp đồng (jpg, pdf, docx) lên bucket S3 (Garage) bằng chữ ký AWS Signature V4, giữ nguyên đường dẫn tương đối làm tên object.
Khóa đọc từ deploy/secrets/garage.env (S3_ACCESS_KEY_ID, S3_SECRET_ACCESS_KEY).

Cách dùng: python tools/media/upload_s3.py <thư mục> <endpoint, vd https://s3-vn.example> [bucket=tbt-media]
"""
import datetime
import hashlib
import hmac
import os
import sys
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def env(path):
    out = {}
    for line in open(path, encoding='utf-8'):
        line = line.strip()
        if line and not line.startswith('#') and '=' in line:
            k, v = line.split('=', 1)
            out[k] = v
    return out


def sign(key, msg):
    return hmac.new(key, msg.encode(), hashlib.sha256).digest()


# Loại tệp nhận tải lên: ảnh dự án, nhân viên; hợp đồng Word, PDF
TYPES = {'.jpg': 'image/jpeg', '.pdf': 'application/pdf',
         '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'}


def put(endpoint, bucket, key, data, access, secret, region='garage', content_type='image/jpeg'):
    url = urllib.parse.urlsplit(endpoint)
    path = '/' + bucket + '/' + urllib.parse.quote(key, safe='/-_.~')
    now = datetime.datetime.now(datetime.timezone.utc)
    amz, day = now.strftime('%Y%m%dT%H%M%SZ'), now.strftime('%Y%m%d')
    payload = hashlib.sha256(data).hexdigest()
    headers = {'host': url.netloc, 'x-amz-content-sha256': payload, 'x-amz-date': amz,
               'content-type': content_type, 'cache-control': 'private, max-age=86400'}
    signed = ';'.join(sorted(headers))
    canonical = '\n'.join(['PUT', path, '', *[f'{k}:{headers[k]}' for k in sorted(headers)], '', signed, payload])
    scope = f'{day}/{region}/s3/aws4_request'
    to_sign = '\n'.join(['AWS4-HMAC-SHA256', amz, scope, hashlib.sha256(canonical.encode()).hexdigest()])
    k = sign(sign(sign(sign(('AWS4' + secret).encode(), day), region), 's3'), 'aws4_request')
    signature = hmac.new(k, to_sign.encode(), hashlib.sha256).hexdigest()
    headers['authorization'] = f'AWS4-HMAC-SHA256 Credential={access}/{scope}, SignedHeaders={signed}, Signature={signature}'
    req = urllib.request.Request(f'{url.scheme}://{url.netloc}{path}', data=data, method='PUT', headers=headers)
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.status


def main():
    folder, endpoint = sys.argv[1], sys.argv[2]
    bucket = sys.argv[3] if len(sys.argv) > 3 else 'tbt-media'
    keys = env(os.path.join(ROOT, 'deploy', 'secrets', 'garage.env'))
    n = 0
    for base, _, files in os.walk(folder):
        for f in sorted(files):
            content_type = TYPES.get(os.path.splitext(f)[1].lower())
            if content_type is None:
                continue
            path = os.path.join(base, f)
            key = os.path.relpath(path, folder).replace(os.sep, '/')
            put(endpoint, bucket, key, open(path, 'rb').read(), keys['S3_ACCESS_KEY_ID'], keys['S3_SECRET_ACCESS_KEY'],
                content_type=content_type)
            n += 1
    print(f'Đã tải {n} tệp lên {endpoint}/{bucket}')


if __name__ == '__main__':
    main()
