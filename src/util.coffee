sleep = (milliSeconds) ->
  startTime = new Date().getTime()
  loop
    break if new Date().getTime() > (startTime + milliSeconds)

exports.sleep = sleep

