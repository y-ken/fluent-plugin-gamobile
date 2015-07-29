class Fluent::GamobileOutput < Fluent::Output
  Fluent::Plugin.register_output('gamobile', self)

  config_param :ga_account, :string
  config_param :development, :string, :default => 'no'
  config_param :set_var, :string, :default => nil
  config_param :map_dl, :string, :default => 'domain'
  config_param :fix_dl, :string, :default => nil
  config_param :map_remoteaddr, :string, :default => 'host'
  config_param :fix_path, :string, :default => nil
  config_param :map_referer, :string, :default => 'referer'
  config_param :map_cd1, :string, :default => 'cd1'
  config_param :map_cd2, :string, :default => 'cd2'
  config_param :map_useragent, :string, :default => 'agent'
  config_param :map_guid, :string, :default => 'guid'
  config_param :map_acceptlang, :string, :default => 'lang'
  config_param :unique_ident_key, :string, :default => ''

  def initialize
    super
    require 'net/http'
    require 'active_support'
    require 'active_support/core_ext'
    Net::HTTP.version_1_2
  end

  def configure(conf)
    super
    @development = Fluent::Config.bool_value(@development) || false
    @unique_ident_key = @unique_ident_key.split(',')
    $log.info "gamobile treats unique identifer key with #{@unique_ident_key}"
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      report(record)
    end

    chain.next
  end

  def set_record(record)
    @record = record
  end

  def get_record(key)
    return @record[key] unless @record[key].blank?
  end

  def get_remote_address
    if get_record(@map_remoteaddr) =~ /^([^.]+\.[^.]+\.[^.]+\.).*/
      return "#{$1}0"
    else
      return ''
    end
  end

  def get_visitor_id
    if !@unique_ident_key.blank?
      message = "#{@ga_account}"
      @unique_ident_key.map {|key| message.concat("#{get_record(key)}")}
    elsif get_record(@map_guid).blank?
      message = "#{get_record(@map_useragent)}#{Digest::SHA1.hexdigest(rand.to_s)}#{Time.now.to_i}"
    else
      message = "#{get_record(@map_guid)}#{@ga_account}"
    end
    md5string = Digest::MD5.hexdigest(message)
    return "0x#{md5string[0,16]}"
  end

  def get_utmv
     user_var = get_record(@set_var).gsub(';','%3B')
     return ERB::Util.u("+__utmv=999#{user_var};") unless user_var.blank?
  end

  def get_dl
     if fix_dl then
       return ERB::Util.u(fix_dl)
     else
       return ERB::Util.u(get_record(@map_dl))
     end
  end

  def build_query
    utm_gif_location = 'http://www.google-analytics.com/r/collect'
    queries = Array.new
    queries << "v=1"
    queries << "t=pageview"
    queries << "dl=#{get_dl}"
    queries << "dr=#{ERB::Util.u(get_record(@map_referer))}"
    queries << "tid=#{@ga_account}"
    queries << "ua=#{get_utmv}"
    queries << "cid=#{get_visitor_id}"
    queries << "cd1=#{ERB::Util.u(get_record(@map_cd1))}"
    queries << "cd2=#{ERB::Util.u(get_record(@map_cd2))}"
    $log.info "gamobile building query: #{queries}" if @development
    return URI.parse(utm_gif_location + '?' + queries.join('&'))
  end

  def report(record)
    set_record(record)
    begin
      uri = build_query
      $log.info "gamobile sending report: #{uri.to_s}" if @development
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.get(uri.request_uri, {
          "User-Agent" => get_record(@map_useragent).to_s,
          "Accepts-Language" => get_record(@map_acceptlang).to_s
        })
      end
    rescue => e
      $log.error("gamobile Error: #{e.message}")
    end
  end
end
