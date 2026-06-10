import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { useAuth } from "@/lib/auth-context";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Trash2, History as HistoryIcon } from "lucide-react";
import { toast } from "sonner";

export const Route = createFileRoute("/_authenticated/app/history")({
  component: HistoryPage,
});

type Post = {
  id: string; type: string; title: string | null; body: string;
  votes_count: number; comments_count: number; created_at: string;
};

function HistoryPage() {
  const { user } = useAuth();
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    if (!user) return;
    setLoading(true);
    const { data } = await supabase.from("posts")
      .select("id, type, title, body, votes_count, comments_count, created_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false });
    setPosts(((data as unknown) as Post[]) ?? []);
    setLoading(false);
  }
  useEffect(() => { load(); }, [user?.id]);

  async function del(id: string) {
    if (!confirm("Delete this post permanently? This also removes its comments and likes.")) return;
    const { error } = await supabase.from("posts").delete().eq("id", id).eq("user_id", user!.id);
    if (error) toast.error(error.message);
    else { toast.success("Deleted"); setPosts((p) => p.filter((x) => x.id !== id)); }
  }

  return (
    <div className="space-y-4 max-w-2xl mx-auto">
      <h1 className="font-display text-3xl font-bold flex items-center gap-2">
        <HistoryIcon className="h-6 w-6 text-primary" /> Your posts
      </h1>
      {loading && <p className="text-sm text-muted-foreground">Loading…</p>}
      {!loading && posts.length === 0 && (
        <p className="text-sm text-muted-foreground py-8 text-center">You haven't posted anything yet.</p>
      )}
      {posts.map((p) => (
        <article key={p.id} className="glass-strong rounded-2xl p-4 flex gap-3 items-start">
          <div className="flex-1 min-w-0">
            <span className="text-[10px] uppercase tracking-wider text-primary">{p.type}</span>
            {p.title && <h3 className="font-semibold mt-1 truncate">{p.title}</h3>}
            <p className="text-sm text-muted-foreground line-clamp-2 mt-1">{p.body}</p>
            <div className="text-xs text-muted-foreground mt-2">
              ❤ {p.votes_count} · 💬 {p.comments_count} · {new Date(p.created_at).toLocaleDateString()}
            </div>
          </div>
          <Button variant="ghost" size="sm" onClick={() => del(p.id)} aria-label="Delete">
            <Trash2 className="h-4 w-4 text-destructive" />
          </Button>
        </article>
      ))}
    </div>
  );
}
