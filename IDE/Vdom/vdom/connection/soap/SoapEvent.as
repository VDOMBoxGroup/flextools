package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	
	public class SoapEvent extends Event
	{
		public static var LOGIN_OK						:String = "Login OK";
		public static var OPEN_SESSION_OK				:String = "Open session OK"; 			//1
		public static var CLOSE_SESSION_OK				:String = "Close session OK"; 			//2
		public static var CREATE_APPLICATION_OK 		:String = "Create Application OK"; 		//3
		public static var SET_APLICATION_OK				:String = "Set application info OK"; 		//4
		public static var LIST_APLICATION_OK 			:String = "List applications OK"; 		//5
		public static var LIST_TYPES_OK 				:String = "List types OK"; 				//6
		public static var GET_TYPE_OK 					:String = "Get type OK"; 				//7
		public static var GET_RESOURCE_OK 				:String = "Get resource OK"; 		//8
		public static var GET_APPLICATION_RESOURCE_OK 	:String = "Get application resource OK" 	//9
		public static var RENDER_WYSIWYG_OK 			:String = "Render wysiwyg OK"; 			//10
		public static var CREATE_OBJECT_OK 				:String = "Create object OK"; 			//11
		public static var GET_TOP_OBJECTS_OK 			:String = "Get top objects OK" 			//12
		public static var GET_CHILD_OBJECTS_OK 			:String = "String Get child objects OK"; 		//13
		public static var GET_APPLICATION_LANGUAGE_DATA_OK :String = "Get application language data OK"; //14
		public static var SET_ATTRIBUTE_OK 				:String = "Set attribute OK"; 			//15
		public static var SET_VALUE_OK 					:String = "Set value OK"; 				//16
		public static var SET_SCRIPT_OK					:String =  "Set Script OK" 				//17
		public static var SET_RESOURCE_OK 				:String = "Set resource OK"; 			//18
		public static var DELETE_OBJECT_OK 				:String = "Delete object OK"; 			//19
		public static var GET_ECHO_OK					:String =  "Get echo OK"; 				//20
		public static var UNZIP_OK						:String =  "Unzip OK";
		public static var GET_ALL_TYPES_OK				:String =  "getAllTypesOK"; 				//21
		public static var SET_ATTRIBUTE_S_OK			:String =  "setAttributesOK"; 				//22
		
		//setAttributes
		
		public static var LOGIN_ERROR						:String = "Login ERROR";
		public static var OPEN_SESSION_ERROR				:String = "Open session ERROR"; 			//1
		public static var CLOSE_SESSION_ERROR				:String = "Close session ERROR"; 			//2
		public static var CREATE_APPLICATION_ERROR 			:String = "Create Application ERROR"; 		//3
		public static var SET_APLICATION_ERROR				:String = "Set application info ERROR"; 		//4
		public static var LIST_APLICATION_ERROR 			:String = "List applications ERROR"; 		//5
		public static var LIST_TYPES_ERROR					:String = "List types ERROR"; 				//6
		public static var GET_TYPE_ERROR 					:String = "Get type ERROR"; 				//7
		public static var GET_RESOURCE_ERROR 				:String = "Get resource ERROR"; 		//8
		public static var GET_APPLICATION_RESOURCE_ERROR 	:String = "Get application resource ERROR" 	//9
		public static var RENDER_WYSIWYG_ERROR 			:String = "Render wysiwyg ERROR"; 			//10
		public static var CREATE_OBJECT_ERROR 				:String = "Create object ERROR"; 			//11
		public static var GET_TOP_OBJECTS_ERROR 			:String = "Get top objects ERROR" 			//12
		public static var GET_CHILD_OBJECTS_ERROR 			:String = "String Get child objects ERROR"; 		//13
		public static var GET_APPLICATION_LANGUAGE_DATA_ERROR :String = "Get application language data ERROR"; //14
		public static var SET_ATTRIBUTE_ERROR 				:String = "Set attribute ERROR"; 			//15
		public static var SET_VALUE_ERROR					:String = "Set value ERROR"; 				//16
		public static var SET_SCRIPT_ERROR					:String =  "Set Script ERROR" 				//17
		public static var SET_RESOURCE_ERROR 				:String = "Set resource ERROR"; 			//18
		public static var DELETE_OBJECT_ERROR 				:String = "Delete object ERROR"; 			//19
		public static var GET_ECHO_ERROR					:String =  "Get echo ERROR"; 				//20
		public static var UNZIP_ERROR						:String =  "Unzip ERROR";
		public static var GET_ALL_TYPES_ERROR				:String =  "getAllTypesERROR"; 				//21
		public static var SET_ATTRIBUTE_S_ERROR				:String =  "setAttributesERROR"; 				//22
		
		public function SoapEvent(type:String, 
									result:XML = null, bubbles:Boolean = false,
								 	cancelable:Boolean = true
								  )
		{
			super(type, bubbles, cancelable);
	
			this.result = result;
		}
		
		public var result:XML = new XML();
		
   		/* public  function dispatch(evt:Event):void {
        	dispatchEvent(evt);
       // 	trace(evt.toString())
    	} */
    	
    	
		private function completeListener():void{
		};
		
		public  function getResult():XML{
			return new XML;
		};

	}
}