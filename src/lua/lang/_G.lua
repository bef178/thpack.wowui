-- I believe wow vanilla is on lua 5.0
if _G == nil and getglobal then
    setglobal("_G", getfenv(0))
end

if _G.select == nil then
    _G.select = function(n, ...)
        if n == "#" then
            return table.getn(arg)
        end

        n = tonumber(n)
        if not n then
            error("InvalidArgumentException")
        end

        if n <= 0 then
            error("IndexOutOfBoundsException")
        end

        for i = 1, n - 1 do
            table.remove(arg, 1)
        end
        return unpack(arg)
    end
end
