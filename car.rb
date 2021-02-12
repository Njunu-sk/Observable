require 'observer'

module Maintenance
  def self.included(base)
    base.class_eval do
      alias_method :original_initialize, :initialize
      def initialize(*args)
        MaintenaceReporter.new(self)
        original_initialize(*args)
      end
    end
  end

  MAINTENANCE = [].tap do |maintenance|
    maintenance << { miles: 5000, description: 'Rotate Tires'}
    maintenance << { miles: 15_000, description: 'Replace Brakes'}
  end

  RECURRING_MAINTENANCE = [].tap do |maintenance|
    maintenance << { miles: 3000, description: 'Engine Oil Change'}
  end

  def maintenance_required(mileage)
    [one_time(mileage), recurring(mileage)].flatten
  end

  def maintenance_needed?(mileage)
    maintenance_required(mileage).any?
  end

  def one_time(mileage)
    MAINTENANCE.select do |m|
      @odometer < m[:miles] && mileage > m[:miles]
    end
  end

  def recurring(mileage)
    RECURRING_MAINTENANCE.select do |m|
      (@odometer / m[:miles]).to_i < (mileage / m[:miles]).to_i
    end
  end
end

class Car
  include Observable
  attr_reader :odometer

  def initialize(name, odometer = 0)
    @name = name
    @odometer = odometer
  end

  #maintenace module
  include Maintenance

  def report_mileage(mileage)
    changed
    notify_observers(mileage)
    @odometer = mileage
  end
end

class MaintenanceObserver
  def initialize(car)
    @car = car
    @car.add_observer(self)
  end
end

class MaintenaceReporter < MaintenanceObserver
  def update(mileage)
    return unless @car.maintenance_needed?(mileage)
    @car.maintenance_required(mileage).each do |maintenance|
      puts "Mileage: #{mileage} Service Required: #{maintenance[:description]}"
    end
  end
end

car = Car.new('Honda', 2000)
car.report_mileage(2500)
car.report_mileage(3500)
car.report_mileage(6500)
car.report_mileage(16500)