# DFD Hugo check-links GitHub Action

GitHub Action to check links (internal-only or optionally all links) for a Hugo site

## Status

### Pushes to main & Weekly scheduled external link check

[![test-check-links](https://github.com/danielfdickinson/link-check-action-hugo-dfd/actions/workflows/test-check-links.yml/badge.svg)](https://github.com/danielfdickinson/link-check-action-hugo-dfd/actions/workflows/test-check-links.yml) [![weekly-external-link-check](https://github.com/danielfdickinson/link-check-action-hugo-dfd/actions/workflows/weekly-external-link-check.yml/badge.svg)](https://github.com/danielfdickinson/link-check-action-hugo-dfd/actions/workflows/weekly-external-link-check.yml)

## GitHub repository

<https://github.com/danielfdickinson/link-check-action-hugo>

## Details

### Purpose

This is a meant to be a pass/fail test which blocks pushing broken internal links, and optionally blocks pushing an update until any broken external links are fixed (external breakage can occur independently of repo changes and this is not recommended). A more reasonable use case for the external link check is to get notifications when a scheduled run (which you would create) of the action detects problem links.

### Inputs

| Input | Req'd | Default | Meaning |
|-------|-------|---------|---------|
| canonical-root | yes | _(nil)_ (will fail build unless specified in ``with``) | URLs beginning with this string are considered internal, in addition to site-relative URLs (e.g. beginning with slash ``/``) or page-relative URLs (no scheme or slash)) |
| check-external | no | n/a | If "true" check all URLs including offsite (external) |
| check-external-strict | no | n/a | If "true" 301 redirects (only occurs with external checks) result in a fail instead on only warning |
| download-site-as | yes | unminified-site | Name of artifact from build stage which contains the site (tarball, no compression) |
| download-site-filename | yes | hugo-site.tar | Name of tarball in artifact from build stage which contains the site (no compression) |
| entry-point | yes | sitemap.xml | File with which to start crawling (should lead to all other pages, even if through links) |
| output-directory | yes | public | Directory (in the artifact, above, containing the site) |
| skip-check-patterns | yes | a list of relevance to my sites | A space-separated list of patterns for which to skip errors such as sites that dislike automated connections like ours |
| upload-logs-as | no | _(nil)_ | If present will, on failed links, upload logs of link check results (ok.log, todo.log, error.log) as an artifact with this name |
| upload-logs-retention | no | _(nil)_ | How many days to retain logs uploaded as an artifact. If not set uses the GitHub default (90 days). |

The tarball in the artifact pointed to by ``download-site-as`` and has the name defined by ``download-site-filename`` (default: ``hugo-site.tar``) and contain the following:

* A subdirectory tree containing the site (default: _public_, optionally defined by ``output-directory``).

## Dependencies

``package.json`` and ``package-lock.json`` are used by ``npm install`` to install ``hyperlink`` which does the link-checking.

``hyperlink`` is <https://www.npmjs.com/package/hyperlink/> with homepage <https://github.com/Munter/hyperlink>.

Needed configuration should exist in the workspace. The best way to do this is to do a shallow checkout of the repo.

If no NPM config exists, use of ``npx`` means that the latest version of ``hyperlink`` will be installed, even without a ``package.json`` or ``package-lock.json``. Using them allows you to control the version of ``hyperlink`` that is used.

### Outputs

None

### Sample usage

#### Usual CI (on pull_request or push)

```yaml
name: test-check-links
on:
  pull_request:
    types:
      - assigned
      - opened
      - synchronize
      - reopened
  push:
    branches:
      - 'feature**'
      - main
      - 'staging**'
jobs:
  build-unminified-site:
    runs-on: ubuntu-20.04
    steps:
      - name: "Build Site with Hugo and Audit"
        uses: danielfdickinson/build-audit-action-hugo-dfd@v0.2
        with:
          source-directory: src
          upload-site-as: unminified-site
          use-lfs: false
  check-links:
    needs: build-unminified-site
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v3
      - name: Run DFD Hugo Check Links
        uses: danielfdickinson/link-check-action-hugo-dfd@v0.2
        with:
          canonical-root: https://www.example.com/
```

#### Scheduled external (all) links check

```yaml
name: weekly-external-link-check
on:
  schedule:
    # At 10:45 PM -0500 check all external links
    - cron: '45 3 * * 3'
jobs:
  build-unminified-site:
    runs-on: ubuntu-20.04
    steps:
      - name: "Build Site with Hugo and Audit"
        uses: danielfdickinson/build-audit-action-hugo-dfd@v0.2
        with:
          source-directory: src
          upload-site-as: unminified-site
          use-lfs: false
  check-external-links:
    needs: build-unminified-site
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v3
      - name: Run DFD Hugo Check Links
        uses: danielfdickinson/link-check-action-hugo-dfd@v0.2
        with:
          canonical-root: https://www.example.com/
          check-external: true
```

#### Scheduled strict external (all) links check

```yaml
name: monthly-strict-external-link-check
on:
  schedule:
    # At 10:45 PM -0500 on the 12th day of the month strictly check all external links (no 'todo' for 301 permanent redirect; fail it)
    - cron: '25 4 12 * *'
jobs:
  build-unminified-site:
    runs-on: ubuntu-20.04
    steps:
      - name: "Build Site with Hugo and Audit"
        uses: danielfdickinson/build-audit-action-hugo-dfd@v0.2
        with:
          source-directory: src
          upload-site-as: unminified-site
          use-lfs: false
  check-external-links:
    needs: build-unminified-site
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v3
      - name: Run DFD Hugo Check Links
        uses: danielfdickinson/link-check-action-hugo-dfd@v0.2
        with:
          canonical-root: https://www.example.com/
          check-external: true
          check-external-strict: true
          upload-logs-as: logs-failed-monthly-strict-external-link-check
```
