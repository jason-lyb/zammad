# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class SearchController < ApplicationController
  prepend_before_action :authentication_check

  # GET|POST /api/v1/search
  # GET|POST /api/v1/search/:objects

  def search_generic
    assets = search_result
      .result
      .values
      .each_with_object({}) { |index_result, memo| ApplicationModel::CanAssets.reduce index_result[:objects], memo }

    result = if param_by_object?
               result_by_object
             else
               result_flattened
             end

    render json: {
      assets: assets,
      result: result,
      # 날짜 범위 정보도 함께 반환
      date_range: date_range_params,
    }
  end

  private

  def result_by_object
    search_result
      .result
      .each_with_object({}) do |(model, metadata), memo|
        memo[model.to_app_model.to_s] = {
          object_ids:  metadata[:objects].pluck(:id),
          total_count: metadata[:total_count]
        }
      end
  end

  def result_flattened
    search_result
      .flattened
      .map do |item|
        {
          type: item.class.to_app_model.to_s,
          id:   item[:id],
        }
      end
  end

  def search_result
    @search_result ||= begin
      # get params
      query = params[:query].try(:permit!)&.to_h || params[:query]

      Service::Search
        .new(
          current_user: current_user, 
          query: query, 
          objects: search_result_objects, 
          options: search_result_options
        )
        .execute
    end
  end

  def search_result_options
    {
      limit:            params[:limit] || 10,
      ids:              params[:ids],
      offset:           params[:offset],
      sort_by:          Array(params[:sort_by]).compact_blank.presence,
      order_by:         Array(params[:order_by]).compact_blank.presence,
      with_total_count: param_by_object?,
      # 날짜 범위 옵션 추가
      date_range:       date_range_params,
    }.compact
  end

  def param_by_object?
    @param_by_object ||= ActiveModel::Type::Boolean.new.cast(params[:by_object])
  end

  def search_result_objects
    objects = Models.searchable

    return objects if params[:objects].blank?

    given_objects = params[:objects].split('-').map(&:downcase)

    objects.select { |elem| given_objects.include? elem.to_app_model.to_s.downcase }
  end

  # 날짜 범위 파라미터 처리 메서드 추가
  def date_range_params
    return nil if params[:date_from].blank? && params[:date_to].blank?

    date_range = {}
    
    if params[:date_from].present?
      begin
        date_range[:from] = Time.zone.parse(params[:date_from]).beginning_of_day
      rescue ArgumentError
        Rails.logger.warn "Invalid date_from parameter: #{params[:date_from]}"
        return nil
      end
    end

    if params[:date_to].present?
      begin
        date_range[:to] = Time.zone.parse(params[:date_to]).end_of_day
      rescue ArgumentError
        Rails.logger.warn "Invalid date_to parameter: #{params[:date_to]}"
        return nil
      end
    end

    # 시작일이 종료일보다 늦은 경우 검증
    if date_range[:from] && date_range[:to] && date_range[:from] > date_range[:to]
      Rails.logger.warn "date_from is later than date_to"
      return nil
    end

    date_range
  end
end