import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/student/grades")({ component: GradesPage });

function gradeBadge(g: string) {
  if (g === "A") return <Badge className="bg-emerald-500 hover:bg-emerald-600 text-white font-bold">A</Badge>;
  if (g === "B") return <Badge className="bg-emerald-500/80 hover:bg-emerald-600 text-white font-bold">B</Badge>;
  if (g === "C") return <Badge className="bg-orange-500 hover:bg-orange-600 text-white font-bold">C</Badge>;
  if (g === "D") return <Badge className="bg-orange-600 text-white font-bold">D</Badge>;
  return <Badge variant="destructive" className="font-bold">F</Badge>;
}

function GradesPage() {
  const { user } = useAuth();
  const [studentGrades, setStudentGrades] = useState<any[]>([]);

  useEffect(() => {
    if (user?.id) {
      fetch(`http://localhost:5000/api/student/grades/${user.id}`)
        .then(res => res.json())
        .then(data => setStudentGrades(data))
        .catch(console.error);
    }
  }, [user]);

  const semesters = Array.from(new Set(studentGrades.map((g) => g.semester)));
  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-3xl font-extrabold">Kết quả học tập</h1>
        <p className="text-muted-foreground mt-1">Bảng điểm chi tiết theo từng học kỳ</p>
      </div>

      {semesters.map((sem) => (
        <Card key={sem} className="rounded-2xl shadow-soft border-0">
          <CardHeader className="bg-gradient-to-r from-primary/5 to-primary-glow/5 rounded-t-2xl">
            <CardTitle className="text-primary">{sem}</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="bg-muted/40">
                    <TableHead>Mã MH</TableHead>
                    <TableHead>Tên môn học</TableHead>
                    <TableHead className="text-center">Điểm CC<br /><span className="text-xs font-normal">(10%)</span></TableHead>
                    <TableHead className="text-center">Điểm GK<br /><span className="text-xs font-normal">(30%)</span></TableHead>
                    <TableHead className="text-center">Điểm CK<br /><span className="text-xs font-normal">(60%)</span></TableHead>
                    <TableHead className="text-center">Điểm Hệ 10</TableHead>
                    <TableHead className="text-center">Xếp loại</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {studentGrades.filter((g) => g.semester === sem).map((g) => (
                    <TableRow key={g.code} className="hover:bg-accent/30">
                      <TableCell className="font-mono font-semibold text-primary">{g.code}</TableCell>
                      <TableCell className="font-medium">{g.name}</TableCell>
                      <TableCell className="text-center">{g.cc.toFixed(1)}</TableCell>
                      <TableCell className="text-center">{g.gk.toFixed(1)}</TableCell>
                      <TableCell className="text-center">{g.ck.toFixed(1)}</TableCell>
                      <TableCell className="text-center font-bold">{g.total.toFixed(2)}</TableCell>
                      <TableCell className="text-center">{gradeBadge(g.grade)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
