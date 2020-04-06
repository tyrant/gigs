class Api::V1::SearchController < ApplicationController

  before_action :massage_stringly_typed_params!
  before_action :validate_params!

  # Return all venues matching:
  # 
  def index 

    venues = Venue.includes(gigs: :act)
    venues = venues.where('acts.id IN (?)', search_params[:acts]) if search_params.key?(:acts)

    if search_params.key?(:times) and search_params[:times].key?(:start)
      venues = venues.where('gigs.at > ?', Time.at(search_params[:times][:start]))
    end

    if search_params.key?(:times) and search_params[:times].key?(:end)
      venues = venues.where('gigs.at < ?', Time.at(search_params[:times][:end]))
    end

    render json: venues.to_json(include: :gigs)
  end

  private

  def search_params
    params.permit!.to_h
  end

  def massage_stringly_typed_params!

    if params.key? :acts
      params[:acts] = params[:acts].map do |act_id|
        if act_id.to_i != 0 || act_id == '0'
          act_id.to_i
        else
          act_id
        end
      end
    end

    if params.key? :times
      if params[:times].key?(:start) && 
        (params[:times][:start].to_i != 0 || 
          params[:times][:start] == '0')
        params[:times][:start] = params[:times][:start].to_i
      end
      if params[:times].key?(:end) && 
        (params[:times][:end].to_i != 0 || 
          params[:times][:end] == '0')
        params[:times][:end] = params[:times][:end].to_i
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
        },
        times: {
          type: 'object',
          required: [],
          properties: {
            start: {
              type: 'integer',
              minimum: 0,
            },
            end: {
              type: 'integer',
              minimum: 0,
            }
          }
        }
      }
    }

    errors = JSON::Validator.fully_validate(search_api_schema, search_params)

    # Json-schema validation doesn't support values depending on other values. Do 'em manually instead:

    # Is times[start] earlier than times[end]?
    if search_params.key?(:times) &&
      search_params[:times].key?(:start) &&
        search_params[:times].key?(:end) && 
          search_params[:times][:start].is_a?(Numeric) && 
            search_params[:times][:end].is_a?(Numeric) && 
              search_params[:times][:start] > search_params[:times][:end]
        errors << "The property '#/times/start' can't be after '#/times/end', now can it"
    end

    if errors.length > 0
      render json: {
        status: "error",
        error: errors 
      }.to_json, status: 402
    end
  end
end
