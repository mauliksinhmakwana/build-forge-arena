import logo from "@/assets/logo.png.asset.json";

type Size = "sm" | "md" | "lg";

const SIZE: Record<Size, string> = {
  sm: "h-5 w-5",
  md: "h-7 w-7",
  lg: "h-9 w-9",
};

export function Logo({ size = "md" }: { size?: Size; glow?: boolean }) {
  const cls = SIZE[size];
  return (
    <span className={`inline-flex ${cls}`}>
      <img
        src={logo.url}
        alt="BuildVerse"
        className={`${cls} rounded-full object-cover`}
      />
    </span>
  );
}
