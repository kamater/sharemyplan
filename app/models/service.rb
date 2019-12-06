class Service < ApplicationRecord
  CATEGORIES = {

    "musique" => "fas fa-music",
    "vosd" => "far fa-play-circle",
    "ecommerce" => "fas fa-shopping-cart",
    "jeuvideo" => "fas fa-gamepad",
    "cloud" => "fas fa-cloud-upload-alt",
    "presse" => "fas fa-book",
    "logiciel" => "fab fa-chrome",
    "x" => "fas fa-toilet-paper"
  }

  has_many :subscriptions, dependent: :destroy
  validates :name, presence: true
  validates :description, presence: true
  validates :number_of_places, presence: true
  validates :total_price, presence: true
  validates :category, inclusion: CATEGORIES.keys
end

