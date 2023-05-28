local M = {}
setmetatable(M, {
  __call = function(self, ...)
    M.log(...)
  end
})


function M.log(...)
  print("-------------------------------------------------")
  print(...)
  print("-------------------------------------------------")
end


function M.block(...)
  print("-------------------------------------------------")
  for i = 1, #arg do
    print(arg[i])
  end
  print("-------------------------------------------------")
end


function M.log2(title, ...)
  print("------------------ "..title.." ------------------")
  for i = 1, #arg do
    print(arg[i])
  end
  print("-------------------------------------------------")
end


function M.title(title)
  print("------------------ "..title.." ------------------")
end


local dash = "-"
function M.line(n)
  local t = {}
  for i = 1, n or 52 do
    t[i] = dash
  end
  print(table.concat(t))
end


function M.logTime(title, todo)
  local start = system.getTimer()
  todo()
  local time = system.getTimer()-start

  M.log2(title, "Time: "..time)
end


return M