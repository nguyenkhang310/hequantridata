import { Link, useRouterState, useNavigate, Outlet } from "@tanstack/react-router";
import { ReactNode } from "react";
import {
  SidebarProvider, Sidebar, SidebarContent, SidebarGroup, SidebarGroupContent,
  SidebarGroupLabel, SidebarMenu, SidebarMenuButton, SidebarMenuItem,
  SidebarTrigger, SidebarHeader, SidebarFooter,
} from "@/components/ui/sidebar";
import { LayoutDashboard, BookOpenCheck, CalendarDays, GraduationCap, Users, LogOut, ChevronDown } from "lucide-react";
import { useAuth } from "@/lib/auth";
import { UthLogo } from "./UthLogo";
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem,
  DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";

const studentNav = [
  { title: "Tổng quan", url: "/student", icon: LayoutDashboard },
  { title: "Đăng ký học phần", url: "/student/register", icon: BookOpenCheck },
  { title: "Thời khóa biểu", url: "/student/schedule", icon: CalendarDays },
  { title: "Kết quả học tập", url: "/student/grades", icon: GraduationCap },
];

const teacherNav = [
  { title: "Tổng quan", url: "/teacher", icon: LayoutDashboard },
  { title: "Quản lý lớp & Nhập điểm", url: "/teacher/classes", icon: Users },
];

function AppSidebar({ role }: { role: "student" | "teacher" }) {
  const items = role === "student" ? studentNav : teacherNav;
  const path = useRouterState({ select: (s) => s.location.pathname });
  const isActive = (url: string) => url === path || (url !== `/${role}` && path.startsWith(url));

  return (
    <Sidebar collapsible="icon">
      <SidebarHeader className="border-b border-sidebar-border p-4">
        <div className="flex items-center gap-2">
          <UthLogo className="h-9 w-auto" />
        </div>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>{role === "student" ? "Sinh viên" : "Giảng viên"}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {items.map((item) => (
                <SidebarMenuItem key={item.url}>
                  <SidebarMenuButton asChild isActive={isActive(item.url)} tooltip={item.title}>
                    <Link to={item.url} className="flex items-center gap-3">
                      <item.icon className="h-4 w-4" />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter className="border-t border-sidebar-border p-3 text-xs text-muted-foreground">
        © 2025 UTH Portal
      </SidebarFooter>
    </Sidebar>
  );
}

export function PortalLayout({ role, children }: { role: "student" | "teacher"; children?: ReactNode }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate({ to: "/" });
  };

  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full bg-gradient-to-br from-background via-secondary/40 to-accent/30">
        <AppSidebar role={role} />
        <div className="flex-1 flex flex-col min-w-0">
          <header className="h-16 sticky top-0 z-30 flex items-center justify-between border-b bg-background/80 backdrop-blur-xl px-4 md:px-6">
            <div className="flex items-center gap-3">
              <SidebarTrigger />
              <div className="hidden md:block">
                <h2 className="text-sm font-semibold text-foreground">UTH Portal</h2>
                <p className="text-xs text-muted-foreground">Hệ thống Quản lý Đào tạo Tín chỉ</p>
              </div>
            </div>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="gap-2 h-12 px-2 md:px-3">
                  <Avatar className="h-9 w-9 ring-2 ring-primary/20">
                    <AvatarFallback className="bg-gradient-brand text-primary-foreground font-semibold">
                      {user?.name.split(" ").pop()?.[0] ?? "U"}
                    </AvatarFallback>
                  </Avatar>
                  <div className="hidden md:flex flex-col items-start">
                    <span className="text-sm font-semibold leading-tight">{user?.name}</span>
                    <span className="text-xs text-muted-foreground leading-tight">{user?.id}</span>
                  </div>
                  <ChevronDown className="h-4 w-4 text-muted-foreground" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <DropdownMenuLabel>
                  <div className="font-semibold">{user?.name}</div>
                  <div className="text-xs text-muted-foreground font-normal">{user?.email}</div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleLogout} className="text-destructive focus:text-destructive">
                  <LogOut className="h-4 w-4 mr-2" />
                  Đăng xuất
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </header>
          <main className="flex-1 p-4 md:p-8 overflow-auto">{children ?? <Outlet />}</main>
        </div>
      </div>
    </SidebarProvider>
  );
}
