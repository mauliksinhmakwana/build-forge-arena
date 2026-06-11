import { Logo } from "@/components/Logo";

export function Footer() {
  return (
    <footer className="relative border-t border-border py-12 px-4 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-7xl flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-2">
          <Logo size="sm" glow={false} />
          <span className="font-display font-bold tracking-tight">
            <span>Build<span className="text-primary">Verse</span></span>
          </span>
        </div>
        <p className="text-xs text-muted-foreground">
          © {new Date().getFullYear()} BuildVerse. Build · Ship · Connect.
        </p>
      </div>
    </footer>
  );
}
