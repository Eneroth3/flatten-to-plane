module Eneroth
module FlattenToPlane

  def self.purge_invalid_texts(entities)
    entities.grep(Sketchup::Text) { |t| t.erase! if t.point.to_a.any?(&:nan?) }

    nil
  end

  def self.flatten_to_plane(entities, plane = [ORIGIN, Z_AXIS])
    # Note that entities here is an Array of Entity objects, not an Entities
    # collection object.

    # If curves are not exploded moving one vertex will also move its neighbours,
    # causing a very unpredictable result.
    curves = entities.select { |e| e.respond_to?(:curve) }.flat_map(&:curve).compact.uniq
    curves.each(&:explode)

    vertices = entities.select { |e| e.respond_to?(:vertices) }.flat_map(&:vertices).uniq
    return if vertices.empty?
    vectors = vertices.map do |v|
      v.position.project_to_plane(plane) - v.position
    end
    entities.first.parent.entities.transform_by_vectors(vertices, vectors)

    # Using transform_by_vectors on several vertices at once may cause 2D texts
    # from going mad with NAN coordinates and break SketchUp rendering.
    # Aka the "Zoom Extents" bug.
    purge_invalid_texts(entities.first.parent.entities)

    nil
  end

  def self.flatten_to_plane_operation
    model = Sketchup.active_model
    model.start_operation("Flatten to Plane", true)
    plane = [model.axes.origin, model.axes.zaxis]
    flatten_to_plane(model.selection, plane)
    model.commit_operation

    nil
  end

  menu = UI.menu("Plugins")
  menu.add_item(EXTENSION.name) { flatten_to_plane_operation }

end
end
