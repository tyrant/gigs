jsonapi_object_schema = {
  type: 'object',
  required: ['id', 'type', 'attributes', 'relationships'],
  properties: {
    id: { type: 'string' },
    type: { type: 'string' },
    attributes: { 
      type: 'object',
    },
    relationships: {
      type: 'object',

    },
    links: {
      type: 'object',
    },
    related: {
      type: 'object',
    },
  }
}

jsonapi_array_schema = {
  type: 'array',
  items: jsonapi_object_schema
}

RSpec::Matchers.define :match_jsonapi_array_types_for do |klass|
  match do |candidate_array|
    candidate_array.all? {|item| item['type'] == klass.model_name.plural }
  end
end

RSpec::Matchers.define :match_jsonapi_array_schema do
  match do |candidate_jsonapi_array|
    JSON::Validator.fully_validate(jsonapi_array_schema, candidate_jsonapi_array).length == 0
  end
end