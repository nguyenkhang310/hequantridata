import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Plus, Minus, Search } from "lucide-react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { toast } from "sonner";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/student/register")({ component: RegisterPage });

function RegisterPage() {
  const { user } = useAuth();
  const [code, setCode] = useState("");
  const [availableCourses, setAvailableCourses] = useState<any[]>([]);
  const [registered, setRegistered] = useState<Set<string>>(new Set());

  const fetchCourses = () => {
    fetch("http://localhost:5000/api/student/courses")
      .then(res => res.json())
      .then(data => setAvailableCourses(data))
      .catch(console.error);
  };

  useEffect(() => {
    fetchCourses();
  }, []);

  const handleRegister = async () => {
    const c = code.trim().toUpperCase();
    if (!c) return toast.error("Vui lòng nhập mã học phần");
    const course = availableCourses.find((x) => x.code === c);
    if (!course) return toast.error("Không tìm thấy học phần");
    if (course.status === "full") return toast.error("Lớp đã đầy");
    
    try {
      const res = await fetch("http://localhost:5000/api/student/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ studentId: user?.id, courseId: c })
      });
      const data = await res.json();
      if (data.success) {
        setRegistered(new Set([...registered, c]));
        toast.success(data.message || `Đăng ký thành công ${course.name}`);
        setCode("");
        fetchCourses(); // refresh capacities
      } else {
        toast.error(data.message || "Đăng ký thất bại");
      }
    } catch(e) {
      toast.error("Lỗi kết nối");
    }
  };

  const handleUnregister = () => {
    const c = code.trim().toUpperCase();
    if (!c) return toast.error("Vui lòng nhập mã học phần");
    // We don't have unregister endpoint in this simple API, so we just local UI remove
    if (!registered.has(c)) return toast.error("Bạn chưa đăng ký học phần này");
    const next = new Set(registered);
    next.delete(c);
    setRegistered(next);
    toast.success(`Đã hủy đăng ký ${c} (UI only)`);
    setCode("");
  };

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-3xl font-extrabold">Đăng ký học phần</h1>
        <p className="text-muted-foreground mt-1">Học kỳ 2 - Năm học 2024-2025</p>
      </div>

      <Card className="rounded-2xl shadow-soft border-0">
        <CardHeader>
          <CardTitle>Đăng ký nhanh theo mã học phần</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col md:flex-row gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Nhập mã học phần (VD: CT305)"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                className="h-12 pl-10 text-base"
              />
            </div>
            <Button onClick={handleRegister} className="h-12 px-6 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold gap-2">
              <Plus className="h-5 w-5" /> Đăng Ký
            </Button>
            <Button onClick={handleUnregister} variant="destructive" className="h-12 px-6 font-semibold gap-2">
              <Minus className="h-5 w-5" /> Hủy Đăng Ký
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card className="rounded-2xl shadow-soft border-0">
        <CardHeader>
          <CardTitle>Danh sách học phần khả dụng</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-muted/40">
                  <TableHead>Mã HP</TableHead>
                  <TableHead>Tên môn học</TableHead>
                  <TableHead className="text-center">Tín chỉ</TableHead>
                  <TableHead>Giảng viên</TableHead>
                  <TableHead className="text-center">Sĩ số</TableHead>
                  <TableHead>Lịch học</TableHead>
                  <TableHead className="text-center">Trạng thái</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {availableCourses.map((c) => {
                  const isReg = registered.has(c.code);
                  return (
                    <TableRow key={c.code} className="hover:bg-accent/30">
                      <TableCell className="font-mono font-semibold text-primary">{c.code}</TableCell>
                      <TableCell className="font-medium">{c.name}</TableCell>
                      <TableCell className="text-center">{c.credits}</TableCell>
                      <TableCell className="text-muted-foreground">{c.teacher}</TableCell>
                      <TableCell className="text-center font-medium">
                        {c.enrolled}/{c.capacity}
                      </TableCell>
                      <TableCell className="text-sm">{c.schedule}</TableCell>
                      <TableCell className="text-center">
                        {isReg ? (
                          <Badge className="bg-primary text-primary-foreground">Đã đăng ký</Badge>
                        ) : c.status === "open" ? (
                          <Badge className="bg-emerald-500 hover:bg-emerald-600 text-white">Mở đăng ký</Badge>
                        ) : (
                          <Badge variant="destructive">Đã đầy</Badge>
                        )}
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
