import { createFileRoute, Outlet, Navigate } from "@tanstack/react-router";
import { PortalLayout } from "@/components/PortalLayout";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/teacher")({ component: TeacherLayout });

function TeacherLayout() {
  const { user } = useAuth();
  if (!user) return <Navigate to="/" />;
  if (user.role !== "teacher") return <Navigate to="/student" />;
  return (
    <PortalLayout role="teacher">
      <Outlet />
    </PortalLayout>
  );
}
