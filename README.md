# Greenwire Portal

Minimal internal portal with quick links for Greenwire Solutions.

Deployed on Cloudflare Pages as `greenwire-portal` and served at `links.greenwiresolutions.com`.

## Links Included
- Gmail
- Syncro
- ScreenConnect
- IT Glue
- 3CX
- Perimeter81
- CIPP
- Huntress
- Proofpoint
- Liongard
- ThreatLocker
- Duo
- Blackpoint Cyber
- Slide (SAT placeholder)

## Deployment
Push to `main` triggers GitHub Action `cloudflare/pages-action@v1`.

Secrets required in GitHub repo settings:
- `CF_API_TOKEN` (Pages:Edit, Pages:Read, Access:Edit, Zone:Read)
- `CF_ACCOUNT_ID`

The action creates/updates the Pages project automatically.
