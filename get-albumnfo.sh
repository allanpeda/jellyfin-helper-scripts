#!/bin/bash
# Time-stamp: <2024-10-04 21:16:42 allan>

# Script to download MusicBrainz Album XML and convert it to Jellyfin album.nfo
# Allan Peda
# October 2024
# Requires xmllint and xmlstarlet
#
# Usage:
# get-albumnfo.sh bd5e5261-c1e8-47b5-973c-b9de1f2f1f85 > album.nfo

set -eEuo pipefail

if [[ "${#1}" -ne 36 ]]
then
    echo "The supplied argument should be a MusicBrainz release ID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" >&2
    exit 1
fi
declare releaseid="$1"

declare mbxml jfinxml xsltfile
declare -r MBURL='https://musicbrainz.org/ws/2/release/'
mbxml="$(mktemp)"
jfinxml="$(mktemp)"
xsltfile="$(mktemp)"
trap 'rm -f "${mbxml}" "${jfinxml}" "${xsltfile}"' EXIT

# load the XSLT function
eval "$(awk '/^genxslt\(/ {p=1} p' "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC2218
genxslt > "$xsltfile"

xmllint --format - < <(curl -s "${MBURL%/}/${releaseid}?inc=artists+recordings+release-groups")  > "${mbxml}"
xmlstarlet tr "$xsltfile" "${mbxml}"

exit
# shellcheck disable=SC2317
genxslt(){
cat<<EOF
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
    xmlns:mb="http://musicbrainz.org/ns/mmd-2.0#">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- Match the <release> element within the namespace -->
    <xsl:template match="/mb:metadata/mb:release">
        <album>
            <review/>
            <outline/>
            <lockdata>false</lockdata>

            <!-- Placeholder for the current date -->
            <dateadded>$(date +'%F %H:%M:%S')</dateadded>

            <!-- Extract the title -->
            <title>
                <xsl:value-of select="mb:title"/>
            </title>

            <!-- Extract year and release date -->
            <year>
                <xsl:value-of select="substring(mb:release-group/mb:first-release-date, 1, 4)"/>
            </year>
            <premiered>
                <xsl:value-of select="mb:release-group/mb:first-release-date"/>
            </premiered>
            <releasedate>
                <xsl:value-of select="mb:release-group/mb:first-release-date"/>
            </releasedate>

            <!-- Calculate runtime (in minutes) from track lengths -->
            <runtime>
                <xsl:value-of select="floor(sum(mb:medium-list/mb:medium/mb:track-list/mb:track/mb:length) div 60000)"/>
            </runtime>

            <!-- Placeholder genre -->
            <genre>Rock</genre>

            <!-- MusicBrainz IDs -->
            <musicbrainzalbumid>
                <xsl:value-of select="@id"/>
            </musicbrainzalbumid>
            <musicbrainzalbumartistid>
                <xsl:value-of select="mb:artist-credit/mb:name-credit/mb:artist/@id"/>
            </musicbrainzalbumartistid>
            <musicbrainzreleasegroupid>
                <xsl:value-of select="mb:release-group/@id"/>
            </musicbrainzreleasegroupid>

            <!-- Placeholder for artwork -->
            <art>
                <poster>/path/to/cover.jpg</poster>
            </art>

            <!-- Extract artist info -->
            <artist>
                <xsl:value-of select="mb:artist-credit/mb:name-credit/mb:artist/mb:name"/>
            </artist>
            <albumartist>
                <xsl:value-of select="mb:artist-credit/mb:name-credit/mb:artist/mb:name"/>
            </albumartist>

            <!-- Iterate over tracks -->
            <xsl:for-each select="mb:medium-list/mb:medium/mb:track-list/mb:track">
                <track>
                    <position>
                        <xsl:value-of select="mb:position"/>
                    </position>
                    <title>
                        <xsl:value-of select="mb:recording/mb:title"/>
                    </title>
                    <duration>
                        <xsl:value-of select="format-number(floor(mb:length div 60000), '00')"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="format-number((mb:length mod 60000) div 1000, '00')"/>
                    </duration>
                </track>
            </xsl:for-each>
        </album>
    </xsl:template>
</xsl:stylesheet>
EOF
} # genxslt()
