override['ds_consul']['definitions']['chef-server'] = {
  type: 'service',
  parameters: {
    port: 80,
    tags: %w(chef-server),
    check: {
      interval: '10s',
      timeout: '5s',
      http: 'http://127.0.0.1/_status',
    },
  },
}

override['datadog']['tags']['service'] = 'chef-server'
