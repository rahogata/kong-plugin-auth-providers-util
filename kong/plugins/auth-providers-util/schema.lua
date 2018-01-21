local utils = require "kong.tools.utils"

local function check_user(anonymous)
  if anonymous == "" or utils.is_valid_uuid(anonymous) then
    return true
  end

  return false, "the anonymous user must be empty or a valid uuid"
end

return {
    no_consumer = true,
    fields = {
      provider_plugin = { required = false, type = "string", enum = { "AUTH_PLUGIN" }, default = "AUTH_PLUGIN" }
    }
}