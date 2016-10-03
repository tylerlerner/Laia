laia = {}
laia.log = require('laia.log')
laia.log.loglevel = 'warn'

-- Require with graceful warning, for optional modules
function wrequire(name)
  local ok, m = pcall(require, name)
  if not ok then
    laia.log.warn(string.format('Optional lua module %q was not found!', name))
  end
  return m or nil
end

-- Mandatory torch packages
torch = require('torch')
nn = require('nn')
-- TODO(jpuigcerver): This package should be optional!
cutorch = require('cutorch')

local term = require('term')
laia.stdout_isatty = term.isatty(io.stdout)
laia.stderr_isatty = term.isatty(io.stderr)

-- Optional packages, show a warning if they are not found.
-- TODO(jpuigcerver): These are actually mandatory modules for the current
-- standard model generated by create_model.lua.
cunn = wrequire('cunn')
cudnn = wrequire('cudnn')

-- Laia packages
require('laia.utilities')
require('laia.CachedBatcher')
require('laia.RandomBatcher')
require('laia.ImageDistorter')
require('laia.MDRNN')
require('laia.Monitor')
require('laia.NCHW2HND')

function laia.manualSeed(seed)
  torch.manualSeed(seed)
  if cutorch then cutorch.manualSeed(seed) end
end

function laia.getRNGState()
  local state = {}
  state.torch = torch.getRNGState()
  if cutorch then state.cutorch = cutorch.getRNGState() end
  return state
end

function laia.setRNGState(state)
  if state.torch then
    torch.setRNGState(state.torch)
  else
    laia.log.error('No torch RNG state found!')
  end
  if cutorch then
    if state.cutorch then
      cutorch.setRNGState(state.cutorch)
    else
      laia.log.error('No cutorch RNG state found!')
    end
  end
end

return laia
