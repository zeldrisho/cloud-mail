## GitHub Action Deployment

**Configure your GitHub repository**

1. Fork or clone the repository: [https://github.com/eoao/cloud-mail](https://github.com/eoao/cloud-mail)
2. Open your GitHub repository settings.
3. Go to `Settings -> Secrets and variables -> Actions -> New repository secret`.
4. Add the following secrets:

| Secret name             | Required | Purpose |
| ----------------------- | :------: | ------- |
| `CLOUDFLARE_API_TOKEN`  |    ✅    | Cloudflare API token (requires Workers and related resource permissions) |
| `CLOUDFLARE_ACCOUNT_ID` |    ✅    | Cloudflare account ID |
| `D1_DATABASE_ID`        |    ✅    | Your D1 database ID |
| `KV_NAMESPACE_ID`       |    ✅    | Your KV namespace ID |
| `R2_BUCKET_NAME`        |    ✅    | Your R2 bucket name |
| `DOMAIN`                |    ✅    | Domain(s) used for mail service, for example `["example.com"]` |
| `ADMIN`                 |    ✅    | Admin email, for example `admin@example.com` |
| `JWT_SECRET`            |    ✅    | Random long string used to sign and verify JWT |
| `INIT_URL`              |    ❌    | Optional Worker URL used to initialize DB after deployment |

---

**Get Cloudflare API token**

1. Visit [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens).
2. Create a new API token.
3. Choose the "Edit Cloudflare Workers" template and add permissions as needed.
   ![dc2e1dc8dcd217644759c46c6c705de1](https://i.miji.bid/2025/07/07/dc2e1dc8dcd217644759c46c6c705de1.png)
4. Save the token and copy it to GitHub secret `CLOUDFLARE_API_TOKEN`.

**Get Cloudflare account ID**

1. Find the account ID in Cloudflare account settings.
2. Copy it to GitHub secret `CLOUDFLARE_ACCOUNT_ID`.

**Run workflow**

1. Manually run the workflow from the Actions page. After upstream sync, it will auto-deploy to Cloudflare Workers.
2. If `INIT_URL` is not configured, manually initialize the database by visiting:
   `https://<your-domain>/api/init/<your-jwt-secret>`.
3. You can sync upstream automatically with a bot or manually by clicking `Sync Upstream`.
