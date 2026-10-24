-- ============ ZYNA PORTFOLIO – SUPABASE SETUP ============
-- Cách dùng: Supabase Dashboard → SQL Editor → New query → dán toàn bộ file → Run.

create table if not exists projects (
  id text primary key, slug text unique not null, title text not null,
  cat text default 'Khác', year int, tags text[] default '{}',
  summary text, problem text, method jsonb default '[]', results jsonb default '[]',
  links jsonb default '{}', media jsonb default '[]', sort int default 0, published boolean default true,
  created_at timestamptz default now());

create table if not exists articles (
  id text primary key, slug text unique not null, title text not null,
  cat text default 'Khác', date text, excerpt text, body jsonb default '[]',
  sort int default 0, published boolean default true, created_at timestamptz default now());

alter table if exists projects add column if not exists media jsonb default '[]';  -- nếu bạn đã chạy bản cũ

create table if not exists settings (key text primary key, value jsonb not null);

-- Danh sách admin (thêm email của bạn sau khi tạo user ở Phase 7)
create table if not exists admins (user_id uuid primary key references auth.users on delete cascade);

create or replace function is_admin() returns boolean
language sql security definer set search_path = public stable
as $$ select exists (select 1 from admins where user_id = auth.uid()) $$;

-- ---- Row Level Security: khách chỉ đọc, admin mới sửa ----
alter table projects enable row level security;
alter table articles enable row level security;
alter table settings enable row level security;
alter table admins   enable row level security;   -- không có policy = chỉ service role truy cập

create policy "public read projects" on projects for select using (published or is_admin());
create policy "admin write projects" on projects for all using (is_admin()) with check (is_admin());
create policy "public read articles" on articles for select using (published or is_admin());
create policy "admin write articles" on articles for all using (is_admin()) with check (is_admin());
create policy "public read settings" on settings for select using (true);
create policy "admin write settings" on settings for all using (is_admin()) with check (is_admin());

-- ---- Storage cho Phase 6: ảnh/video, tối đa 50 MB/file ----
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media','media',true,52428800,
  array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm'])
on conflict (id) do nothing;
create policy "public read media" on storage.objects for select using (bucket_id = 'media');
create policy "admin write media" on storage.objects for all
  using (bucket_id = 'media' and is_admin()) with check (bucket_id = 'media' and is_admin());

-- ---- Dữ liệu mẫu hiện tại ----
insert into projects(id,slug,title,cat,year,tags,summary,problem,method,results,links,sort) values ('p0','computer-vision','Computer Vision','Computer Vision',2026,array['Python','PyTorch','OpenCV'],'Hệ thống nhận diện và theo dõi phương tiện, người đi bộ trên đường phố từ video camera.','Phát hiện đối tượng theo thời gian thực trong điều kiện ánh sáng và mật độ giao thông thay đổi, làm nền tảng cho các ứng dụng giao thông thông minh.','["Thu thập và gán nhãn dữ liệu video đường phố","Huấn luyện mô hình phát hiện (YOLO) bằng PyTorch","Theo dõi đối tượng và tiền xử lý ảnh bằng OpenCV","Đánh giá và tinh chỉnh siêu tham số"]'::jsonb,'[["mAP","XX%"],["FPS","XX"],["Số lớp","X"]]'::jsonb,'{"github":"#","report":"#"}'::jsonb,4) on conflict (id) do nothing;
insert into projects(id,slug,title,cat,year,tags,summary,problem,method,results,links,sort) values ('p1','electromagnetic-localization','Electromagnetic Localization','Research',2025,array['MATLAB','Optimization','FIM/CRLB'],'Nghiên cứu mô phỏng định vị trong trường điện từ, phân tích giới hạn độ chính xác bằng FIM/CRLB.','Xác định vị trí đối tượng dựa trên tín hiệu điện từ và đánh giá giới hạn lý thuyết của sai số ước lượng.','["Xây dựng mô hình trường điện từ","Tính ma trận thông tin Fisher (FIM) và cận CRLB","Tối ưu bố trí cảm biến","Mô phỏng và so sánh với lý thuyết"]'::jsonb,'[["RMSE","XX mm"],["Cải thiện","XX%"],["Kịch bản","X"]]'::jsonb,'{"github":"#","report":"#"}'::jsonb,3) on conflict (id) do nothing;
insert into projects(id,slug,title,cat,year,tags,summary,problem,method,results,links,sort) values ('p2','automation-system','Automation System','Automation',2025,array['Arduino','C++','Sensors'],'Hệ thống tự động hóa dùng cảm biến và vi điều khiển để giám sát và điều khiển quy trình nhỏ.','Thiết kế mạch điều khiển ổn định, đọc dữ liệu cảm biến và phản hồi theo thời gian thực.','["Thiết kế sơ đồ khối và mạch","Lập trình firmware C++ trên Arduino","Hiệu chuẩn cảm biến, điều khiển PID","Kiểm thử và đo đạc"]'::jsonb,'[["Sai số","XX%"],["Thời gian đáp ứng","XX ms"],["Cảm biến","X"]]'::jsonb,'{"github":"#","report":"#"}'::jsonb,2) on conflict (id) do nothing;
insert into projects(id,slug,title,cat,year,tags,summary,problem,method,results,links,sort) values ('p3','portfolio-website','Personal Portfolio Website','Web',2026,array['React','Tailwind','Node.js'],'Website portfolio cá nhân kết hợp hệ thống quản trị nội dung để tự cập nhật dự án và bài viết.','Có một nơi tập trung giới thiệu dự án, hành trình học tập và định hướng, dễ cập nhật mà không cần sửa code.','["Thiết kế giao diện và hệ thống màu","Xây dựng trang chủ, dự án, bài viết","Dashboard quản trị và lưu trữ Supabase","Triển khai lên hosting"]'::jsonb,'[["Trang","X"],["Lighthouse","XX"],["Thời gian tải","X s"]]'::jsonb,'{"github":"#","report":"#"}'::jsonb,1) on conflict (id) do nothing;
insert into articles(id,slug,title,cat,date,excerpt,body,sort) values ('a0','unet-segnet-unext','So sánh các mô hình AI cho Computer Vision (UNet vs SegNet vs UNeXt)','Computer Vision','12 Sep 2026','Điểm khác nhau về kiến trúc và khi nào nên chọn mô hình nào cho bài toán phân đoạn ảnh.','[["p","Phân đoạn ảnh (segmentation) gán nhãn cho từng điểm ảnh. Ba kiến trúc dưới đây đều theo mô hình encoder–decoder nhưng khác nhau ở cách truyền thông tin."],["h","UNet"],["p","UNet nối trực tiếp (skip connection) đặc trưng của encoder sang decoder, giúp giữ chi tiết biên. Rất phổ biến trong ảnh y tế nhờ hoạt động tốt với ít dữ liệu."],["h","SegNet"],["p","SegNet lưu lại chỉ số max-pooling ở encoder để upsampling chính xác ở decoder, tiết kiệm bộ nhớ hơn so với việc truyền toàn bộ đặc trưng."],["h","UNeXt"],["p","UNeXt là biến thể nhẹ, kết hợp tích chập với khối MLP, giảm mạnh số tham số và chi phí tính toán, phù hợp thiết bị hạn chế tài nguyên."],["h","Nên chọn gì?"],["ul",["Cần độ chính xác biên, dữ liệu ít: UNet","Cần tiết kiệm bộ nhớ khi suy luận: SegNet","Cần mô hình nhẹ, chạy nhanh: UNeXt"]]]'::jsonb,3) on conflict (id) do nothing;
insert into articles(id,slug,title,cat,date,excerpt,body,sort) values ('a1','hoc-bong-mines-paris-psl','Kinh nghiệm apply học bổng Mines Paris–PSL','Học tập','5 Sep 2026','Bản nháp: chuẩn bị hồ sơ, thư động lực và lộ trình thời gian.','[["p","Đây là bài nháp mẫu — bạn sẽ viết lại bằng trải nghiệm thật của mình trong Dashboard."],["h","Chuẩn bị hồ sơ"],["ul",["Bảng điểm và GPA","Chứng chỉ ngoại ngữ","Thư động lực và CV"]],["h","Lộ trình thời gian"],["p","Liệt kê các mốc quan trọng: tìm hiểu chương trình, hoàn thiện hồ sơ, nộp và phỏng vấn."],["h","Bài học rút ra"],["p","Chia sẻ những điều bạn ước mình biết sớm hơn."]]'::jsonb,2) on conflict (id) do nothing;
insert into articles(id,slug,title,cat,date,excerpt,body,sort) values ('a2','ielts-7-trong-1-nam','Tổng hợp lộ trình học IELTS 7.0 trong 1 năm','Học tập','26 Aug 2026','Bản nháp: kế hoạch học từng kỹ năng và nguồn tài liệu.','[["p","Đây là bài nháp mẫu — bạn sẽ viết lại bằng kinh nghiệm thật của mình."],["h","Kế hoạch theo kỹ năng"],["ul",["Listening","Reading","Writing","Speaking"]],["h","Tài liệu sử dụng"],["p","Liệt kê sách, kênh học và công cụ bạn đã dùng."],["h","Lời khuyên"],["p","Những điều giúp bạn duy trì động lực suốt một năm."]]'::jsonb,1) on conflict (id) do nothing;

-- ---- Phase 7: form liên hệ (khách chỉ GỬI được, admin mới ĐỌC/XÓA) ----
create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  name text check (char_length(name) <= 100),
  email text check (char_length(email) <= 200),
  message text not null check (char_length(message) between 1 and 2000),
  created_at timestamptz default now());
alter table messages enable row level security;
create policy "anyone can send" on messages for insert to anon, authenticated with check (true);
create policy "admin read messages" on messages for select using (is_admin());
create policy "admin delete messages" on messages for delete using (is_admin());

-- ---- Sau khi tạo user ở Authentication → Users, chạy dòng này (thay email của bạn) ----
-- insert into admins (user_id) select id from auth.users where email = 'khantly120106@gmail.com';

-- ---- Phase 9+: Lab / Experiments (mỗi thí nghiệm có trang riêng) ----
create table if not exists experiments (
  id text primary key, slug text unique not null, title text not null,
  cat text default 'Thí nghiệm', date text, tags text[] default '{}', summary text,
  sim text, body jsonb default '[]', media jsonb default '[]', links jsonb default '{}',
  sort int default 0, published boolean default true, created_at timestamptz default now());
alter table experiments enable row level security;
create policy "public read experiments" on experiments for select using (published or is_admin());
create policy "admin write experiments" on experiments for all using (is_admin()) with check (is_admin());
