package PowerPack.com
{
	import PowerPack.com.managers.LanguageManager;
	
	import mx.utils.StringUtil;
	
	public class BasicError extends Error
	{
        public static const FATAL:int = 0;
        public static const WARNING:int = 1;
        protected static var messages:XML;
        public var severity:int;
        public var details:String;
        public var target:Object;
        		
		public function BasicError(message:String="", id:int=0, words:Array=null)
		{
			var _words:Array = []; 
			var _words2:Array = []; 
			
			if(words) {
				_words = words.concat();
				_words2 = words.concat();				
			}
			
			super(message, id);	
			
			_words.unshift(message);
			this.message = (StringUtil.substitute as Function).apply(null, _words); 
			
			var msg:String = getMessageText(id);
			
			if(msg)
			{
				details = message;		
				_words2.unshift(msg);
				this.message = (StringUtil.substitute as Function).apply(null, _words2); 
			}
		}
		
        public function getMessageText(id:int):String 
        {
        	if(!messages)
        		return null;
        		
            var messages:XMLList = messages.error.(@code == id);
            
            if(messages.length()==0)
            	return null;
            	            
			var xml:XML = messages[0];          
            var retVal:String = null;//LanguageManager.sentences[xml.@ID];
            
            return (retVal ? retVal : xml.text());
        }
        
        public function getTitle():String {
        	if(message)
        		return LanguageManager.sentences.error+": "+message;
        		
            return LanguageManager.sentences.error+" #"+errorID;
        }
        
        public function toString():String {
            return "["+String(LanguageManager.sentences.error).toUpperCase()+" #"+errorID+"] "+message+ 
            	(details ? "\n"+LanguageManager.sentences.details+": "+details : "");
        }		
	}
}