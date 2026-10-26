"""
Họ tên: Nguyễn Tâm Bình
MSSV:   2324801030003
Môn:    Kiến trúc và thiết kế phần mềm
Bài:    Đồ án TBT Center đa quốc gia
Ngày:   2026-10-25

Gán ảnh cho nhân viên và dự án của một khu vực: cắt, thu nhỏ ảnh, đặt tên theo mã,
sinh update.sql ghi đường dẫn object (employees/<mã>.jpg, projects/<mã>.jpg).

Cách dùng:
  python tools/media/build_media.py --region vn --workers <thư mục ảnh công nhân> \
      --sites <thư mục ảnh công trình, chia thư mục con theo loại> \
      --employees vn_employees.txt --projects vn_projects.tsv --out deploy/media/vn
  employees.txt: mỗi dòng một mã nhân viên; projects.tsv: mã<TAB>tên dự án.
"""
import argparse
import os
import unicodedata

from PIL import Image, ImageOps

REGION_OFFSET = {'vn': 0, 'de': 77, 'us': 31, 'br': 62, 'za': 93, 'au': 124}

# Loại công trình theo từ khóa trong tên dự án (vi, de, en, pt); không khớp thì là đang thi công
CATEGORIES = [
    ('khach-san', ['khach san', 'nghi duong', 'resort', 'hotel', 'einkaufszentrum', 'shopping', 'mall']),
    ('chung-cu-cao-tang', ['chung cu', 'can ho', 'cao tang', 'tru so', 'van phong', 'toa nha', 'buro', 'office',
                           'apartment', 'mehrfamilien', 'edificio', 'apartamento', 'tower', 'vien nghien cuu']),
    ('nha-o', ['nha', 'biet thu', 'villa', 'einfamilienhaus', 'house', 'casa', 'residencia', 'home']),
]


def plain(text):
    text = unicodedata.normalize('NFD', text.lower()).replace('đ', 'd')
    return ''.join(c for c in text if unicodedata.category(c) != 'Mn')


def category(name):
    words = plain(name)
    for cat, keys in CATEGORIES:
        if any(k in words for k in keys):
            return cat
    return 'dang-thi-cong'


def images(folder):
    return sorted(os.path.join(folder, f) for f in os.listdir(folder) if f.lower().endswith(('.jpg', '.jpeg', '.png')))


def save_square(src, dst, size=512):
    im = ImageOps.exif_transpose(Image.open(src)).convert('RGB')
    side = min(im.size)
    # Ảnh dọc: lấy phần trên (đầu, vai) thay vì giữa ảnh
    top = int((im.height - side) * 0.2)
    left = (im.width - side) // 2
    im.crop((left, top, left + side, top + side)).resize((size, size), Image.LANCZOS).save(dst, 'JPEG', quality=82, optimize=True, progressive=True)


def save_wide(src, dst, size=(1280, 720)):
    im = ImageOps.exif_transpose(Image.open(src)).convert('RGB')
    ImageOps.fit(im, size, Image.LANCZOS, centering=(0.5, 0.45)).save(dst, 'JPEG', quality=82, optimize=True, progressive=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--region', required=True)
    ap.add_argument('--workers', required=True)
    ap.add_argument('--sites', required=True)
    ap.add_argument('--employees', required=True)
    ap.add_argument('--projects', required=True)
    ap.add_argument('--out', required=True)
    a = ap.parse_args()

    os.makedirs(os.path.join(a.out, 'employees'), exist_ok=True)
    os.makedirs(os.path.join(a.out, 'projects'), exist_ok=True)
    sql = ['-- Sinh bởi tools/media/build_media.py: đường dẫn ảnh trong bucket tbt-media của Garage khu vực']

    workers = images(a.workers)
    employees = [l.strip() for l in open(a.employees, encoding='utf-8') if l.strip()]
    offset = REGION_OFFSET.get(a.region, 0)
    sql.append('\\connect hr_db')
    for i, emp in enumerate(employees):
        key = f'employees/{emp}.jpg'
        save_square(workers[(offset + i) % len(workers)], os.path.join(a.out, key))
        sql.append(f"update employees set photo_url = '{key}' where id = '{emp}';")

    pools = {cat: images(os.path.join(a.sites, cat)) for cat in os.listdir(a.sites) if os.path.isdir(os.path.join(a.sites, cat))}
    used = {cat: offset for cat in pools}
    sql.append('\\connect project_contract_db')
    counts = {}
    for line in open(a.projects, encoding='utf-8'):
        if not line.strip():
            continue
        pid, _, name = line.rstrip('\n').partition('\t')
        cat = category(name)
        pool = pools[cat]
        src = pool[used[cat] % len(pool)]
        used[cat] += 1
        counts[cat] = counts.get(cat, 0) + 1
        key = f'projects/{pid}.jpg'
        save_wide(src, os.path.join(a.out, key))
        sql.append(f"update projects set image_key = '{key}' where id = '{pid}';")

    open(os.path.join(a.out, 'update.sql'), 'w', encoding='utf-8', newline='\n').write('\n'.join(sql) + '\n')
    print(f'{a.region}: {len(employees)} ảnh nhân viên, dự án theo loại {counts}')


if __name__ == '__main__':
    main()
