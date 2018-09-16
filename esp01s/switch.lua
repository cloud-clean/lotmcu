Switch={}

function Switch:on(pin)
    print(string.format("on  pin:%d",pin))
    gpio.mode(pin,gpio.OUTPUT)
    gpio.write(pin,gpio.HIGH)
    return 1
end

function Switch:off(pin)
    print(string.format("off  pin:%d",pin))
    gpio.mode(pin,gpio.OUTPUT)
    gpio.write(pin,gpio.LOW)
    return 0
end

function Switch:status(pin)
    return gpio.read(pin)
end