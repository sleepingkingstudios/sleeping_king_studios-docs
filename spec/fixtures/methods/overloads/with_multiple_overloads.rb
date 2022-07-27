# frozen_string_literal: true

# @overload launch(rocket)
#   Don't forget to point the correct end toward space.
#
# @overload launch(rocket, **options)
#   If not, you will not be going to space today after all.
#
#   @return [BigDecimal] the repair bill for the launch pad.
def launch(rocket, **options); end
