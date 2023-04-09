-- Generative AI technology to predict and suggests your next lines of code.
return function()
  require('cmp_tabnine.config'):setup {
    max_line = 1000,
    max_num_results = 20,
    sort = true,
  }
end
