require 'observer'

class Restock
  include Observable
  attr_reader :quantity

  def run
    product = Product.fetch(@quantity)

    if product.zero?
      changed
      notify_observers(Time.now, product)
    end
  end
end

class Product
  def self.fetch(quantity)
    rand(0..5)
  end
end

class Outofstock
  def initialize(restock)
    restock.add_observer(self)
  end
end

class Notification < Outofstock
  def update(time, product)
    if product.zero?
      print "----#{time.to_s}: Product is out of stock!! \n"
    end
  end
end

restock = Restock.new
Notification.new(restock)
restock.run
