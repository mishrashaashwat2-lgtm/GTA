# GTA Cheat Codes Hub

Original mobile-first neon-sunset fan-made cheat-code companion.

## Current status

- **Front-end demo features:** responsive design, dark/light/auto theme, welcome gate, guest mode, search with synonyms, platform rendering, categories, local favorites and votes, copy fallback, loadouts/share links, controller practice, daily pick, local checklist, configurable countdown, local notification signup, nickname, JSON export, SEO metadata, web app manifest and icon.
- **Cheat catalogue:** includes non-weapon entries for GTA III, Vice City, San Andreas, GTA IV, GTA V, Liberty City Stories, Vice City Stories and Chinatown Wars. The game selector lists the wider series, but titles without verified entries currently show no results. Platform variants are not complete for every entry; codes display their stated platform when controller mappings are unavailable. No GTA 6 codes or news headlines are invented. Explore map/news/vehicle panels remain placeholders.
- **Demo mode:** empty `SUPABASE_URL` and `SUPABASE_ANON_KEY` constants mean localStorage demo mode. No emails are sent and nothing syncs across devices.
- **Not production-ready:** community submissions, moderation UI, comments, leaderboard, quiz, complete translations, real map data, server-side rate limits and synced favorites/votes still need implementation and testing. `supabase/schema.sql` is a starter draft, not a verified production security audit.

## Run locally

1. Download/clone this branch.
2. Serve the folder with a static server, e.g. `python -m http.server 8000`, then open `http://localhost:8000`.
3. Leave Supabase constants empty to test demo mode.

## Supabase setup (when ready)

1. Create a Supabase project.
2. Review `supabase/schema.sql` carefully before running it in SQL Editor.
3. Set the Project URL and public anon/publishable key in the two constants at the top of `index.html`. Never use a service-role key in browser code.
4. Configure Supabase Auth URL/redirect settings for the deployed site.
5. Configure Google OAuth in Supabase and Google Cloud Console if needed.
6. Test signup, email confirmation, magic links, password reset, OAuth redirects, RLS and admin permissions with separate test accounts.

**Important:** the current browser UI does not yet connect community forms to the schema. Auth is starter wiring only; the full community experience is not implemented. Security-review RLS before production and never promote an admin from the client.

## Catalogue source references

- [GTA Wiki — Liberty City Stories cheats](https://thegta.wiki/wiki/cheats-in-gta-liberty-city-stories/)
- [GTA Wiki — Vice City Stories cheats](https://thegta.wiki/wiki/cheats-in-gta-vice-city-stories/)
- [GTA Wiki — Chinatown Wars cheats](https://thegta.wiki/wiki/cheats-in-gta-chinatown-wars/)
- [GTADEX — multi-game catalogue reference](https://gtadex.net/cheats)

Codes should still be rechecked per game edition and platform before production.

## GitHub Pages

This branch is `gta-hub-upgrade`. The existing public Pages branch remains `initial-gta-cheat-codes-hub`, so the current live site will not show these changes until Pages is pointed at this branch or the changes are reviewed and copied to the publishing branch.

## Before launch

- [ ] Expand coverage for GTA 1, GTA 2, GTA Advance and other editions; verify every code against multiple reliable sources and label platform/version clearly.
- [ ] Complete and security-test Supabase auth/RLS.
- [ ] Implement submissions, votes, comments, reports, moderation and abuse prevention server-side.
- [ ] Replace local-only notification capture with a server-side email provider/Edge Function; add consent and privacy policy.
- [ ] Implement complete English, Hindi, Spanish and Portuguese translations.
- [ ] Add real sourced news, verified secrets, map and vehicle data when available.
- [ ] Test accessibility, mobile browsers, installability, and error/loading states.
- [ ] Add privacy policy, terms and contact/report process.
