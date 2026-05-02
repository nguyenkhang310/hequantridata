import { createFileRoute } from "@tanstack/react-router";
import { Card, CardContent } from "@/components/ui/card";
import { useAuth } from "@/lib/auth";
import { Users, BookOpen, GraduationCap } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { teacherClasses } from "@/lib/mock-data";

export const Route = createFileRoute("/teacher/")({ component: TeacherDashboard });

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
          <div className={`p-3 rounded-xl ${color}`}>
            <Icon className="h-6 w-6 text-white" />
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

function TeacherDashboard() {
  const { user } = useAuth();
  const totalStudents = teacherClasses.reduce((s, c) => s + c.students.length, 0);
  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div className="bg-gradient-hero rounded-3xl p-8 text-white shadow-elegant relative overflow-hidden">
        <div className="absolute -right-10 -top-10 w-64 h-64 rounded-full bg-white/10 blur-3xl" />
        <div className="relative">
          <p className="text-white/80 text-sm">Xin chào Giảng viên 👨‍🏫</p>
          <h1 className="text-3xl md:text-4xl font-extrabold mt-2">{user?.name}</h1>
          <p className="text-white/90 mt-1">Mã GV: {user?.id} · Khoa {user?.faculty}</p>
          <Badge className="mt-4 bg-white/20 text-white border-white/30 hover:bg-white/30">Học kỳ 1 - Năm học 2024-2025</Badge>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <StatCard icon={BookOpen} label="Tổng số lớp đang giảng dạy" value={teacherClasses.length} sub="Trong học kỳ hiện tại" color="bg-gradient-brand" />
        <StatCard icon={Users} label="Tổng số sinh viên" value={totalStudents} sub="Đang theo học" color="bg-gradient-to-br from-emerald-500 to-emerald-700" />
        <StatCard icon={GraduationCap} label="Số tiết giảng / tuần" value="18" sub="6 buổi học" color="bg-gradient-to-br from-orange-500 to-red-600" />
      </div>

      <Card className="rounded-2xl shadow-soft border-0">
        <CardContent className="p-6">
          <h3 className="font-bold text-lg mb-4">Lớp học đang phụ trách</h3>
          <div className="grid gap-3 md:grid-cols-2">
            {teacherClasses.map((c) => (
              <div key={c.id} className="flex items-center justify-between p-4 rounded-xl bg-accent/40 hover:bg-accent/60 transition">
                <div>
                  <p className="font-semibold">{c.name}</p>
                  <p className="text-xs text-muted-foreground mt-1">Mã lớp: {c.id}</p>
                </div>
                <Badge variant="secondary" className="font-semibold">{c.students.length} SV</Badge>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
