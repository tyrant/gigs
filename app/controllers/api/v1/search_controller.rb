class Api::V1::SearchController < ApplicationController

  before_action :massage_stringly_typed_params!
  before_action :validate_params!

  # Return all venues matching:
  # 
  def index 
    venues = Venue.left_outer_joins(gigs: :act)
    venues = venues.where('acts.id IN (?)', search_params[:acts]) if search_params.key?(:acts)

    render json: venues.as_json(include: :gigs)
  end

  def search_params
    params.permit!.to_h
  end

  def massage_stringly_typed_params!
    if params.key? :acts
      params[:acts] = params[:acts].map do |act_id|
        act_id.to_i != 0 ? act_id.to_i : act_id
      end
    end
  end

  def validate_params!
    search_api_schema = {
      type: 'object',
      required: [],
      properties: {
        acts: {
          type: 'array',
          items: {
            type: 'integer',
            minimum: 0,
          }
        }
      }
    }

    errors = JSON::Validator.fully_validate(search_api_schema, search_params)

    if errors.length > 0
      render json: {
        status: "error",
        error: errors 
      }.to_json, status: 402
    end
  end
end
