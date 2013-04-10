package 
{
import cn.geckos.net.Message;
import flash.display.Sprite;
import flash.events.Event;
/**
 * ...消息测试
 * @author 
 */
public class MessageTest extends Sprite 
{
	public static const TEST1:String = "test1";
	public static const TEST2:String = "test2";
	public function MessageTest() 
	{
		Message.getInstance().addMsgListener(MessageTest.TEST1, test1Listener);
		Message.getInstance().addMsgListener(MessageTest.TEST2, test2Listener);
		//Message.getInstance().removeMsgListener(MessageTest.TEST2);
		var o:Object = { "as":1 };
		Message.getInstance().execute(MessageTest.TEST1)
		o = { "as":2 };
		Message.getInstance().execute(MessageTest.TEST2, o, "12", "3");
	}
	
	private function test2Listener(o:Object, s1:String, s2:String):void  
	{
		trace("is test2Listener", o, s1, s2);
	}
	
	private function test1Listener():void 
	{
		trace("is test1Listener");
	}
	
}
}