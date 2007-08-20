package com.connection.protect
{
	public class Code 
	{
		import com.connection.protect.VDOM_session_protector;
//		import com.gsolo.encryption.protector;

		public var sessionId: String;
		
		private var protector:VDOM_session_protector;
		private var key:String;
		private var counter:int = -1;
		
		
		private static var instance:Code;
		
		
		public function Code() {
            if( instance ) throw new Error( "Singleton and can only be accessed through Code.getInstance(hstr:String)" );
         } 		
		 
		 // initialization		
		 public static function getInstance():Code {
             
             return instance || (instance = new Code()); ;
        }
		//initialization
		public function init(hstr:String):void{
		//	trace('hesh:' + hstr)
			protector = new VDOM_session_protector(hstr);
		}
		
		// input First key
		public function inputSKey(str:String):void{
			key = str;
		//	trace('first key: ' + key)
		}
		
		// generation next key
		public function skey():String{
			
			
			key = protector.nextSessionKey(key);
			counter++;
		//	trace('key: ' + key)
			return key+'_'+counter.toString();
		}
		
		// count amount of calls
		public function count():String{
			return counter.toString();
		}
		
		
	}
}