# frozen_string_literal: true

# You are going to space today.
#
# This object has a full description. It is comprised of a short description,
# followed by a multiline explanation, a list, and an essay cliche.
#
# - This is a description item.
# - This is another description item.
#
# In conclusion, space is a land of contrasts.
#
# @param apoapsis [Float] the highest point in the orbit.
# @param payload [Object] the payload to launch.
# @param recovery [Boolean] if true, will attempt to recover the rocket after a
#   successful launch.
# @param rocket [Rocket] the rocket to launch.
# @param options [Hash] additional options for the launch.
#
# @option options [Boolean] recovery_transponder if true, adds a recovery
#   transponder to the rocket.
# @option options [Boolean] flight_termination_system if true, adds a flight
#   termination system to the rocket in case of launch failure.
#
# @raise [AuthorizationError] if the launch has not been authorized.
# @raise [NotGoingToSpaceTodayError] if the rocket is pointed the wrong way.
#
# @return [true] if the predicate is true.
# @return [false] if the predicate is false.
#
# @yield [rocket, payload: nil, **destinations] executes the mission profile.
#
# @yieldparam rocket [Rocket] the rocket to launch.
# @yieldparam payload [Object] the payload to launch.
# @yieldparam destinations [Hash] the destinations to visit.
#
# @yieldreturn [Array<Astronaut, SurfaceSample>] if the mission was crewed.
# @yieldreturn [Array<Signal>] if the mission was automated.
#
# @example Named Example
#   # This is a named example.
#
# @note This is a note.
#
# @see https://foo.
#
# @todo Remove the plutonium.
#
# @overload launch(rocket)
#   Don't forget to point the correct end toward space.
#
# @overload launch(rocket, **options)
#   If not, you will not be going to space today after all.
#
#   @return [BigDecimal] the repair bill for the launch pad.
def launch(rocket, payload = nil, apoapsis:, recovery: false, **options); end
