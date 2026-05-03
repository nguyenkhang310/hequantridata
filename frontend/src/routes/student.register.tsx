import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect, useCallback, useRef } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Plus, Minus, Search, RefreshCw } from "lucide-react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { toast } from "sonner";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/student/register")({ component: RegisterPage });

const API = "http://localhost:5000";

function RegisterPage() {
  const { user } = useAuth();
  const [code, setCode] = useState("");
  const [availableCourses, setAvailableCourses] = useState<any[]>([]);
  const [registered, setRegistered] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(false);
  const toastShownRef = useRef(false); // chặn toast trùng do React StrictMode
  const authHeaders = user?.token ? { Authorization: `Bearer ${user.token}` } : {};

  // Load danh sách học phần và danh sách đã đăng ký từ DB
  const fetchAll = useCallback(async (showErrorToast = true) => {
    setLoading(true);
    toastShownRef.current = false;
    try {
      const [coursesRes, myRes] = await Promise.all([
        fetch(`${API}/api/student/courses`, { headers: authHeaders }),
        user?.id ? fetch(`${API}/api/student/my-courses/${user.id}`, { headers: authHeaders }) : Promise.resolve(null),
      ]);
      const courses = await coursesRes.json();
      setAvailableCourses(Array.isArray(courses) ? courses : []);

      if (myRes) {
        const myCourses: string[] = await myRes.json();
        setRegistered(new Set(Array.isArray(myCourses) ? myCourses : []));
      }
    } catch (e) {
      if (showErrorToast && !toastShownRef.current) {
        toastShownRef.current = true;
        toast.error("Không thể tải dữ liệu học phần. Kiểm tra backend đang chạy chưa.");
      }
    } finally {
      setLoading(false);
    }
  }, [user?.id, user?.token]);

  useEffect(() => {
    fetchAll();
  }, [fetchAll]);


  const handleRegister = async () => {
    const c = code.trim().toUpperCase();
    if (!c) return toast.error("Vui lòng nhập mã học phần");
    if (registered.has(c)) return toast.error("Bạn đã đăng ký học phần này rồi!");
    const course = availableCourses.find((x) => x.code === c);
    if (!course) return toast.error("Không tìm thấy học phần trong danh sách");
    if (course.status !== "open") return toast.error("Học phần đã đầy hoặc đóng đăng ký");

    try {
      const res = await fetch(`${API}/api/student/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json", ...authHeaders },
        body: JSON.stringify({ courseId: c }),
      });
      const data = await res.json();
      if (data.success) {
        toast.success(data.message || `Đăng ký thành công ${course.name}`);
        setCode("");
        await fetchAll();
      } else {
        toast.error(data.message || "Đăng ký thất bại");
      }
    } catch {
      toast.error("Lỗi kết nối tới server");
    }
  };

  const handleUnregister = async () => {
    const c = code.trim().toUpperCase();
    if (!c) return toast.error("Vui lòng nhập mã học phần");
    if (!registered.has(c)) return toast.error("Bạn chưa đăng ký học phần này");

    try {
      const res = await fetch(`${API}/api/student/unregister`, {
        method: "POST",
        headers: { "Content-Type": "application/json", ...authHeaders },
        body: JSON.stringify({ courseId: c }),
      });
      const data = await res.json();
      if (data.success) {
        toast.success(data.message || `Hủy đăng ký ${c} thành công`);
        setCode("");
        await fetchAll();
      } else {
        toast.error(data.message || "Hủy đăng ký thất bại");
      }
    } catch {
      toast.error("Lỗi kết nối tới server");
    }
  };

  // Click vào row → điền mã vào ô tìm kiếm (như desktop app)
  const handleRowClick = (courseCode: string) => {
    setCode(courseCode);
  };

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-3xl font-extrabold">Đăng ký học phần</h1>
          <p className="text-muted-foreground mt-1">Các học phần đang trong thời gian mở đăng ký</p>
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={() => fetchAll()}
          disabled={loading}
          className="gap-2"
          id="btn-refresh-courses"
        >
          <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          Làm mới
        </Button>
      </div>

      <Card className="rounded-2xl shadow-soft border-0">
        <CardHeader>
          <CardTitle>Đăng ký / Hủy theo mã học phần</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground mb-3">
            💡 Click vào dòng học phần bên dưới để điền mã tự động
          </p>
          <div className="flex flex-col md:flex-row gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                id="input-course-code"
                placeholder="Nhập mã học phần (VD: HP001)"
                value={code}
                onChange={(e) => setCode(e.target.value.toUpperCase())}
                onKeyDown={(e) => e.key === "Enter" && handleRegister()}
                className="h-12 pl-10 text-base font-mono"
              />
            </div>
            <Button
              id="btn-register-course"
              onClick={handleRegister}
              className="h-12 px-6 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold gap-2"
            >
              <Plus className="h-5 w-5" /> Đăng Ký
            </Button>
            <Button
              id="btn-unregister-course"
              onClick={handleUnregister}
              variant="destructive"
              className="h-12 px-6 font-semibold gap-2"
            >
              <Minus className="h-5 w-5" /> Hủy Đăng Ký
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card className="rounded-2xl shadow-soft border-0">
        <CardHeader>
          <CardTitle>
            Danh sách học phần khả dụng
            <span className="ml-2 text-sm font-normal text-muted-foreground">
              ({availableCourses.length} học phần — {registered.size} đã đăng ký)
            </span>
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          {loading ? (
            <div className="flex items-center justify-center py-16 text-muted-foreground">
              <RefreshCw className="h-5 w-5 animate-spin mr-2" /> Đang tải...
            </div>
          ) : availableCourses.length === 0 ? (
            <div className="text-center py-16 text-muted-foreground">
              Không có học phần nào đang mở đăng ký.
            </div>
          ) : (
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
                    const isFull = c.status !== "open";
                    return (
                      <TableRow
                        key={c.code}
                        onClick={() => handleRowClick(c.code)}
                        className={`cursor-pointer transition-colors ${
                          code === c.code
                            ? "bg-primary/10 hover:bg-primary/15"
                            : "hover:bg-accent/40"
                        }`}
                      >
                        <TableCell className="font-mono font-semibold text-primary">
                          {c.code}
                        </TableCell>
                        <TableCell className="font-medium">{c.name}</TableCell>
                        <TableCell className="text-center">{c.credits}</TableCell>
                        <TableCell className="text-muted-foreground">{c.teacher}</TableCell>
                        <TableCell
                          className={`text-center font-medium ${
                            c.enrolled >= c.capacity ? "text-destructive" : ""
                          }`}
                        >
                          {c.enrolled}/{c.capacity}
                        </TableCell>
                        <TableCell className="text-sm">{c.schedule || "—"}</TableCell>
                        <TableCell className="text-center">
                          {isReg ? (
                            <Badge className="bg-primary text-primary-foreground">Đã đăng ký</Badge>
                          ) : isFull ? (
                            <Badge variant="destructive">Đã đầy</Badge>
                          ) : (
                            <Badge className="bg-emerald-500 hover:bg-emerald-600 text-white">
                              Mở đăng ký
                            </Badge>
                          )}
                        </TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
