import { createClient } from '@supabase/supabase-js';
export const supabase = createClient('https://pentvxbgrqithicezozf.supabase.co', 'sb_publishable_W5frvlQ0xdTRleKlX5iujw_n4Iwbos3', {auth:{persistSession:false,autoRefreshToken:false,detectSessionInUrl:false}});
