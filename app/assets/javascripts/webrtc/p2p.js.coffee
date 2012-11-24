dispatcher '^/webrtc/p2p', ->
  lvideo = $("#lvideo")[0]
  rvideo = $("#rvideo")[0]
  startLocalVideoButton    = $("#startLocalVideo")
  publishStreamURIButton   = $("#publishStreamURI")
  connectRemoteVideoButton = $("#connectRemoteVideo")
  endRemoteVideoButton     = $("#endRemoteVideo")
  localStreamURI  = $("#localStreamURI")
  remoteStreamURI = $("#remoteStreamURI")

  localStream = null
  lConnection = null
  rConnection = null

  startLocalVideoButton.attr('disabled', false)
  publishStreamURIButton.attr('disabled', true)
  connectRemoteVideoButton.attr('disabled', true)
  endRemoteVideoButton.attr('disabled', true)

  trace = (text) ->
    if text[text.length - 1] == '\n'
      text = text.substring(0, text.length - 1)
    console.log((performance.now() / 1000).toFixed(3) + ": " + text)

  initLocalStream = (stream) ->
    trace("Received local stream")
    lvideo.src = webkitURL.createObjectURL(stream)
    localStream = stream
    publishStreamURIButton.attr('disabled', false)

  initLocalStreamError = (error) ->
    trace("Init Local Stream Error: " + error.code)

  startLocalVideo = ->
    trace("Requesting local stream")
    startLocalVideoButton.attr('disabled', true)
    navigator.webkitGetUserMedia {audio:true, video:true}, initLocalStream, initLocalStreamError

  publishStreamURI = ->
    publishStreamURIButton.attr('disabled', true)
    connectRemoteVideoButton.attr('disabled', false)
    trace("Starting startRemoteVideo")

    lIceServers =
      iceServers: [{url:"stun:stun.l.google.com:19302"}]
    lConnection = new webkitRTCPeerConnection(lIceServers)
    trace("Created local peer connection object lConnection")
    lConnection.onicecandidate = onLIceCandidate
    lConnection.onaddstream = onLAddStream

    lConnection.addStream(localStream)
    trace("Adding Local Stream to peer connection")

    lConnection.createOffer(setLDescription)

  connectRemoteVideo = ->
    uri = localStreamURI.val()
    trace("connectRemoteVideo: uri: " + uri)
    rIceServers =
      iceServers: [{url: uri}]
    rConnection = new webkitRTCPeerConnection(rIceServers)
    trace("Created remote peer connection object rConnection")

    rConnection.onicecandidate = onRIceCandidate
    rConnection.onaddstream = onRAddStream

    # lConnection.createOffer(setLDescription)

  lDesc = null
  setLDescription = (desc) ->
    lConnection.setLocalDescription(desc)
    trace("Offer from lConnection \n" + desc.sdp)
    lDesc = desc
    # rConnection.setRemoteDescription(desc)
    # rConnection.createAnswer(setRDescription)

  setRDescription = (desc) ->
    rConnection.setRemoteDescription(lDesc)
    rConnection.createAnswer(setRDescription)

    rConnection.setLocalDescription(desc)
    trace("Answer from rConnection \n" + desc.sdp)
    lConnection.setRemoteDescription(desc)

  endRemoteVideo = ->
    trace("Ending call")
    lConnection.close() 
    rConnection.close()
    lConnection = null
    rConnection = null
    endRemoteVideoButton.attr('disabled', true)
    connectRemoteVideoButton.attr('disabled', false)

  onLAddStream = (e) ->
    uri = webkitURL.createObjectURL(e.stream)
    localStreamURI.val(uri)
    trace("Received local stream: " + uri)

  onRAddStream = (e) ->
    uri = webkitURL.createObjectURL(e.stream)
    rvideo.src = uri
    trace("Received remote stream: " + uri)

  lCandidate = null
  onLIceCandidate = (event) ->
    if (event.candidate)
      lCandidate = event.candidate
      # rConnection.addIceCandidate(new RTCIceCandidate(event.candidate))
      trace("Local ICE candidate: \n" + event.candidate.candidate)

  onRIceCandidate = (event) ->
    if event.candidate
      rConnection.addIceCandidate(new RTCIceCandidate(lCandidate))
      lConnection.addIceCandidate(new RTCIceCandidate(event.candidate))
      trace("Remote ICE candidate: \n " + event.candidate.candidate)

  startLocalVideoButton.on 'click', ->
    startLocalVideo()
  publishStreamURIButton.on 'click', ->
    publishStreamURI()
  connectRemoteVideoButton.on 'click', ->
    connectRemoteVideo()
  endRemoteVideoButton.on 'click', ->
    endRemoteVideo()
