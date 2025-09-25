# Arch User Repository (AUR) Packages for hale

Repository that contains AUR packages for hale-studio and hale-cli.

This repository is based on a template for maintaining [Arch User Repository (AUR)][1] packages automatically using [Renovate][2].
Check out my [AUR packages repository][3] to see it working.

## How it works

Check out [the breakdown on @JamieMagee's blog][4] for a step-by-step walkthrough.
The short version is:

1. Renovate will open PRs to update the `pkgver`
1. GitHub Actions will run `updpkgsums` and `makepkg --printsrcinfo > .SRCINFO` for each PR
1. When a PR is merged GitHub Actions will publish the package to the AUR (if you've configured the `AUR_USERNAME`, `AUR_EMAIL` and `AUR_SSH_PRIVATE_KEY` secrets).

## Adding a new package

1. Add a new directory with the package name
1. Manually create your `PKGBUILD` and `.SRCINFO`
1. Add a comment after pkgver with the [Renovate datasource][5] and package name

```
pkgver=1.2.3 # renovate: datasource=github-tags depName=git/git
```

## Working with packages locally

Each subfolder represents a package build. Change to the respective subfolder and use the following commands to update, build and install it.

### How to update `sha256sums`
You can update the checksums automatically with:
```sh
updpkgsums
```
This will update the `sha256sums` array in your PKGBUILD in place.

Alternatively, to generate checksums manually:
```sh
makepkg -g
```
Then copy the output into the `sha256sums` array in the PKGBUILD.

### How to build and install locally
1. Install base-devel and git if not already installed:
   ```sh
   sudo pacman -S --needed base-devel git
   ```
2. Clone this repository and enter the directory:
   ```sh
   git clone <this-repo-url>
   cd aur-hale-studio-bin
   ```
3. Build the package:
   ```sh
   makepkg -si
   ```
   - The `-s` flag installs missing dependencies.
   - The `-i` flag installs the package after building.

**If you make changes to the PKGBUILD after building:**
- You must rebuild the package for changes to take effect.
- If the package does not update, force a rebuild with:
  ```sh
  makepkg -fsi
  ```
  The `-f` (force) flag overwrites any existing package file and ensures a full rebuild.
- Alternatively, clean up old build files first:
  ```sh
  makepkg -C
  makepkg -si
  ```

### How to update .SRCINFO
After making changes to the PKGBUILD, update the .SRCINFO file with:
```sh
makepkg --printsrcinfo > .SRCINFO
```
This ensures the AUR metadata is up to date and should be done before pushing changes to the AUR.

### How to uninstall
To remove the package, use pacman:
```sh
sudo pacman -R hale-studio-bin
```

## License

All code in this repository is licensed under [the MIT license][6].
See the `license` property in each `PKGBUILD` for the license under which each package is distributed.

[1]: https://wiki.archlinux.org/title/Arch_User_Repository
[2]: https://github.com/apps/renovate
[3]: https://github.com/jamieMagee/aur-packages
[4]: https://jamiemagee.co.uk/blog/maintaining-aur-packages-with-renovate
[5]: https://docs.renovatebot.com/modules/datasource/
[6]: https://opensource.org/licenses/MIT
