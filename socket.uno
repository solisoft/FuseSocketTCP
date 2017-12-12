using Fuse;
using Fuse.Scripting;
using Fuse.Reactive.Resource;
using Uno.UX;
using Uno.Net.Sockets;
using Uno.Text;
using Uno.Threading;

[UXGlobalModule]
public class MySocket : NativeEventEmitterModule
{
    static readonly MySocket _instance;
    public delegate void ShowValue();
    Socket socket;
    public MySocket()
        : base(true, "onMessageReceived", "onConnected", "onDisconnected", "onError")
    {
        // Make sure we're only initializing the module once
        if(_instance != null) return;
        _instance = this;
        Uno.UX.Resource.SetGlobalKey(_instance, "MySocket");

        AddMember(new NativeFunction("connect", (NativeCallback)Connect));
        AddMember(new NativeFunction("disconnect", (NativeCallback)Disconnect));
        AddMember(new NativeFunction("send", (NativeCallback)Send));

    }

    // Send
    // Launched via Javascript
    string Send(Context c, object[] args)
    {
        var message = args[0] as string;
        try {
          socket.Send(Ascii.GetBytes(message));
        } catch(SocketException e) {
          Emit("onError", e.Message.ToString());
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
          Emit("onConnected", "Connected");
          var t = new Thread(Read);
          t.Start();
        } catch(SocketException e) {
          Emit("onError", e.Message.ToString());
        }
        return "";
    }

    // Disconnect
    // Close the socket
    string Disconnect(Context c, object[] args)
    {
        socket.Close();
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
            Emit("onMessageReceived", Ascii.GetString(read));
          } catch(SocketException e) {
            Emit("onError", e.Message.ToString());
          }
        }
        Emit("onDisconnected", "Disconnected");
    }

}