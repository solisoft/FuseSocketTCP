# TCP Socket for FuseTools / UNO

This project is a port of Uno.Net.Socket to Javascript.

## Requirements

Fuse >= 0.32

## How to use it

I provide a little echo server `node echo_srv.js` which run a TCP echo server on 127.0.0.1:8888

Copy the socket.uno into your project then in your view.

Add "Uno.Net.Sockets" to your .unoproj Pacakages.


````
var Socket = require('MySocket');
Socket.connect("127.0.0.1", "8888");
Socket.on("onError", function(message) {
  // Do something
})

Socket.on("onConnected", function(message) {
  // Do something
})

Socket.on("onDisconnected", function(message) {
  // Do something
})

Socket.on("onMessageReceived", function(message) {
  // Do something
})
````

