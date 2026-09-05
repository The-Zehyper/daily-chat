# DEPLOYMENT — next-chat-demo

## 1. Supabase
Create a Supabase project.

Open SQL Editor, create a new query, paste ALL of `supabase.sql`, then Run.

Then open Project Settings / API and copy:
- Project URL
- Publishable key (or the project's anon key if that is what your dashboard shows)

## 2. GitHub OAuth
This project logs in with GitHub.

In Supabase:
Authentication -> Providers -> GitHub -> enable it.

Create a GitHub OAuth App and use this Supabase callback URL:
https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback

Put the GitHub Client ID and Client Secret into the Supabase GitHub provider settings.

## 3. Deploy to Vercel
Import this GitHub repository into Vercel.

Add these environment variables:

NEXT_PUBLIC_SUPABASE_URL = your Supabase Project URL
NEXT_PUBLIC_SUPABASE_ANON_KEY = your Supabase Publishable/anon key

Deploy.

## 4. Supabase URL Configuration
After Vercel gives you the production URL:

Authentication -> URL Configuration

Site URL:
https://YOUR-VERCEL-DOMAIN.vercel.app

Redirect URLs:
https://YOUR-VERCEL-DOMAIN.vercel.app/auth/callback

Save.

## 5. Test
1. Open the Vercel site.
2. Click GitHub login.
3. After login, check Supabase -> Table Editor -> users.
4. Send a chat message.
5. Check Supabase -> messages.
6. Open the site in a second browser/device and test realtime chat.

IMPORTANT:
Do not put the Supabase service_role/secret key into NEXT_PUBLIC_* variables.
The app only needs the public client key in the browser.
