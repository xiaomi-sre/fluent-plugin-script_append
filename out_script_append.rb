class Fluent::ScriptAppendOutput < Fluent::Output

  config_param :add_key,         :string, :default => nil
  config_param :lookup_key,      :string, :default => nil
  config_param :language,        :string, :default => 'shell'
  config_param :run_script,      :string, :default => nil
  config_param :tag,             :string, :default => nil

  SUPPORTED_SCRIPT_NAME = %w(sh shell)

  def configure(conf)
    super
    ensure_param_set!(:add_key, @add_key)
    ensure_param_set!(:lookup_key, @lookup_key)
    ensure_param_set!(:run_script, @run_script)
    ensure_param_set!(":tag", @tag)

    @script_runner = Object.new

    unless SUPPORTED_SCRIPT_NAME.include? @language
      warn "Plugin out_script_append would not accept 'language' value other than 'shell'. Ignoring."
      @language = 'shell'
    end
  end

  def emit(tag, event_stream, chain)
    event_stream.each do |time, record|
      rewrited_tag = get_tag(tag)
      record[@add_key] = `#{@run_script} #{record[@lookup_key]}`
      Fluent::Engine.emit(rewrited_tag, time, record)
    end
    chain.next
  end

  private
  def get_tag(tag)
    if @tag
      @tag
    end
  end

  def ensure_param_set!(name, value)
    unless value
      raise Fluent::ConfigError, "#{name} must be set"
    end
  end

  Fluent::Plugin.register_output('script_append', self)
end
