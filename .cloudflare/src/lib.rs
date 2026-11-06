use worker::*;

const GITHUB_USERNAME: &str = "hoangvangioi";
const GITHUB_REPO: &str = "dotfiles";
const DEFAULT_BRANCH: &str = "main";

/// Is this request coming from a terminal tool (curl / wget / ...)?
fn is_terminal_agent(ua: &str) -> bool {
    ["curl", "wget", "httpie", "fetch"]
        .iter()
        .any(|tool| ua.contains(tool))
}

fn script_headers() -> Result<Headers> {
    let headers = Headers::new();
    headers.set("content-type", "text/plain; charset=utf-8")?;
    headers.set("cache-control", "no-store")?;
    Ok(headers)
}

#[event(fetch)]
async fn fetch(req: Request, _env: Env, _ctx: Context) -> Result<Response> {
    let url = req.url()?;
    let user_agent = req
        .headers()
        .get("user-agent")?
        .unwrap_or_default()
        .to_lowercase();

    let base_github_url = format!("https://github.com/{GITHUB_USERNAME}/{GITHUB_REPO}");
    let terminal = is_terminal_agent(&user_agent);

    // Case 1: `curl -LsS https://arch.hoangvangioi.com | bash`
    if terminal && (url.path() == "/" || url.path().is_empty()) {
        // NOTE: the install script lives in the (shallow) clone, so it has to be
        // executed from there - never from the caller's working directory.
        let wrapper_script = format!(
            r#"#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${{HOME}}/.{repo}"

echo "Setting up dotfiles into $DOTFILES_DIR..."

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    git clone --depth 1 "https://github.com/{user}/{repo}.git" "$DOTFILES_DIR"
else
    git -C "$DOTFILES_DIR" pull --ff-only origin {branch}
fi

cd "$DOTFILES_DIR"
chmod +x ./install.sh

./install.sh "$@"
"#,
            user = GITHUB_USERNAME,
            repo = GITHUB_REPO,
            branch = DEFAULT_BRANCH
        );

        return Ok(Response::ok(wrapper_script)?.with_headers(script_headers()?));
    }

    // Case 2: terminal deep-link, e.g. `curl https://arch.hoangvangioi.com/.zshrc`
    if terminal {
        let raw_url = format!(
            "https://raw.githubusercontent.com/{}/{}/{}{}",
            GITHUB_USERNAME,
            GITHUB_REPO,
            DEFAULT_BRANCH,
            url.path()
        );

        let mut res = match Fetch::Url(raw_url.parse()?).send().await {
            Ok(res) => res,
            Err(_) => return Response::error("Upstream fetch failed", 502),
        };

        if res.status_code() == 404 {
            return Response::error("File Not Found on GitHub", 404);
        }
        if res.status_code() != 200 {
            return Response::error("Upstream error", 502);
        }

        // Binary-safe: screenshots/wallpapers must not be mangled by `text()`
        let body = res.bytes().await?;
        let mut response = Response::from_bytes(body)?;

        let content_type = res
            .headers()
            .get("content-type")?
            .unwrap_or_else(|| "application/octet-stream".to_string());
        response.headers_mut().set("content-type", &content_type)?;
        response
            .headers_mut()
            .set("cache-control", "public, max-age=300")?;

        return Ok(response);
    }

    // Case 3: browser requests go to the GitHub UI
    Response::redirect(Url::parse(&base_github_url)?)
}
