-- loading spinner & lsp status
return function()
  require('fidget').setup {
    window = { blend = 0 },
    sources = {
      ['null-ls'] = { ignore = true },
    },
    text = {

      ---@type LoadingSpinner
      spinner = 'dots_ellipsis',
    },
  }
end

---animation shown when tasks are ongoing
--- - See: https://github.com/j-hui/fidget.nvim/blob/main/lua/fidget/spinners.lua
--- This alias created with https://github.com/j-hui/fidget.nvim/blob/main/doc/fidget.md#spinners
---@alias LoadingSpinner
---|'dots_negative'
---|'dots_snake'
---|'dots_footsteps'
---|'dots_hop'
---|'line'
---|'pipe'
---|'dots_ellipsis'
---|'dots_scrolling'
---|'star'
---|'flip'
---|'hamburger'
---|'grow_vertical'
---|'grow_horizontal'
---|'noise'
---|'dots_bounce'
---|'triangle'
---|'arc'
---|'circle'
---|'square_corners'
---|'circle_quarters'
---|'circle_halves'
---|'dots_toggle'
---|'box_toggle'
---|'arrow'
---|'zip'
---|'bouncing_bar'
---|'bouncing_ball'
---|'clock'
---|'earth'
---|'moon'
---|'dots_pulse'
---|'meter'
