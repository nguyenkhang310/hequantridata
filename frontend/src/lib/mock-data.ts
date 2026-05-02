export const availableCourses = [
  { code: "CT101", name: "Lập trình hướng đối tượng", credits: 3, teacher: "TS. Trần Thị Lan", enrolled: 45, capacity: 50, schedule: "Thứ 2, Tiết 1-3, P.A305", status: "open" },
  { code: "CT202", name: "Cấu trúc dữ liệu & Giải thuật", credits: 4, teacher: "PGS.TS. Lê Văn Hùng", enrolled: 50, capacity: 50, schedule: "Thứ 3, Tiết 4-6, P.B201", status: "full" },
  { code: "CT305", name: "Hệ điều hành", credits: 3, teacher: "TS. Phạm Minh Tuấn", enrolled: 32, capacity: 50, schedule: "Thứ 4, Tiết 1-3, P.C101", status: "open" },
  { code: "CT410", name: "Mạng máy tính", credits: 3, teacher: "ThS. Nguyễn Hoài An", enrolled: 28, capacity: 45, schedule: "Thứ 5, Tiết 7-9, P.A201", status: "open" },
  { code: "CT420", name: "Cơ sở dữ liệu nâng cao", credits: 4, teacher: "TS. Trần Thị Lan", enrolled: 40, capacity: 45, schedule: "Thứ 6, Tiết 4-6, P.B305", status: "open" },
  { code: "CT505", name: "Trí tuệ nhân tạo", credits: 4, teacher: "PGS.TS. Đỗ Quang Vinh", enrolled: 50, capacity: 50, schedule: "Thứ 7, Tiết 1-4, P.D101", status: "full" },
  { code: "GT201", name: "Vận tải đa phương thức", credits: 2, teacher: "TS. Hoàng Văn Bình", enrolled: 35, capacity: 60, schedule: "Thứ 2, Tiết 7-8, P.E202", status: "open" },
];

export const studentSchedule = [
  { day: "Thứ 2", period: "Tiết 1-3 (07:00-09:30)", room: "A305", course: "Lập trình hướng đối tượng", teacher: "TS. Trần Thị Lan" },
  { day: "Thứ 3", period: "Tiết 4-6 (09:45-12:15)", room: "B201", course: "Cấu trúc dữ liệu & Giải thuật", teacher: "PGS.TS. Lê Văn Hùng" },
  { day: "Thứ 4", period: "Tiết 1-3 (07:00-09:30)", room: "C101", course: "Hệ điều hành", teacher: "TS. Phạm Minh Tuấn" },
  { day: "Thứ 5", period: "Tiết 7-9 (13:00-15:30)", room: "A201", course: "Mạng máy tính", teacher: "ThS. Nguyễn Hoài An" },
  { day: "Thứ 6", period: "Tiết 4-6 (09:45-12:15)", room: "B305", course: "Cơ sở dữ liệu nâng cao", teacher: "TS. Trần Thị Lan" },
];

export const studentGrades = [
  { semester: "HK1 2023-2024", code: "CT100", name: "Nhập môn Lập trình", cc: 9.0, gk: 8.5, ck: 9.2, total: 9.0, grade: "A" },
  { semester: "HK1 2023-2024", code: "MA101", name: "Toán cao cấp A1", cc: 8.0, gk: 7.5, ck: 8.0, total: 7.9, grade: "B" },
  { semester: "HK1 2023-2024", code: "PH101", name: "Vật lý đại cương", cc: 7.5, gk: 7.0, ck: 7.5, total: 7.4, grade: "B" },
  { semester: "HK2 2023-2024", code: "CT102", name: "Kỹ thuật Lập trình", cc: 9.5, gk: 9.0, ck: 9.5, total: 9.4, grade: "A" },
  { semester: "HK2 2023-2024", code: "MA102", name: "Toán cao cấp A2", cc: 6.0, gk: 5.5, ck: 6.5, total: 6.1, grade: "C" },
  { semester: "HK2 2023-2024", code: "EN101", name: "Anh văn 1", cc: 8.5, gk: 8.0, ck: 8.5, total: 8.3, grade: "B" },
  { semester: "HK1 2024-2025", code: "CT201", name: "Lập trình Web", cc: 9.5, gk: 9.5, ck: 9.0, total: 9.3, grade: "A" },
  { semester: "HK1 2024-2025", code: "CT203", name: "Cơ sở dữ liệu", cc: 8.0, gk: 7.5, ck: 8.0, total: 7.9, grade: "B" },
  { semester: "HK1 2024-2025", code: "EN102", name: "Anh văn 2", cc: 5.0, gk: 4.0, ck: 3.5, total: 4.0, grade: "F" },
];

export const teacherClasses = [
  {
    id: "CT101-01",
    name: "Lập trình hướng đối tượng - Nhóm 01",
    students: [
      { id: "20221001", name: "Nguyễn Văn Minh", className: "CNTT22A", cc: 9.0, gk: 8.5, ck: 9.0 },
      { id: "20221002", name: "Trần Thị Hương", className: "CNTT22A", cc: 8.5, gk: 9.0, ck: 8.5 },
      { id: "20221003", name: "Lê Hoàng Phúc", className: "CNTT22A", cc: 7.5, gk: 7.0, ck: 8.0 },
      { id: "20221004", name: "Phạm Quỳnh Anh", className: "CNTT22B", cc: 9.5, gk: 9.5, ck: 9.5 },
      { id: "20221005", name: "Võ Thành Đạt", className: "CNTT22B", cc: 6.0, gk: 5.5, ck: 6.0 },
    ],
  },
  {
    id: "CT420-02",
    name: "Cơ sở dữ liệu nâng cao - Nhóm 02",
    students: [
      { id: "20211010", name: "Đặng Thị Mai", className: "CNTT21A", cc: 8.0, gk: 8.5, ck: 8.0 },
      { id: "20211011", name: "Bùi Văn Tùng", className: "CNTT21A", cc: 9.0, gk: 9.0, ck: 9.5 },
      { id: "20211012", name: "Hoàng Thị Lan", className: "CNTT21B", cc: 7.0, gk: 6.5, ck: 7.5 },
      { id: "20211013", name: "Ngô Minh Khôi", className: "CNTT21B", cc: 8.5, gk: 8.0, ck: 8.5 },
    ],
  },
];
