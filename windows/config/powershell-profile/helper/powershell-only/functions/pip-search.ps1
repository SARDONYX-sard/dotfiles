if (Get-Command pip -ErrorAction SilentlyContinue)
{
  function pips()
  { pip_search $args
  };
}
