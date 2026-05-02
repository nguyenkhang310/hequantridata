import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Clock, MapPin, User } from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/student/schedule")({ component: SchedulePage });

const days = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7"];

const periods = [
  { label: "Sáng", range: "Tiết 1-3", time: "07:00 - 09:30" },
  { label: "Sáng", range: "Tiết 4-6", time: "09:45 - 12:15" },
  { label: "Chiều", range: "Tiết 7-9", time: "13:00 - 15:30" },
  { label: "Chiều", range: "Tiết 10-12", time: "15:45 - 18:15" },
];

const dayAccent: Record<string, string> = {
  "Thứ 2": "from-blue-500 to-blue-700",
  "Thứ 3": "from-emerald-500 to-emerald-700",
  "Thứ 4": "from-orange-500 to-orange-700",
  "Thứ 5": "from-purple-500 to-purple-700",
  "Thứ 6": "from-pink-500 to-pink-700",
  "Thứ 7": "from-cyan-500 to-cyan-700",
};

function SchedulePage() {
  const { user } = useAuth();
  const [studentSchedule, setStudentSchedule] = useState<any[]>([]);

  useEffect(() => {
    if (user?.id) {
      fetch(`http://localhost:5000/api/student/schedule/${user.id}`)
        .then(res => res.json())
        .then(data => setStudentSchedule(data))
        .catch(console.error);
    }
  }, [user]);

  function findClass(day: string, periodRange: string) {
    return studentSchedule.find((s) => s.day === day && s.period.startsWith(periodRange));
  }

  return (
    <div className="space-y-6 max-w-[1400px] mx-auto">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-3">
        <div>
          <h1 className="text-3xl font-extrabold">Thời khóa biểu</h1>
          <p className="text-muted-foreground mt-1">Học kỳ 1 - Năm học 2024-2025</p>
        </div>
        <div className="flex flex-wrap items-center gap-4 text-xs text-muted-foreground">
          <div className="flex items-center gap-1.5">
            <span className="w-3 h-3 rounded bg-gradient-to-br from-blue-500 to-blue-700" /> Có tiết học
          </div>
          <div className="flex items-center gap-1.5">
            <span className="w-3 h-3 rounded border border-dashed border-muted-foreground/40" /> Trống
          </div>
        </div>
      </div>

      <Card className="rounded-3xl shadow-elegant border-0 overflow-hidden">
        <CardHeader className="bg-gradient-hero text-white">
          <CardTitle className="text-white flex items-center gap-2">
            <Clock className="h-5 w-5" /> Lịch học theo tuần
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full border-collapse min-w-[1000px]">
              <thead>
                <tr className="bg-muted/50">
                  <th className="sticky left-0 z-10 bg-muted/80 backdrop-blur p-3 text-left text-xs font-bold uppercase tracking-wider text-muted-foreground border-b border-r w-44">
                    Tiết / Thời gian
                  </th>
                  {days.map((d) => (
                    <th key={d} className="p-3 text-center border-b border-r last:border-r-0">
                      <div className={cn("inline-flex flex-col items-center justify-center px-4 py-2 rounded-xl bg-gradient-to-br text-white shadow-soft", dayAccent[d])}>
                        <span className="text-sm font-bold">{d}</span>
                      </div>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {periods.map((p) => (
                  <tr key={p.range} className="hover:bg-accent/10 transition">
                    <td className="sticky left-0 z-10 bg-card p-3 border-b border-r align-top">
                      <div className="flex flex-col gap-0.5">
                        <span className="text-xs uppercase font-semibold text-primary tracking-wide">{p.label}</span>
                        <span className="font-bold text-sm text-foreground">{p.range}</span>
                        <span className="text-xs text-muted-foreground">{p.time}</span>
                      </div>
                    </td>
                    {days.map((d) => {
                      const cls = findClass(d, p.range);
                      return (
                        <td key={d + p.range} className="p-2 border-b border-r last:border-r-0 align-top h-28">
                          {cls ? (
                            <div className={cn(
                              "h-full rounded-xl p-3 text-white shadow-soft hover:shadow-elegant hover:-translate-y-0.5 transition-all bg-gradient-to-br cursor-pointer",
                              dayAccent[d]
                            )}>
                              <p className="font-bold text-sm leading-tight line-clamp-2">{cls.course}</p>
                              <div className="mt-2 space-y-1 text-[11px] text-white/90">
                                <div className="flex items-center gap-1">
                                  <MapPin className="h-3 w-3" /> P. {cls.room}
                                </div>
                                <div className="flex items-center gap-1 line-clamp-1">
                                  <User className="h-3 w-3 shrink-0" /> {cls.teacher}
                                </div>
                              </div>
                            </div>
                          ) : (
                            <div className="h-full rounded-xl border border-dashed border-border/60 flex items-center justify-center text-xs text-muted-foreground/50">
                              —
                            </div>
                          )}
                        </td>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      {/* Summary stats */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card className="rounded-2xl border-0 shadow-soft">
          <CardContent className="p-5 flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">Tổng số môn / tuần</p>
              <p className="text-2xl font-extrabold mt-1">{studentSchedule.length}</p>
            </div>
            <div className="p-3 rounded-xl bg-gradient-brand text-white">
              <Clock className="h-5 w-5" />
            </div>
          </CardContent>
        </Card>
        <Card className="rounded-2xl border-0 shadow-soft">
          <CardContent className="p-5 flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">Số ngày có tiết</p>
              <p className="text-2xl font-extrabold mt-1">{new Set(studentSchedule.map((s) => s.day)).size}</p>
            </div>
            <div className="p-3 rounded-xl bg-gradient-to-br from-emerald-500 to-emerald-700 text-white">
              <MapPin className="h-5 w-5" />
            </div>
          </CardContent>
        </Card>
        <Card className="rounded-2xl border-0 shadow-soft">
          <CardContent className="p-5 flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">Tổng số tiết / tuần</p>
              <p className="text-2xl font-extrabold mt-1">{studentSchedule.length * 3}</p>
            </div>
            <div className="p-3 rounded-xl bg-gradient-to-br from-orange-500 to-red-600 text-white">
              <User className="h-5 w-5" />
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
