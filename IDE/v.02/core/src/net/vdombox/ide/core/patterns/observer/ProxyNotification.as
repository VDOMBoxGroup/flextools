package net.vdombox.ide.core.patterns.observer
{
	import mx.rpc.AsyncToken;

	import org.puremvc.as3.multicore.patterns.observer.Notification;

	public class ProxyNotification extends Notification
	{
		public function ProxyNotification( name : String, body : Object = null, type : String = null )
		{
			super( name, body, type );
		}

		public var token : AsyncToken;

		public function get isAsync() : Boolean
		{
			return token ? true : false;
		}
	}
}