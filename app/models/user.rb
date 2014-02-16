require 'bcrypt'
require 'gibberish'
require 'json'
require 'zlib'
require 'base64'

class User < ActiveRecord::Base
  before_save :update_user
  after_create :store_uindex
  
  @password_updated=false
  @dcrypted=false
  
  def password_updated=(yesno)
    @password_updated=yesno
  end
  
  def store_uindex
    dcrypt_user
    u541t = GlobalKey.find_by_key('u541t')[:val]
    @nu_gid = Uindex.crypt_id("--#{u541t[1,6]}#{u541t[11,17]}--",self.id.to_s)
    Uindex.create(
      uid: do_hash_user[:uid],
      xid: Uindex.crypt_id("--#{self.salt[1,5]}#{self.salt[10,17]}--",self.id.to_s),
      gid: @nu_gid
    )
  end
  
  def self.authenticate(login,password)
    user=User.find_by_login(Gibberish::SHA256(login)) rescue false
    if user
      user.dcrypt_user
      user_hash=user.do_hash_user
      user_hash=reset_tries(user_hash) if ((user_hash[:tries].to_i > 2) && (Time.now > (DateTime.parse(user_hash[:last_try])+60.minutes)))
      if !user[:active]
        {:result=>false,:error=>"#{I18n.t 'user_destroyed_error'}"}
      elsif user_hash[:tries].to_i < 3
        if authenticated?(user_hash,password,user.salt)
          user_hash=reset_tries(user_hash)
          user[:user]=JSON.generate(user_hash)
          user.save
          {:result=>true,:user=>user}
        else
          user_hash[:tries]=(user_hash[:tries].nil?) ? 0 : user_hash[:tries].to_i + 1
          user_hash[:last_try]=Time.now
          user[:user]=JSON.generate(user_hash)
          user.save
          {:result=>false,:error=>"#{I18n.t 'user_login_error'}"}
        end
      else
        {:result=>false,:error=>"#{I18n.t 'too_many_tries'}"}
      end
    else
      {:result=>false,:error=>"#{I18n.t 'user_login_error'}"}
    end
  end
  
  def self.reset_tries(user_hash)
    user_hash.tap { |hs| hs.delete(:tries) }
    user_hash.tap { |hs| hs.delete(:last_try) }
    user_hash
  end
  
  def self.authenticated?(user_hash,password,salt)
    BCrypt::Password.new(user_hash[:pass]) == dosalt(password, salt)
  end
  
  def dosalt(s, salt)
    self.class.dosalt(s, salt)
  end
  
  def do_hash_user
    JSON.parse(self.user).deep_symbolize_keys!
  end
  
  def dcrypt_user
    cipher = Gibberish::AES.new("--#{self.salt[6,8]}#{self.login}#{self.salt[16,18]}--")
    self.user=cipher.dec(Zlib::Inflate.inflate(Base64.decode64 self.user)) if !@dcrypted
    @dcrypted=true
  end
  
  #TODO Remove this once it becomes useless
  def dzip_user
    self.user=Zlib::Inflate.inflate(Base64.decode64 self.user)
  end
  
  protected
  
  def crypt_login
    self.login=Gibberish::SHA256(self.login) rescue nil
  end
  
  def gen_salt
    if self.salt.nil?
      self.salt=Gibberish::SHA256("--salt-#{self.login}-salt--")
    end
  end
  
  def crypt_password
    user_hash=do_hash_user
    user_hash[:pass] = encrypt_pass(user_hash[:pass])
    self.user=JSON.generate(user_hash)
  end
  
  def self.dosalt(s, salt)
    "--#{salt[0,4]}#{salt[9,16]}--#{s}--"
  end
  def encrypt_pass(password)
    password = dosalt(password, self.salt)
    BCrypt::Password.create(password)
  end
  
  def update_user
    if new_record?
      crypt_login
      gen_salt
      @dcrypted=true
    end
    if @password_updated || new_record?
      crypt_password
    end
    crypt_user
  end
  
  def crypt_user
    cipher = Gibberish::AES.new("--#{self.salt[6,8]}#{self.login}#{self.salt[16,18]}--")
    self.user=Base64.encode64 Zlib::Deflate.deflate(cipher.enc(self.user)) if @dcrypted
    @dcrypted=false
    true
  end
end
