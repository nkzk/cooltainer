## release: 

By default, release-please uses `GITHUB_TOKEN`, but this will not trigger additional workflows like `publish-docker-image` in this case [[source](https://github.com/googleapis/release-please-action?tab=readme-ov-file#github-credentials)]

So that "release-please" PR's can trigger additional workflows, I use the action `actions/create-github-app-token` to create a token based on github app app credentials.

```sh
      - uses: actions/create-github-app-token@v1
        id: app-token
        with:
          app-id: ${{ vars.APP_ID }}
          private-key: ${{ secrets.APP_PRIVATE_KEY }}
```

and then update `.token` field in release-please action:
```sh
 - uses: googleapis/release-please-action@v4
        id: release
        with:
          token: ${{ steps.app-token.outputs.token }}
          release-type: simple
```

## release-please app config

**1:** create personal or organization github app

**2:** use the following permissions:
  - Metadata - readonly (mandatory)
  - Contents - read/write
  - Pull Requests - read/write

**3:** note app-id

**4:** create/download private-key
  - its stored in ~/downloads (depending on browser/settings)

**5:** update project secrets/variables

## release-please required permissions:

In `.github\{action}.yml`:

```sh
permissions:
  contents: write
  pull-requests: write
  issues: write
```

In Github project:
  - Set "Allow GitHub Actions to create and approve pull requests" under repository Settings > Actions > Gener
