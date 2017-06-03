module HousesHelper
  def link_to_add_field(name, f, association, options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    id = new_object.object_id

    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_form", f: builder)
    end

    link_to(name, '#', class: "add_field", data: {id: id, fields: fields.gsub("\n","")})
  end

  def link_to_remove_field(name, f, options={})
    f.hidden_field(:_destroy) + link_to(name, '#', class: "remove_field close")
  end
end
