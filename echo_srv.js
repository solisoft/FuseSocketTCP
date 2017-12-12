var net = require('net');

var HOST = '127.0.0.1';
var PORT = 8888;

function rand(i) {
  return parseInt((Math.random() * 10000) % i);
}

net.createServer(function(sock) {
    // We have a connection - a socket object is assigned to the connection automatically
    console.log('CONNECTED: ' + sock.remoteAddress +':'+ sock.remotePort);

    // Add a 'data' event handler to this instance of socket
    sock.on('data', function(data) {
      console.log('RCV Data : ' + sock.remoteAddress + ': ' + data.toString().trim());
      sock.write(data.toString().trim());
    });

    // Add a 'close' event handler to this instance of socket
    sock.on('close', function(data) {
      console.log('CLOSED:');
    });

}).listen(PORT, HOST);

console.log('Server listening on ' + HOST +':'+ PORT);