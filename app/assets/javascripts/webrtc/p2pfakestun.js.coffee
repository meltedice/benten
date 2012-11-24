dispatcher '^/webrtc/p2pfakestun', ->
  lvideo = $("#lvideo")[0]
  rvideo = $("#rvideo")[0]
  startLocalVideoButton  = $("#startLocalVideo")
  startRemoteVideoButton = $("#startRemoteVideo")
  endRemoteVideoButton   = $("#endRemoteVideo")
  localStream = null
  lConnection = null
  rConnection = null

  startLocalVideoButton.attr('disabled', false)
  startRemoteVideoButton.attr('disabled', true)
  endRemoteVideoButton.attr('disabled', true)

  trace = (text) ->
    if text[text.length - 1] == '\n'
      text = text.substring(0, text.length - 1)
    console.log((performance.now() / 1000).toFixed(3) + ": " + text)

  initLocalStream = (stream) ->
    trace("Received local stream")
    lvideo.src = webkitURL.createObjectURL(stream)
    localStream = stream
    startRemoteVideoButton.attr('disabled', false)

  initLocalStreamError = (error) ->
    trace("Init Local Stream Error: " + error.code)

  startLocalVideo = ->
    trace("Requesting local stream")
    startLocalVideoButton.attr('disabled', true)
    navigator.webkitGetUserMedia {audio:true, video:true}, initLocalStream, initLocalStreamError

  startRemoteVideo = ->
    startRemoteVideoButton.attr('disabled', true)
    endRemoteVideoButton.attr('disabled', false)
    trace("Starting startRemoteVideo")
    if (localStream.videoTracks.length > 0)
      trace('Using Video device: ' + localStream.videoTracks[0].label)  
    if (localStream.audioTracks.length > 0)
      trace('Using Audio device: ' + localStream.audioTracks[0].label)

    lIceServers =
      iceServers: [{url:"stun:stun.l.google.com:19302"}]
    lConnection = new webkitRTCPeerConnection(lIceServers)
    trace("Created local peer connection object lConnection")
    lConnection.onicecandidate = onLIceCandidate

    rIceServers =
      iceServers: [{url:"stun:stun.l.google.com:19302"}]
    rConnection = new webkitRTCPeerConnection(rIceServers)
    trace("Created remote peer connection object rConnection")

    rConnection.onicecandidate = onRIceCandidate
    rConnection.onaddstream = onRAddStream

    lConnection.addStream(localStream)
    trace("Adding Local Stream to peer connection")

    lConnection.createOffer(setLDescription)

  setLDescription = (desc) ->
    lConnection.setLocalDescription(desc)
    trace("Offer from lConnection \n" + desc.sdp)
    rConnection.setRemoteDescription(desc)
    rConnection.createAnswer(setRDescription)

  setRDescription = (desc) ->
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
    startRemoteVideoButton.attr('disabled', false)

  onRAddStream = (e) ->
    rvideo.src = webkitURL.createObjectURL(e.stream)
    trace("Received remote stream")

  onLIceCandidate = (event) ->
    if (event.candidate)
      rConnection.addIceCandidate(new RTCIceCandidate(event.candidate))
      trace("Local ICE candidate: \n" + event.candidate.candidate)

  onRIceCandidate = (event) ->
    if event.candidate
      lConnection.addIceCandidate(new RTCIceCandidate(event.candidate))
      trace("Remote ICE candidate: \n " + event.candidate.candidate)

  startLocalVideoButton.on 'click', ->
    startLocalVideo()
  startRemoteVideoButton.on 'click', ->
    startRemoteVideo()
  endRemoteVideoButton.on 'click', ->
    endRemoteVideo()
