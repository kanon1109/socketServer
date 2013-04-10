package cn.geckos.net
{
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
/**
 * ...全局消息发送器 支持事件
 * @author Kanon
 */
public class Message extends EventDispatcher
{
	private var dictionary:Dictionary = new Dictionary();
	private static var instance:Message;
	public function Message(enforcer:SingletonEnforcer)
	{
	}
	
	public static function getInstance():Message
	{
		if (!Message.instance)
			Message.instance = new Message(new SingletonEnforcer());
		return Message.instance;
	}
	
	/**
	 * 注册消息
	 * @param	message 消息名
	 * @param	callback
	 */
	public function addMsgListener(message:String, callback:Function):void
	{
		if (message && !this.dictionary[message] && callback is Function)
			this.dictionary[message] = callback;
	}
	
	/**
	 * 执行消息
	 * @param	message		消息名
	 * @param	reset		任意数量参数
	 */
	public function execute(message:*, ...reset):void
	{
		if (this.dictionary && this.dictionary[message] is Function)
			var fun:Function = this.dictionary[message] as Function;
			fun.apply(null, reset);
	}
	
	/**
	 * 注销消息
	 * @param	message 消息名
	 */
	public function removeMsgListener(message:*):void
	{
		if (message && message != "")
		{
			this.dictionary[message] = null;
			delete this.dictionary[message];
		}
	}
	
	/**
	 * 销毁
	 */
	public function destory():void
	{
		this.dictionary = null;
	}
}
}

class SingletonEnforcer { }