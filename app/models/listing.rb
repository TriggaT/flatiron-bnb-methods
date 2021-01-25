class Listing < ActiveRecord::Base
  belongs_to :neighborhood
  belongs_to :host, :class_name => "User"
  has_many :reservations
  has_many :reviews, :through => :reservations
  has_many :guests, :class_name => "User", :through => :reservations

  validates :address, :listing_type, :title, :description, :price, :neighborhood_id, presence: true 
  after_save :create_host
  before_destroy :remove_host

  def average_review_rating
    arr = []
    self.reviews.map do |review|
      arr << review.rating 
    end 
    arr.inject(0.0) { |sum, el| sum + el } / arr.size


  end 

  private 

  def self.available(start_date, end_date)
    if start_date && end_date
      joins(:reservations).
      where.not(reservations: {checkin: start_date..end_date}) &
      joins(:reservations).
      where.not(reservations: {checkout: start_date..end_date})
    else
      []
    end
  end


  def create_host
    unless host.host?
      host.update(host: true)
    end 

     
  end 

  def remove_host 
    if  Listing.where(host: host).where.not(id: id).empty?
      host.update(host: false)
    end 
  end 
    
  
  
end
