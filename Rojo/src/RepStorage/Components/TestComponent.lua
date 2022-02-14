-- Test component

local module = {}

function module.create(object)
    local componentObj1 = Instance.new("TextBox", object)
    componentObj1.Text = "Hello from TestComponent!"
end

return module