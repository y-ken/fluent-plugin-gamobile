class Fluent::GamobileOutput < Fluent::Output
  Fluent::Plugin.register_output('gamobile', self)

  config_param :ga_account, :string
  config_param :development, :string, :default => 'no'
  config_param :set_var, :string, :default => nil
  config_param :map_domain, :string, :default => 'domain'
  config_param :map_remoteaddr, :string, :default => 'host'
  config_param :map_path, :string, :default => 'path'
  config_param :map_referer, :string, :default => 'referer'
  config_param :map_useragent, :string, :default => 'agent'
  config_param :map_guid, :string, :default => 'guid'
  config_param :map_acceptlang, :string, :default => 'lang'
  config_param :unique_ident_key, :string, :default => ''

  def initialize
    super
    require 'net/http'
    require 'active_support/core_ext'
    Net::HTTP.version_1_2
  end

  def configure(conf)
    super
    @ga_account = @ga_account.gsub('UA-', 'MO-') if @ga_account.include?('UA-')
    @development = Fluent::Config.bool_value(@development) || false
    @unique_ident_key = @unique_ident_key.split(',')
    $log.info "gamobile: unique key with #{@unique_ident_key}"
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
    if !@unique_ident_key.empty?
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
     return ERB::Util.u("+__utmv=999#{get_record(@set_var)};") unless get_record(@set_var).blank?
  end

  def build_query
    utm_gif_location = 'http://www.google-analytics.com/__utm.gif'
    queries = Array.new
    queries << "utmwv=4.4sh"
    queries << "utmn=#{rand(1000000*1000000)}"
    queries << "utmhn=#{ERB::Util.u(get_record(@map_domain))}"
    queries << "utmr=#{ERB::Util.u(get_record(@map_referer))}"
    queries << "utmp=#{ERB::Util.u(get_record(@map_path))}"
    queries << "utmac=#{@ga_account}"
    queries << "utmcc=__utma%3D999.999.999.999.999.1%3B#{get_utmv}"
    queries << "utmvid=#{get_visitor_id}"
    queries << "utmip=#{get_remote_address}"
    return URI.parse(utm_gif_location + '?' + queries.join('&'))
  end

  def report(record)
    set_record(record)
    begin
      uri = build_query
      $log.info "gamobile sending report: #{uri.to_s}" if @development
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.get(uri.request_uri, {
          "user_agent" => get_record(@map_useragent).to_s,
          "Accepts-Language" => get_record(@map_acceptlang).to_s
        })
      end
    rescue => e
      $log.error("gamobile Error: #{e.message}")
    end
  end
end
