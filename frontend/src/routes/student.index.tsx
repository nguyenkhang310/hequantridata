import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/lib/auth";
import { GraduationCap, BookOpenCheck, Award, Calendar, Bell, Clock } from "lucide-react";
import { Badge } from "@/components/ui/badge";

export const Route = createFileRoute("/student/")({ component: StudentDashboard });

// Map thứ DB → tiếng Việt
const THU_MAP: Record<string, string> = {
  Thu2: "Thứ 2", Thu3: "Thứ 3", Thu4: "Thứ 4",
  Thu5: "Thứ 5", Thu6: "Thứ 6", Thu7: "Thứ 7", ChuNhat: "Chủ nhật",
};

// Map thứ → số để biết hôm nay là thứ mấy (getDay: 0=CN,1=T2,...)
const DAY_INDEX: Record<string, number> = {
  Thu2: 1, Thu3: 2, Thu4: 3, Thu5: 4, Thu6: 5, Thu7: 6, ChuNhat: 0,
};

// Chuyển tiết học sang giờ hiển thị (tiết 1 = 7:00, mỗi tiết 50 phút)
function tietToTime(tiet: number): string {
  const start = 7 * 60 + (tiet - 1) * 50;
  const h = Math.floor(start / 60).toString().padStart(2, "0");
  const m = (start % 60).toString().padStart(2, "0");
  return `${h}:${m}`;
}

function StatCard({ icon: Icon, label, value, sub, color }: any) {
  return (
    <Card className="overflow-hidden border-0 shadow-soft hover:shadow-elegant transition-all hover:-translate-y-1 rounded-2xl">
      <div className={`h-1.5 ${color}`} />
      <CardContent className="p-6">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm font-medium text-muted-foreground">{label}</p>
            <p className="text-3xl font-extrabold mt-2 text-foreground">{value}</p>
            <p className="text-xs text-muted-foreground mt-1">{sub}</p>
          </div>
          <div className={`p-3 rounded-xl ${color} bg-opacity-10`}>
            <Icon className="h-6 w-6 text-white" />
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

function StudentDashboard() {
  const { user } = useAuth();
  const [stats, setStats] = useState({ gpa: 0, standing: "Chưa có", credits: 0, registered: 0 });
  const [todaySchedule, setTodaySchedule] = useState<any[]>([]);
  const [loadingSchedule, setLoadingSchedule] = useState(true);
  const authHeaders = user?.token ? { Authorization: `Bearer ${user.token}` } : {};

  useEffect(() => {
    if (!user?.id) return;

    // Lấy stats GPA
    fetch(`http://localhost:5000/api/student/dashboard/${user.id}`, { headers: authHeaders })
      .then((res) => res.json())
      .then((data) => setStats(data))
      .catch(console.error);

    // Lấy lịch học thực tế và lọc hôm nay
    setLoadingSchedule(true);
    fetch(`http://localhost:5000/api/student/schedule/${user.id}`, { headers: authHeaders })
      .then((res) => res.json())
      .then((data: any[]) => {
        const todayDow = new Date().getDay(); // 0=CN, 1=T2,...
        // Tìm khóa DB map với hôm nay
        const todayKey = Object.keys(DAY_INDEX).find((k) => DAY_INDEX[k] === todayDow);
        if (todayKey) {
          // API trả về day đã map sang "Thứ 2" etc → so sánh luôn
          const todayLabel = THU_MAP[todayKey];
          const filtered = data.filter((s) => s.day === todayLabel);
          setTodaySchedule(filtered);
        } else {
          setTodaySchedule([]);
        }
      })
      .catch(() => setTodaySchedule([]))
      .finally(() => setLoadingSchedule(false));
  }, [user?.id, user?.token]);

  const todayName = THU_MAP[Object.keys(DAY_INDEX).find(
    (k) => DAY_INDEX[k] === new Date().getDay()
  ) ?? ""] ?? "Hôm nay";

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Banner chào mừng */}
      <div className="bg-gradient-hero rounded-3xl p-8 text-white shadow-elegant relative overflow-hidden">
        <div className="absolute -right-10 -top-10 w-64 h-64 rounded-full bg-white/10 blur-3xl" />
        <div className="relative">
          <p className="text-white/80 text-sm">Chào mừng quay trở lại 👋</p>
          <h1 className="text-3xl md:text-4xl font-extrabold mt-2">{user?.name}</h1>
          <p className="text-white/90 mt-1">
            MSSV: {user?.id} · Khoa {user?.faculty}
          </p>
          <Badge className="mt-4 bg-white/20 text-white border-white/30 hover:bg-white/30">
            Học kỳ 1 - Năm học 2025-2026
          </Badge>
        </div>
      </div>

      {/* Stat cards */}
      <div className="grid gap-4 md:grid-cols-3">
        <StatCard
          icon={Award}
          label="GPA Tích lũy"
          value={`${stats.gpa} / 4.0`}
          sub="Cập nhật gần nhất"
          color="bg-gradient-brand"
        />
        <StatCard
          icon={BookOpenCheck}
          label="Số tín chỉ tích lũy"
          value={stats.credits}
          sub="Tổng TC đã tích lũy"
          color="bg-gradient-to-br from-emerald-500 to-emerald-700"
        />
        <StatCard
          icon={GraduationCap}
          label="Xếp loại học lực"
          value={stats.standing}
          sub="Theo GPA hệ 4"
          color="bg-gradient-to-br from-orange-500 to-red-600"
        />
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Lịch học hôm nay — dữ liệu thật từ API */}
        <Card className="rounded-2xl shadow-soft border-0">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Calendar className="h-5 w-5 text-primary" />
              Lịch học {todayName}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {loadingSchedule ? (
              <p className="text-sm text-muted-foreground text-center py-4">Đang tải...</p>
            ) : todaySchedule.length === 0 ? (
              <div className="text-center py-6">
                <p className="text-muted-foreground text-sm">🎉 Hôm nay không có lịch học!</p>
              </div>
            ) : (
              todaySchedule.map((item, i) => {
                // Lấy số tiết từ chuỗi "Tiết X-Y"
                const match = item.period?.match(/Tiết (\d+)-(\d+)/);
                const startTime = match ? tietToTime(parseInt(match[1])) : "—";
                const endTime = match ? tietToTime(parseInt(match[2])) : "";
                return (
                  <div
                    key={i}
                    className="flex items-center gap-4 p-3 rounded-xl bg-accent/40 hover:bg-accent/60 transition"
                  >
                    <div className="flex items-center gap-1.5 min-w-[70px]">
                      <Clock className="h-3.5 w-3.5 text-muted-foreground" />
                      <div className="text-center">
                        <p className="text-xs font-medium">{startTime}</p>
                        <p className="text-xs text-muted-foreground">{endTime}</p>
                      </div>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-sm truncate">{item.course}</p>
                      <p className="text-xs text-muted-foreground">
                        Phòng {item.room} · {item.teacher || "Chưa phân công"}
                      </p>
                    </div>
                    <Badge variant="outline" className="text-xs shrink-0">
                      {item.period}
                    </Badge>
                  </div>
                );
              })
            )}
          </CardContent>
        </Card>

        {/* Thông báo */}
        <Card className="rounded-2xl shadow-soft border-0">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Bell className="h-5 w-5 text-orange-500" />
              Thông báo mới
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {[
              {
                title: "Mở đăng ký học phần HK1 2025-2026",
                time: "Hôm nay",
                color: "bg-emerald-500",
              },
              {
                title: "Thông báo nộp học phí học kỳ",
                time: "1 ngày trước",
                color: "bg-orange-500",
              },
              {
                title: "Lịch thi giữa kỳ đã được cập nhật",
                time: "3 ngày trước",
                color: "bg-primary",
              },
            ].map((n) => (
              <div
                key={n.title}
                className="flex items-start gap-3 p-3 rounded-xl hover:bg-accent/40 transition cursor-pointer"
              >
                <div className={`w-2 h-2 rounded-full mt-2 shrink-0 ${n.color}`} />
                <div className="flex-1">
                  <p className="font-medium text-sm">{n.title}</p>
                  <p className="text-xs text-muted-foreground mt-0.5">{n.time}</p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
