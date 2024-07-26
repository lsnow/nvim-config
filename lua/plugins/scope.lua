----------------------------------------------------------------
-- tiagovla/scope.nvim
----------------------------------------------------------------

return {
  "tiagovla/scope.nvim",
  event = "VeryLazy",
  enabled = true,
  config = function()
    require("scope").setup({})
  end,
}
