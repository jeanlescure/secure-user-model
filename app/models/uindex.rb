require 'gibberish'

class Uindex < ActiveRecord::Base
  def self.crypt_id(key,id)
    cipher = Gibberish::AES.new(key)
    cipher.enc(id).squish
  end
  
  def dcrypt_xid(key)
    Uindex.dcrypt_xid(key,xid)
  end
  
  def self.dcrypt_xid(key,xid)
    cipher = Gibberish::AES.new("--#{key[1,5]}#{key[10,17]}--")
    cipher.dec(xid)
  end
  
  def dcrypt_gid(key)
    Uindex.dcrypt_gid(key,gid)
  end
  
  def self.dcrypt_gid(key,gid)
    cipher = Gibberish::AES.new("--#{key[1,6]}#{key[11,17]}--")
    cipher.dec(gid)
  end
end
