import { createContext, useContext, useState, useEffect, ReactNode } from "react";

export type Role = "student" | "teacher";
export interface User {
  id: string;
  name: string;
  role: Role;
  email: string;
  token: string;
  faculty?: string;
}

interface AuthCtx {
  user: User | null;
  login: (id: string, password: string, role: Role) => Promise<boolean>;
  logout: () => void;
}

const AuthContext = createContext<AuthCtx | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const raw = typeof window !== "undefined" ? localStorage.getItem("uth_user") : null;
    if (raw) setUser(JSON.parse(raw));
  }, []);

  const login = async (id: string, password: string, role: Role) => {
    try {
      const res = await fetch("http://localhost:5000/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, password, role })
      });
      const data = await res.json();
      if (data.success) {
        const u: User = { ...data.user, email: `${id}@${role === 'student' ? 'st.uth.edu.vn' : 'uth.edu.vn'}` };
        setUser(u);
        localStorage.setItem("uth_user", JSON.stringify(u));
        return true;
      }
      return false;
    } catch (e) {
      console.error(e);
      return false;
    }
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem("uth_user");
  };

  return <AuthContext.Provider value={{ user, login, logout }}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be inside AuthProvider");
  return ctx;
}
