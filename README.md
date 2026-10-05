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

The [Publish API Docs](.github/workflows/docs.yml) GitHub Actions workflow runs on every push to `main` (and can be triggered manually). It runs [`scripts/build-docs.sh`](scripts/build-docs.sh), which uses the [Bruno CLI](https://docs.usebruno.com/bru-cli/overview) to generate a self-contained HTML documentation page, applies the Oktopus branding, and deploys it to GitHub Pages, served at the custom domain `api.oktopus.app.br`.

Only the `Public` environment (`environments/Public.yml`) is embedded in the published page. It holds placeholder values only, since everything in it is publicly visible. Other environments are never published (see [Running Against Your Own Oktopus Instance](#running-against-your-own-oktopus-instance)).

To build the documentation locally (requires Node.js, Python 3 and rsync):

```sh
npm install -g @usebruno/cli
./scripts/build-docs.sh            # output in site/
./scripts/build-docs.sh --offline  # also bundles the renderer, so it opens without internet
```

Open `site/index.html` in your browser. Keep all files in `site/` together.

### Branding

The logo and colors of the published page live in `branding/`:

- `logo.png`: shown in the page header and used as the favicon.
- `theme.css`: overrides the renderer's `--oc-*` color variables for the dark and light themes.

Bruno does not offer branding options when generating docs, so the build script injects these files into the generated page.

## Repository Structure

```
.
├── .github/workflows/     # Documentation publishing pipeline
├── branding/              # Logo and colors of the published docs
├── scripts/build-docs.sh  # Builds the branded documentation page
├── opencollection.yml     # Collection definition and shared variables
├── environments/          # Bruno environments (only Public.yml is versioned)
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
4. Create your own environment pointing to your Oktopus instance, as described in [Running Against Your Own Oktopus Instance](#running-against-your-own-oktopus-instance), and select it in the top-right corner.
5. Run the `Auth/Login` request. Its post-response script stores the returned JWT in the `authToken` variable, which is used by the other requests.
6. Send any other request.

## Running Against Your Own Oktopus Instance

The `Public` environment only contains placeholders such as `https://{domain-name}/api/`. To send real requests, keep your domain, credentials and device data in a private environment that never leaves your machine:

1. In Bruno, open **Environment Settings**, clone the `Public` environment (or create a new one), and give it your own name, e.g. `Local` or `Prod`.
2. Fill in your values: `base_url`/`url` with your Oktopus API address (e.g. `https://oktopus.example.com/api/`), `email`, `device`, and so on.
3. Mark sensitive variables (`password`, file server usernames and passwords, etc.) as **Secret**. Bruno stores secret values encrypted in its local app storage instead of the environment file.
4. Select your environment and run `Auth/Login`.

Your environment is saved as `environments/<name>.yml`. This repository git-ignores every file in `environments/` except `Public.yml`, so it is never committed, pushed or published.

Other options for keeping data private:

- **`.env` file**: put values in a `.env` file at the collection root and reference them as `{{process.env.VAR_NAME}}` in your environment. `.env` files are git-ignored. Commit a `.env.example` with placeholder names if you want to share the expected variables.
- **Global environments**: Bruno global environments are stored in the Bruno app, outside this repository, so they can never be committed.

Before committing, make sure your changes don't leak private data:

- Never put real values in `environments/Public.yml`; it is published at https://api.oktopus.app.br.
- Use variables (`{{base_url}}`, `{{device}}`, ...) in requests instead of hard-coded domains, IDs or tokens.
- Scrub saved example responses of real device IDs, serial numbers, IP and MAC addresses, emails and tokens.
- Review `git status` and `git diff` before every commit.

## Contributing API Changes

1. Create a branch from `main`.
2. Add or edit requests in Bruno (or edit the `.yml` files directly). Include example responses and docs whenever possible.
3. Never commit real credentials, domains or device data. Follow the checklist in [Running Against Your Own Oktopus Instance](#running-against-your-own-oktopus-instance).
4. Open a Pull Request describing the API change.
5. Once merged into `main`, the documentation at https://api.oktopus.app.br is updated automatically.

## License

See [LICENSE](LICENSE).
