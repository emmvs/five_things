Datadog.configure do |c|
  c.service = 'five-things'
  c.env = Rails.env

  # Only enable tracing outside of test env
  c.tracing.enabled = !Rails.env.test?
  c.tracing.instrument :rails
  c.tracing.instrument :active_record
end
