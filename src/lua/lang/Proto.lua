Proto = (function()
    local Proto = {}

    function Proto.getProto(self)
        local meta = getmetatable(self)
        return meta and meta.__index
    end

    function Proto.setProto(self, super)
        return setmetatable(self, {
            __index = super
        })
    end

    -- ctor(o) as user-defined constructor
    -- client would call :new() to create instance
    function Proto.newProto(super, ctor)
        local proto = {}
        Proto.setProto(proto, super)
        proto.__new = ctor

        function proto:new(...)
            local o = {}
            Proto.setProto(o, self)

            local q = {}
            local p = Proto.getProto(o)
            while p do
                table.insert(q, p)
                p = Proto.getProto(p)
            end
            while table.getn(q) > 0 do
                p = table.remove(q)
                local fn = rawget(p, "__new")
                if type(fn) == "function" then
                    fn(o, unpack(arg))
                end
            end

            return o
        end

        return proto
    end

    return Proto
end)()
