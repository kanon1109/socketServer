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
	//服务端消息的长度
	private var dataLength:int;
	//消息头部为4个字节 因为消息头存放的是消息的长度是int型为4个字节
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
			trace("bytesAvailable", this.socket.bytesAvailable);
																		//||-----bytesAvailable-----||
			//如果未读头字节，如果缓冲区的长度大于头字节则获取内容的长度。||---头---||-----内容-----||;
			if (this.dataLength == 0 && this.socket.bytesAvailable >= this.headLength)
				this.dataLength = this.socket.readInt(); //读出头信息里面包含了 内容长度
				
			trace("this.dataLength", this.dataLength);
			trace("this.socket.bytesAvailable", this.socket.bytesAvailable);
			
			//头字节读取完毕，并且缓冲区里的数据满足条件
			if (this.dataLength > 0 && this.socket.bytesAvailable >= this.dataLength)
			{
				//将socket中的字节流读出到bytes
				var bytes:ByteArray = new ByteArray();
				this.socket.readBytes(bytes, 0, this.dataLength);
				//长度归零
				this.dataLength = 0;
				//获取数据
				Net.getData(bytes);
				//如果数据流缓冲去的长度还是大于头长度，说明还是有数据在缓冲区内没被读取，继续读取数据。
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