Car={}
Car['l1'] = 1
Car['l2'] = 2
Car['r1'] = 4
Car['r2'] = 3
Car['ll'] = 0
Car['rl'] = 0
RF_PIN = 5

local function run(input1,input2,side,level)
    print(string.format("input1:%d, input2:%d,level:%d",input1,input2,level))
	local ll = ''
    if(side == "left") then
        ll = 'll'
    else
        ll = 'rl'
    end        
	if(Car[ll] == 0) then
		--启动
		if(level == 0) then
			--do nothing
		elseif(level > 0) then
			pwm.setup(input1,500,level*255)
			gpio.mode(input2,gpio.OUTPUT)
			gpio.write(input2,gpio.LOW)
			pwm.start(input1)
		else
			pwm.setup(input2,500,-level*255)
			gpio.mode(input1,gpio.OUTPUT)
			gpio.write(input1,gpio.LOW)
			pwm.start(input2)
        end  
	else
		--变速
        if(Car[ll]*level > 0)then
        --同向
    		if(Car[ll] > 0) then
    			if(level == 0) then
    				pwm.close(input1)
    				gpio.mode(input1,gpio.OUTPUT)
    				gpio.write(input1,gpio.HIGH)
    				gpio.write(input2,gpio.HIGH)
    			else	
    			    pwm.setduty(input1,math.abs(level*255))
                end   
    		else
    			if(level == 0) then
    				pwm.close(input2)
    				gpio.mode(input2,gpio.OUTPUT)
    				gpio.write(input2,gpio.HIGH)
    				gpio.write(input1,gpio.HIGH)
    			else
    			    pwm.setduty(input2,math.abs(level*255))
                end   
    		end
         else
         --换向
            if(Car[ll] > 0)then
                --停止
                pwm.close(input1)
                gpio.mode(input1,gpio.OUTPUT)
                gpio.write(input1,gpio.HIGH)
                gpio.write(input2,gpio.HIGH)
                if(level ~= 0) then
                    pwm.setup(input2,500,math.abs(level*255))
                    gpio.write(input1,gpio.LOW)
                    pwm.start(input2)
                end
            else
                pwm.close(input2)
                gpio.mode(input2,gpio.OUTPUT)
                gpio.write(input2,gpio.HIGH)
                gpio.write(input1,gpio.HIGH)
                 if(level ~= 0) then
                    pwm.setup(input1,500,math.abs(level*255))
                    gpio.write(input2,gpio.LOW)
                    pwm.start(input1)
                end
            end
         end
	end
    Car[ll] = level
end	

local function leftRun(level)
	local input1 = Car['l1']
	local input2 = Car['l2']
	run(input1,input2,'left',level)
end

local function rightRun(level)
	local input1 = Car['r1']
	local input2 = Car['r2']
	run(input1,input2,'right',level)
end	

local function getLevel(side)
	return Car[side]
end

local function up(side)
    local levelSide = ""
    if(side == "left")then
        levelSide = 'll'
        local level = getLevel(levelSide)
        if(level >0 and level < 4) then
            level = level+1
            leftRun(level)  
        end      
    else
        levelSide = 'rl'  
        local level = getLevel(levelSide)
        if(level >0 and level < 4) then
            level = level+1
            rightRun(level)
        end    
    end
end


local function down(side)
    local levelSide = ""
    if(side == "left")then
        levelSide = 'll'
        local level = getLevel(levelSide)
        if(level >0 and level <= 4) then
            level = level-1
            leftRun(level)  
        end      
    else
        levelSide = 'rl'  
        local level = getLevel(levelSide)
        if(level >0 and level <= 4) then
            level = level-1
            rightRun(level)
        end    
    end
end

function reverse()
    print("开始避开")
    gpio.trig(RF_PIN)
    tmr.alarm(RF_PIN,3000,tmr.ALARM_SINGLE,function()
        gpio.trig(RF_PIN,'down',reverse)
        end)
    local ll = Car['ll']
    local rl = Car['rl']
    leftRun(0)
    rightRun(0)
    leftRun(ll*(-1))
    rightRun(rl*(-1))
end
    

function Car:start()
    leftRun(0)
    rightRun(0)
	leftRun(-2)
	rightRun(-2)
end

function Car:stop()
	leftRun(0)
	rightRun(0)
end

function Car:back()
    leftRun(0)
    rightRun(0)
    leftRun(2)
    rightRun(2)
end

function Car:getStatus()
    print("left status %d right status: %d",Car['ls'],Car['rs'])
    print("left level %d right level:%d",Car['ll'],Car['rl'])
end

function Car:left()
--    down('left')
--    up('right')
    leftRun(-3)
    rightRun(3)
end

function Car:right()
--    up('left')
--    down('right')
    rightRun(-3)
    leftRun(3)
end

function Car:listen()
    gpio.mode(RF_PIN,gpio.INT)
    gpio.trig(RF_PIN,'down',reverse)
end




    
    


