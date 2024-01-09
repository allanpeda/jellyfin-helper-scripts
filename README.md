# What this is

In order for me to get Jellyfin working on a Mac Mini, without logging via the GUI, and accessing media from an external 4TB HDD, I had to do the following:

1. Create a dedicated jellyfin user account using the GUI interface (useradd neglected to create needed enrcyption keys).
2. Grant that account the ability to remotely log in (because I was using SSH to administer this machine and upload content.
3. Install [Homebrew](https://brew.sh/)
4. I had to create a proper fstab file to consitently mount the [Satechi HDD](https://satechi.net/products/stand-hub-for-mac-mini-with-ssd-enclosure)
5. I also installed:
     - A newer Bash (version 5)
     - GNU Awk (gawk)
     - yt-dlp
     - coreutils (for the `timeout` utility)
     - ffmpeg
     - handbrake
     - jq
     - The [jc](https://github.com/kellyjonbrazil/jc) json conversion utility
     - handbrake
6. Create the following Process List files:
     - `/Library/LaunchDaemons/vip.a8545eff.jellyfin.plist`
     - `/Library/LaunchDaemons/vip.a8545eff.jellyfinmonitor.plist`
     - `/Library/LaunchDaemons/vip.a8545eff.mountexthdd.plist`
7. These files control the following scripts
     - `/usr/local/sbin/mount-uuid` (given a UUID this conditionally mounts the needed hard drive at `/Volumes/EXTHDD` 
     - `/Users/jellyfin/bin/jellyfin-monitor` Uses curl to check the site and restart if unresponsive
     - `/Users/jellyfin/bin/start-jellyfin` Waits for the needed fileststem to be ready
  
