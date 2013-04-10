package cn.geckos.net 
{
	import flash.utils.ByteArray;
/**
 * ...socket消息发送器
 * @author ...
 */
public class Net 
{
	//socket服务器
	private static var socketServer:SocketServer;
	public static function init(socketServer:SocketServer):void
	{
		Net.socketServer = socketServer;
	}
	
	/**
	 * 获取socket数据 并根据相应的协议执行注册的方法。
	 * @param	bytes   socket内数据的字节数组
	 */
	public static function getData(bytes:ByteArray):void
	{
		trace("收到", "长度=" + bytes.length, "可读=" + bytes.bytesAvailable);
		//读取协议号
		var id:int = bytes.readInt();
		trace("bytes.length", bytes.length, bytes.bytesAvailable);
		trace("id", id);
		var params:Object = { };
		switch(id)
		{
			case 1:
				params.str = bytes.readUTFBytes(bytes.bytesAvailable);
				//readUTF writeUTF 会带2位长度的。
				//head:一个16为的整数表示之后字符串的字节数。
				//body:字符串的字节流. (这里的汉字用3个字节表示)。
				trace("params.str", params.str);
				break;
			case 2:
				break;
		}
		//Message.getInstance().execute(id, params);
	}
	
	/**
	 * 发送消息
	 * @param	actionName   业务大类
	 * @param	type		 大类中的具体业务类型
	 * @param	...reset     需要传给服务端的参数
	 */
	public static function send(actionName:int, type:int, ...reset):void
	{
		var bytes:ByteArray = new ByteArray();
		bytes.writeByte(actionName);
		bytes.writeByte(type);
		if (params)
		{
			for each(var params:* in reset) 
			{
				if (params is int)
					bytes.writeInt(int(params));
				else if (params is String)
					bytes.writeUTF(String(params));
			}		
		}
		Net.socketServer.send(bytes);
	}
}
}