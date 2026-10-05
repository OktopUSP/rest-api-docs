# Oktopus Controller REST API

REST API documentation of the Oktopus USP Controller and CWMP-compatible multi-vendor device management platform.

The published documentation is available at **https://api.oktopus.app.br**.

## Open Source vs. Enterprise

This collection documents both editions of Oktopus:

| Folder | Use it if you are running |
| --- | --- |
| `Auth/`, `Dashboard/`, `Device/` (repository root) | Oktopus **Open Source** |
| `Enterprise Version/` | Oktopus **commercial (Enterprise)** version |

If you are using the commercial version of Oktopus, refer to the requests inside the `Enterprise Version/` folder. It contains the endpoints available only in the commercial edition (AI Assistant, Audit Trail, Billing, Mass Actions, Organizations, Roles, Time Series, and more), as well as the commercial variants of the endpoints shared with the open source edition.

## How It Works

The documentation is maintained as a [Bruno](https://www.usebruno.com/) collection stored in plain YAML files ([OpenCollection](https://www.opencollection.com/) format). This gives us:

- **Interactive testing**: open the collection in Bruno to send real requests to an Oktopus instance.
- **Change tracking**: every endpoint is a file under version control, so API changes are reviewed and tracked through GitHub like any other code change.
- **Continuous publishing**: every commit to the `main` branch automatically updates the documentation at https://api.oktopus.app.br.

```
Edit requests in Bruno ──▶ Commit / Pull Request ──▶ Merge to main ──▶ api.oktopus.app.br updated
```

### Publishing

The [Publish API Docs](.github/workflows/docs.yml) GitHub Actions workflow runs on every push to `main` (and can be triggered manually). It uses the [Bruno CLI](https://docs.usebruno.com/bru-cli/overview) to generate a self-contained HTML documentation page and deploys it to GitHub Pages, served at the custom domain `api.oktopus.app.br`.

Only the `Prod` environment is embedded in the published page, and secret variables are never included. Keep non-secret values in `environments/Prod.yml` generic, since they are publicly visible.

To preview the documentation locally:

```sh
npm install -g @usebruno/cli
bru docs generate --envs Prod -o site/index.html
```

## Repository Structure

```
.
├── .github/workflows/     # Documentation publishing pipeline
├── opencollection.yml     # Collection definition and shared variables
├── environments/          # Bruno environments (e.g. Prod)
├── Auth/                  # Open source endpoints
├── Dashboard/
├── Device/
└── Enterprise Version/    # Commercial version endpoints
```

Each request is a `.yml` file containing the HTTP method, URL, headers, body, scripts, and example responses. Each folder has a `folder.yml` with folder-level settings and documentation.

## Using the Collection with Bruno

1. Install [Bruno](https://www.usebruno.com/downloads).
2. Clone this repository:
   ```sh
   git clone https://github.com/OktopUSP/rest-api-docs.git
   ```
3. In Bruno, choose **Open Collection** and select the cloned folder.
4. Select an environment (e.g. `Prod`) in the top-right corner, or create your own pointing to your Oktopus instance by setting `base_url`.
5. Fill in the secret variables (`password`, file server credentials, etc.) in the environment. Secret values are stored locally by Bruno and are never committed.
6. Run the `Auth/Login` request. Its post-response script stores the returned JWT in the `authToken` variable, which is used by the other requests.
7. Send any other request.

## Contributing API Changes

1. Create a branch from `main`.
2. Add or edit requests in Bruno (or edit the `.yml` files directly). Include example responses and docs whenever possible.
3. Never commit real credentials. Mark sensitive environment variables as secret, or reference them from a local `.env` file via `{{process.env.VAR_NAME}}` (`.env` is git-ignored).
4. Open a Pull Request describing the API change.
5. Once merged into `main`, the documentation at https://api.oktopus.app.br is updated automatically.

## License

See [LICENSE](LICENSE).
