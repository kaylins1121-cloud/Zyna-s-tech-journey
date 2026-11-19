# Zyna – Personal Engineering + AI Portfolio

Website portfolio của Trần Thị Khánh Ly (Zyna): Automation × AI × Computer Vision.
Trang tĩnh (1 file `index.html`) + Supabase (database, đăng nhập, lưu trữ ảnh/video), host trên Vercel.

## Cấu trúc
- `index.html` – toàn bộ website
- `vercel.json` – header bảo mật (CSP, HSTS, …)
- `supabase/setup.sql` – bảng, RLS, storage, dữ liệu mẫu

## Cấu hình Supabase
Mở `index.html`, tìm dòng `const SB={url:"",key:""};` và điền:
- `url`: Project URL (dạng https://xxxx.supabase.co)
- `key`: **anon public key** (KHÔNG dùng service_role key)

## Deploy
Import repo này vào Vercel (Framework Preset: Other, không cần build). Mỗi lần push lên `main`, Vercel tự deploy lại.
