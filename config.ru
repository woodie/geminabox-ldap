require 'rubygems'
require 'geminabox'
require 'net-ldap'
require 'ostruct'

VIRTUAL_HOST = ENV['VIRTUAL_HOST'] || 'rubygems.example.com'
HEADER_IMAGE = ENV['HEADER_IMAGE'] || 'http://bit.ly/2lJIYsJ'
# http://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/
DEFAULT_LDAP = {attribute:'uid', base:'DC=example,DC=com', host:'ldap.forumsys.com'}

Geminabox.views = 'views'
Geminabox.data = 'data'

Geminabox::Server.helpers do
  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && member(*@auth.credentials)
  end

  def ldap_config
    @ldap ||= OpenStruct.new DEFAULT_LDAP.merge(Hash[ENV.keys.map { |k| [k[5..-1].downcase, ENV[k]] if k[0..4] == 'LDAP_' }.compact])
  end

  def container_id
    hash = `hostname`.strip
    hash.each_byte.map { |b| b.to_s(16) }.join[0..11] if hash.size > 12
  end

  def member(user, pass)
    return true if pass.eql?(container_id) unless ENV['BACKDOOR'].nil?
    return false if user.empty? or pass.empty?
    config = ldap_config
    # should also support bind_dn and bind_pw
    bind_dn = (config.attribute == 'sAMAccountname') ?
        "#{user}@#{config.base.gsub(/\w+=/,'').split(',')[-2..-1].join('.')}" :
        ["#{config.attribute}=#{user}", config.branch, config.base].compact.join(',')
    ldap = Net::LDAP.new config
    ldap.auth(bind_dn, pass)
    return false unless ldap.bind
    return true if config.member.nil?
    f = Net::LDAP::Filter.join(
        Net::LDAP::Filter.eq(config.attribute, user),
        Net::LDAP::Filter.eq('objectClass', 'user') |
        Net::LDAP::Filter.eq('objectClass', 'person') |
        Net::LDAP::Filter.eq('objectClass', 'inetOrgPerson') |
        Net::LDAP::Filter.eq('objectClass', 'organizationalPerson'))
    person = ldap.search(filter: f, attributes: %w(dn memberOf)).first
    f = Net::LDAP::Filter.join(
        Net::LDAP::Filter.eq(*config.member.split('=')),
        Net::LDAP::Filter.eq('objectClass', 'group') |
        Net::LDAP::Filter.eq('objectClass', 'groupOfNames') |
        Net::LDAP::Filter.eq('objectClass', 'groupOfUniqueNames') |
        Net::LDAP::Filter.eq('objectClass', 'organizationalUnit'))
    group = ldap.search(filter: f, attributes: %w(dn member uniqueMember)).first
    return true if person.respond_to?(:memberOf) && person.memberOf.include?(group.dn)
    return true if group.respond_to?(:member) && group.member.include?(person.dn)
    return true if group.respond_to?(:uniqueMember) && group.uniqueMember.include?(person.dn)
    return false
  end

  def is_protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Geminabox")
      halt 401, "No pushing or deleting without auth.\n"
    end
  end
end

class Geminabox::Server
  get '/faq' do
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @conf = OpenStruct.new( member: ldap_config.member, port: request.port,
        user: @auth.provided? ? @auth.credentials.first : 'username',
        host: @auth.provided? ? container_id : 'container_id' )
    erb :faq
  end
end

Geminabox::Server.before '/upload' do
  is_protected!
end

Geminabox::Server.before do
  is_protected! if request.delete?
end

Geminabox::Server.before '/api/v1/gems' do
  unless env['HTTP_AUTHORIZATION'] == 'API_KEY'
    halt 401, "Access Denied. Api_key invalid or missing.\n"
  end
end

run Geminabox::Server
