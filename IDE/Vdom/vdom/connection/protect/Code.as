/* 
* Provide protect when connetion to server 
*/
package vdom.connection.protect
{
	public class Code 
	{
		
//		import com.gsolo.encryption.protector;

		public var sessionId: String;
		
		private var protector:VDOM_session_protector;
		private var key:String;
		private var counter:int = -1;
		
		
		private static var instance:Code;
		
		
		/**
		 * this is impossible, because it is singleton
		 * 
		 * @return 
		 * 
		 */
		public function Code() {
            if( instance ) throw new Error( "Singleton and can only be accessed through Code.getInstance(hstr:String)" );
         } 		
		 
		  		
		 
		 /**
		  *  class initialization.
		  * 
		  * @return instanse of this class
		  * 
		  */
		 public static function getInstance():Code {
             
             return instance || (instance = new Code()); ;
        }

		/**
		 * protect initialization
		 *  
		 * @param hstr - hesh
		 * 
		 */
		public function init(hstr:String):void{
		//	trace('hesh:' + hstr)
			counter = -1;
			protector = new VDOM_session_protector(hstr);
		}
		
		
		/**
		 * input First key
		 * 
		 * @param str
		 * 
		 */
		public function inputSKey(str:String):void{
			key = str;
		}
		
		/**
		 * generation next key
		 * 
		 * @return necessary key 
		 * 
		 */
		public function skey():String{
			key = protector.nextSessionKey(key);
			counter++;
			return key+'_'+counter.toString();
		}
	}
}