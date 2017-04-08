module Api
  module V1
  	class ItemsController < ApplicationController
      before_action :set_item, only: [:show, :accept, :stop]
      before_action :auth_check, only: [:stop]
  	  def show
        render json: @item
  	  end

      def accept
        if @item.email == nil and @item.auth_token == nil
          @item.email = params[:email]
          @item.auth_token = params[:auth_token]
          if @item.save
            render json: @item and return
          else
            render status: :unprocessable_entity, json: { errors: ["Save failed."] } and return
          end
        else
          render status: :unprocessable_entity, json: { errors: ["Already rented."] } and return
        end
      end

      def stop
        if @item.email != nil and @item.auth_token != nil
          @item.email = nil
          @item.auth_token = nil
          @pastt = @item.updated_at
          if @item.save
            render json: @item.as_json.merge({:bill => (((Time.now.to_datetime - @pastt.to_datetime)*24*60*60).to_i)*@item.tariff }) and return
          else
            render status: :unprocessable_entity, json: { errors: ["Save failed."] } and return
          end
        else
          render status: :unprocessable_entity, json: { errors: ["Not already rented."] } and return
        end
      end

      private

      def set_item
        begin
          @item = Item.find(params[:id]) #Any response when wrong id
        rescue
          render status: :not_found, json: { errors: ["Not Found."] }
        end
      end

      def auth_check
        if @item.auth_token != params[:auth_token]
          render status: :unauthorized, json: { errors: ["Unauthorized."] }
        end
      end

  	end
  end
end