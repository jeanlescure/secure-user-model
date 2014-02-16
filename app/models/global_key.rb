require 'securerandom'
require 'gibberish'

class GlobalKey < ActiveRecord::Base
  def self.doGlobal
    guid = find_by_key('guid')
    create({:key => 'guid',:val => SecureRandom.uuid}) if !guid
    guid = find_by_key('guid') unless guid
    
    u541t = find_by_key('u541t')
    create({:key => 'u541t',:val => Gibberish::SHA256("--user-#{guid}-user--")}) if !u541t
  end
end
