# frozen_string_literal: true

# This is a private constant.
PRIVATE_CONSTANT = nil
private_constant :PRIVATE_CONSTANT

# This constant is tagged as private.
#
# @private
PRIVATE_TAGGED_CONSTANT = nil

# This is a constant in the top-level namespace.
TOP_LEVEL_CONSTANT = nil

# This is a class method in the top-level namespace.
def self.top_level_class_method; end

# This is an instance method in the top-level namespace.
def top_level_instance_method; end

# This is a class defined in the top-level namespace.
class TopLevelClass; end

# This is a module defined in the top-level namespace.
module TopLevelModule
  # This is a scoped constant.
  SCOPED_CONSTANT = nil

  # This module is tagged as private.
  #
  # @private
  module PrivateModule; end

  # This is a scoped module.
  module ScopedModule; end

  # This class is tagged as private.
  #
  # @private
  class PrivateClass; end

  # This is a scoped class.
  class ScopedClass; end

  # This is a scoped class method.
  def self.scoped_class_method; end

  # This attribute is tagged as private.
  #
  # @private
  attr_reader :private_tagged_attribute

  # This method is tagged as private.
  #
  # @private
  def private_tagged_method; end

  # This is a scoped instance method.
  def scoped_instance_method; end
  alias aliased_instance_method scoped_instance_method

  private

  # This is a private attribute.
  attr_reader :private_attribute

  # This is a private method.
  def private_method; end
end
