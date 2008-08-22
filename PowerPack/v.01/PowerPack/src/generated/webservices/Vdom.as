
/**
 * VdomService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
 /**
  * Usage example: to use this service from within your Flex application you have two choices:
  * Use it via Actionscript only
  * Use it via MXML tags
  * Actionscript sample code:
  * Step 1: create an instance of the service; pass it the LCDS destination string if any
  * var myService:Vdom= new Vdom();
  * Step 2: for the desired operation add a result handler (a function that you have already defined previously)  
  * myService.addget_echoEventListener(myResultHandlingFunction);
  * Step 3: Call the operation as a method on the service. Pass the right values as arguments:
  * myService.get_echo(mysid);
  *
  * MXML sample code:
  * First you need to map the package where the files were generated to a namespace, usually on the <mx:Application> tag, 
  * like this: xmlns:srv="generated.webservices.*"
  * Define the service and within its tags set the request wrapper for the desired operation
  * <srv:Vdom id="myService">
  *   <srv:get_echo_request_var>
  *		<srv:Get_echo_request sid=myValue/>
  *   </srv:get_echo_request_var>
  * </srv:Vdom>
  * Then call the operation for which you have set the request wrapper value above, like this:
  * <mx:Button id="myButton" label="Call operation" click="myService.get_echo_send()" />
  */
 package generated.webservices{
	import mx.rpc.AsyncToken;
	import flash.events.EventDispatcher;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;

    /**
     * Dispatches when a call to the operation get_echo completes with success
     * and returns some data
     * @eventType Get_echoResultEvent
     */
    [Event(name="Get_echo_result", type="generated.webservices.Get_echoResultEvent")]
    
    /**
     * Dispatches when a call to the operation create_guid completes with success
     * and returns some data
     * @eventType Create_guidResultEvent
     */
    [Event(name="Create_guid_result", type="generated.webservices.Create_guidResultEvent")]
    
    /**
     * Dispatches when a call to the operation delete_object completes with success
     * and returns some data
     * @eventType Delete_objectResultEvent
     */
    [Event(name="Delete_object_result", type="generated.webservices.Delete_objectResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_top_objects completes with success
     * and returns some data
     * @eventType Get_top_objectsResultEvent
     */
    [Event(name="Get_top_objects_result", type="generated.webservices.Get_top_objectsResultEvent")]
    
    /**
     * Dispatches when a call to the operation whole_delete completes with success
     * and returns some data
     * @eventType Whole_deleteResultEvent
     */
    [Event(name="Whole_delete_result", type="generated.webservices.Whole_deleteResultEvent")]
    
    /**
     * Dispatches when a call to the operation search completes with success
     * and returns some data
     * @eventType SearchResultEvent
     */
    [Event(name="Search_result", type="generated.webservices.SearchResultEvent")]
    
    /**
     * Dispatches when a call to the operation keep_alive completes with success
     * and returns some data
     * @eventType Keep_aliveResultEvent
     */
    [Event(name="Keep_alive_result", type="generated.webservices.Keep_aliveResultEvent")]
    
    /**
     * Dispatches when a call to the operation close_session completes with success
     * and returns some data
     * @eventType Close_sessionResultEvent
     */
    [Event(name="Close_session_result", type="generated.webservices.Close_sessionResultEvent")]
    
    /**
     * Dispatches when a call to the operation open_session completes with success
     * and returns some data
     * @eventType Open_sessionResultEvent
     */
    [Event(name="Open_session_result", type="generated.webservices.Open_sessionResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_type completes with success
     * and returns some data
     * @eventType Get_typeResultEvent
     */
    [Event(name="Get_type_result", type="generated.webservices.Get_typeResultEvent")]
    
    /**
     * Dispatches when a call to the operation send_event completes with success
     * and returns some data
     * @eventType Send_eventResultEvent
     */
    [Event(name="Send_event_result", type="generated.webservices.Send_eventResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_application_info completes with success
     * and returns some data
     * @eventType Set_application_infoResultEvent
     */
    [Event(name="Set_application_info_result", type="generated.webservices.Set_application_infoResultEvent")]
    
    /**
     * Dispatches when a call to the operation list_applications completes with success
     * and returns some data
     * @eventType List_applicationsResultEvent
     */
    [Event(name="List_applications_result", type="generated.webservices.List_applicationsResultEvent")]
    
    /**
     * Dispatches when a call to the operation export_application completes with success
     * and returns some data
     * @eventType Export_applicationResultEvent
     */
    [Event(name="Export_application_result", type="generated.webservices.Export_applicationResultEvent")]
    
    /**
     * Dispatches when a call to the operation execute_sql completes with success
     * and returns some data
     * @eventType Execute_sqlResultEvent
     */
    [Event(name="Execute_sql_result", type="generated.webservices.Execute_sqlResultEvent")]
    
    /**
     * Dispatches when a call to the operation create_application completes with success
     * and returns some data
     * @eventType Create_applicationResultEvent
     */
    [Event(name="Create_application_result", type="generated.webservices.Create_applicationResultEvent")]
    
    /**
     * Dispatches when a call to the operation submit_object_script_presentation completes with success
     * and returns some data
     * @eventType Submit_object_script_presentationResultEvent
     */
    [Event(name="Submit_object_script_presentation_result", type="generated.webservices.Submit_object_script_presentationResultEvent")]
    
    /**
     * Dispatches when a call to the operation whole_create completes with success
     * and returns some data
     * @eventType Whole_createResultEvent
     */
    [Event(name="Whole_create_result", type="generated.webservices.Whole_createResultEvent")]
    
    /**
     * Dispatches when a call to the operation remote_method_call completes with success
     * and returns some data
     * @eventType Remote_method_callResultEvent
     */
    [Event(name="Remote_method_call_result", type="generated.webservices.Remote_method_callResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_application_structure completes with success
     * and returns some data
     * @eventType Get_application_structureResultEvent
     */
    [Event(name="Get_application_structure_result", type="generated.webservices.Get_application_structureResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_thumbnail completes with success
     * and returns some data
     * @eventType Get_thumbnailResultEvent
     */
    [Event(name="Get_thumbnail_result", type="generated.webservices.Get_thumbnailResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_application_language_data completes with success
     * and returns some data
     * @eventType Get_application_language_dataResultEvent
     */
    [Event(name="Get_application_language_data_result", type="generated.webservices.Get_application_language_dataResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_application_structure completes with success
     * and returns some data
     * @eventType Set_application_structureResultEvent
     */
    [Event(name="Set_application_structure_result", type="generated.webservices.Set_application_structureResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_one_object completes with success
     * and returns some data
     * @eventType Get_one_objectResultEvent
     */
    [Event(name="Get_one_object_result", type="generated.webservices.Get_one_objectResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_name completes with success
     * and returns some data
     * @eventType Set_nameResultEvent
     */
    [Event(name="Set_name_result", type="generated.webservices.Set_nameResultEvent")]
    
    /**
     * Dispatches when a call to the operation whole_create_page completes with success
     * and returns some data
     * @eventType Whole_create_pageResultEvent
     */
    [Event(name="Whole_create_page_result", type="generated.webservices.Whole_create_pageResultEvent")]
    
    /**
     * Dispatches when a call to the operation list_types completes with success
     * and returns some data
     * @eventType List_typesResultEvent
     */
    [Event(name="List_types_result", type="generated.webservices.List_typesResultEvent")]
    
    /**
     * Dispatches when a call to the operation create_object completes with success
     * and returns some data
     * @eventType Create_objectResultEvent
     */
    [Event(name="Create_object_result", type="generated.webservices.Create_objectResultEvent")]
    
    /**
     * Dispatches when a call to the operation render_wysiwyg completes with success
     * and returns some data
     * @eventType Render_wysiwygResultEvent
     */
    [Event(name="Render_wysiwyg_result", type="generated.webservices.Render_wysiwygResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_attributes completes with success
     * and returns some data
     * @eventType Set_attributesResultEvent
     */
    [Event(name="Set_attributes_result", type="generated.webservices.Set_attributesResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_script completes with success
     * and returns some data
     * @eventType Set_scriptResultEvent
     */
    [Event(name="Set_script_result", type="generated.webservices.Set_scriptResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_application_info completes with success
     * and returns some data
     * @eventType Get_application_infoResultEvent
     */
    [Event(name="Get_application_info_result", type="generated.webservices.Get_application_infoResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_script completes with success
     * and returns some data
     * @eventType Get_scriptResultEvent
     */
    [Event(name="Get_script_result", type="generated.webservices.Get_scriptResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_child_objects_tree completes with success
     * and returns some data
     * @eventType Get_child_objects_treeResultEvent
     */
    [Event(name="Get_child_objects_tree_result", type="generated.webservices.Get_child_objects_treeResultEvent")]
    
    /**
     * Dispatches when a call to the operation modify_resource completes with success
     * and returns some data
     * @eventType Modify_resourceResultEvent
     */
    [Event(name="Modify_resource_result", type="generated.webservices.Modify_resourceResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_child_objects completes with success
     * and returns some data
     * @eventType Get_child_objectsResultEvent
     */
    [Event(name="Get_child_objects_result", type="generated.webservices.Get_child_objectsResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_resource completes with success
     * and returns some data
     * @eventType Get_resourceResultEvent
     */
    [Event(name="Get_resource_result", type="generated.webservices.Get_resourceResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_code_interface_data completes with success
     * and returns some data
     * @eventType Get_code_interface_dataResultEvent
     */
    [Event(name="Get_code_interface_data_result", type="generated.webservices.Get_code_interface_dataResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_application_events completes with success
     * and returns some data
     * @eventType Get_application_eventsResultEvent
     */
    [Event(name="Get_application_events_result", type="generated.webservices.Get_application_eventsResultEvent")]
    
    /**
     * Dispatches when a call to the operation about completes with success
     * and returns some data
     * @eventType AboutResultEvent
     */
    [Event(name="About_result", type="generated.webservices.AboutResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_resource completes with success
     * and returns some data
     * @eventType Set_resourceResultEvent
     */
    [Event(name="Set_resource_result", type="generated.webservices.Set_resourceResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_application_events completes with success
     * and returns some data
     * @eventType Set_application_eventsResultEvent
     */
    [Event(name="Set_application_events_result", type="generated.webservices.Set_application_eventsResultEvent")]
    
    /**
     * Dispatches when a call to the operation list_resources completes with success
     * and returns some data
     * @eventType List_resourcesResultEvent
     */
    [Event(name="List_resources_result", type="generated.webservices.List_resourcesResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_all_types completes with success
     * and returns some data
     * @eventType Get_all_typesResultEvent
     */
    [Event(name="Get_all_types_result", type="generated.webservices.Get_all_typesResultEvent")]
    
    /**
     * Dispatches when a call to the operation set_attribute completes with success
     * and returns some data
     * @eventType Set_attributeResultEvent
     */
    [Event(name="Set_attribute_result", type="generated.webservices.Set_attributeResultEvent")]
    
    /**
     * Dispatches when a call to the operation whole_update completes with success
     * and returns some data
     * @eventType Whole_updateResultEvent
     */
    [Event(name="Whole_update_result", type="generated.webservices.Whole_updateResultEvent")]
    
    /**
     * Dispatches when a call to the operation get_object_script_presentation completes with success
     * and returns some data
     * @eventType Get_object_script_presentationResultEvent
     */
    [Event(name="Get_object_script_presentation_result", type="generated.webservices.Get_object_script_presentationResultEvent")]
    
    /**
     * Dispatches when a call to the operation install_application completes with success
     * and returns some data
     * @eventType Install_applicationResultEvent
     */
    [Event(name="Install_application_result", type="generated.webservices.Install_applicationResultEvent")]
    
	/**
	 * Dispatches when the operation that has been called fails. The fault event is common for all operations
	 * of the WSDL
	 * @eventType mx.rpc.events.FaultEvent
	 */
    [Event(name="fault", type="mx.rpc.events.FaultEvent")]

	public class Vdom extends EventDispatcher implements Ivdom
	{
    	private var _baseService:Basevdom;
        
        /**
         * Constructor for the facade; sets the destination and create a baseService instance
         * @param The LCDS destination (if any) associated with the imported WSDL
         */  
        public function Vdom(destination:String=null,rootURL:String=null)
        {
        	_baseService = new Basevdom(destination,rootURL);
        }
        
		//stub functions for the get_echo operation
          

        /**
         * @see IVdom#get_echo()
         */
        public function get_echo(sid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_echo(sid);
            _internal_token.addEventListener("result",_get_echo_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_echo_send()
		 */    
        public function get_echo_send():AsyncToken
        {
        	return get_echo(_get_echo_request.sid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_echo_request:Get_echo_request;
		/**
		 * @see IVdom#get_echo_request_var
		 */
		[Bindable]
		public function get get_echo_request_var():Get_echo_request
		{
			return _get_echo_request;
		}
		
		/**
		 * @private
		 */
		public function set get_echo_request_var(request:Get_echo_request):void
		{
			_get_echo_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_echo_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_echo_lastResult
		 */	  
		public function get get_echo_lastResult():String
		{
			return _get_echo_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_echo_lastResult(lastResult:String):void
		{
			_get_echo_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_echo()
		 */
		public function addget_echoEventListener(listener:Function):void
		{
			addEventListener(Get_echoResultEvent.Get_echo_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_echo_populate_results(event:ResultEvent):void
        {
        var e:Get_echoResultEvent = new Get_echoResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_echo_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the create_guid operation
          

        /**
         * @see IVdom#create_guid()
         */
        public function create_guid(sid:String,skey:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.create_guid(sid,skey);
            _internal_token.addEventListener("result",_create_guid_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#create_guid_send()
		 */    
        public function create_guid_send():AsyncToken
        {
        	return create_guid(_create_guid_request.sid,_create_guid_request.skey);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _create_guid_request:Create_guid_request;
		/**
		 * @see IVdom#create_guid_request_var
		 */
		[Bindable]
		public function get create_guid_request_var():Create_guid_request
		{
			return _create_guid_request;
		}
		
		/**
		 * @private
		 */
		public function set create_guid_request_var(request:Create_guid_request):void
		{
			_create_guid_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _create_guid_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#create_guid_lastResult
		 */	  
		public function get create_guid_lastResult():String
		{
			return _create_guid_lastResult;
		}
		/**
		 * @private
		 */
		public function set create_guid_lastResult(lastResult:String):void
		{
			_create_guid_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addcreate_guid()
		 */
		public function addcreate_guidEventListener(listener:Function):void
		{
			addEventListener(Create_guidResultEvent.Create_guid_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _create_guid_populate_results(event:ResultEvent):void
        {
        var e:Create_guidResultEvent = new Create_guidResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             create_guid_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the delete_object operation
          

        /**
         * @see IVdom#delete_object()
         */
        public function delete_object(sid:String,skey:String,appid:String,objid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.delete_object(sid,skey,appid,objid);
            _internal_token.addEventListener("result",_delete_object_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#delete_object_send()
		 */    
        public function delete_object_send():AsyncToken
        {
        	return delete_object(_delete_object_request.sid,_delete_object_request.skey,_delete_object_request.appid,_delete_object_request.objid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _delete_object_request:Delete_object_request;
		/**
		 * @see IVdom#delete_object_request_var
		 */
		[Bindable]
		public function get delete_object_request_var():Delete_object_request
		{
			return _delete_object_request;
		}
		
		/**
		 * @private
		 */
		public function set delete_object_request_var(request:Delete_object_request):void
		{
			_delete_object_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _delete_object_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#delete_object_lastResult
		 */	  
		public function get delete_object_lastResult():String
		{
			return _delete_object_lastResult;
		}
		/**
		 * @private
		 */
		public function set delete_object_lastResult(lastResult:String):void
		{
			_delete_object_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#adddelete_object()
		 */
		public function adddelete_objectEventListener(listener:Function):void
		{
			addEventListener(Delete_objectResultEvent.Delete_object_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _delete_object_populate_results(event:ResultEvent):void
        {
        var e:Delete_objectResultEvent = new Delete_objectResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             delete_object_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_top_objects operation
          

        /**
         * @see IVdom#get_top_objects()
         */
        public function get_top_objects(sid:String,skey:String,appid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_top_objects(sid,skey,appid);
            _internal_token.addEventListener("result",_get_top_objects_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_top_objects_send()
		 */    
        public function get_top_objects_send():AsyncToken
        {
        	return get_top_objects(_get_top_objects_request.sid,_get_top_objects_request.skey,_get_top_objects_request.appid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_top_objects_request:Get_top_objects_request;
		/**
		 * @see IVdom#get_top_objects_request_var
		 */
		[Bindable]
		public function get get_top_objects_request_var():Get_top_objects_request
		{
			return _get_top_objects_request;
		}
		
		/**
		 * @private
		 */
		public function set get_top_objects_request_var(request:Get_top_objects_request):void
		{
			_get_top_objects_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_top_objects_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_top_objects_lastResult
		 */	  
		public function get get_top_objects_lastResult():String
		{
			return _get_top_objects_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_top_objects_lastResult(lastResult:String):void
		{
			_get_top_objects_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_top_objects()
		 */
		public function addget_top_objectsEventListener(listener:Function):void
		{
			addEventListener(Get_top_objectsResultEvent.Get_top_objects_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_top_objects_populate_results(event:ResultEvent):void
        {
        var e:Get_top_objectsResultEvent = new Get_top_objectsResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_top_objects_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the whole_delete operation
          

        /**
         * @see IVdom#whole_delete()
         */
        public function whole_delete(sid:String,skey:String,appid:String,objid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.whole_delete(sid,skey,appid,objid);
            _internal_token.addEventListener("result",_whole_delete_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#whole_delete_send()
		 */    
        public function whole_delete_send():AsyncToken
        {
        	return whole_delete(_whole_delete_request.sid,_whole_delete_request.skey,_whole_delete_request.appid,_whole_delete_request.objid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _whole_delete_request:Whole_delete_request;
		/**
		 * @see IVdom#whole_delete_request_var
		 */
		[Bindable]
		public function get whole_delete_request_var():Whole_delete_request
		{
			return _whole_delete_request;
		}
		
		/**
		 * @private
		 */
		public function set whole_delete_request_var(request:Whole_delete_request):void
		{
			_whole_delete_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _whole_delete_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#whole_delete_lastResult
		 */	  
		public function get whole_delete_lastResult():String
		{
			return _whole_delete_lastResult;
		}
		/**
		 * @private
		 */
		public function set whole_delete_lastResult(lastResult:String):void
		{
			_whole_delete_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addwhole_delete()
		 */
		public function addwhole_deleteEventListener(listener:Function):void
		{
			addEventListener(Whole_deleteResultEvent.Whole_delete_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _whole_delete_populate_results(event:ResultEvent):void
        {
        var e:Whole_deleteResultEvent = new Whole_deleteResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             whole_delete_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the search operation
          

        /**
         * @see IVdom#search()
         */
        public function search(sid:String,skey:String,appid:String,pattern:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.search(sid,skey,appid,pattern);
            _internal_token.addEventListener("result",_search_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#search_send()
		 */    
        public function search_send():AsyncToken
        {
        	return search(_search_request.sid,_search_request.skey,_search_request.appid,_search_request.pattern);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _search_request:Search_request;
		/**
		 * @see IVdom#search_request_var
		 */
		[Bindable]
		public function get search_request_var():Search_request
		{
			return _search_request;
		}
		
		/**
		 * @private
		 */
		public function set search_request_var(request:Search_request):void
		{
			_search_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _search_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#search_lastResult
		 */	  
		public function get search_lastResult():String
		{
			return _search_lastResult;
		}
		/**
		 * @private
		 */
		public function set search_lastResult(lastResult:String):void
		{
			_search_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addsearch()
		 */
		public function addsearchEventListener(listener:Function):void
		{
			addEventListener(SearchResultEvent.Search_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _search_populate_results(event:ResultEvent):void
        {
        var e:SearchResultEvent = new SearchResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             search_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the keep_alive operation
          

        /**
         * @see IVdom#keep_alive()
         */
        public function keep_alive(sid:String,skey:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.keep_alive(sid,skey);
            _internal_token.addEventListener("result",_keep_alive_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#keep_alive_send()
		 */    
        public function keep_alive_send():AsyncToken
        {
        	return keep_alive(_keep_alive_request.sid,_keep_alive_request.skey);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _keep_alive_request:Keep_alive_request;
		/**
		 * @see IVdom#keep_alive_request_var
		 */
		[Bindable]
		public function get keep_alive_request_var():Keep_alive_request
		{
			return _keep_alive_request;
		}
		
		/**
		 * @private
		 */
		public function set keep_alive_request_var(request:Keep_alive_request):void
		{
			_keep_alive_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _keep_alive_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#keep_alive_lastResult
		 */	  
		public function get keep_alive_lastResult():String
		{
			return _keep_alive_lastResult;
		}
		/**
		 * @private
		 */
		public function set keep_alive_lastResult(lastResult:String):void
		{
			_keep_alive_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addkeep_alive()
		 */
		public function addkeep_aliveEventListener(listener:Function):void
		{
			addEventListener(Keep_aliveResultEvent.Keep_alive_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _keep_alive_populate_results(event:ResultEvent):void
        {
        var e:Keep_aliveResultEvent = new Keep_aliveResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             keep_alive_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the close_session operation
          

        /**
         * @see IVdom#close_session()
         */
        public function close_session(sid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.close_session(sid);
            _internal_token.addEventListener("result",_close_session_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#close_session_send()
		 */    
        public function close_session_send():AsyncToken
        {
        	return close_session(_close_session_request.sid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _close_session_request:Close_session_request;
		/**
		 * @see IVdom#close_session_request_var
		 */
		[Bindable]
		public function get close_session_request_var():Close_session_request
		{
			return _close_session_request;
		}
		
		/**
		 * @private
		 */
		public function set close_session_request_var(request:Close_session_request):void
		{
			_close_session_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _close_session_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#close_session_lastResult
		 */	  
		public function get close_session_lastResult():String
		{
			return _close_session_lastResult;
		}
		/**
		 * @private
		 */
		public function set close_session_lastResult(lastResult:String):void
		{
			_close_session_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addclose_session()
		 */
		public function addclose_sessionEventListener(listener:Function):void
		{
			addEventListener(Close_sessionResultEvent.Close_session_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _close_session_populate_results(event:ResultEvent):void
        {
        var e:Close_sessionResultEvent = new Close_sessionResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             close_session_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the open_session operation
          

        /**
         * @see IVdom#open_session()
         */
        public function open_session(name:String,pwd_md5:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.open_session(name,pwd_md5);
            _internal_token.addEventListener("result",_open_session_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#open_session_send()
		 */    
        public function open_session_send():AsyncToken
        {
        	return open_session(_open_session_request.name,_open_session_request.pwd_md5);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _open_session_request:Open_session_request;
		/**
		 * @see IVdom#open_session_request_var
		 */
		[Bindable]
		public function get open_session_request_var():Open_session_request
		{
			return _open_session_request;
		}
		
		/**
		 * @private
		 */
		public function set open_session_request_var(request:Open_session_request):void
		{
			_open_session_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _open_session_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#open_session_lastResult
		 */	  
		public function get open_session_lastResult():String
		{
			return _open_session_lastResult;
		}
		/**
		 * @private
		 */
		public function set open_session_lastResult(lastResult:String):void
		{
			_open_session_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addopen_session()
		 */
		public function addopen_sessionEventListener(listener:Function):void
		{
			addEventListener(Open_sessionResultEvent.Open_session_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _open_session_populate_results(event:ResultEvent):void
        {
        var e:Open_sessionResultEvent = new Open_sessionResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             open_session_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_type operation
          

        /**
         * @see IVdom#get_type()
         */
        public function get_type(sid:String,skey:String,typeid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_type(sid,skey,typeid);
            _internal_token.addEventListener("result",_get_type_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_type_send()
		 */    
        public function get_type_send():AsyncToken
        {
        	return get_type(_get_type_request.sid,_get_type_request.skey,_get_type_request.typeid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_type_request:Get_type_request;
		/**
		 * @see IVdom#get_type_request_var
		 */
		[Bindable]
		public function get get_type_request_var():Get_type_request
		{
			return _get_type_request;
		}
		
		/**
		 * @private
		 */
		public function set get_type_request_var(request:Get_type_request):void
		{
			_get_type_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_type_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_type_lastResult
		 */	  
		public function get get_type_lastResult():String
		{
			return _get_type_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_type_lastResult(lastResult:String):void
		{
			_get_type_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_type()
		 */
		public function addget_typeEventListener(listener:Function):void
		{
			addEventListener(Get_typeResultEvent.Get_type_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_type_populate_results(event:ResultEvent):void
        {
        var e:Get_typeResultEvent = new Get_typeResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_type_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the send_event operation
          

        /**
         * @see IVdom#send_event()
         */
        public function send_event(sid:String,skey:String,evdata:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.send_event(sid,skey,evdata);
            _internal_token.addEventListener("result",_send_event_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#send_event_send()
		 */    
        public function send_event_send():AsyncToken
        {
        	return send_event(_send_event_request.sid,_send_event_request.skey,_send_event_request.evdata);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _send_event_request:Send_event_request;
		/**
		 * @see IVdom#send_event_request_var
		 */
		[Bindable]
		public function get send_event_request_var():Send_event_request
		{
			return _send_event_request;
		}
		
		/**
		 * @private
		 */
		public function set send_event_request_var(request:Send_event_request):void
		{
			_send_event_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _send_event_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#send_event_lastResult
		 */	  
		public function get send_event_lastResult():String
		{
			return _send_event_lastResult;
		}
		/**
		 * @private
		 */
		public function set send_event_lastResult(lastResult:String):void
		{
			_send_event_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addsend_event()
		 */
		public function addsend_eventEventListener(listener:Function):void
		{
			addEventListener(Send_eventResultEvent.Send_event_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _send_event_populate_results(event:ResultEvent):void
        {
        var e:Send_eventResultEvent = new Send_eventResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             send_event_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_application_info operation
          

        /**
         * @see IVdom#set_application_info()
         */
        public function set_application_info(sid:String,skey:String,appid:String,attr:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_application_info(sid,skey,appid,attr);
            _internal_token.addEventListener("result",_set_application_info_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_application_info_send()
		 */    
        public function set_application_info_send():AsyncToken
        {
        	return set_application_info(_set_application_info_request.sid,_set_application_info_request.skey,_set_application_info_request.appid,_set_application_info_request.attr);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_application_info_request:Set_application_info_request;
		/**
		 * @see IVdom#set_application_info_request_var
		 */
		[Bindable]
		public function get set_application_info_request_var():Set_application_info_request
		{
			return _set_application_info_request;
		}
		
		/**
		 * @private
		 */
		public function set set_application_info_request_var(request:Set_application_info_request):void
		{
			_set_application_info_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_application_info_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_application_info_lastResult
		 */	  
		public function get set_application_info_lastResult():String
		{
			return _set_application_info_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_application_info_lastResult(lastResult:String):void
		{
			_set_application_info_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_application_info()
		 */
		public function addset_application_infoEventListener(listener:Function):void
		{
			addEventListener(Set_application_infoResultEvent.Set_application_info_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_application_info_populate_results(event:ResultEvent):void
        {
        var e:Set_application_infoResultEvent = new Set_application_infoResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_application_info_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the list_applications operation
          

        /**
         * @see IVdom#list_applications()
         */
        public function list_applications(sid:String,skey:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.list_applications(sid,skey);
            _internal_token.addEventListener("result",_list_applications_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#list_applications_send()
		 */    
        public function list_applications_send():AsyncToken
        {
        	return list_applications(_list_applications_request.sid,_list_applications_request.skey);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _list_applications_request:List_applications_request;
		/**
		 * @see IVdom#list_applications_request_var
		 */
		[Bindable]
		public function get list_applications_request_var():List_applications_request
		{
			return _list_applications_request;
		}
		
		/**
		 * @private
		 */
		public function set list_applications_request_var(request:List_applications_request):void
		{
			_list_applications_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _list_applications_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#list_applications_lastResult
		 */	  
		public function get list_applications_lastResult():String
		{
			return _list_applications_lastResult;
		}
		/**
		 * @private
		 */
		public function set list_applications_lastResult(lastResult:String):void
		{
			_list_applications_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addlist_applications()
		 */
		public function addlist_applicationsEventListener(listener:Function):void
		{
			addEventListener(List_applicationsResultEvent.List_applications_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _list_applications_populate_results(event:ResultEvent):void
        {
        var e:List_applicationsResultEvent = new List_applicationsResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             list_applications_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the export_application operation
          

        /**
         * @see IVdom#export_application()
         */
        public function export_application(sid:String,skey:String,appid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.export_application(sid,skey,appid);
            _internal_token.addEventListener("result",_export_application_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#export_application_send()
		 */    
        public function export_application_send():AsyncToken
        {
        	return export_application(_export_application_request.sid,_export_application_request.skey,_export_application_request.appid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _export_application_request:Export_application_request;
		/**
		 * @see IVdom#export_application_request_var
		 */
		[Bindable]
		public function get export_application_request_var():Export_application_request
		{
			return _export_application_request;
		}
		
		/**
		 * @private
		 */
		public function set export_application_request_var(request:Export_application_request):void
		{
			_export_application_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _export_application_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#export_application_lastResult
		 */	  
		public function get export_application_lastResult():String
		{
			return _export_application_lastResult;
		}
		/**
		 * @private
		 */
		public function set export_application_lastResult(lastResult:String):void
		{
			_export_application_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addexport_application()
		 */
		public function addexport_applicationEventListener(listener:Function):void
		{
			addEventListener(Export_applicationResultEvent.Export_application_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _export_application_populate_results(event:ResultEvent):void
        {
        var e:Export_applicationResultEvent = new Export_applicationResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             export_application_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the execute_sql operation
          

        /**
         * @see IVdom#execute_sql()
         */
        public function execute_sql(sid:String,skey:String,appid:String,dbid:String,sql:String,script:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.execute_sql(sid,skey,appid,dbid,sql,script);
            _internal_token.addEventListener("result",_execute_sql_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#execute_sql_send()
		 */    
        public function execute_sql_send():AsyncToken
        {
        	return execute_sql(_execute_sql_request.sid,_execute_sql_request.skey,_execute_sql_request.appid,_execute_sql_request.dbid,_execute_sql_request.sql,_execute_sql_request.script);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _execute_sql_request:Execute_sql_request;
		/**
		 * @see IVdom#execute_sql_request_var
		 */
		[Bindable]
		public function get execute_sql_request_var():Execute_sql_request
		{
			return _execute_sql_request;
		}
		
		/**
		 * @private
		 */
		public function set execute_sql_request_var(request:Execute_sql_request):void
		{
			_execute_sql_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _execute_sql_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#execute_sql_lastResult
		 */	  
		public function get execute_sql_lastResult():String
		{
			return _execute_sql_lastResult;
		}
		/**
		 * @private
		 */
		public function set execute_sql_lastResult(lastResult:String):void
		{
			_execute_sql_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addexecute_sql()
		 */
		public function addexecute_sqlEventListener(listener:Function):void
		{
			addEventListener(Execute_sqlResultEvent.Execute_sql_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _execute_sql_populate_results(event:ResultEvent):void
        {
        var e:Execute_sqlResultEvent = new Execute_sqlResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             execute_sql_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the create_application operation
          

        /**
         * @see IVdom#create_application()
         */
        public function create_application(sid:String,skey:String,attr:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.create_application(sid,skey,attr);
            _internal_token.addEventListener("result",_create_application_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#create_application_send()
		 */    
        public function create_application_send():AsyncToken
        {
        	return create_application(_create_application_request.sid,_create_application_request.skey,_create_application_request.attr);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _create_application_request:Create_application_request;
		/**
		 * @see IVdom#create_application_request_var
		 */
		[Bindable]
		public function get create_application_request_var():Create_application_request
		{
			return _create_application_request;
		}
		
		/**
		 * @private
		 */
		public function set create_application_request_var(request:Create_application_request):void
		{
			_create_application_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _create_application_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#create_application_lastResult
		 */	  
		public function get create_application_lastResult():String
		{
			return _create_application_lastResult;
		}
		/**
		 * @private
		 */
		public function set create_application_lastResult(lastResult:String):void
		{
			_create_application_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addcreate_application()
		 */
		public function addcreate_applicationEventListener(listener:Function):void
		{
			addEventListener(Create_applicationResultEvent.Create_application_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _create_application_populate_results(event:ResultEvent):void
        {
        var e:Create_applicationResultEvent = new Create_applicationResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             create_application_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the submit_object_script_presentation operation
          

        /**
         * @see IVdom#submit_object_script_presentation()
         */
        public function submit_object_script_presentation(sid:String,skey:String,appid:String,objid:String,pres:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.submit_object_script_presentation(sid,skey,appid,objid,pres);
            _internal_token.addEventListener("result",_submit_object_script_presentation_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#submit_object_script_presentation_send()
		 */    
        public function submit_object_script_presentation_send():AsyncToken
        {
        	return submit_object_script_presentation(_submit_object_script_presentation_request.sid,_submit_object_script_presentation_request.skey,_submit_object_script_presentation_request.appid,_submit_object_script_presentation_request.objid,_submit_object_script_presentation_request.pres);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _submit_object_script_presentation_request:Submit_object_script_presentation_request;
		/**
		 * @see IVdom#submit_object_script_presentation_request_var
		 */
		[Bindable]
		public function get submit_object_script_presentation_request_var():Submit_object_script_presentation_request
		{
			return _submit_object_script_presentation_request;
		}
		
		/**
		 * @private
		 */
		public function set submit_object_script_presentation_request_var(request:Submit_object_script_presentation_request):void
		{
			_submit_object_script_presentation_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _submit_object_script_presentation_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#submit_object_script_presentation_lastResult
		 */	  
		public function get submit_object_script_presentation_lastResult():String
		{
			return _submit_object_script_presentation_lastResult;
		}
		/**
		 * @private
		 */
		public function set submit_object_script_presentation_lastResult(lastResult:String):void
		{
			_submit_object_script_presentation_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addsubmit_object_script_presentation()
		 */
		public function addsubmit_object_script_presentationEventListener(listener:Function):void
		{
			addEventListener(Submit_object_script_presentationResultEvent.Submit_object_script_presentation_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _submit_object_script_presentation_populate_results(event:ResultEvent):void
        {
        var e:Submit_object_script_presentationResultEvent = new Submit_object_script_presentationResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             submit_object_script_presentation_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the whole_create operation
          

        /**
         * @see IVdom#whole_create()
         */
        public function whole_create(sid:String,skey:String,appid:String,parentid:String,name:String,data:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.whole_create(sid,skey,appid,parentid,name,data);
            _internal_token.addEventListener("result",_whole_create_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#whole_create_send()
		 */    
        public function whole_create_send():AsyncToken
        {
        	return whole_create(_whole_create_request.sid,_whole_create_request.skey,_whole_create_request.appid,_whole_create_request.parentid,_whole_create_request.name,_whole_create_request.data);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _whole_create_request:Whole_create_request;
		/**
		 * @see IVdom#whole_create_request_var
		 */
		[Bindable]
		public function get whole_create_request_var():Whole_create_request
		{
			return _whole_create_request;
		}
		
		/**
		 * @private
		 */
		public function set whole_create_request_var(request:Whole_create_request):void
		{
			_whole_create_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _whole_create_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#whole_create_lastResult
		 */	  
		public function get whole_create_lastResult():String
		{
			return _whole_create_lastResult;
		}
		/**
		 * @private
		 */
		public function set whole_create_lastResult(lastResult:String):void
		{
			_whole_create_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addwhole_create()
		 */
		public function addwhole_createEventListener(listener:Function):void
		{
			addEventListener(Whole_createResultEvent.Whole_create_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _whole_create_populate_results(event:ResultEvent):void
        {
        var e:Whole_createResultEvent = new Whole_createResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             whole_create_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the remote_method_call operation
          

        /**
         * @see IVdom#remote_method_call()
         */
        public function remote_method_call(sid:String,skey:String,appid:String,objid:String,func_name:String,xml_param:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.remote_method_call(sid,skey,appid,objid,func_name,xml_param);
            _internal_token.addEventListener("result",_remote_method_call_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#remote_method_call_send()
		 */    
        public function remote_method_call_send():AsyncToken
        {
        	return remote_method_call(_remote_method_call_request.sid,_remote_method_call_request.skey,_remote_method_call_request.appid,_remote_method_call_request.objid,_remote_method_call_request.func_name,_remote_method_call_request.xml_param);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _remote_method_call_request:Remote_method_call_request;
		/**
		 * @see IVdom#remote_method_call_request_var
		 */
		[Bindable]
		public function get remote_method_call_request_var():Remote_method_call_request
		{
			return _remote_method_call_request;
		}
		
		/**
		 * @private
		 */
		public function set remote_method_call_request_var(request:Remote_method_call_request):void
		{
			_remote_method_call_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _remote_method_call_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#remote_method_call_lastResult
		 */	  
		public function get remote_method_call_lastResult():String
		{
			return _remote_method_call_lastResult;
		}
		/**
		 * @private
		 */
		public function set remote_method_call_lastResult(lastResult:String):void
		{
			_remote_method_call_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addremote_method_call()
		 */
		public function addremote_method_callEventListener(listener:Function):void
		{
			addEventListener(Remote_method_callResultEvent.Remote_method_call_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _remote_method_call_populate_results(event:ResultEvent):void
        {
        var e:Remote_method_callResultEvent = new Remote_method_callResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             remote_method_call_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_application_structure operation
          

        /**
         * @see IVdom#get_application_structure()
         */
        public function get_application_structure(sid:String,skey:String,appid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_application_structure(sid,skey,appid);
            _internal_token.addEventListener("result",_get_application_structure_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_application_structure_send()
		 */    
        public function get_application_structure_send():AsyncToken
        {
        	return get_application_structure(_get_application_structure_request.sid,_get_application_structure_request.skey,_get_application_structure_request.appid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_application_structure_request:Get_application_structure_request;
		/**
		 * @see IVdom#get_application_structure_request_var
		 */
		[Bindable]
		public function get get_application_structure_request_var():Get_application_structure_request
		{
			return _get_application_structure_request;
		}
		
		/**
		 * @private
		 */
		public function set get_application_structure_request_var(request:Get_application_structure_request):void
		{
			_get_application_structure_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_application_structure_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_application_structure_lastResult
		 */	  
		public function get get_application_structure_lastResult():String
		{
			return _get_application_structure_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_application_structure_lastResult(lastResult:String):void
		{
			_get_application_structure_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_application_structure()
		 */
		public function addget_application_structureEventListener(listener:Function):void
		{
			addEventListener(Get_application_structureResultEvent.Get_application_structure_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_application_structure_populate_results(event:ResultEvent):void
        {
        var e:Get_application_structureResultEvent = new Get_application_structureResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_application_structure_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_thumbnail operation
          

        /**
         * @see IVdom#get_thumbnail()
         */
        public function get_thumbnail(sid:String,skey:String,appid:String,resid:String,width:String,height:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_thumbnail(sid,skey,appid,resid,width,height);
            _internal_token.addEventListener("result",_get_thumbnail_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_thumbnail_send()
		 */    
        public function get_thumbnail_send():AsyncToken
        {
        	return get_thumbnail(_get_thumbnail_request.sid,_get_thumbnail_request.skey,_get_thumbnail_request.appid,_get_thumbnail_request.resid,_get_thumbnail_request.width,_get_thumbnail_request.height);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_thumbnail_request:Get_thumbnail_request;
		/**
		 * @see IVdom#get_thumbnail_request_var
		 */
		[Bindable]
		public function get get_thumbnail_request_var():Get_thumbnail_request
		{
			return _get_thumbnail_request;
		}
		
		/**
		 * @private
		 */
		public function set get_thumbnail_request_var(request:Get_thumbnail_request):void
		{
			_get_thumbnail_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_thumbnail_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_thumbnail_lastResult
		 */	  
		public function get get_thumbnail_lastResult():String
		{
			return _get_thumbnail_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_thumbnail_lastResult(lastResult:String):void
		{
			_get_thumbnail_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_thumbnail()
		 */
		public function addget_thumbnailEventListener(listener:Function):void
		{
			addEventListener(Get_thumbnailResultEvent.Get_thumbnail_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_thumbnail_populate_results(event:ResultEvent):void
        {
        var e:Get_thumbnailResultEvent = new Get_thumbnailResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_thumbnail_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_application_language_data operation
          

        /**
         * @see IVdom#get_application_language_data()
         */
        public function get_application_language_data(sid:String,skey:String,appid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_application_language_data(sid,skey,appid);
            _internal_token.addEventListener("result",_get_application_language_data_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_application_language_data_send()
		 */    
        public function get_application_language_data_send():AsyncToken
        {
        	return get_application_language_data(_get_application_language_data_request.sid,_get_application_language_data_request.skey,_get_application_language_data_request.appid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_application_language_data_request:Get_application_language_data_request;
		/**
		 * @see IVdom#get_application_language_data_request_var
		 */
		[Bindable]
		public function get get_application_language_data_request_var():Get_application_language_data_request
		{
			return _get_application_language_data_request;
		}
		
		/**
		 * @private
		 */
		public function set get_application_language_data_request_var(request:Get_application_language_data_request):void
		{
			_get_application_language_data_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_application_language_data_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_application_language_data_lastResult
		 */	  
		public function get get_application_language_data_lastResult():String
		{
			return _get_application_language_data_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_application_language_data_lastResult(lastResult:String):void
		{
			_get_application_language_data_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_application_language_data()
		 */
		public function addget_application_language_dataEventListener(listener:Function):void
		{
			addEventListener(Get_application_language_dataResultEvent.Get_application_language_data_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_application_language_data_populate_results(event:ResultEvent):void
        {
        var e:Get_application_language_dataResultEvent = new Get_application_language_dataResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_application_language_data_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_application_structure operation
          

        /**
         * @see IVdom#set_application_structure()
         */
        public function set_application_structure(sid:String,skey:String,appid:String,struct:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_application_structure(sid,skey,appid,struct);
            _internal_token.addEventListener("result",_set_application_structure_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_application_structure_send()
		 */    
        public function set_application_structure_send():AsyncToken
        {
        	return set_application_structure(_set_application_structure_request.sid,_set_application_structure_request.skey,_set_application_structure_request.appid,_set_application_structure_request.struct);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_application_structure_request:Set_application_structure_request;
		/**
		 * @see IVdom#set_application_structure_request_var
		 */
		[Bindable]
		public function get set_application_structure_request_var():Set_application_structure_request
		{
			return _set_application_structure_request;
		}
		
		/**
		 * @private
		 */
		public function set set_application_structure_request_var(request:Set_application_structure_request):void
		{
			_set_application_structure_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_application_structure_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_application_structure_lastResult
		 */	  
		public function get set_application_structure_lastResult():String
		{
			return _set_application_structure_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_application_structure_lastResult(lastResult:String):void
		{
			_set_application_structure_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_application_structure()
		 */
		public function addset_application_structureEventListener(listener:Function):void
		{
			addEventListener(Set_application_structureResultEvent.Set_application_structure_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_application_structure_populate_results(event:ResultEvent):void
        {
        var e:Set_application_structureResultEvent = new Set_application_structureResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_application_structure_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_one_object operation
          

        /**
         * @see IVdom#get_one_object()
         */
        public function get_one_object(sid:String,skey:String,appid:String,objid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_one_object(sid,skey,appid,objid);
            _internal_token.addEventListener("result",_get_one_object_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_one_object_send()
		 */    
        public function get_one_object_send():AsyncToken
        {
        	return get_one_object(_get_one_object_request.sid,_get_one_object_request.skey,_get_one_object_request.appid,_get_one_object_request.objid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_one_object_request:Get_one_object_request;
		/**
		 * @see IVdom#get_one_object_request_var
		 */
		[Bindable]
		public function get get_one_object_request_var():Get_one_object_request
		{
			return _get_one_object_request;
		}
		
		/**
		 * @private
		 */
		public function set get_one_object_request_var(request:Get_one_object_request):void
		{
			_get_one_object_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_one_object_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_one_object_lastResult
		 */	  
		public function get get_one_object_lastResult():String
		{
			return _get_one_object_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_one_object_lastResult(lastResult:String):void
		{
			_get_one_object_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_one_object()
		 */
		public function addget_one_objectEventListener(listener:Function):void
		{
			addEventListener(Get_one_objectResultEvent.Get_one_object_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_one_object_populate_results(event:ResultEvent):void
        {
        var e:Get_one_objectResultEvent = new Get_one_objectResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_one_object_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_name operation
          

        /**
         * @see IVdom#set_name()
         */
        public function set_name(sid:String,skey:String,appid:String,objid:String,name:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_name(sid,skey,appid,objid,name);
            _internal_token.addEventListener("result",_set_name_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_name_send()
		 */    
        public function set_name_send():AsyncToken
        {
        	return set_name(_set_name_request.sid,_set_name_request.skey,_set_name_request.appid,_set_name_request.objid,_set_name_request.name);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_name_request:Set_name_request;
		/**
		 * @see IVdom#set_name_request_var
		 */
		[Bindable]
		public function get set_name_request_var():Set_name_request
		{
			return _set_name_request;
		}
		
		/**
		 * @private
		 */
		public function set set_name_request_var(request:Set_name_request):void
		{
			_set_name_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_name_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_name_lastResult
		 */	  
		public function get set_name_lastResult():String
		{
			return _set_name_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_name_lastResult(lastResult:String):void
		{
			_set_name_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_name()
		 */
		public function addset_nameEventListener(listener:Function):void
		{
			addEventListener(Set_nameResultEvent.Set_name_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_name_populate_results(event:ResultEvent):void
        {
        var e:Set_nameResultEvent = new Set_nameResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_name_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the whole_create_page operation
          

        /**
         * @see IVdom#whole_create_page()
         */
        public function whole_create_page(sid:String,skey:String,appid:String,sourceid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.whole_create_page(sid,skey,appid,sourceid);
            _internal_token.addEventListener("result",_whole_create_page_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#whole_create_page_send()
		 */    
        public function whole_create_page_send():AsyncToken
        {
        	return whole_create_page(_whole_create_page_request.sid,_whole_create_page_request.skey,_whole_create_page_request.appid,_whole_create_page_request.sourceid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _whole_create_page_request:Whole_create_page_request;
		/**
		 * @see IVdom#whole_create_page_request_var
		 */
		[Bindable]
		public function get whole_create_page_request_var():Whole_create_page_request
		{
			return _whole_create_page_request;
		}
		
		/**
		 * @private
		 */
		public function set whole_create_page_request_var(request:Whole_create_page_request):void
		{
			_whole_create_page_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _whole_create_page_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#whole_create_page_lastResult
		 */	  
		public function get whole_create_page_lastResult():String
		{
			return _whole_create_page_lastResult;
		}
		/**
		 * @private
		 */
		public function set whole_create_page_lastResult(lastResult:String):void
		{
			_whole_create_page_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addwhole_create_page()
		 */
		public function addwhole_create_pageEventListener(listener:Function):void
		{
			addEventListener(Whole_create_pageResultEvent.Whole_create_page_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _whole_create_page_populate_results(event:ResultEvent):void
        {
        var e:Whole_create_pageResultEvent = new Whole_create_pageResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             whole_create_page_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the list_types operation
          

        /**
         * @see IVdom#list_types()
         */
        public function list_types(sid:String,skey:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.list_types(sid,skey);
            _internal_token.addEventListener("result",_list_types_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#list_types_send()
		 */    
        public function list_types_send():AsyncToken
        {
        	return list_types(_list_types_request.sid,_list_types_request.skey);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _list_types_request:List_types_request;
		/**
		 * @see IVdom#list_types_request_var
		 */
		[Bindable]
		public function get list_types_request_var():List_types_request
		{
			return _list_types_request;
		}
		
		/**
		 * @private
		 */
		public function set list_types_request_var(request:List_types_request):void
		{
			_list_types_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _list_types_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#list_types_lastResult
		 */	  
		public function get list_types_lastResult():String
		{
			return _list_types_lastResult;
		}
		/**
		 * @private
		 */
		public function set list_types_lastResult(lastResult:String):void
		{
			_list_types_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addlist_types()
		 */
		public function addlist_typesEventListener(listener:Function):void
		{
			addEventListener(List_typesResultEvent.List_types_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _list_types_populate_results(event:ResultEvent):void
        {
        var e:List_typesResultEvent = new List_typesResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             list_types_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the create_object operation
          

        /**
         * @see IVdom#create_object()
         */
        public function create_object(sid:String,skey:String,appid:String,parentid:String,typeid:String,name:String,attr:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.create_object(sid,skey,appid,parentid,typeid,name,attr);
            _internal_token.addEventListener("result",_create_object_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#create_object_send()
		 */    
        public function create_object_send():AsyncToken
        {
        	return create_object(_create_object_request.sid,_create_object_request.skey,_create_object_request.appid,_create_object_request.parentid,_create_object_request.typeid,_create_object_request.name,_create_object_request.attr);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _create_object_request:Create_object_request;
		/**
		 * @see IVdom#create_object_request_var
		 */
		[Bindable]
		public function get create_object_request_var():Create_object_request
		{
			return _create_object_request;
		}
		
		/**
		 * @private
		 */
		public function set create_object_request_var(request:Create_object_request):void
		{
			_create_object_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _create_object_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#create_object_lastResult
		 */	  
		public function get create_object_lastResult():String
		{
			return _create_object_lastResult;
		}
		/**
		 * @private
		 */
		public function set create_object_lastResult(lastResult:String):void
		{
			_create_object_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addcreate_object()
		 */
		public function addcreate_objectEventListener(listener:Function):void
		{
			addEventListener(Create_objectResultEvent.Create_object_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _create_object_populate_results(event:ResultEvent):void
        {
        var e:Create_objectResultEvent = new Create_objectResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             create_object_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the render_wysiwyg operation
          

        /**
         * @see IVdom#render_wysiwyg()
         */
        public function render_wysiwyg(sid:String,skey:String,appid:String,objid:String,parentid:String,_dynamic:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.render_wysiwyg(sid,skey,appid,objid,parentid,_dynamic);
            _internal_token.addEventListener("result",_render_wysiwyg_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#render_wysiwyg_send()
		 */    
        public function render_wysiwyg_send():AsyncToken
        {
        	return render_wysiwyg(_render_wysiwyg_request.sid,_render_wysiwyg_request.skey,_render_wysiwyg_request.appid,_render_wysiwyg_request.objid,_render_wysiwyg_request.parentid,_render_wysiwyg_request._dynamic);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _render_wysiwyg_request:Render_wysiwyg_request;
		/**
		 * @see IVdom#render_wysiwyg_request_var
		 */
		[Bindable]
		public function get render_wysiwyg_request_var():Render_wysiwyg_request
		{
			return _render_wysiwyg_request;
		}
		
		/**
		 * @private
		 */
		public function set render_wysiwyg_request_var(request:Render_wysiwyg_request):void
		{
			_render_wysiwyg_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _render_wysiwyg_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#render_wysiwyg_lastResult
		 */	  
		public function get render_wysiwyg_lastResult():String
		{
			return _render_wysiwyg_lastResult;
		}
		/**
		 * @private
		 */
		public function set render_wysiwyg_lastResult(lastResult:String):void
		{
			_render_wysiwyg_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addrender_wysiwyg()
		 */
		public function addrender_wysiwygEventListener(listener:Function):void
		{
			addEventListener(Render_wysiwygResultEvent.Render_wysiwyg_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _render_wysiwyg_populate_results(event:ResultEvent):void
        {
        var e:Render_wysiwygResultEvent = new Render_wysiwygResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             render_wysiwyg_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_attributes operation
          

        /**
         * @see IVdom#set_attributes()
         */
        public function set_attributes(sid:String,skey:String,appid:String,objid:String,attr:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_attributes(sid,skey,appid,objid,attr);
            _internal_token.addEventListener("result",_set_attributes_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_attributes_send()
		 */    
        public function set_attributes_send():AsyncToken
        {
        	return set_attributes(_set_attributes_request.sid,_set_attributes_request.skey,_set_attributes_request.appid,_set_attributes_request.objid,_set_attributes_request.attr);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_attributes_request:Set_attributes_request;
		/**
		 * @see IVdom#set_attributes_request_var
		 */
		[Bindable]
		public function get set_attributes_request_var():Set_attributes_request
		{
			return _set_attributes_request;
		}
		
		/**
		 * @private
		 */
		public function set set_attributes_request_var(request:Set_attributes_request):void
		{
			_set_attributes_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_attributes_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_attributes_lastResult
		 */	  
		public function get set_attributes_lastResult():String
		{
			return _set_attributes_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_attributes_lastResult(lastResult:String):void
		{
			_set_attributes_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_attributes()
		 */
		public function addset_attributesEventListener(listener:Function):void
		{
			addEventListener(Set_attributesResultEvent.Set_attributes_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_attributes_populate_results(event:ResultEvent):void
        {
        var e:Set_attributesResultEvent = new Set_attributesResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_attributes_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_script operation
          

        /**
         * @see IVdom#set_script()
         */
        public function set_script(sid:String,skey:String,appid:String,objid:String,script:String,lang:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_script(sid,skey,appid,objid,script,lang);
            _internal_token.addEventListener("result",_set_script_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_script_send()
		 */    
        public function set_script_send():AsyncToken
        {
        	return set_script(_set_script_request.sid,_set_script_request.skey,_set_script_request.appid,_set_script_request.objid,_set_script_request.script,_set_script_request.lang);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_script_request:Set_script_request;
		/**
		 * @see IVdom#set_script_request_var
		 */
		[Bindable]
		public function get set_script_request_var():Set_script_request
		{
			return _set_script_request;
		}
		
		/**
		 * @private
		 */
		public function set set_script_request_var(request:Set_script_request):void
		{
			_set_script_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_script_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_script_lastResult
		 */	  
		public function get set_script_lastResult():String
		{
			return _set_script_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_script_lastResult(lastResult:String):void
		{
			_set_script_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_script()
		 */
		public function addset_scriptEventListener(listener:Function):void
		{
			addEventListener(Set_scriptResultEvent.Set_script_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_script_populate_results(event:ResultEvent):void
        {
        var e:Set_scriptResultEvent = new Set_scriptResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_script_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_application_info operation
          

        /**
         * @see IVdom#get_application_info()
         */
        public function get_application_info(sid:String,skey:String,appid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_application_info(sid,skey,appid);
            _internal_token.addEventListener("result",_get_application_info_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_application_info_send()
		 */    
        public function get_application_info_send():AsyncToken
        {
        	return get_application_info(_get_application_info_request.sid,_get_application_info_request.skey,_get_application_info_request.appid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_application_info_request:Get_application_info_request;
		/**
		 * @see IVdom#get_application_info_request_var
		 */
		[Bindable]
		public function get get_application_info_request_var():Get_application_info_request
		{
			return _get_application_info_request;
		}
		
		/**
		 * @private
		 */
		public function set get_application_info_request_var(request:Get_application_info_request):void
		{
			_get_application_info_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_application_info_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_application_info_lastResult
		 */	  
		public function get get_application_info_lastResult():String
		{
			return _get_application_info_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_application_info_lastResult(lastResult:String):void
		{
			_get_application_info_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_application_info()
		 */
		public function addget_application_infoEventListener(listener:Function):void
		{
			addEventListener(Get_application_infoResultEvent.Get_application_info_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_application_info_populate_results(event:ResultEvent):void
        {
        var e:Get_application_infoResultEvent = new Get_application_infoResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_application_info_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_script operation
          

        /**
         * @see IVdom#get_script()
         */
        public function get_script(sid:String,skey:String,appid:String,objid:String,lang:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_script(sid,skey,appid,objid,lang);
            _internal_token.addEventListener("result",_get_script_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_script_send()
		 */    
        public function get_script_send():AsyncToken
        {
        	return get_script(_get_script_request.sid,_get_script_request.skey,_get_script_request.appid,_get_script_request.objid,_get_script_request.lang);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_script_request:Get_script_request;
		/**
		 * @see IVdom#get_script_request_var
		 */
		[Bindable]
		public function get get_script_request_var():Get_script_request
		{
			return _get_script_request;
		}
		
		/**
		 * @private
		 */
		public function set get_script_request_var(request:Get_script_request):void
		{
			_get_script_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_script_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_script_lastResult
		 */	  
		public function get get_script_lastResult():String
		{
			return _get_script_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_script_lastResult(lastResult:String):void
		{
			_get_script_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_script()
		 */
		public function addget_scriptEventListener(listener:Function):void
		{
			addEventListener(Get_scriptResultEvent.Get_script_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_script_populate_results(event:ResultEvent):void
        {
        var e:Get_scriptResultEvent = new Get_scriptResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_script_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_child_objects_tree operation
          

        /**
         * @see IVdom#get_child_objects_tree()
         */
        public function get_child_objects_tree(sid:String,skey:String,appid:String,objid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_child_objects_tree(sid,skey,appid,objid);
            _internal_token.addEventListener("result",_get_child_objects_tree_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_child_objects_tree_send()
		 */    
        public function get_child_objects_tree_send():AsyncToken
        {
        	return get_child_objects_tree(_get_child_objects_tree_request.sid,_get_child_objects_tree_request.skey,_get_child_objects_tree_request.appid,_get_child_objects_tree_request.objid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_child_objects_tree_request:Get_child_objects_tree_request;
		/**
		 * @see IVdom#get_child_objects_tree_request_var
		 */
		[Bindable]
		public function get get_child_objects_tree_request_var():Get_child_objects_tree_request
		{
			return _get_child_objects_tree_request;
		}
		
		/**
		 * @private
		 */
		public function set get_child_objects_tree_request_var(request:Get_child_objects_tree_request):void
		{
			_get_child_objects_tree_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_child_objects_tree_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_child_objects_tree_lastResult
		 */	  
		public function get get_child_objects_tree_lastResult():String
		{
			return _get_child_objects_tree_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_child_objects_tree_lastResult(lastResult:String):void
		{
			_get_child_objects_tree_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_child_objects_tree()
		 */
		public function addget_child_objects_treeEventListener(listener:Function):void
		{
			addEventListener(Get_child_objects_treeResultEvent.Get_child_objects_tree_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_child_objects_tree_populate_results(event:ResultEvent):void
        {
        var e:Get_child_objects_treeResultEvent = new Get_child_objects_treeResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_child_objects_tree_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the modify_resource operation
          

        /**
         * @see IVdom#modify_resource()
         */
        public function modify_resource(sid:String,skey:String,appid:String,objid:String,resid:String,attrname:String,operation:String,attr:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.modify_resource(sid,skey,appid,objid,resid,attrname,operation,attr);
            _internal_token.addEventListener("result",_modify_resource_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#modify_resource_send()
		 */    
        public function modify_resource_send():AsyncToken
        {
        	return modify_resource(_modify_resource_request.sid,_modify_resource_request.skey,_modify_resource_request.appid,_modify_resource_request.objid,_modify_resource_request.resid,_modify_resource_request.attrname,_modify_resource_request.operation,_modify_resource_request.attr);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _modify_resource_request:Modify_resource_request;
		/**
		 * @see IVdom#modify_resource_request_var
		 */
		[Bindable]
		public function get modify_resource_request_var():Modify_resource_request
		{
			return _modify_resource_request;
		}
		
		/**
		 * @private
		 */
		public function set modify_resource_request_var(request:Modify_resource_request):void
		{
			_modify_resource_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _modify_resource_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#modify_resource_lastResult
		 */	  
		public function get modify_resource_lastResult():String
		{
			return _modify_resource_lastResult;
		}
		/**
		 * @private
		 */
		public function set modify_resource_lastResult(lastResult:String):void
		{
			_modify_resource_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addmodify_resource()
		 */
		public function addmodify_resourceEventListener(listener:Function):void
		{
			addEventListener(Modify_resourceResultEvent.Modify_resource_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _modify_resource_populate_results(event:ResultEvent):void
        {
        var e:Modify_resourceResultEvent = new Modify_resourceResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             modify_resource_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_child_objects operation
          

        /**
         * @see IVdom#get_child_objects()
         */
        public function get_child_objects(sid:String,skey:String,appid:String,objid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_child_objects(sid,skey,appid,objid);
            _internal_token.addEventListener("result",_get_child_objects_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_child_objects_send()
		 */    
        public function get_child_objects_send():AsyncToken
        {
        	return get_child_objects(_get_child_objects_request.sid,_get_child_objects_request.skey,_get_child_objects_request.appid,_get_child_objects_request.objid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_child_objects_request:Get_child_objects_request;
		/**
		 * @see IVdom#get_child_objects_request_var
		 */
		[Bindable]
		public function get get_child_objects_request_var():Get_child_objects_request
		{
			return _get_child_objects_request;
		}
		
		/**
		 * @private
		 */
		public function set get_child_objects_request_var(request:Get_child_objects_request):void
		{
			_get_child_objects_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_child_objects_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_child_objects_lastResult
		 */	  
		public function get get_child_objects_lastResult():String
		{
			return _get_child_objects_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_child_objects_lastResult(lastResult:String):void
		{
			_get_child_objects_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_child_objects()
		 */
		public function addget_child_objectsEventListener(listener:Function):void
		{
			addEventListener(Get_child_objectsResultEvent.Get_child_objects_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_child_objects_populate_results(event:ResultEvent):void
        {
        var e:Get_child_objectsResultEvent = new Get_child_objectsResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_child_objects_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_resource operation
          

        /**
         * @see IVdom#get_resource()
         */
        public function get_resource(sid:String,skey:String,ownerid:String,resid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_resource(sid,skey,ownerid,resid);
            _internal_token.addEventListener("result",_get_resource_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_resource_send()
		 */    
        public function get_resource_send():AsyncToken
        {
        	return get_resource(_get_resource_request.sid,_get_resource_request.skey,_get_resource_request.ownerid,_get_resource_request.resid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_resource_request:Get_resource_request;
		/**
		 * @see IVdom#get_resource_request_var
		 */
		[Bindable]
		public function get get_resource_request_var():Get_resource_request
		{
			return _get_resource_request;
		}
		
		/**
		 * @private
		 */
		public function set get_resource_request_var(request:Get_resource_request):void
		{
			_get_resource_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_resource_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_resource_lastResult
		 */	  
		public function get get_resource_lastResult():String
		{
			return _get_resource_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_resource_lastResult(lastResult:String):void
		{
			_get_resource_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_resource()
		 */
		public function addget_resourceEventListener(listener:Function):void
		{
			addEventListener(Get_resourceResultEvent.Get_resource_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_resource_populate_results(event:ResultEvent):void
        {
        var e:Get_resourceResultEvent = new Get_resourceResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_resource_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_code_interface_data operation
          

        /**
         * @see IVdom#get_code_interface_data()
         */
        public function get_code_interface_data(sid:String,skey:String,appid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_code_interface_data(sid,skey,appid);
            _internal_token.addEventListener("result",_get_code_interface_data_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_code_interface_data_send()
		 */    
        public function get_code_interface_data_send():AsyncToken
        {
        	return get_code_interface_data(_get_code_interface_data_request.sid,_get_code_interface_data_request.skey,_get_code_interface_data_request.appid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_code_interface_data_request:Get_code_interface_data_request;
		/**
		 * @see IVdom#get_code_interface_data_request_var
		 */
		[Bindable]
		public function get get_code_interface_data_request_var():Get_code_interface_data_request
		{
			return _get_code_interface_data_request;
		}
		
		/**
		 * @private
		 */
		public function set get_code_interface_data_request_var(request:Get_code_interface_data_request):void
		{
			_get_code_interface_data_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_code_interface_data_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_code_interface_data_lastResult
		 */	  
		public function get get_code_interface_data_lastResult():String
		{
			return _get_code_interface_data_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_code_interface_data_lastResult(lastResult:String):void
		{
			_get_code_interface_data_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_code_interface_data()
		 */
		public function addget_code_interface_dataEventListener(listener:Function):void
		{
			addEventListener(Get_code_interface_dataResultEvent.Get_code_interface_data_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_code_interface_data_populate_results(event:ResultEvent):void
        {
        var e:Get_code_interface_dataResultEvent = new Get_code_interface_dataResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_code_interface_data_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_application_events operation
          

        /**
         * @see IVdom#get_application_events()
         */
        public function get_application_events(sid:String,skey:String,appid:String,objid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_application_events(sid,skey,appid,objid);
            _internal_token.addEventListener("result",_get_application_events_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_application_events_send()
		 */    
        public function get_application_events_send():AsyncToken
        {
        	return get_application_events(_get_application_events_request.sid,_get_application_events_request.skey,_get_application_events_request.appid,_get_application_events_request.objid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_application_events_request:Get_application_events_request;
		/**
		 * @see IVdom#get_application_events_request_var
		 */
		[Bindable]
		public function get get_application_events_request_var():Get_application_events_request
		{
			return _get_application_events_request;
		}
		
		/**
		 * @private
		 */
		public function set get_application_events_request_var(request:Get_application_events_request):void
		{
			_get_application_events_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_application_events_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_application_events_lastResult
		 */	  
		public function get get_application_events_lastResult():String
		{
			return _get_application_events_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_application_events_lastResult(lastResult:String):void
		{
			_get_application_events_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_application_events()
		 */
		public function addget_application_eventsEventListener(listener:Function):void
		{
			addEventListener(Get_application_eventsResultEvent.Get_application_events_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_application_events_populate_results(event:ResultEvent):void
        {
        var e:Get_application_eventsResultEvent = new Get_application_eventsResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_application_events_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the about operation
          

        /**
         * @see IVdom#about()
         */
        public function about():AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.about();
            _internal_token.addEventListener("result",_about_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#about_send()
		 */    
        public function about_send():AsyncToken
        {
        	return about();
        }
              
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _about_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#about_lastResult
		 */	  
		public function get about_lastResult():String
		{
			return _about_lastResult;
		}
		/**
		 * @private
		 */
		public function set about_lastResult(lastResult:String):void
		{
			_about_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addabout()
		 */
		public function addaboutEventListener(listener:Function):void
		{
			addEventListener(AboutResultEvent.About_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _about_populate_results(event:ResultEvent):void
        {
        var e:AboutResultEvent = new AboutResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             about_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_resource operation
          

        /**
         * @see IVdom#set_resource()
         */
        public function set_resource(sid:String,skey:String,appid:String,restype:String,resname:String,resdata:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_resource(sid,skey,appid,restype,resname,resdata);
            _internal_token.addEventListener("result",_set_resource_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_resource_send()
		 */    
        public function set_resource_send():AsyncToken
        {
        	return set_resource(_set_resource_request.sid,_set_resource_request.skey,_set_resource_request.appid,_set_resource_request.restype,_set_resource_request.resname,_set_resource_request.resdata);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_resource_request:Set_resource_request;
		/**
		 * @see IVdom#set_resource_request_var
		 */
		[Bindable]
		public function get set_resource_request_var():Set_resource_request
		{
			return _set_resource_request;
		}
		
		/**
		 * @private
		 */
		public function set set_resource_request_var(request:Set_resource_request):void
		{
			_set_resource_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_resource_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_resource_lastResult
		 */	  
		public function get set_resource_lastResult():String
		{
			return _set_resource_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_resource_lastResult(lastResult:String):void
		{
			_set_resource_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_resource()
		 */
		public function addset_resourceEventListener(listener:Function):void
		{
			addEventListener(Set_resourceResultEvent.Set_resource_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_resource_populate_results(event:ResultEvent):void
        {
        var e:Set_resourceResultEvent = new Set_resourceResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_resource_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_application_events operation
          

        /**
         * @see IVdom#set_application_events()
         */
        public function set_application_events(sid:String,skey:String,appid:String,objid:String,events:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_application_events(sid,skey,appid,objid,events);
            _internal_token.addEventListener("result",_set_application_events_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_application_events_send()
		 */    
        public function set_application_events_send():AsyncToken
        {
        	return set_application_events(_set_application_events_request.sid,_set_application_events_request.skey,_set_application_events_request.appid,_set_application_events_request.objid,_set_application_events_request.events);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_application_events_request:Set_application_events_request;
		/**
		 * @see IVdom#set_application_events_request_var
		 */
		[Bindable]
		public function get set_application_events_request_var():Set_application_events_request
		{
			return _set_application_events_request;
		}
		
		/**
		 * @private
		 */
		public function set set_application_events_request_var(request:Set_application_events_request):void
		{
			_set_application_events_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_application_events_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_application_events_lastResult
		 */	  
		public function get set_application_events_lastResult():String
		{
			return _set_application_events_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_application_events_lastResult(lastResult:String):void
		{
			_set_application_events_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_application_events()
		 */
		public function addset_application_eventsEventListener(listener:Function):void
		{
			addEventListener(Set_application_eventsResultEvent.Set_application_events_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_application_events_populate_results(event:ResultEvent):void
        {
        var e:Set_application_eventsResultEvent = new Set_application_eventsResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_application_events_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the list_resources operation
          

        /**
         * @see IVdom#list_resources()
         */
        public function list_resources(sid:String,skey:String,ownerid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.list_resources(sid,skey,ownerid);
            _internal_token.addEventListener("result",_list_resources_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#list_resources_send()
		 */    
        public function list_resources_send():AsyncToken
        {
        	return list_resources(_list_resources_request.sid,_list_resources_request.skey,_list_resources_request.ownerid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _list_resources_request:List_resources_request;
		/**
		 * @see IVdom#list_resources_request_var
		 */
		[Bindable]
		public function get list_resources_request_var():List_resources_request
		{
			return _list_resources_request;
		}
		
		/**
		 * @private
		 */
		public function set list_resources_request_var(request:List_resources_request):void
		{
			_list_resources_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _list_resources_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#list_resources_lastResult
		 */	  
		public function get list_resources_lastResult():String
		{
			return _list_resources_lastResult;
		}
		/**
		 * @private
		 */
		public function set list_resources_lastResult(lastResult:String):void
		{
			_list_resources_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addlist_resources()
		 */
		public function addlist_resourcesEventListener(listener:Function):void
		{
			addEventListener(List_resourcesResultEvent.List_resources_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _list_resources_populate_results(event:ResultEvent):void
        {
        var e:List_resourcesResultEvent = new List_resourcesResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             list_resources_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_all_types operation
          

        /**
         * @see IVdom#get_all_types()
         */
        public function get_all_types(sid:String,skey:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_all_types(sid,skey);
            _internal_token.addEventListener("result",_get_all_types_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_all_types_send()
		 */    
        public function get_all_types_send():AsyncToken
        {
        	return get_all_types(_get_all_types_request.sid,_get_all_types_request.skey);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_all_types_request:Get_all_types_request;
		/**
		 * @see IVdom#get_all_types_request_var
		 */
		[Bindable]
		public function get get_all_types_request_var():Get_all_types_request
		{
			return _get_all_types_request;
		}
		
		/**
		 * @private
		 */
		public function set get_all_types_request_var(request:Get_all_types_request):void
		{
			_get_all_types_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_all_types_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_all_types_lastResult
		 */	  
		public function get get_all_types_lastResult():String
		{
			return _get_all_types_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_all_types_lastResult(lastResult:String):void
		{
			_get_all_types_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_all_types()
		 */
		public function addget_all_typesEventListener(listener:Function):void
		{
			addEventListener(Get_all_typesResultEvent.Get_all_types_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_all_types_populate_results(event:ResultEvent):void
        {
        var e:Get_all_typesResultEvent = new Get_all_typesResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_all_types_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the set_attribute operation
          

        /**
         * @see IVdom#set_attribute()
         */
        public function set_attribute(sid:String,skey:String,appid:String,objid:String,attr:String,value:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.set_attribute(sid,skey,appid,objid,attr,value);
            _internal_token.addEventListener("result",_set_attribute_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#set_attribute_send()
		 */    
        public function set_attribute_send():AsyncToken
        {
        	return set_attribute(_set_attribute_request.sid,_set_attribute_request.skey,_set_attribute_request.appid,_set_attribute_request.objid,_set_attribute_request.attr,_set_attribute_request.value);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _set_attribute_request:Set_attribute_request;
		/**
		 * @see IVdom#set_attribute_request_var
		 */
		[Bindable]
		public function get set_attribute_request_var():Set_attribute_request
		{
			return _set_attribute_request;
		}
		
		/**
		 * @private
		 */
		public function set set_attribute_request_var(request:Set_attribute_request):void
		{
			_set_attribute_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _set_attribute_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#set_attribute_lastResult
		 */	  
		public function get set_attribute_lastResult():String
		{
			return _set_attribute_lastResult;
		}
		/**
		 * @private
		 */
		public function set set_attribute_lastResult(lastResult:String):void
		{
			_set_attribute_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addset_attribute()
		 */
		public function addset_attributeEventListener(listener:Function):void
		{
			addEventListener(Set_attributeResultEvent.Set_attribute_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _set_attribute_populate_results(event:ResultEvent):void
        {
        var e:Set_attributeResultEvent = new Set_attributeResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             set_attribute_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the whole_update operation
          

        /**
         * @see IVdom#whole_update()
         */
        public function whole_update(sid:String,skey:String,appid:String,objid:String,data:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.whole_update(sid,skey,appid,objid,data);
            _internal_token.addEventListener("result",_whole_update_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#whole_update_send()
		 */    
        public function whole_update_send():AsyncToken
        {
        	return whole_update(_whole_update_request.sid,_whole_update_request.skey,_whole_update_request.appid,_whole_update_request.objid,_whole_update_request.data);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _whole_update_request:Whole_update_request;
		/**
		 * @see IVdom#whole_update_request_var
		 */
		[Bindable]
		public function get whole_update_request_var():Whole_update_request
		{
			return _whole_update_request;
		}
		
		/**
		 * @private
		 */
		public function set whole_update_request_var(request:Whole_update_request):void
		{
			_whole_update_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _whole_update_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#whole_update_lastResult
		 */	  
		public function get whole_update_lastResult():String
		{
			return _whole_update_lastResult;
		}
		/**
		 * @private
		 */
		public function set whole_update_lastResult(lastResult:String):void
		{
			_whole_update_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addwhole_update()
		 */
		public function addwhole_updateEventListener(listener:Function):void
		{
			addEventListener(Whole_updateResultEvent.Whole_update_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _whole_update_populate_results(event:ResultEvent):void
        {
        var e:Whole_updateResultEvent = new Whole_updateResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             whole_update_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the get_object_script_presentation operation
          

        /**
         * @see IVdom#get_object_script_presentation()
         */
        public function get_object_script_presentation(sid:String,skey:String,appid:String,objid:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.get_object_script_presentation(sid,skey,appid,objid);
            _internal_token.addEventListener("result",_get_object_script_presentation_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#get_object_script_presentation_send()
		 */    
        public function get_object_script_presentation_send():AsyncToken
        {
        	return get_object_script_presentation(_get_object_script_presentation_request.sid,_get_object_script_presentation_request.skey,_get_object_script_presentation_request.appid,_get_object_script_presentation_request.objid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _get_object_script_presentation_request:Get_object_script_presentation_request;
		/**
		 * @see IVdom#get_object_script_presentation_request_var
		 */
		[Bindable]
		public function get get_object_script_presentation_request_var():Get_object_script_presentation_request
		{
			return _get_object_script_presentation_request;
		}
		
		/**
		 * @private
		 */
		public function set get_object_script_presentation_request_var(request:Get_object_script_presentation_request):void
		{
			_get_object_script_presentation_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _get_object_script_presentation_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#get_object_script_presentation_lastResult
		 */	  
		public function get get_object_script_presentation_lastResult():String
		{
			return _get_object_script_presentation_lastResult;
		}
		/**
		 * @private
		 */
		public function set get_object_script_presentation_lastResult(lastResult:String):void
		{
			_get_object_script_presentation_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addget_object_script_presentation()
		 */
		public function addget_object_script_presentationEventListener(listener:Function):void
		{
			addEventListener(Get_object_script_presentationResultEvent.Get_object_script_presentation_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _get_object_script_presentation_populate_results(event:ResultEvent):void
        {
        var e:Get_object_script_presentationResultEvent = new Get_object_script_presentationResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             get_object_script_presentation_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the install_application operation
          

        /**
         * @see IVdom#install_application()
         */
        public function install_application(sid:String,skey:String,vhname:String,appxml:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.install_application(sid,skey,vhname,appxml);
            _internal_token.addEventListener("result",_install_application_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IVdom#install_application_send()
		 */    
        public function install_application_send():AsyncToken
        {
        	return install_application(_install_application_request.sid,_install_application_request.skey,_install_application_request.vhname,_install_application_request.appxml);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _install_application_request:Install_application_request;
		/**
		 * @see IVdom#install_application_request_var
		 */
		[Bindable]
		public function get install_application_request_var():Install_application_request
		{
			return _install_application_request;
		}
		
		/**
		 * @private
		 */
		public function set install_application_request_var(request:Install_application_request):void
		{
			_install_application_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _install_application_lastResult:String;
		[Bindable]
		/**
		 * @see IVdom#install_application_lastResult
		 */	  
		public function get install_application_lastResult():String
		{
			return _install_application_lastResult;
		}
		/**
		 * @private
		 */
		public function set install_application_lastResult(lastResult:String):void
		{
			_install_application_lastResult = lastResult;
		}
		
		/**
		 * @see IVdom#addinstall_application()
		 */
		public function addinstall_applicationEventListener(listener:Function):void
		{
			addEventListener(Install_applicationResultEvent.Install_application_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _install_application_populate_results(event:ResultEvent):void
        {
        var e:Install_applicationResultEvent = new Install_applicationResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             install_application_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//service-wide functions
		/**
		 * @see IVdom#getWebService()
		 */
		public function getWebService():Basevdom
		{
			return _baseService;
		}
		
		/**
		 * Set the event listener for the fault event which can be triggered by each of the operations defined by the facade
		 */
		public function addVdomFaultEventListener(listener:Function):void
		{
			addEventListener("fault",listener);
		}
		
		/**
		 * Internal function to re-dispatch the fault event passed on by the base service implementation
		 * @private
		 */
		 
		 private function throwFault(event:FaultEvent):void
		 {
		 	dispatchEvent(event);
		 }
    }
}
