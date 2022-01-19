#!/bin/bash -e

# FFmpeg
if [ "$install_ffmpeg" = "Y" ]; then

	outputHandler "section" "Installing FFmpeg"

	command "sudo port -N install ffmpeg +nonfree"

	outputHandler "comment" "FFmpeg: OK"

else
	outputHandler "comment" "Skipping FFmpeg"
fi
