# frozen_string_literal: true

# You are going to space today.
#
# @option config [Boolean] enable_cheats if true, enables cheat codes.
# @option options [Boolean] recovery_transponder if true, adds a recovery
#   transponder to the rocket.
# @option options [Boolean] flight_termination_system if true, adds a flight
#   termination system to the rocket in case of launch failure.
def launch(config = {}, **options); end
