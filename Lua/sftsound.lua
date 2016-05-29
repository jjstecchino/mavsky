--
--  Author: Scott Simpson
--
-- 	This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.  
--    
--  Version 2.1.17.6
-- 
local ArmedModeWavFile = {}
local FlightModeWavFile = {}
local MessageSeverityWavFile = {}
local HdopWavFile = {}

local goodHdopThreshold = 2.5
local fairHdopThreshold = 5
local poorHdopThreshold = 99

local function init()
  ArmedModeWavFile[1]="darmed.wav"          -- armed value 0 - disarmed
  ArmedModeWavFile[2]="armed.wav"           -- armed value 1 - disarmed

  FlightModeWavFile[1]="stblz.wav"          -- flight mode 0 - Stabilize
  FlightModeWavFile[2]="acro.wav"           -- flight mode 1 - Acro
  FlightModeWavFile[3]="althld.wav"         -- flight mode 2 - Alt Hold
  FlightModeWavFile[4]="auto.wav"           -- flight mode 3 - Auto
  FlightModeWavFile[5]="gidd.wav"           -- flight mode 4 - Guided
  FlightModeWavFile[6]="loitr.wav"          -- flight mode 5 - Loiter
  FlightModeWavFile[7]="rtl.wav"            -- flight mode 6 - RTL
  FlightModeWavFile[8]="crcl.wav"           -- flight mode 7 - Circle
  FlightModeWavFile[9]="invldmd.wav"        -- flight mode 8 - Invalid Mode
  FlightModeWavFile[10]="landing.wav"       -- flight mode 9 - Land
  FlightModeWavFile[11]="optltr.wav"        -- flight mode 10 - Optical Loiter
  FlightModeWavFile[12]="drft.wav"          -- flight mode 11 - Drift
  FlightModeWavFile[13]="invldmd.wav"       -- flight mode 12 - Invalid Mode
  FlightModeWavFile[14]="sprt.wav"          -- flight mode 13 - Sport
  FlightModeWavFile[15]="flip.wav"          -- flight mode 14 - Flip
  FlightModeWavFile[16]="auttn.wav"         -- flight mode 15 - Autotune
  FlightModeWavFile[17]="poshld.wav"        -- flight mode 16 - Position Hold

  MessageSeverityWavFile[1]="emrgncyl.wav"  -- 0 - emergency - System is unusable. This is a "panic" condition
  MessageSeverityWavFile[2]=""              -- 1 - alert 	  - Action should be taken immediately. Indicates error in non-critical systems
  MessageSeverityWavFile[3]="crtcll.wav"    -- 2 - crititcal - Action must be taken immediately. Indicates failure in a primary system
  MessageSeverityWavFile[4]="errorl.wav"    -- 3 - error     - Indicates an error in secondary/redundant systems
  MessageSeverityWavFile[5]="warngl.wav"    -- 4 - warning   - Indicates an warning in secondary/redundant systems
  MessageSeverityWavFile[6]="noticel.wav"   -- 5 - notice    - An unusual event has occured, though not an error condition. This should be investigated for the root cause
  MessageSeverityWavFile[7]="info.wav"      -- 6 - info      - Normal operational messages. Useful for logging. No action is required for these messages
  MessageSeverityWavFile[8]="debug.wav"     -- 7 - debug     - Useful non-operational messages that can assist in debugging. These should not occur during normal operation

  HdopWavFile[1]="gpsgdl.wav"               -- good hdop - between 0.1 and 2.5
  HdopWavFile[2]="gpsfrl.wav"               -- fair hdop between 2.6 and 5
  HdopWavFile[3]="gpsprl.wav"               -- poor hdop between 5.1 and 98.9
  HdopWavFile[4]="gpsnfx.wav"               -- no GPS fix
  
end

-------------------------------------------------------------------------------------------------------------------------------------    

local function printGlobalVariable(col, row, label, gv)
  local val = model.getGlobalVariable(gv, 0)
  local x = (col - 1) * 106
  local y = row * 7 - 6
  lcd.drawText(x, y, label, SMLSIZE)
  if val ~= nil then
    lcd.drawText(x + 70, y, val, SMLSIZE)
  end
end

local previousArmedValue = -1
local previousFlightModeValue = -1
local previousMessageSeverityValue = -1
local previousHdopIndex = -1

local function background() 
  local wavFilename
  
  if FlightMode[1] == nil then
    return
  end
  
  -- armed/disarmed
  local gvArmedValue = model.getGlobalVariable(gvArmed, 0)
  if gvArmedValue >= 0 and gvArmedValue <= 1 and previousArmedValue ~= gvArmedValue then
    wavFilename = ArmedModeWavFile[gvArmedValue + 1]
    if wavFilename ~= "" then
      playFile(wavFilename)
    end
  end
  previousArmedValue = gvArmedValue
  
  -- flight mode
  local gvFlightModeValue = model.getGlobalVariable(gvFlightMode, 0)
  if gvFlightModeValue >= 0 and gvFlightModeValue <= 16 and previousFlightModeValue ~= gvFlightModeValue then
    wavFilename = FlightModeWavFile[gvFlightModeValue + 1]
    if wavFilename ~= "" then
      playFile(wavFilename)
    end
  end
  previousFlightModeValue = gvFlightModeValue
  
  -- severity
  local gvMessageSeverityValue = model.getGlobalVariable(gvMessageSeverity, 0)
  if gvMessageSeverityValue >= 0 and gvMessageSeverityValue <= 7 and previousMessageSeverityValue ~= gvMessageSeverityValue then
    wavFilename = MessageSeverityWavFile[gvMessageSeverityValue + 1]
    if wavFilename ~= "" then
      playFile(wavFilename)
    end
  end
  previousMessageSeverityValue = gvMessageSeverityValue
  
  -- hdop
  local gvHdopValue = model.getGlobalVariable(gvHdop, 0) / 10
  local hdopIndex 
  if gvHdopValue >= 0.1 and gvHdopValue <= goodHdopThreshold then
    hdopIndex = 1
  elseif gvHdopValue > goodHdopThreshold and gvHdopValue <= fairHdopThreshold then
    hdopIndex = 2
  elseif gvHdopValue > fairHdopThreshold and gvHdopValue <= poorHdopThreshold then
    hdopIndex = 3
  else
    hdopIndex = 4
  end
  if hdopIndex ~= previousHdopIndex then  
    wavFilename = HdopWavFile[hdopIndex] 
    if wavFilename ~= "" then
      playFile(wavFilename)
    end
  end
    previousHdopIndex = hdopIndex
end

local function run(event)
	lcd.clear()
  lcd.drawFilledRectangle(0, 0, 212, 9, 0)
  lcd.drawText(1, 1, "Sound Controller Diagnostics", INVERS)   

  if FlightMode[1] == nil then
    lcd.drawText(0, 8, "Please add sfthud1 to a screen using model telemetry setting page", INVERS)   
    return
  end
  
	printGlobalVariable(1, 2, "armed", gvArmed)
	printGlobalVariable(1, 3, "flight Mode", gvFlightMode)
	printGlobalVariable(1, 4, "severity", gvMessageSeverity)
	printGlobalVariable(1, 5, "hdop", gvHdop)
	printGlobalVariable(1, 6, "sequence", gvSequence)
end

return {init=init, run=run, background=background}