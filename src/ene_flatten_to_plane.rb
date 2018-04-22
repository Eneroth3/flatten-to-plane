#-------------------------------------------------------------------------------
#
#    Author: Julia Christina Eneroth
# Copyright: Copyright (c) 2018
#   License: MIT
#
#-------------------------------------------------------------------------------

require "extensions.rb"

module Eneroth
module FlattenToPlane

  path = __FILE__
  path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

  PLUGIN_ID = File.basename(path, ".rb")
  PLUGIN_DIR = File.join(File.dirname(path), PLUGIN_ID)

  EXTENSION = SketchupExtension.new(
    "Eneroth Flatten to Plane",
    File.join(PLUGIN_DIR, "main")
  )
  EXTENSION.creator     = "Julia Christina Eneroth"
  EXTENSION.description =
    "Flatten selected geometry to horizontal plane. Useful for cleaning up "\
    "imported DWGs."
  EXTENSION.version     = "1.1.0"
  EXTENSION.copyright   = "#{EXTENSION.creator} Copyright (c) 2018"
  Sketchup.register_extension(EXTENSION, true)

end
end
