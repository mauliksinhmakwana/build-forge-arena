
-- 1. profiles: restrict SELECT to authenticated only (date_of_birth exposure)
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Profiles viewable by authenticated"
  ON public.profiles FOR SELECT TO authenticated USING (true);

-- 2. streaks: restrict SELECT to authenticated only
DROP POLICY IF EXISTS "streaks readable" ON public.streaks;
CREATE POLICY "streaks readable by authenticated"
  ON public.streaks FOR SELECT TO authenticated USING (true);

-- 3. user_roles: users may only read their own row
DROP POLICY IF EXISTS "User roles readable to authenticated" ON public.user_roles;
CREATE POLICY "Users read own role"
  ON public.user_roles FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY "Admins read all roles"
  ON public.user_roles FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role));

-- 4. challenge_enrollments: restrict SELECT to authenticated
DROP POLICY IF EXISTS "enroll read" ON public.challenge_enrollments;
CREATE POLICY "enroll read authenticated"
  ON public.challenge_enrollments FOR SELECT TO authenticated USING (true);

-- 5. hall-of-fame storage bucket: only admins may upload
DROP POLICY IF EXISTS "panel buckets write own" ON storage.objects;
CREATE POLICY "panel buckets write own"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = ANY (ARRAY['avatars','post-media','resources','chat-attachments'])
    AND (storage.foldername(name))[1] = (auth.uid())::text
  );
CREATE POLICY "hall-of-fame admin upload"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'hall-of-fame'
    AND public.has_role(auth.uid(), 'admin'::app_role)
  );

-- 6. Lock down SECURITY DEFINER functions: revoke EXECUTE from PUBLIC/anon.
-- has_role is intentionally callable by authenticated (required by RLS policies).
REVOKE EXECUTE ON FUNCTION public.has_role(uuid, app_role) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.posts_after_insert() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.comments_after_insert() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.votes_after_change() FROM PUBLIC, anon, authenticated;
