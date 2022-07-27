# frozen_string_literal: true

# @overload launch(rocket, recovery:)
#   Don't forget to point the correct end toward space.
#
#   @param rocket [Rocket] the rocket to launch.
#   @param recovery [Boolean] if true, will attempt to recover the rocket after
#     a successful launch.
def launch(rocket, **options); end
