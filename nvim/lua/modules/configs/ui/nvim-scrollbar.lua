return function()
  require('scrollbar').setup {
    handle = {
      color = '#808080', ---@type '#008080'|'#808080'
    },
  }
  require('scrollbar.handlers.search').setup()
end
