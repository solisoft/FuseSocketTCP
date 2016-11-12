using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno.Net.Sockets;
using Uno.Text;
using Uno.Threading;

[UXGlobalModule]
public class MySocket : NativeModule
{
    static readonly MySocket _instance;
    public delegate void ShowValue();
    NativeEvent _nativeEvent;
    NativeEvent _nativeEventConnected;
    NativeEvent _nativeEventDisconnected;
    NativeEvent _nativeEventError;
    Socket socket;

    public MySocket()
    {
        // Make sure we're only initializing the module once
        if(_instance != null) return;
        _instance = this;
        Resource.SetGlobalKey(_instance, "MySocket");
        
        AddMember(new NativeFunction("connect", (NativeCallback)Connect));
        AddMember(new NativeFunction("send", (NativeCallback)Send));       
        
        _nativeEvent = new NativeEvent("onMessageReceived");
        _nativeEventConnected = new NativeEvent("onConnected");
        _nativeEventDisconnected = new NativeEvent("onDisconnected");
        _nativeEventError = new NativeEvent("onError");
        
        AddMember(_nativeEvent);
        AddMember(_nativeEventConnected);
        AddMember(_nativeEventDisconnected);
        AddMember(_nativeEventError);
    }

    // Send
    // Launched via Javascript 
    string Send(Context c, object[] args)
    {
        var message = args[0] as string;
        try {
          socket.Send(Ascii.GetBytes(message));
        } catch(SocketException e) {
          _nativeEventError.RaiseAsync(e.Message.ToString());
        }
        return "";
    }

    // Connect
    // Launched via Javascript
    string Connect(Context c, object[] args)
    {
        socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);       
        var address = args[0] as string;
        int port = int.Parse(args[1] as string);
        try {
          socket.Connect(address, port);
          _nativeEventConnected.RaiseAsync("Connected");
          var t = Thread.Create(Read);
          t.Start();
        } catch(SocketException e) {
          _nativeEventError.RaiseAsync(e.Message.ToString());
        }
        return "";
    }
    
    // Read
    // Loop on socket.Receive
    void Read()
    {
        // socket.Connected seems to always be true 
        // even if server is killed
        var loop = true;
        while(loop) {           
          try {
            byte[] read = new byte[1024];
            var r = socket.Receive(read, 0, read.Length, SocketFlags.None);
            if(r == 0) loop = false;
            _nativeEvent.RaiseAsync(Ascii.GetString(read));
          } catch(SocketException e) {
            _nativeEventError.RaiseAsync(e.Message.ToString());
          }
        }
        _nativeEventDisconnected.RaiseAsync("Disconnected");
    }
    
}