# frozen_string_literal: true

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

  # This is a scoped module.
  module ScopedModule; end

  # This is a scoped class.
  class ScopedClass; end

  # This is a scoped class method.
  def self.scoped_class_method; end

  # This is a scoped instance method.
  def scoped_instance_method; end

  private

  # This is a private method.
  def private_method; end
end
