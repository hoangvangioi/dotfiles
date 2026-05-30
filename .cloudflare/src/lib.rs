use worker::*;

#[event(fetch)]
async fn fetch(_req: Request, _env: Env, _ctx: Context) -> Result<Response> {
    let url = _req.url()?;
    let headers = _req.headers();
    let user_agent = headers.get("user-agent")?.unwrap_or_default().to_lowercase();

    // Configuration
    let github_username = "hoangvangioi";
    let github_repo = "dotfiles"; 
    let default_branch = "main";

    let base_github_url = format!("https://github.com/{}/{}", github_username, github_repo);

    // Case 1: Terminal root request
    if (user_agent.contains("curl") || user_agent.contains("wget")) && url.path() == "/" {
        
        let wrapper_script = format!(
            r#"#!/bin/bash
set -e

DOTFILES_DIR="$HOME/.{github_repo}"

echo "Setting up dotfiles into $DOTFILES_DIR..."

# Clone if not exists, otherwise pull updates (Shallow clone optimized)
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --depth 1 https://github.com/{github_username}/{github_repo}.git "$DOTFILES_DIR"
else
    cd "$DOTFILES_DIR" && git pull origin {default_branch}
fi

cd "$DOTFILES_DIR"
chmod +x ./install.sh 2>/dev/null || chmod +x ./install 2>/dev/null

if [ -f "./install.sh" ]; then
    ./install.sh
else
    ./install
fi
"#,
            github_username = github_username,
            github_repo = github_repo,
            default_branch = default_branch
        );

        let headers = Headers::new();
        return Ok(Response::ok(wrapper_script)?.with_headers(headers));
    }

    // Case 2: Terminal deep-link request
    if user_agent.contains("curl") || user_agent.contains("wget") {
        let github_raw_url = format!(
            "https://raw.githubusercontent.com/{}/{}/{}{}",
            github_username, github_repo, default_branch, url.path()
        );
        let mut res = Fetch::Url(github_raw_url.parse()?).send().await?;
        if res.status_code() == 404 {
            return Response::error("File Not Found on GitHub", 404);
        }
        let body = res.text().await?;
        let headers = Headers::new();
        return Ok(Response::ok(body)?.with_headers(headers));
    }

    // Case 3: Browser requests redirect to GitHub UI
    Response::redirect(Url::parse(&base_github_url)?)
}
