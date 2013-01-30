# ChinaPay

A simple payment library for china payment gateways.

## 安装方法

Add this line to your application's Gemfile:

    gem 'china_pay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install china_pay

## 使用指南

### 支付宝 即时到账交易接口

此接口的官方服务名称为：create_direct_pay_by_user

接口集成示例代码：

    class PaymentsController < ApplicationController
      def pay
        @partner_id = '2088123456' # 支付宝合作者身份 ID，以 2088 开头
        @key = 'SECURE_KEY' # 安全校验码

        @merchant = ChinaPay::Alipay::Merchant.new(@partner_id, @key)

        @order_id = 'KC201301300001D' # 商家内部唯一订单编号
        @subject = 'iPhone 5 16G 黑色 x 1' # 订单标题
        @description = '感谢您购买 iPhone 5 ！' # 订单内容

        @order = @merchant.create_order(@order_id, @subject, @description)

        @seller_email = 'seller@company.com' # 卖家支付宝帐号
        @total_fee = 0.01 # 订单总额

        @direct_pay = @order.seller_email(@seller_email).total_fee(@total_fee).direct_pay

        # 交易成功同步返回地址
        @return_url = 'http://company.com/payments/success'
        @direct_pay.after_payment_redirect_url(@return_url)

        # 交易状态变更异步通知地址
        @notify_url = 'http://company.com/payments/notify'
        @direct_pay.notification_callback_url(@notify_url)

        redirect_to @direct_pay.gateway_api_url
      end
    end

或者，用一行代码搞定：

    class PaymentsController < ApplicationController
      def pay
        redirect_to ChinaPay::Alipay::Merchant.new('2088123456', 'SECURE_KEY')
                      .create_order('KC201301300001D', 'iPhone 5 16G 黑色 x 1', '感谢您购买 iPhone 5 ！')
                      .seller_email('seller@company.com').total_fee(0.01)
                      .direct_pay
                      .after_payment_redirect_url('http://company.com/payments/success')
                      .notification_callback_url('http://company.com/payments/notify')
                      .gateway_api_url
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
