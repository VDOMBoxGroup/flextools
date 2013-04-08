/*
 * Provide protect when connetion to server
 */
package net.vdombox.ide.core.model.business.protect
{

	public class Code
	{
		public function Code()
		{
			if ( instance )
				throw new Error( "Singleton and can only be accessed through Code.getInstance(hstr:String)" );
		}

		private static var instance : Code;

		public static function getInstance() : Code
		{
			return instance || ( instance = new Code() );
		}

		public var sessionId : String;

		private var counter : int = -1;

		private var protector : VDOMSessionProtector;

		private var key : String;

		public function initialize( hashString : String, sessionKey : String ) : void
		{
			counter = -1;
			protector = new VDOMSessionProtector( hashString );
			key = sessionKey;
		}

		public function get nextSessionKey() : String
		{
			key = protector.nextSessionKey( key );
			counter++;

			return key + "_" + counter.toString();
		}
	}
}
