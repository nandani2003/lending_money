class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable   
  enum role: { admin: 0,customer: 1}
  has_many :lendings
  validates :wallet,numrically: {greater_than_or_equal_to}
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "encrypted_password", "id", "id_value", "name", "remember_created_at", "reset_password_sent_at",     "reset_password_token", "role", "updated_at", "wallet"]
  end
end
