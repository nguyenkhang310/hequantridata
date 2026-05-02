import logo from "@/assets/uth-logo.png";

export function UthLogo({ className = "h-12" }: { className?: string }) {
  return <img src={logo} alt="UTH - University of Transport Ho Chi Minh City" className={className} />;
}
