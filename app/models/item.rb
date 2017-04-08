class Item < ActiveRecord::Base
  validates :name, presence: true, length: { minimum: 1, maximum: 40 }
  validates :tariff, presence: true
  validates :itype, presence: true, length: { minimum: 1, maximum: 40 }
end