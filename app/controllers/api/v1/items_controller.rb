require 'uri'
require 'net/http'

class ::Float
  def encode_json(opts = nil)
    "%.10f" % self
  end
end

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
          @auth_t = @item.auth_token
          @sat_amt = (((Time.now.to_datetime - @pastt.to_datetime)*24*60*60).to_i)*@item.tariff
          if @item.save
            callUno(@auth_t, @sat_amt)
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

      def callUno(auth_token, amount)
        p auth_token
        p amount

        url = URI("https://sandbox.unocoin.co/api/v1/wallet/sendingbtc")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/json'
        request["authorization"] = auth_token
        request["cache-control"] = 'no-cache'
        request.body = "{\r\n\t\"to_address\":\"3Eudzybvhf7EkEJQyTK42h7CsagQoWhYEn\",\r\n\t\"btcamount\":\""+(amount.to_f/100000000).encode_json+"\"\r\n}"

        response = http.request(request)
        p response.read_body
      end

  	end
  end
end