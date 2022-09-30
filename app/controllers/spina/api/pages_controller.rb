module Spina
  module Api
    class PagesController < ApiController
      include Paginable

      before_action :set_resource

      def index
        paginated_records = Page.live.includes(:translations).where(
          resource: @resource
        ).order(:created_at)
                                .page(params[:page]).per(params[:per_page])
        render json: data(paginated_records)
      end

      def show
        @page = Page.live.where(resource: @resource).find(params[:id])
        render json: Spina::Api::PageSerializer.new(@page).serializable_hash.to_json
      end

      private

      def set_resource
        @resource = Spina::Resource.find(params[:resource_id]) if params[:resource_id].present?
      end

      def data(paginated_records)
        Spina::Api::PageSerializer.new(
          paginated_records,
          {
            meta: pagination_meta(paginated_records),
            links: pagination_links(paginated_records),
            params: { view_context: view_context }
          }
        ).serializable_hash.to_json
      end
    end
  end
end
