package  
{
import cn.geckos.net.Message;
import cn.geckos.net.Net;
import cn.geckos.net.Protocols;
import cn.geckos.net.SocketServer;
import flash.display.Sprite;
import flash.events.Event;

/**
 * ...套接字测试
 * @author ...Kanon
 */
public class SocketServerTest extends Sprite 
{
	public function SocketServerTest() 
	{
		var socketServer:SocketServer = new SocketServer("127.0.0.1", 8000);
		socketServer.connect();
		Message.getInstance().addMsgListener(Protocols.LOGIN, loginHandler);
		Net.init(socketServer);
	}
	
	private function loginHandler(obj:Object):void 
	{
		trace("loginHandler", obj.str, obj.index, obj.index2);
		Net.send(3, 4, "akb", 110);
	}
	
}
}