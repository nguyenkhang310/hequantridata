import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/lib/auth";
import { GraduationCap, BookOpenCheck, Award, TrendingUp, Calendar, Bell } from "lucide-react";
import { Badge } from "@/components/ui/badge";

export const Route = createFileRoute("/student/")({ component: StudentDashboard });

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
  const [stats, setStats] = useState({ gpa: 0, standing: "Chưa có", credits: 0 });

  useEffect(() => {
    if (user?.id) {
      fetch(`http://localhost:5000/api/student/dashboard/${user.id}`)
        .then(res => res.json())
        .then(data => setStats(data))
        .catch(console.error);
    }
  }, [user]);

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div className="bg-gradient-hero rounded-3xl p-8 text-white shadow-elegant relative overflow-hidden">
        <div className="absolute -right-10 -top-10 w-64 h-64 rounded-full bg-white/10 blur-3xl" />
        <div className="relative">
          <p className="text-white/80 text-sm">Chào mừng quay trở lại 👋</p>
          <h1 className="text-3xl md:text-4xl font-extrabold mt-2">{user?.name}</h1>
          <p className="text-white/90 mt-1">MSSV: {user?.id} · Khoa {user?.faculty}</p>
          <Badge className="mt-4 bg-white/20 text-white border-white/30 hover:bg-white/30">Học kỳ 1 - Năm học 2024-2025</Badge>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <StatCard icon={Award} label="GPA Tích lũy" value={`${stats.gpa} / 4.0`} sub="Cập nhật gần nhất" color="bg-gradient-brand" />
        <StatCard icon={BookOpenCheck} label="Số tín chỉ tích lũy" value={stats.credits} sub="Tổng TC đã tích lũy" color="bg-gradient-to-br from-emerald-500 to-emerald-700" />
        <StatCard icon={GraduationCap} label="Xếp loại học lực" value={stats.standing} sub="Theo GPA hệ 4" color="bg-gradient-to-br from-orange-500 to-red-600" />
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card className="rounded-2xl shadow-soft border-0">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Calendar className="h-5 w-5 text-primary" />
              Lịch học hôm nay
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {[
              { time: "07:00 - 09:30", course: "Lập trình hướng đối tượng", room: "A305" },
              { time: "13:00 - 15:30", course: "Mạng máy tính", room: "A201" },
            ].map((item) => (
              <div key={item.course} className="flex items-center gap-4 p-3 rounded-xl bg-accent/40 hover:bg-accent/60 transition">
                <div className="text-center min-w-[80px]">
                  <p className="text-xs text-muted-foreground">{item.time.split(" - ")[0]}</p>
                  <p className="text-xs text-muted-foreground">{item.time.split(" - ")[1]}</p>
                </div>
                <div className="flex-1">
                  <p className="font-semibold text-sm">{item.course}</p>
                  <p className="text-xs text-muted-foreground">Phòng {item.room}</p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card className="rounded-2xl shadow-soft border-0">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Bell className="h-5 w-5 text-accent-red" />
              Thông báo mới
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {[
              { title: "Mở đăng ký học phần HK2 2024-2025", time: "2 giờ trước", color: "bg-emerald-500" },
              { title: "Thông báo nộp học phí học kỳ", time: "1 ngày trước", color: "bg-orange-500" },
              { title: "Lịch thi giữa kỳ đã được cập nhật", time: "3 ngày trước", color: "bg-primary" },
            ].map((n) => (
              <div key={n.title} className="flex items-start gap-3 p-3 rounded-xl hover:bg-accent/40 transition">
                <div className={`w-2 h-2 rounded-full mt-2 ${n.color}`} />
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
