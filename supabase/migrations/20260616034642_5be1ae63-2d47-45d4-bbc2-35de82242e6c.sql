
-- Restrict SELECT policies to authenticated users
DROP POLICY IF EXISTS "posts readable to all" ON public.posts;
CREATE POLICY "posts readable to authenticated" ON public.posts FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "comments readable" ON public.post_comments;
CREATE POLICY "comments readable" ON public.post_comments FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "votes readable" ON public.post_votes;
CREATE POLICY "votes readable" ON public.post_votes FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "resources readable" ON public.resources;
CREATE POLICY "resources readable" ON public.resources FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "hof readable" ON public.hall_of_fame;
CREATE POLICY "hof readable" ON public.hall_of_fame FOR SELECT TO authenticated USING (true);

-- Admin-only delete for hall-of-fame bucket; exclude that bucket from generic owner-delete policy
DROP POLICY IF EXISTS "panel buckets delete own" ON storage.objects;
CREATE POLICY "panel buckets delete own" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id IN ('avatars','post-media','resources','chat-attachments')
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "hall-of-fame admin delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'hall-of-fame'
    AND public.has_role(auth.uid(), 'admin'::public.app_role)
  );
