class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest

 validates :name,  presence: true, length: { maximum: 50 }
 VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
 validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
 

 has_secure_password
 validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

 has_many :microposts, dependent: :destroy
 
    class << self
    # Returns the hash digest of the given string.
  	 def digest(string)
   		 cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    	 BCrypt::Password.create(string, cost: cost)
  	 end

    # Returns a random token.
      def new_token
        SecureRandom.urlsafe_base64
      end
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
      self.remember_token = User.new_token
      update_attribute(:remember_digest, User.digest(remember_token))
    end
    # return true if the given token matches with the digest
    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token) # return False if in Database have the ****_digest tuong ung voi ID user
    end

    #forget the user
    def forget
      update_attribute(:remember_digest, nil)
    end

    def activate
      #update on database

      update_columns(activated: true, activated_at: Time.zone.now)  #thay the update_attribute methods
      
    end

    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end


    def create_reset_digest
      self.reset_token = User.new_token
      update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
      
    end

    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end  
    
    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end

    def feed
      Micropost.where("user_id = ?", id)
    end




      private
    # Converts email to all lower-case.
        def downcase_email
          self.email = email.downcase
        end

        # Creates and assigns the activation token and digest.
        def create_activation_digest
          self.activation_token  = User.new_token
          self.activation_digest = User.digest(activation_token)
        end


end
