local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"
local putils = require "kong.plugins.auth-providers-util.utils"

local AuthProvidersUtil = BasePlugin:extend()

local string_match = string.match

local MESSAGE = "message"

function AuthProvidersUtil:new()
  AuthProvidersUtil.super.new(self, "auth-providers-util")
end

function AuthProvidersUtil:access(conf)
  AuthProvidersUtil.super.access(self)
  if ngx.req.get_method() == "GET" then
    local uri = ngx.var.uri
    local from, _ = string_match(uri, "/oauth2/authorize[%s/]*$", nil, true)
    if from then
      local plugins, err = singletons.dao.plugins:find_all({ api_id = ngx.ctx.api.id })
      if err then
        responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
      end
      
      local providers
      for _, p in ipairs(plugins) do
        if p.config.plugin_type == conf.provider_plugin then
          providers = putils.list_merge(providers, putils.get_providers(p.config.provider_type))
        end
      end
      return responses.send(200, providers)
    end
  end
end

AuthProvidersUtil.PRIORITY = 1005
AuthProvidersUtil.VERSION = "0.1.0"

return AuthProvidersUtil
