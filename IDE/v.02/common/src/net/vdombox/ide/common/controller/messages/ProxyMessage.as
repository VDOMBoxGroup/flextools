package net.vdombox.ide.common.controller.messages
{
	import net.vdombox.ide.common.MessageTypes;

	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public class ProxyMessage extends Message
	{
		public const PROXY_MESSAGE : String = "proxyMessage";

		public function ProxyMessage( proxy : String, operation : String, target : String, body : Object = null )
		{
			_proxy = proxy;
			_operation = operation;
			_target = target;

			super( MessageTypes.PROXY_MESSAGE, proxy, body );
		}

		protected var _proxy : String;

		protected var _operation : String;

		protected var _target : String;

		public function get proxy() : String
		{
			return _proxy;
		}

		public function get operation() : String
		{
			return _operation;
		}

		public function get target() : String
		{
			return _target;
		}
	}
}
