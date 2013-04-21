package cn.geckos.net 
{
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.Timer;
/**
 * ...socket通信类
 * @author ...Kanon
 */
public class SocketServer 
{
	//套接字
	private var socket:Socket;
	//服务器地址
	private var host:String;
	//服务器端口
	private var port:int;
	//重链计时器
	private var reconnentTimer:Timer;
	//重链秒数
	private var reconnentDelay:int = 15;
	//包体的长度
	private var bodyLength:int;
	//包头固定的长度
	private var headLength:int = 4;
	public function SocketServer(host:String, port:int) 
	{
		this.host = host;
		this.port = port;
		this.initSocket();
	}
	
	/**
	 * 初始化套接字
	 */
	private function initSocket():void
	{
		if (this.socket) return;
		this.socket = new Socket(this.host, this.port);
		//链接成功
		this.socket.addEventListener(Event.CONNECT, connectHandler);
		//关闭连接
		this.socket.addEventListener(Event.CLOSE, closeHandler);
		//安全策略问题
		this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		//当错误导致输入或输出操作失败时调度
		this.socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		//在套接字接收到数据后调度
		this.socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	}
	
	/**
	 * 向服务端发送一条消息
	 * @param	bytes   消息内容二进制
	 */
	public function send(bytes:ByteArray):void
	{
		if (this.isConnected())
		{
			var dataBytes:ByteArray = new ByteArray();
			//先写入长度
			dataBytes.writeInt(bytes.length);
			//再写入内容
			dataBytes.writeBytes(bytes);
			this.socket.writeBytes(dataBytes);
			this.socket.flush();
		}
	}
	
	/**
	 * 链接服务器
	 */
	public function connect():void
	{
		if (!this.isConnected())
			this.socket.connect(this.host, this.port);
	}
	
	/**
	 * 断开
	 */
	public function close():void
	{
		if (this.isConnected())
			this.socket.close();
	}
	
	/**
	 * 重链接
	 */
	private function reconnect():void
	{
		this.close();
		this.createReconnectTimer();
	}
	
	/**
	 * 创建重链计时器
	 */
	private function createReconnectTimer():void
	{
		this.removeReconnectTimer();
		//15秒尝试一次重链
		this.reconnentTimer = new Timer(this.reconnentDelay * 1000, 1);
		this.reconnentTimer.addEventListener(TimerEvent.TIMER_COMPLETE, reconnentTimerComplete);
		this.reconnentTimer.start();
	}
	
	private function reconnentTimerComplete(event:TimerEvent):void 
	{
		trace("开始重链")
		this.removeReconnectTimer();
		this.connect();
	}
	
	/**
	 * 销毁重链计时器
	 */
	private function removeReconnectTimer():void
	{
		if (this.reconnentTimer)
		{
			this.reconnentTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, reconnentTimerComplete);
			this.reconnentTimer.stop();
			this.reconnentTimer = null;
		}
	}
	
	//在套接字接收到数据后调度
	private function socketDataHandler(event:ProgressEvent):void 
	{
		this.getSocketData();
	}
	
	/**
	 * 获取数据
	 */
	private function getSocketData():void
	{
		if (this.isConnected())
		{		
																		//||-----bytesAvailable-----||
			//socket可读长度必须大于包头固定的长度					 	  ||---头---||-----内容-----||;
			if (this.bodyLength == 0 && this.socket.bytesAvailable >= this.headLength)
				this.bodyLength = this.socket.readInt(); //读出包头的内容，包头内容表示包体的长度
				
			//头字节读取完毕，并且缓冲区里的可读数据长度大于包体的长度
			if (this.bodyLength > 0 && this.socket.bytesAvailable >= this.bodyLength)
			{
				var bytes:ByteArray = new ByteArray();
				//根据包体的长度读出包体的内容。
				this.socket.readBytes(bytes, 0, this.bodyLength);
				//包体长度归零
				this.bodyLength = 0;
				//获取数据
				Net.getData(bytes);
				//过网络中的字节流没有界线的，每次到达的缓冲区的数据，
				//有可能不止一个数据包，因此需要继续执行。
				if (this.socket.bytesAvailable >= this.headLength)
					this.getSocketData();
			}
		}
	}
	
	//当错误导致输入或输出操作失败时调度
	private function ioErrorHandler(event:IOErrorEvent):void 
	{
		trace("网络错误");
		this.reconnect();
	}
	
	//安全策略问题
	private function securityErrorHandler(event:SecurityErrorEvent):void 
	{
		trace("security error");
	}
	
	//关闭连接
	private function closeHandler(event:Event):void 
	{
		trace("connect close");
	}
	
	//链接成功
	private function connectHandler(event:Event):void 
	{
		trace("connect success");
	}
	
	/**
	 * 是否连接
	 * @return
	 */
	private function isConnected():Boolean
	{
		if (this.socket && this.socket.connected)
			return true;
		return false;
	}
	
	/**
	 * 销毁套接字
	 */
	private function removeSocket():void
	{
		if (!this.socket) return;
		this.socket.removeEventListener(Event.CONNECT, connectHandler);
		this.socket.removeEventListener(Event.CLOSE, closeHandler);
		this.socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		this.socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		this.socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		this.socket = null;
	}
	
	/**
	 * 销毁
	 */
	public function destroy():void
	{
		this.close();
		this.removeSocket();
		this.removeReconnectTimer();
	}
}
}