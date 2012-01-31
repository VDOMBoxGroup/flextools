package net.vdombox.ide.common.model.messages
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import net.vdombox.ide.common.MessageTypes;
	
	public class ErrorProxyMessage extends Message
	{
		public function ErrorProxyMessage( proxy : String, operation : String, target : String, body : Object = null )
		{
			_proxy = proxy;
			_operation = operation;
			_target = target;
			
			super( MessageTypes.ERROR_PROXY_MESSAGE, proxy, body );
		}
		
		protected var _proxy : String;
		
		protected var _operation : String;
		
		protected var _target : String;
		
		protected var _errorCode : String;
		
		protected var _errorString : String;
		
		protected var _errorDetail : String;
		
		public function setErrorDescription( errorCode : String, errorString : String, errorDetail : String ) : void
		{
			_errorCode = errorCode;
			
			_errorString = errorString;
			
			_errorDetail = errorDetail;
		}
		
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
		
		public function get errorCode() : String
		{
			return _errorCode;
		}
		
		public function get errorString() : String
		{
			return _errorString;
		}
		
		public function get errorDetail() : String
		{
			return _errorDetail;			
		}
	}
}