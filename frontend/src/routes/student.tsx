import { createFileRoute, Outlet, Navigate } from "@tanstack/react-router";
import { PortalLayout } from "@/components/PortalLayout";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/student")({ component: StudentLayout });

function StudentLayout() {
  const { user } = useAuth();
  if (!user) return <Navigate to="/" />;
  if (user.role !== "student") return <Navigate to="/teacher" />;
  return (
    <PortalLayout role="student">
      <Outlet />
    </PortalLayout>
  );
}
