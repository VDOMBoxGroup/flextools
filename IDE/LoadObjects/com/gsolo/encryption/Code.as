package com.gsolo.encryption
{
	public class Code 
	{
		import com.gsolo.encryption.VDOM_session_protector;
//		import com.gsolo.encryption.protector;
		
		private var protector:VDOM_session_protector;
		private var key:String;
		private var counter:int = -1;
		
		//initialization
		public function Code(hstr:String):void{
			trace('hesh:' + hstr)
			protector = new VDOM_session_protector(hstr);
		}
		
		// input First key
		public function inputSKey(str:String):void{
			key = str;
			trace('first key: ' + key)
		}
		
		// generation next key
		public function skey():String{
			
			
			key = protector.nextSessionKey(key);
			counter++;
			trace('key: ' + key)
			return key+'_'+counter.toString();
		}
		
		// count amount of calls
		public function count():String{
			return counter.toString();
		}
		
		
	}
}