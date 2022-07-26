# frozen_string_literal: true

# You are going to space today.
#
# @param apoapsis [Float] the highest point in the orbit.
# @param payload [Object] the payload to launch.
# @param recovery [Boolean] if true, will attempt to recover the rocket after a
#   successful launch.
# @param rocket [Rocket] the rocket to launch.
def launch(rocket, payload = nil, apoapsis:, recovery: false); end
