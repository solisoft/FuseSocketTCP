# TCP Socket for FuseTools / UNO

This project is a port of Uno.Net.Socket to Javascript.

## How to use it

Copy the socket.uno into your project then in your view.

````
var Socket = require('MySocket');
Socket.connect("127.0.0.1", "8888");
Socket.onError = function(message) {
  // Do something
}
Socket.onConnected = function(message) {
  // Do something
}
Socket.onDisconnected = function(message) {
  // Do something
}
Socket.onMessageReceived = function(message) {
  // Do something
}
````
