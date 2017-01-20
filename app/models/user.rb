class User < ApplicationRecord
  has_merit

  after_save :keep_admin_exist
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  enum role: { editor: 0, admin: 99 }

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  validates :username, presence: true, uniqueness: { :case_sensitive => false }, length: { in: 3..255 }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end

  def self.find_for_oauth(auth)
    user = User.where(uid: auth.uid, provider: auth.provider).first

    unless user
      user = User.create(
        uid:      auth.uid,
        provider: auth.provider,
      )
    end

    user
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.password = Devise.friendly_token[0,20]
    end
  end

  def self.new_with_session(params, session)
    if session['devise.misoca_data']
      s = session['devise.misoca_data']
      new(provider: 'misoca', uid: s['uid'], email: s['info']['email']) do |user|
        user.attributes = params
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  private

  def keep_admin_exist
    self.admin! if User.admin.count == 0
  end
end
