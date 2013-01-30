# encoding: utf-8
require 'digest'

module ChinaPay
  module Alipay
    module Product
      class Base
        DEFAULT_CHARSET = 'utf-8'
        SIGN_TYPE_MD5 = 'MD5'

        GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'

        ATTR_REQUIRED = [:service, :partner, :_input_charset,
          :sign_type, :sign, :notify_url, :return_url,
          :out_trade_no, :subject, :payment_type, :seller_email
        ]

      end

      class DirectPay < Base
        NAME = '即时到账'
        SERVICE_LABEL = :create_direct_pay_by_user

        def initialize(order)
          @order = order

          @params = {}
          @extra_params = {}
          @extended_params = {}
        end

        def notification_callback_url(url)
          @params[:notify_url] = url
          self
        end

        def after_payment_redirect_url(url)
          @params[:return_url] = url
          self
        end

        def extra_params(params)
          @extra_params = params
          self
        end

        def gateway_api_url
          secure_signature = create_signature
          request_params = sign_params.merge(
            :sign_type => SIGN_TYPE_MD5,
            :sign => secure_signature
          )

          lost_attributes = ATTR_REQUIRED - request_params.keys
          if lost_attributes.any?
            raise "the following keys are lost: #{lost_attributes.inspect}"
          end

          uri = URI(GATEWAY_URL)
          uri.query = URI.encode_www_form(request_params.sort)

          uri.to_s
        end

        # 公用业务扩展参数
        #
        # 用于特定业务信息的传递
        #
        # NOTE: 需要单独签约才能生效
        def extended_params(params)
          @extended_params = params
          self
        end

        # 出错通知异步调用 URL
        #
        # NOTE: 需要联系技术支持才能开通
        def error_callback_url(url)
          @params[:error_notify_url] = url
          self
        end

        private
          def sign_params
            params = @order.attributes.merge(@params)
            params[:service] = SERVICE_LABEL
            params[:partner] = @order.merchant.partner
            params[:_input_charset] = DEFAULT_CHARSET
            @sign_params ||= params
          end

          def create_signature
            sequence = sign_params.sort.map {|k, v| "#{k}=#{v}"}.join('&')
            Digest::MD5.hexdigest(sequence + @order.merchant.key)
          end
      end
    end

    class Order
      PAYMENT_TYPE_BUYING = 1
      PAYMENT_TYPE_DONATION = 4

      attr_accessor :merchant
      attr_reader :attributes

      def initialize(order_id, subject, description)
        @attributes = {
          :out_trade_no => order_id,
          :subject => subject,
          :body => description }

        @attributes[:payment_type] = PAYMENT_TYPE_BUYING
      end

      def seller_email(email)
        @attributes[:seller_email] = email
        self
      end

      def buyer_email(email)
        @attributes[:buyer_email] = email
        self
      end

      def total_fee(fee)
        @attributes[:total_fee] = fee

        self
      end

      def product_url(url)
        @attributes[:show_url] = url
        self
      end

      def as_donation
        @attributes[:payment_type] = PAYMENT_TYPE_DONATION
        self
      end

      def direct_pay
        Product::DirectPay.new(self)
      end

    end

    class Merchant
      attr_accessor :partner, :key

      def initialize(partner, key)
        @partner = partner
        @key = key
      end

      def create_order(order_id, subject, description)
        order = Order.new(order_id, subject, description)
        order.merchant = self
        order
      end
    end
  end
end

