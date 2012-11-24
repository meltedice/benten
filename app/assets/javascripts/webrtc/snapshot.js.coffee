dispatcher '^/webrtc/snapshot', ->
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

  $('#snapshot').on 'click', ->
    canvas = $('#snapshotCanvas')[0]
    video  = $('#livevideo')[0]
    context = canvas.getContext('2d')
    context.drawImage(video, 0, 0)

    img = new Image()
    img.src = canvas.toDataURL()
    $('#images').prepend img
