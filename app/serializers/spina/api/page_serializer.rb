module Spina
  module Api
    class PageSerializer < BaseSerializer
      set_type :page

      attributes :title, :seo_title, :menu_title, :materialized_path, :name, :description

      attribute(:content) { |page, params| page_content(page, params) }

      belongs_to :resource

      class << self
        def page_content(page, params)
          return [] unless view_template(page)

          view_template(page)[:parts].map do |part|
            if %w[onboarding_logo onboarding_step_image].include?(part)
              fetch_image_data(params, part, page)
            else
              { part => page.content(part) }
            end
          end
        end

        def view_template(page)
          Spina::Current.theme.view_templates.find { |view_template| view_template[:name] == page.view_template }
        end

        def image_contents(page_attributes, image, params, resize_key, part)
          { part => page_attributes.merge(
            original_url: params[:view_context].main_app.url_for(image.file),
            thumbnail_url: params[:view_context].main_app.url_for(image.variant(resize_to_fill: Spina.config.thumbnail_image_size)),
            embedded_image_size_url: params[:view_context].main_app.url_for(image.variant({ resize_key => Spina.config.embedded_image_size }))
          ) }
        end

        def fetch_image_data(params, part, page)
          page_attributes = page.content(part).attributes
          image = Spina::Image.find(page_attributes['image_id'])
          resize_key = Spina.config.embedded_image_size.is_a?(Array) ? :resize_to_limit : :resize
          image_contents(page_attributes, image, params, resize_key, part)
        end
      end
    end
  end
end
