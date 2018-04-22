module Eneroth
module FlattenToPlane

  def self.purge_invalid_texts(entities)
    entities.grep(Sketchup::Text) { |t| t.erase! if t.point.to_a.any?(&:nan?) }

    nil
  end

  def self.flatten_to_plane(entities, plane = [ORIGIN, Z_AXIS])
    # If curves are not exploded moving one vertex will also move its neighbours,
    # causing a very unpredictable result.
    curves = entities.select { |e| e.respond_to?(:curve) }.flat_map(&:curve).compact.uniq
    curves.each { |c| c.edges.first.explode_curve }

    vertices = entities.select { |e| e.respond_to?(:vertices) }.flat_map(&:vertices).uniq
    instances = entities.select { |e| e.respond_to?(:transformation) }
    original_points = vertices.map(&:position)
    original_points += instances.map { |i| i.transformation.origin }
    vectors = original_points.map { |p| p.project_to_plane(plane) - p }
    entities.first.parent.entities.transform_by_vectors(vertices + instances, vectors)

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
