dispatcher '^/webrtc/echo', ->
  onSuccess = (stream) ->
    video = $("#livevideo")[0]
    video.src = webkitURL.createObjectURL(stream)
    video.play()

  onError = (error) ->
    console && console.log("Error: " + error.code)

  videoOpts =
    video: true
    audio: true

  navigator.webkitGetUserMedia videoOpts, onSuccess, onError
