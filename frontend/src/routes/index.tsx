import { createFileRoute, useNavigate, Navigate } from "@tanstack/react-router";
import { useState } from "react";
import { Eye, EyeOff, GraduationCap, BookUser, ShieldCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useAuth, type Role } from "@/lib/auth";
import { UthLogo } from "@/components/UthLogo";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

export const Route = createFileRoute("/")({ component: LoginPage });

function LoginPage() {
  const { user, login } = useAuth();
  const navigate = useNavigate();
  const [id, setId] = useState("");
  const [password, setPassword] = useState("");
  const [show, setShow] = useState(false);
  const [role, setRole] = useState<Role>("student");

  if (user) return <Navigate to={user.role === "student" ? "/student" : "/teacher"} />;

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!id || !password) {
      toast.error("Vui lòng nhập đầy đủ thông tin");
      return;
    }
    const success = await login(id, password, role);
    if (success) {
      toast.success(`Chào mừng ${role === "student" ? "Sinh viên" : "Giảng viên"} quay trở lại!`);
      navigate({ to: role === "student" ? "/student" : "/teacher" });
    } else {
      toast.error("Sai ID hoặc mật khẩu!");
    }
  };

  return (
    <div className="min-h-screen relative flex items-center justify-center p-4 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-hero" />
      <div className="absolute inset-0 opacity-30">
        <div className="absolute top-20 left-10 w-72 h-72 rounded-full bg-primary-glow/40 blur-3xl" />
        <div className="absolute bottom-10 right-20 w-96 h-96 rounded-full bg-accent-red/30 blur-3xl" />
        <div className="absolute top-1/2 left-1/3 w-80 h-80 rounded-full bg-primary/30 blur-3xl" />
      </div>

      <div className="relative grid md:grid-cols-2 gap-8 max-w-5xl w-full items-center">
        {/* Left brand panel */}
        <div className="hidden md:flex flex-col gap-6 text-white p-8">
          <div className="bg-white rounded-2xl p-4 w-fit shadow-elegant">
            <UthLogo className="h-16 w-auto" />
          </div>
          <h1 className="text-4xl font-extrabold leading-tight">
            UTH Portal
            <span className="block text-2xl font-semibold text-white/90 mt-2">
              Hệ Thống Quản Lý Đào Tạo Tín Chỉ
            </span>
          </h1>
          <p className="text-white/80 text-lg max-w-md">
            Cổng thông tin chính thức của Trường Đại học Giao thông Vận tải TP. Hồ Chí Minh.
            Đăng ký học phần, theo dõi kết quả và quản lý đào tạo trực tuyến.
          </p>
          <div className="flex items-center gap-2 text-white/80 text-sm">
            <ShieldCheck className="h-5 w-5" />
            Bảo mật & xác thực bởi UTH IT Center
          </div>
        </div>

        {/* Login card */}
        <div className="glass rounded-3xl shadow-elegant p-8 md:p-10">
          <div className="md:hidden flex justify-center mb-6">
            <UthLogo className="h-14 w-auto" />
          </div>
          <h2 className="text-2xl font-bold text-foreground">Đăng nhập hệ thống</h2>
          <p className="text-sm text-muted-foreground mt-1 mb-6">Sử dụng tài khoản UTH của bạn</p>

          {/* Role selector */}
          <div className="grid grid-cols-2 gap-3 mb-6">
            {([
              { value: "student", label: "Sinh Viên", icon: GraduationCap },
              { value: "teacher", label: "Giảng Viên", icon: BookUser },
            ] as const).map((r) => (
              <button
                key={r.value}
                type="button"
                onClick={() => setRole(r.value)}
                className={cn(
                  "flex flex-col items-center gap-2 rounded-xl border-2 p-4 transition-all",
                  role === r.value
                    ? "border-primary bg-primary/5 shadow-soft"
                    : "border-border hover:border-primary/40 hover:bg-accent/40"
                )}
              >
                <r.icon className={cn("h-6 w-6", role === r.value ? "text-primary" : "text-muted-foreground")} />
                <span className={cn("text-sm font-semibold", role === r.value ? "text-primary" : "text-foreground")}>
                  {r.label}
                </span>
              </button>
            ))}
          </div>

          <form onSubmit={onSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="id">Mã số (ID)</Label>
              <Input
                id="id"
                value={id}
                onChange={(e) => setId(e.target.value)}
                placeholder={role === "student" ? "VD: 20221001" : "VD: GV001"}
                className="h-11"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="pw">Mật khẩu (Password)</Label>
              <div className="relative">
                <Input
                  id="pw"
                  type={show ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="h-11 pr-10"
                />
                <button
                  type="button"
                  onClick={() => setShow(!show)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                >
                  {show ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <Button type="submit" className="w-full h-12 text-base font-semibold bg-gradient-brand hover:opacity-95 shadow-elegant">
              Đăng Nhập
            </Button>
          </form>

          <p className="text-xs text-center text-muted-foreground mt-6">
            © 2025 University of Transport Ho Chi Minh City
          </p>
        </div>
      </div>
    </div>
  );
}
