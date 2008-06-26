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
		public static var SET_APLICATION_OK				:String = "Set application info OK"; 	//4
		public static var LIST_APLICATION_OK 			:String = "List applications OK"; 		//5
		public static var LIST_TYPES_OK 				:String = "List types OK"; 				//6
		public static var GET_TYPE_OK 					:String = "Get type OK"; 				//7
		public static var GET_RESOURCE_OK 				:String = "Get resource OK"; 			//8
		public static var RENDER_WYSIWYG_OK 			:String = "Render wysiwyg OK"; 			//9
		public static var CREATE_OBJECT_OK 				:String = "Create object OK"; 			//10
		public static var GET_TOP_OBJECTS_OK 			:String = "Get top objects OK" 			//11
		public static var GET_CHILD_OBJECTS_OK 			:String = "String Get child objects OK"; 		//12
		public static var GET_APPLICATION_LANGUAGE_DATA_OK :String = "Get application language data OK"; //13
		public static var SET_ATTRIBUTE_OK 				:String = "Set attribute OK"; 			//14
		public static var SET_VALUE_OK 					:String = "Set value OK"; 				//15
		public static var SET_SCRIPT_OK					:String =  "Set Script OK" 				//16
		public static var SET_RESOURCE_OK 				:String = "Set resource OK"; 			//17
		public static var DELETE_OBJECT_OK 				:String = "Delete object OK"; 			//18
		public static var GET_ECHO_OK					:String =  "Get echo OK"; 				//19
		public static var UNZIP_OK						:String =  "Unzip OK";
		public static var GET_ALL_TYPES_OK				:String =  "getAllTypesOK"; 				//20
		public static var SET_ATTRIBUTE_S_OK			:String =  "setAttributesOK"; 				//21
	
		public static var SET_NAME_OK					:String =  "setNameOK"; 					//22
		public static var WHOLE_CREATE_OK				:String =  "wholeCreateOK"; 					//23
		public static var WHOLE_DELETE_OK				:String =  "wholeDeleteOK"; 					//24
		public static var WHOLE_UPDATE_OK				:String =  "wholeUpdateOK"; 					//25
		public static var WHOLE_CREATE_PAGE_OK			:String =  "wholeCreatePageOK"; 				//26
		public static var GET_CHILD_OBJECTS_TREE_OK		:String =  "Get child objects tree OK";
		public static var GET_APPLICATION_STRUCTURE_OK	:String =  "GetApplicationStructureOK";
		public static var SET_APPLICATION_STRUCTURE_OK	:String =  "SetApplicationStructureOK";
		public static var SUBMIT_OBJECT_SCRIPT_PRESENTATION_OK 	:String =  "SubmitObjectScriptPresentationOK";
		public static var GET_OBJECT_SCRIPT_PRESENTATION_OK  	:String =  "GetObjectScriptPresentationOK";
		public static var GET_ONE_OBJECT_OK			  	:String =  "SGetOneObjectOK"; 
		public static var LIST_RESOURSES_OK			  	:String =  "ListResourseOK"; 
		public static var MODIFY_RESOURSE_OK  			:String =  "modifyResourceOK"; 
		public static var GET_SCRIPT_OK					:String =  "Get Script OK" 	
		
		public static var GET_APPLICATION_EVENTS_OK 	:String = "getApplicationEventsOK";
		public static var SET_APPLICATION_EVENTS_OK 	:String = "setApplicationEventsOK";
		
		//setAttributes
		
		public static var LOGIN_ERROR						:String = "Login ERROR";
		public static var OPEN_SESSION_ERROR				:String = "Open session ERROR"; 			//1
		public static var CLOSE_SESSION_ERROR				:String = "Close session ERROR"; 			//2
		public static var CREATE_APPLICATION_ERROR 			:String = "Create Application ERROR"; 		//3
		public static var SET_APLICATION_ERROR				:String = "Set application info ERROR"; 	//4
		public static var LIST_APLICATION_ERROR 			:String = "List applications ERROR"; 		//5
		public static var LIST_TYPES_ERROR					:String = "List types ERROR"; 				//6
		public static var GET_TYPE_ERROR 					:String = "Get type ERROR"; 				//7
		public static var GET_RESOURCE_ERROR 				:String = "Get resource ERROR"; 			//8
		public static var RENDER_WYSIWYG_ERROR 				:String = "Render wysiwyg ERROR"; 				//9
		public static var CREATE_OBJECT_ERROR 				:String = "Create object ERROR"; 			//10
		public static var GET_TOP_OBJECTS_ERROR 			:String = "Get top objects ERROR" 			//11
		public static var GET_CHILD_OBJECTS_ERROR 			:String = "String Get child objects ERROR"; 		//12
		public static var GET_APPLICATION_LANGUAGE_DATA_ERROR :String = "Get application language data ERROR"; //13
		public static var SET_ATTRIBUTE_ERROR 				:String = "Set attribute ERROR"; 			//14
		public static var SET_VALUE_ERROR					:String = "Set value ERROR"; 				//15
		public static var SET_SCRIPT_ERROR					:String =  "Set Script ERROR" 				//16
		public static var SET_RESOURCE_ERROR 				:String = "Set resource ERROR"; 			//17
		public static var DELETE_OBJECT_ERROR 				:String = "Delete object ERROR"; 			//18
		public static var GET_ECHO_ERROR					:String =  "Get echo ERROR"; 				//19
		public static var UNZIP_ERROR						:String =  "Unzip ERROR";
		public static var GET_ALL_TYPES_ERROR				:String =  "getAllTypesERROR"; 				//20
		public static var SET_ATTRIBUTE_S_ERROR				:String =  "setAttributesERROR"; 			//21
		
		public static var SET_NAME_ERROR					:String =  "setNameERROR"; 					//22
		public static var WHOLE_CREATE_ERROR				:String =  "wholeCreateERROR"; 				//23
		public static var WHOLE_DELETE_ERROR				:String =  "wholeDeleteERROR"; 				//24
		public static var WHOLE_UPDATE_ERROR				:String =  "wholeUpdateERROR"; 				//25
		public static var WHOLE_CREATE_PAGE_ERROR			:String =  "wholeCreatePageERROR"; 			//26
		public static var GET_CHILD_OBJECTS_TREE_ERROR		:String =  "Get child objects tree ERROR";
		public static var GET_APPLICATION_STRUCTURE_ERROR			:String =  "GetApplicationStructureERROR";
		public static var SET_APPLICATION_STRUCTURE_ERROR			:String =  "SetApplicationStructureERROR";
		public static var SUBMIT_OBJECT_SCRIPT_PRESENTATION_ERROR 	:String =  "SubmitObjectScriptPresentationERROR";
		public static var GET_OBJECT_SCRIPT_PRESENTATION_ERROR  	:String =  "GetObjectScriptPresentationERROR";
		public static var GET_ONE_OBJECT_ERROR			  	:String =  "SGetOneObjectERROR";
		public static var LIST_RESOURSES_ERROR		  		:String =  "ListResourseERROR"; 
		public static var MODIFY_RESOURSE_ERROR 			:String =  "modifyResourceERROR"; 
		public static var GET_SCRIPT_ERROR					:String =  "Get Script ERROR" 	
		
		public static var GET_APPLICATION_EVENTS_ERROR :String = "getApplicationEventsERROR";
		public static var SET_APPLICATION_EVENTS_ERROR :String = "setApplicationEventsERROR"; 
		
		public function SoapEvent(type:String, 
									result:XML = null, bubbles:Boolean = false,
								 	cancelable:Boolean = true)
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