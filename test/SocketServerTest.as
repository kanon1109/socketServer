package  
{
import cn.geckos.net.Net;
import cn.geckos.net.SocketServer;
import flash.display.Sprite;

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
		Net.init(socketServer);
	}
	
}
}