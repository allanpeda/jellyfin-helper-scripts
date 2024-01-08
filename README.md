# What this is

In order for me to get Jellyfin working on a Mac Mini, accessing media from an external 4TB HDD, I had to do the following:

1. Create a dedicated jellyfin user account using the GUI interface (useradd neglected to address needed enryption keys).
2. Grant that account the ability to remotely log in (because I was using SSH to administer this macheine and upload media.
3. Install [[Homebrew|https://brew.sh/]]
