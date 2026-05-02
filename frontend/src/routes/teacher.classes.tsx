import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Pencil, Save } from "lucide-react";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/teacher/classes")({ component: ClassesPage });

type Student = { id: string; name: string; className: string; cc: number; gk: number; ck: number };
type ClassData = { id: string; name: string; students: Student[] };

function calcTotal(cc: number, gk: number, ck: number) {
  return +(cc * 0.1 + gk * 0.3 + ck * 0.6).toFixed(2);
}

function ClassesPage() {
  const { user } = useAuth();
  const [data, setData] = useState<ClassData[]>([]);
  const [selectedId, setSelectedId] = useState("");
  const [editing, setEditing] = useState<Student | null>(null);
  const [form, setForm] = useState({ cc: 0, gk: 0, ck: 0 });

  useEffect(() => {
    if (user?.id) {
      fetch(`http://localhost:5000/api/teacher/classes/${user.id}`)
        .then(res => res.json())
        .then(resData => {
          setData(resData);
          if (resData.length > 0) setSelectedId(resData[0].id);
        })
        .catch(console.error);
    }
  }, [user]);

  const cls = data.find((c) => c.id === selectedId);

  const openEdit = (s: Student) => {
    setEditing(s);
    setForm({ cc: s.cc, gk: s.gk, ck: s.ck });
  };

  const save = async () => {
    if ([form.cc, form.gk, form.ck].some((v) => v < 0 || v > 10)) {
      return toast.error("Điểm phải trong khoảng 0 - 10");
    }
    
    try {
      const res = await fetch("http://localhost:5000/api/teacher/grade", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ studentId: editing!.id, courseId: selectedId, ...form })
      });
      const resData = await res.json();
      if (resData.success) {
        setData(data.map((c) =>
          c.id !== selectedId ? c : {
            ...c,
            students: c.students.map((s) => s.id === editing!.id ? { ...s, ...form } : s),
          }
        ));
        toast.success(`Đã lưu điểm cho ${editing!.name}`);
        setEditing(null);
      } else {
        toast.error("Không thể lưu điểm");
      }
    } catch(e) {
      toast.error("Lỗi kết nối");
    }
  };

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-3xl font-extrabold">Quản lý lớp & Nhập điểm</h1>
        <p className="text-muted-foreground mt-1">Chọn lớp để xem danh sách sinh viên và nhập điểm</p>
      </div>

      <Card className="rounded-2xl shadow-soft border-0">
        <CardHeader>
          <CardTitle>Chọn lớp giảng dạy</CardTitle>
        </CardHeader>
        <CardContent>
          <Select value={selectedId} onValueChange={setSelectedId}>
            <SelectTrigger className="h-12 max-w-md text-base">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {data.map((c) => (
                <SelectItem key={c.id} value={c.id}>
                  {c.name} ({c.students.length} SV)
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      <Card className="rounded-2xl shadow-soft border-0">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>{cls?.name}</CardTitle>
          <Badge variant="secondary">{cls?.students.length || 0} sinh viên</Badge>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-muted/40">
                  <TableHead>Mã SV</TableHead>
                  <TableHead>Họ tên</TableHead>
                  <TableHead>Lớp</TableHead>
                  <TableHead className="text-center">Điểm CC (10%)</TableHead>
                  <TableHead className="text-center">Điểm GK (30%)</TableHead>
                  <TableHead className="text-center">Điểm CK (60%)</TableHead>
                  <TableHead className="text-center">Điểm Tổng</TableHead>
                  <TableHead className="text-center">Hành động</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {cls?.students.map((s) => {
                  const total = calcTotal(s.cc, s.gk, s.ck);
                  return (
                    <TableRow key={s.id} className="hover:bg-accent/30">
                      <TableCell className="font-mono font-semibold text-primary">{s.id}</TableCell>
                      <TableCell className="font-medium">{s.name}</TableCell>
                      <TableCell>{s.className}</TableCell>
                      <TableCell className="text-center">{s.cc.toFixed(1)}</TableCell>
                      <TableCell className="text-center">{s.gk.toFixed(1)}</TableCell>
                      <TableCell className="text-center">{s.ck.toFixed(1)}</TableCell>
                      <TableCell className="text-center font-bold text-primary">{total.toFixed(2)}</TableCell>
                      <TableCell className="text-center">
                        <Button size="sm" variant="outline" onClick={() => openEdit(s)} className="gap-1.5">
                          <Pencil className="h-3.5 w-3.5" /> Sửa
                        </Button>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      <Dialog open={!!editing} onOpenChange={(o) => !o && setEditing(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl">
          <DialogHeader>
            <DialogTitle>Nhập điểm sinh viên</DialogTitle>
            <DialogDescription>
              {editing?.name} · MSSV: {editing?.id} · Lớp {editing?.className}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-2">
            {[
              { key: "cc" as const, label: "Điểm Chuyên cần (10%)" },
              { key: "gk" as const, label: "Điểm Giữa kỳ (30%)" },
              { key: "ck" as const, label: "Điểm Cuối kỳ (60%)" },
            ].map((f) => (
              <div key={f.key} className="space-y-2">
                <Label>{f.label}</Label>
                <Input
                  type="number"
                  min={0}
                  max={10}
                  step={0.1}
                  value={form[f.key]}
                  onChange={(e) => setForm({ ...form, [f.key]: parseFloat(e.target.value) || 0 })}
                  className="h-11"
                />
              </div>
            ))}
            <div className="rounded-xl bg-primary/5 border border-primary/20 p-4 flex justify-between items-center">
              <span className="text-sm font-medium">Điểm Tổng kết</span>
              <span className="text-2xl font-extrabold text-primary">
                {calcTotal(form.cc, form.gk, form.ck).toFixed(2)}
              </span>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditing(null)}>Hủy</Button>
            <Button onClick={save} className="bg-gradient-brand gap-2">
              <Save className="h-4 w-4" /> Lưu Điểm
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
