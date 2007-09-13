package vdom.events
{
import flash.events.Event;

public class ProxyEvent extends Event
{
	public static const PROXY_COMPLETE:String = 'proxyComplete';
	
	public static const PROXY_ERROR:String = 'proxyError';
	
	public var xml:XML;
	
	public function ProxyEvent(type:String, xml:String='', bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
		
		this.xml = XML(xml);
	}
}
}