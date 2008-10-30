
/**
 * Service.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package generated.webservices{
	import mx.rpc.AsyncToken;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
               
    public interface IVdom
    {
    	//Stub functions for the get_echo operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @return An AsyncToken
    	 */
    	function get_echo(sid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_echo_send():AsyncToken;
        
        /**
         * The get_echo operation lastResult property
         */
        function get get_echo_lastResult():String;
		/**
		 * @private
		 */
        function set get_echo_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_echo operation successful result event
        * @param The listener function
        */
       function addget_echoEventListener(listener:Function):void;
       
       
        /**
         * The get_echo operation request wrapper
         */
        function get get_echo_request_var():Get_echo_request;
        
        /**
         * @private
         */
        function set get_echo_request_var(request:Get_echo_request):void;
                   
    	//Stub functions for the create_guid operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @return An AsyncToken
    	 */
    	function create_guid(sid:String,skey:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function create_guid_send():AsyncToken;
        
        /**
         * The create_guid operation lastResult property
         */
        function get create_guid_lastResult():String;
		/**
		 * @private
		 */
        function set create_guid_lastResult(lastResult:String):void;
       /**
        * Add a listener for the create_guid operation successful result event
        * @param The listener function
        */
       function addcreate_guidEventListener(listener:Function):void;
       
       
        /**
         * The create_guid operation request wrapper
         */
        function get create_guid_request_var():Create_guid_request;
        
        /**
         * @private
         */
        function set create_guid_request_var(request:Create_guid_request):void;
                   
    	//Stub functions for the delete_object operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @return An AsyncToken
    	 */
    	function delete_object(sid:String,skey:String,appid:String,objid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function delete_object_send():AsyncToken;
        
        /**
         * The delete_object operation lastResult property
         */
        function get delete_object_lastResult():String;
		/**
		 * @private
		 */
        function set delete_object_lastResult(lastResult:String):void;
       /**
        * Add a listener for the delete_object operation successful result event
        * @param The listener function
        */
       function adddelete_objectEventListener(listener:Function):void;
       
       
        /**
         * The delete_object operation request wrapper
         */
        function get delete_object_request_var():Delete_object_request;
        
        /**
         * @private
         */
        function set delete_object_request_var(request:Delete_object_request):void;
                   
    	//Stub functions for the update_object operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param data
    	 * @return An AsyncToken
    	 */
    	function update_object(sid:String,skey:String,appid:String,objid:String,data:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function update_object_send():AsyncToken;
        
        /**
         * The update_object operation lastResult property
         */
        function get update_object_lastResult():String;
		/**
		 * @private
		 */
        function set update_object_lastResult(lastResult:String):void;
       /**
        * Add a listener for the update_object operation successful result event
        * @param The listener function
        */
       function addupdate_objectEventListener(listener:Function):void;
       
       
        /**
         * The update_object operation request wrapper
         */
        function get update_object_request_var():Update_object_request;
        
        /**
         * @private
         */
        function set update_object_request_var(request:Update_object_request):void;
                   
    	//Stub functions for the whole_delete operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @return An AsyncToken
    	 */
    	function whole_delete(sid:String,skey:String,appid:String,objid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function whole_delete_send():AsyncToken;
        
        /**
         * The whole_delete operation lastResult property
         */
        function get whole_delete_lastResult():String;
		/**
		 * @private
		 */
        function set whole_delete_lastResult(lastResult:String):void;
       /**
        * Add a listener for the whole_delete operation successful result event
        * @param The listener function
        */
       function addwhole_deleteEventListener(listener:Function):void;
       
       
        /**
         * The whole_delete operation request wrapper
         */
        function get whole_delete_request_var():Whole_delete_request;
        
        /**
         * @private
         */
        function set whole_delete_request_var(request:Whole_delete_request):void;
                   
    	//Stub functions for the search operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param pattern
    	 * @return An AsyncToken
    	 */
    	function search(sid:String,skey:String,appid:String,pattern:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function search_send():AsyncToken;
        
        /**
         * The search operation lastResult property
         */
        function get search_lastResult():String;
		/**
		 * @private
		 */
        function set search_lastResult(lastResult:String):void;
       /**
        * Add a listener for the search operation successful result event
        * @param The listener function
        */
       function addsearchEventListener(listener:Function):void;
       
       
        /**
         * The search operation request wrapper
         */
        function get search_request_var():Search_request;
        
        /**
         * @private
         */
        function set search_request_var(request:Search_request):void;
                   
    	//Stub functions for the keep_alive operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @return An AsyncToken
    	 */
    	function keep_alive(sid:String,skey:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function keep_alive_send():AsyncToken;
        
        /**
         * The keep_alive operation lastResult property
         */
        function get keep_alive_lastResult():String;
		/**
		 * @private
		 */
        function set keep_alive_lastResult(lastResult:String):void;
       /**
        * Add a listener for the keep_alive operation successful result event
        * @param The listener function
        */
       function addkeep_aliveEventListener(listener:Function):void;
       
       
        /**
         * The keep_alive operation request wrapper
         */
        function get keep_alive_request_var():Keep_alive_request;
        
        /**
         * @private
         */
        function set keep_alive_request_var(request:Keep_alive_request):void;
                   
    	//Stub functions for the close_session operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @return An AsyncToken
    	 */
    	function close_session(sid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function close_session_send():AsyncToken;
        
        /**
         * The close_session operation lastResult property
         */
        function get close_session_lastResult():String;
		/**
		 * @private
		 */
        function set close_session_lastResult(lastResult:String):void;
       /**
        * Add a listener for the close_session operation successful result event
        * @param The listener function
        */
       function addclose_sessionEventListener(listener:Function):void;
       
       
        /**
         * The close_session operation request wrapper
         */
        function get close_session_request_var():Close_session_request;
        
        /**
         * @private
         */
        function set close_session_request_var(request:Close_session_request):void;
                   
    	//Stub functions for the open_session operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param name
    	 * @param pwd_md5
    	 * @return An AsyncToken
    	 */
    	function open_session(name:String,pwd_md5:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function open_session_send():AsyncToken;
        
        /**
         * The open_session operation lastResult property
         */
        function get open_session_lastResult():String;
		/**
		 * @private
		 */
        function set open_session_lastResult(lastResult:String):void;
       /**
        * Add a listener for the open_session operation successful result event
        * @param The listener function
        */
       function addopen_sessionEventListener(listener:Function):void;
       
       
        /**
         * The open_session operation request wrapper
         */
        function get open_session_request_var():Open_session_request;
        
        /**
         * @private
         */
        function set open_session_request_var(request:Open_session_request):void;
                   
    	//Stub functions for the get_type operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param typeid
    	 * @return An AsyncToken
    	 */
    	function get_type(sid:String,skey:String,typeid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_type_send():AsyncToken;
        
        /**
         * The get_type operation lastResult property
         */
        function get get_type_lastResult():String;
		/**
		 * @private
		 */
        function set get_type_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_type operation successful result event
        * @param The listener function
        */
       function addget_typeEventListener(listener:Function):void;
       
       
        /**
         * The get_type operation request wrapper
         */
        function get get_type_request_var():Get_type_request;
        
        /**
         * @private
         */
        function set get_type_request_var(request:Get_type_request):void;
                   
    	//Stub functions for the set_server_actions operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param actions
    	 * @return An AsyncToken
    	 */
    	function set_server_actions(sid:String,skey:String,appid:String,objid:String,actions:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_server_actions_send():AsyncToken;
        
        /**
         * The set_server_actions operation lastResult property
         */
        function get set_server_actions_lastResult():String;
		/**
		 * @private
		 */
        function set set_server_actions_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_server_actions operation successful result event
        * @param The listener function
        */
       function addset_server_actionsEventListener(listener:Function):void;
       
       
        /**
         * The set_server_actions operation request wrapper
         */
        function get set_server_actions_request_var():Set_server_actions_request;
        
        /**
         * @private
         */
        function set set_server_actions_request_var(request:Set_server_actions_request):void;
                   
    	//Stub functions for the send_event operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param evdata
    	 * @return An AsyncToken
    	 */
    	function send_event(sid:String,skey:String,evdata:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function send_event_send():AsyncToken;
        
        /**
         * The send_event operation lastResult property
         */
        function get send_event_lastResult():String;
		/**
		 * @private
		 */
        function set send_event_lastResult(lastResult:String):void;
       /**
        * Add a listener for the send_event operation successful result event
        * @param The listener function
        */
       function addsend_eventEventListener(listener:Function):void;
       
       
        /**
         * The send_event operation request wrapper
         */
        function get send_event_request_var():Send_event_request;
        
        /**
         * @private
         */
        function set send_event_request_var(request:Send_event_request):void;
                   
    	//Stub functions for the create_objects operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param parentid
    	 * @param objects
    	 * @return An AsyncToken
    	 */
    	function create_objects(sid:String,skey:String,appid:String,parentid:String,objects:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function create_objects_send():AsyncToken;
        
        /**
         * The create_objects operation lastResult property
         */
        function get create_objects_lastResult():String;
		/**
		 * @private
		 */
        function set create_objects_lastResult(lastResult:String):void;
       /**
        * Add a listener for the create_objects operation successful result event
        * @param The listener function
        */
       function addcreate_objectsEventListener(listener:Function):void;
       
       
        /**
         * The create_objects operation request wrapper
         */
        function get create_objects_request_var():Create_objects_request;
        
        /**
         * @private
         */
        function set create_objects_request_var(request:Create_objects_request):void;
                   
    	//Stub functions for the set_application_info operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param attr
    	 * @return An AsyncToken
    	 */
    	function set_application_info(sid:String,skey:String,appid:String,attr:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_application_info_send():AsyncToken;
        
        /**
         * The set_application_info operation lastResult property
         */
        function get set_application_info_lastResult():String;
		/**
		 * @private
		 */
        function set set_application_info_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_application_info operation successful result event
        * @param The listener function
        */
       function addset_application_infoEventListener(listener:Function):void;
       
       
        /**
         * The set_application_info operation request wrapper
         */
        function get set_application_info_request_var():Set_application_info_request;
        
        /**
         * @private
         */
        function set set_application_info_request_var(request:Set_application_info_request):void;
                   
    	//Stub functions for the list_applications operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @return An AsyncToken
    	 */
    	function list_applications(sid:String,skey:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function list_applications_send():AsyncToken;
        
        /**
         * The list_applications operation lastResult property
         */
        function get list_applications_lastResult():String;
		/**
		 * @private
		 */
        function set list_applications_lastResult(lastResult:String):void;
       /**
        * Add a listener for the list_applications operation successful result event
        * @param The listener function
        */
       function addlist_applicationsEventListener(listener:Function):void;
       
       
        /**
         * The list_applications operation request wrapper
         */
        function get list_applications_request_var():List_applications_request;
        
        /**
         * @private
         */
        function set list_applications_request_var(request:List_applications_request):void;
                   
    	//Stub functions for the export_application operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @return An AsyncToken
    	 */
    	function export_application(sid:String,skey:String,appid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function export_application_send():AsyncToken;
        
        /**
         * The export_application operation lastResult property
         */
        function get export_application_lastResult():String;
		/**
		 * @private
		 */
        function set export_application_lastResult(lastResult:String):void;
       /**
        * Add a listener for the export_application operation successful result event
        * @param The listener function
        */
       function addexport_applicationEventListener(listener:Function):void;
       
       
        /**
         * The export_application operation request wrapper
         */
        function get export_application_request_var():Export_application_request;
        
        /**
         * @private
         */
        function set export_application_request_var(request:Export_application_request):void;
                   
    	//Stub functions for the execute_sql operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param dbid
    	 * @param sql
    	 * @param script
    	 * @return An AsyncToken
    	 */
    	function execute_sql(sid:String,skey:String,appid:String,dbid:String,sql:String,script:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function execute_sql_send():AsyncToken;
        
        /**
         * The execute_sql operation lastResult property
         */
        function get execute_sql_lastResult():String;
		/**
		 * @private
		 */
        function set execute_sql_lastResult(lastResult:String):void;
       /**
        * Add a listener for the execute_sql operation successful result event
        * @param The listener function
        */
       function addexecute_sqlEventListener(listener:Function):void;
       
       
        /**
         * The execute_sql operation request wrapper
         */
        function get execute_sql_request_var():Execute_sql_request;
        
        /**
         * @private
         */
        function set execute_sql_request_var(request:Execute_sql_request):void;
                   
    	//Stub functions for the create_application operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param attr
    	 * @return An AsyncToken
    	 */
    	function create_application(sid:String,skey:String,attr:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function create_application_send():AsyncToken;
        
        /**
         * The create_application operation lastResult property
         */
        function get create_application_lastResult():String;
		/**
		 * @private
		 */
        function set create_application_lastResult(lastResult:String):void;
       /**
        * Add a listener for the create_application operation successful result event
        * @param The listener function
        */
       function addcreate_applicationEventListener(listener:Function):void;
       
       
        /**
         * The create_application operation request wrapper
         */
        function get create_application_request_var():Create_application_request;
        
        /**
         * @private
         */
        function set create_application_request_var(request:Create_application_request):void;
                   
    	//Stub functions for the submit_object_script_presentation operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param pres
    	 * @return An AsyncToken
    	 */
    	function submit_object_script_presentation(sid:String,skey:String,appid:String,objid:String,pres:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function submit_object_script_presentation_send():AsyncToken;
        
        /**
         * The submit_object_script_presentation operation lastResult property
         */
        function get submit_object_script_presentation_lastResult():String;
		/**
		 * @private
		 */
        function set submit_object_script_presentation_lastResult(lastResult:String):void;
       /**
        * Add a listener for the submit_object_script_presentation operation successful result event
        * @param The listener function
        */
       function addsubmit_object_script_presentationEventListener(listener:Function):void;
       
       
        /**
         * The submit_object_script_presentation operation request wrapper
         */
        function get submit_object_script_presentation_request_var():Submit_object_script_presentation_request;
        
        /**
         * @private
         */
        function set submit_object_script_presentation_request_var(request:Submit_object_script_presentation_request):void;
                   
    	//Stub functions for the whole_create operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param parentid
    	 * @param name
    	 * @param data
    	 * @return An AsyncToken
    	 */
    	function whole_create(sid:String,skey:String,appid:String,parentid:String,name:String,data:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function whole_create_send():AsyncToken;
        
        /**
         * The whole_create operation lastResult property
         */
        function get whole_create_lastResult():String;
		/**
		 * @private
		 */
        function set whole_create_lastResult(lastResult:String):void;
       /**
        * Add a listener for the whole_create operation successful result event
        * @param The listener function
        */
       function addwhole_createEventListener(listener:Function):void;
       
       
        /**
         * The whole_create operation request wrapper
         */
        function get whole_create_request_var():Whole_create_request;
        
        /**
         * @private
         */
        function set whole_create_request_var(request:Whole_create_request):void;
                   
    	//Stub functions for the remote_method_call operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param func_name
    	 * @param xml_param
    	 * @param session_id
    	 * @return An AsyncToken
    	 */
    	function remote_method_call(sid:String,skey:String,appid:String,objid:String,func_name:String,xml_param:String,session_id:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function remote_method_call_send():AsyncToken;
        
        /**
         * The remote_method_call operation lastResult property
         */
        function get remote_method_call_lastResult():String;
		/**
		 * @private
		 */
        function set remote_method_call_lastResult(lastResult:String):void;
       /**
        * Add a listener for the remote_method_call operation successful result event
        * @param The listener function
        */
       function addremote_method_callEventListener(listener:Function):void;
       
       
        /**
         * The remote_method_call operation request wrapper
         */
        function get remote_method_call_request_var():Remote_method_call_request;
        
        /**
         * @private
         */
        function set remote_method_call_request_var(request:Remote_method_call_request):void;
                   
    	//Stub functions for the get_application_structure operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @return An AsyncToken
    	 */
    	function get_application_structure(sid:String,skey:String,appid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_application_structure_send():AsyncToken;
        
        /**
         * The get_application_structure operation lastResult property
         */
        function get get_application_structure_lastResult():String;
		/**
		 * @private
		 */
        function set get_application_structure_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_application_structure operation successful result event
        * @param The listener function
        */
       function addget_application_structureEventListener(listener:Function):void;
       
       
        /**
         * The get_application_structure operation request wrapper
         */
        function get get_application_structure_request_var():Get_application_structure_request;
        
        /**
         * @private
         */
        function set get_application_structure_request_var(request:Get_application_structure_request):void;
                   
    	//Stub functions for the get_thumbnail operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param resid
    	 * @param width
    	 * @param height
    	 * @return An AsyncToken
    	 */
    	function get_thumbnail(sid:String,skey:String,appid:String,resid:String,width:String,height:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_thumbnail_send():AsyncToken;
        
        /**
         * The get_thumbnail operation lastResult property
         */
        function get get_thumbnail_lastResult():String;
		/**
		 * @private
		 */
        function set get_thumbnail_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_thumbnail operation successful result event
        * @param The listener function
        */
       function addget_thumbnailEventListener(listener:Function):void;
       
       
        /**
         * The get_thumbnail operation request wrapper
         */
        function get get_thumbnail_request_var():Get_thumbnail_request;
        
        /**
         * @private
         */
        function set get_thumbnail_request_var(request:Get_thumbnail_request):void;
                   
    	//Stub functions for the get_application_language_data operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @return An AsyncToken
    	 */
    	function get_application_language_data(sid:String,skey:String,appid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_application_language_data_send():AsyncToken;
        
        /**
         * The get_application_language_data operation lastResult property
         */
        function get get_application_language_data_lastResult():String;
		/**
		 * @private
		 */
        function set get_application_language_data_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_application_language_data operation successful result event
        * @param The listener function
        */
       function addget_application_language_dataEventListener(listener:Function):void;
       
       
        /**
         * The get_application_language_data operation request wrapper
         */
        function get get_application_language_data_request_var():Get_application_language_data_request;
        
        /**
         * @private
         */
        function set get_application_language_data_request_var(request:Get_application_language_data_request):void;
                   
    	//Stub functions for the set_application_structure operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param struct
    	 * @return An AsyncToken
    	 */
    	function set_application_structure(sid:String,skey:String,appid:String,struct:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_application_structure_send():AsyncToken;
        
        /**
         * The set_application_structure operation lastResult property
         */
        function get set_application_structure_lastResult():String;
		/**
		 * @private
		 */
        function set set_application_structure_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_application_structure operation successful result event
        * @param The listener function
        */
       function addset_application_structureEventListener(listener:Function):void;
       
       
        /**
         * The set_application_structure operation request wrapper
         */
        function get set_application_structure_request_var():Set_application_structure_request;
        
        /**
         * @private
         */
        function set set_application_structure_request_var(request:Set_application_structure_request):void;
                   
    	//Stub functions for the get_one_object operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @return An AsyncToken
    	 */
    	function get_one_object(sid:String,skey:String,appid:String,objid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_one_object_send():AsyncToken;
        
        /**
         * The get_one_object operation lastResult property
         */
        function get get_one_object_lastResult():String;
		/**
		 * @private
		 */
        function set get_one_object_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_one_object operation successful result event
        * @param The listener function
        */
       function addget_one_objectEventListener(listener:Function):void;
       
       
        /**
         * The get_one_object operation request wrapper
         */
        function get get_one_object_request_var():Get_one_object_request;
        
        /**
         * @private
         */
        function set get_one_object_request_var(request:Get_one_object_request):void;
                   
    	//Stub functions for the set_name operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param name
    	 * @return An AsyncToken
    	 */
    	function set_name(sid:String,skey:String,appid:String,objid:String,name:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_name_send():AsyncToken;
        
        /**
         * The set_name operation lastResult property
         */
        function get set_name_lastResult():String;
		/**
		 * @private
		 */
        function set set_name_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_name operation successful result event
        * @param The listener function
        */
       function addset_nameEventListener(listener:Function):void;
       
       
        /**
         * The set_name operation request wrapper
         */
        function get set_name_request_var():Set_name_request;
        
        /**
         * @private
         */
        function set set_name_request_var(request:Set_name_request):void;
                   
    	//Stub functions for the whole_create_page operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param sourceid
    	 * @return An AsyncToken
    	 */
    	function whole_create_page(sid:String,skey:String,appid:String,sourceid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function whole_create_page_send():AsyncToken;
        
        /**
         * The whole_create_page operation lastResult property
         */
        function get whole_create_page_lastResult():String;
		/**
		 * @private
		 */
        function set whole_create_page_lastResult(lastResult:String):void;
       /**
        * Add a listener for the whole_create_page operation successful result event
        * @param The listener function
        */
       function addwhole_create_pageEventListener(listener:Function):void;
       
       
        /**
         * The whole_create_page operation request wrapper
         */
        function get whole_create_page_request_var():Whole_create_page_request;
        
        /**
         * @private
         */
        function set whole_create_page_request_var(request:Whole_create_page_request):void;
                   
    	//Stub functions for the list_types operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @return An AsyncToken
    	 */
    	function list_types(sid:String,skey:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function list_types_send():AsyncToken;
        
        /**
         * The list_types operation lastResult property
         */
        function get list_types_lastResult():String;
		/**
		 * @private
		 */
        function set list_types_lastResult(lastResult:String):void;
       /**
        * Add a listener for the list_types operation successful result event
        * @param The listener function
        */
       function addlist_typesEventListener(listener:Function):void;
       
       
        /**
         * The list_types operation request wrapper
         */
        function get list_types_request_var():List_types_request;
        
        /**
         * @private
         */
        function set list_types_request_var(request:List_types_request):void;
                   
    	//Stub functions for the create_object operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param parentid
    	 * @param typeid
    	 * @param name
    	 * @param attr
    	 * @return An AsyncToken
    	 */
    	function create_object(sid:String,skey:String,appid:String,parentid:String,typeid:String,name:String,attr:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function create_object_send():AsyncToken;
        
        /**
         * The create_object operation lastResult property
         */
        function get create_object_lastResult():String;
		/**
		 * @private
		 */
        function set create_object_lastResult(lastResult:String):void;
       /**
        * Add a listener for the create_object operation successful result event
        * @param The listener function
        */
       function addcreate_objectEventListener(listener:Function):void;
       
       
        /**
         * The create_object operation request wrapper
         */
        function get create_object_request_var():Create_object_request;
        
        /**
         * @private
         */
        function set create_object_request_var(request:Create_object_request):void;
                   
    	//Stub functions for the render_wysiwyg operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param parentid
    	 * @param dynamic
    	 * @return An AsyncToken
    	 */
    	function render_wysiwyg(sid:String,skey:String,appid:String,objid:String,parentid:String,_dynamic:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function render_wysiwyg_send():AsyncToken;
        
        /**
         * The render_wysiwyg operation lastResult property
         */
        function get render_wysiwyg_lastResult():String;
		/**
		 * @private
		 */
        function set render_wysiwyg_lastResult(lastResult:String):void;
       /**
        * Add a listener for the render_wysiwyg operation successful result event
        * @param The listener function
        */
       function addrender_wysiwygEventListener(listener:Function):void;
       
       
        /**
         * The render_wysiwyg operation request wrapper
         */
        function get render_wysiwyg_request_var():Render_wysiwyg_request;
        
        /**
         * @private
         */
        function set render_wysiwyg_request_var(request:Render_wysiwyg_request):void;
                   
    	//Stub functions for the set_attributes operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param attr
    	 * @return An AsyncToken
    	 */
    	function set_attributes(sid:String,skey:String,appid:String,objid:String,attr:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_attributes_send():AsyncToken;
        
        /**
         * The set_attributes operation lastResult property
         */
        function get set_attributes_lastResult():String;
		/**
		 * @private
		 */
        function set set_attributes_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_attributes operation successful result event
        * @param The listener function
        */
       function addset_attributesEventListener(listener:Function):void;
       
       
        /**
         * The set_attributes operation request wrapper
         */
        function get set_attributes_request_var():Set_attributes_request;
        
        /**
         * @private
         */
        function set set_attributes_request_var(request:Set_attributes_request):void;
                   
    	//Stub functions for the set_script operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param script
    	 * @param lang
    	 * @return An AsyncToken
    	 */
    	function set_script(sid:String,skey:String,appid:String,objid:String,script:String,lang:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_script_send():AsyncToken;
        
        /**
         * The set_script operation lastResult property
         */
        function get set_script_lastResult():String;
		/**
		 * @private
		 */
        function set set_script_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_script operation successful result event
        * @param The listener function
        */
       function addset_scriptEventListener(listener:Function):void;
       
       
        /**
         * The set_script operation request wrapper
         */
        function get set_script_request_var():Set_script_request;
        
        /**
         * @private
         */
        function set set_script_request_var(request:Set_script_request):void;
                   
    	//Stub functions for the get_application_info operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @return An AsyncToken
    	 */
    	function get_application_info(sid:String,skey:String,appid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_application_info_send():AsyncToken;
        
        /**
         * The get_application_info operation lastResult property
         */
        function get get_application_info_lastResult():String;
		/**
		 * @private
		 */
        function set get_application_info_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_application_info operation successful result event
        * @param The listener function
        */
       function addget_application_infoEventListener(listener:Function):void;
       
       
        /**
         * The get_application_info operation request wrapper
         */
        function get get_application_info_request_var():Get_application_info_request;
        
        /**
         * @private
         */
        function set get_application_info_request_var(request:Get_application_info_request):void;
                   
    	//Stub functions for the get_script operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param lang
    	 * @return An AsyncToken
    	 */
    	function get_script(sid:String,skey:String,appid:String,objid:String,lang:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_script_send():AsyncToken;
        
        /**
         * The get_script operation lastResult property
         */
        function get get_script_lastResult():String;
		/**
		 * @private
		 */
        function set get_script_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_script operation successful result event
        * @param The listener function
        */
       function addget_scriptEventListener(listener:Function):void;
       
       
        /**
         * The get_script operation request wrapper
         */
        function get get_script_request_var():Get_script_request;
        
        /**
         * @private
         */
        function set get_script_request_var(request:Get_script_request):void;
                   
    	//Stub functions for the get_child_objects_tree operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @return An AsyncToken
    	 */
    	function get_child_objects_tree(sid:String,skey:String,appid:String,objid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_child_objects_tree_send():AsyncToken;
        
        /**
         * The get_child_objects_tree operation lastResult property
         */
        function get get_child_objects_tree_lastResult():String;
		/**
		 * @private
		 */
        function set get_child_objects_tree_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_child_objects_tree operation successful result event
        * @param The listener function
        */
       function addget_child_objects_treeEventListener(listener:Function):void;
       
       
        /**
         * The get_child_objects_tree operation request wrapper
         */
        function get get_child_objects_tree_request_var():Get_child_objects_tree_request;
        
        /**
         * @private
         */
        function set get_child_objects_tree_request_var(request:Get_child_objects_tree_request):void;
                   
    	//Stub functions for the modify_resource operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param resid
    	 * @param attrname
    	 * @param operation
    	 * @param attr
    	 * @return An AsyncToken
    	 */
    	function modify_resource(sid:String,skey:String,appid:String,objid:String,resid:String,attrname:String,operation:String,attr:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function modify_resource_send():AsyncToken;
        
        /**
         * The modify_resource operation lastResult property
         */
        function get modify_resource_lastResult():String;
		/**
		 * @private
		 */
        function set modify_resource_lastResult(lastResult:String):void;
       /**
        * Add a listener for the modify_resource operation successful result event
        * @param The listener function
        */
       function addmodify_resourceEventListener(listener:Function):void;
       
       
        /**
         * The modify_resource operation request wrapper
         */
        function get modify_resource_request_var():Modify_resource_request;
        
        /**
         * @private
         */
        function set modify_resource_request_var(request:Modify_resource_request):void;
                   
    	//Stub functions for the get_child_objects operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @return An AsyncToken
    	 */
    	function get_child_objects(sid:String,skey:String,appid:String,objid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_child_objects_send():AsyncToken;
        
        /**
         * The get_child_objects operation lastResult property
         */
        function get get_child_objects_lastResult():String;
		/**
		 * @private
		 */
        function set get_child_objects_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_child_objects operation successful result event
        * @param The listener function
        */
       function addget_child_objectsEventListener(listener:Function):void;
       
       
        /**
         * The get_child_objects operation request wrapper
         */
        function get get_child_objects_request_var():Get_child_objects_request;
        
        /**
         * @private
         */
        function set get_child_objects_request_var(request:Get_child_objects_request):void;
                   
    	//Stub functions for the get_resource operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param ownerid
    	 * @param resid
    	 * @return An AsyncToken
    	 */
    	function get_resource(sid:String,skey:String,ownerid:String,resid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_resource_send():AsyncToken;
        
        /**
         * The get_resource operation lastResult property
         */
        function get get_resource_lastResult():String;
		/**
		 * @private
		 */
        function set get_resource_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_resource operation successful result event
        * @param The listener function
        */
       function addget_resourceEventListener(listener:Function):void;
       
       
        /**
         * The get_resource operation request wrapper
         */
        function get get_resource_request_var():Get_resource_request;
        
        /**
         * @private
         */
        function set get_resource_request_var(request:Get_resource_request):void;
                   
    	//Stub functions for the get_code_interface_data operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @return An AsyncToken
    	 */
    	function get_code_interface_data(sid:String,skey:String,appid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_code_interface_data_send():AsyncToken;
        
        /**
         * The get_code_interface_data operation lastResult property
         */
        function get get_code_interface_data_lastResult():String;
		/**
		 * @private
		 */
        function set get_code_interface_data_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_code_interface_data operation successful result event
        * @param The listener function
        */
       function addget_code_interface_dataEventListener(listener:Function):void;
       
       
        /**
         * The get_code_interface_data operation request wrapper
         */
        function get get_code_interface_data_request_var():Get_code_interface_data_request;
        
        /**
         * @private
         */
        function set get_code_interface_data_request_var(request:Get_code_interface_data_request):void;
                   
    	//Stub functions for the get_application_events operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @return An AsyncToken
    	 */
    	function get_application_events(sid:String,skey:String,appid:String,objid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_application_events_send():AsyncToken;
        
        /**
         * The get_application_events operation lastResult property
         */
        function get get_application_events_lastResult():String;
		/**
		 * @private
		 */
        function set get_application_events_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_application_events operation successful result event
        * @param The listener function
        */
       function addget_application_eventsEventListener(listener:Function):void;
       
       
        /**
         * The get_application_events operation request wrapper
         */
        function get get_application_events_request_var():Get_application_events_request;
        
        /**
         * @private
         */
        function set get_application_events_request_var(request:Get_application_events_request):void;
                   
    	//Stub functions for the about operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @return An AsyncToken
    	 */
    	function about():AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function about_send():AsyncToken;
        
        /**
         * The about operation lastResult property
         */
        function get about_lastResult():String;
		/**
		 * @private
		 */
        function set about_lastResult(lastResult:String):void;
       /**
        * Add a listener for the about operation successful result event
        * @param The listener function
        */
       function addaboutEventListener(listener:Function):void;
       
       
    	//Stub functions for the set_resource operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param restype
    	 * @param resname
    	 * @param resdata
    	 * @return An AsyncToken
    	 */
    	function set_resource(sid:String,skey:String,appid:String,restype:String,resname:String,resdata:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_resource_send():AsyncToken;
        
        /**
         * The set_resource operation lastResult property
         */
        function get set_resource_lastResult():String;
		/**
		 * @private
		 */
        function set set_resource_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_resource operation successful result event
        * @param The listener function
        */
       function addset_resourceEventListener(listener:Function):void;
       
       
        /**
         * The set_resource operation request wrapper
         */
        function get set_resource_request_var():Set_resource_request;
        
        /**
         * @private
         */
        function set set_resource_request_var(request:Set_resource_request):void;
                   
    	//Stub functions for the set_application_events operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param events
    	 * @return An AsyncToken
    	 */
    	function set_application_events(sid:String,skey:String,appid:String,objid:String,events:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_application_events_send():AsyncToken;
        
        /**
         * The set_application_events operation lastResult property
         */
        function get set_application_events_lastResult():String;
		/**
		 * @private
		 */
        function set set_application_events_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_application_events operation successful result event
        * @param The listener function
        */
       function addset_application_eventsEventListener(listener:Function):void;
       
       
        /**
         * The set_application_events operation request wrapper
         */
        function get set_application_events_request_var():Set_application_events_request;
        
        /**
         * @private
         */
        function set set_application_events_request_var(request:Set_application_events_request):void;
                   
    	//Stub functions for the list_resources operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param ownerid
    	 * @return An AsyncToken
    	 */
    	function list_resources(sid:String,skey:String,ownerid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function list_resources_send():AsyncToken;
        
        /**
         * The list_resources operation lastResult property
         */
        function get list_resources_lastResult():String;
		/**
		 * @private
		 */
        function set list_resources_lastResult(lastResult:String):void;
       /**
        * Add a listener for the list_resources operation successful result event
        * @param The listener function
        */
       function addlist_resourcesEventListener(listener:Function):void;
       
       
        /**
         * The list_resources operation request wrapper
         */
        function get list_resources_request_var():List_resources_request;
        
        /**
         * @private
         */
        function set list_resources_request_var(request:List_resources_request):void;
                   
    	//Stub functions for the get_all_types operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @return An AsyncToken
    	 */
    	function get_all_types(sid:String,skey:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_all_types_send():AsyncToken;
        
        /**
         * The get_all_types operation lastResult property
         */
        function get get_all_types_lastResult():String;
		/**
		 * @private
		 */
        function set get_all_types_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_all_types operation successful result event
        * @param The listener function
        */
       function addget_all_typesEventListener(listener:Function):void;
       
       
        /**
         * The get_all_types operation request wrapper
         */
        function get get_all_types_request_var():Get_all_types_request;
        
        /**
         * @private
         */
        function set get_all_types_request_var(request:Get_all_types_request):void;
                   
    	//Stub functions for the set_attribute operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param attr
    	 * @param value
    	 * @return An AsyncToken
    	 */
    	function set_attribute(sid:String,skey:String,appid:String,objid:String,attr:String,value:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function set_attribute_send():AsyncToken;
        
        /**
         * The set_attribute operation lastResult property
         */
        function get set_attribute_lastResult():String;
		/**
		 * @private
		 */
        function set set_attribute_lastResult(lastResult:String):void;
       /**
        * Add a listener for the set_attribute operation successful result event
        * @param The listener function
        */
       function addset_attributeEventListener(listener:Function):void;
       
       
        /**
         * The set_attribute operation request wrapper
         */
        function get set_attribute_request_var():Set_attribute_request;
        
        /**
         * @private
         */
        function set set_attribute_request_var(request:Set_attribute_request):void;
                   
    	//Stub functions for the whole_update operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @param data
    	 * @return An AsyncToken
    	 */
    	function whole_update(sid:String,skey:String,appid:String,objid:String,data:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function whole_update_send():AsyncToken;
        
        /**
         * The whole_update operation lastResult property
         */
        function get whole_update_lastResult():String;
		/**
		 * @private
		 */
        function set whole_update_lastResult(lastResult:String):void;
       /**
        * Add a listener for the whole_update operation successful result event
        * @param The listener function
        */
       function addwhole_updateEventListener(listener:Function):void;
       
       
        /**
         * The whole_update operation request wrapper
         */
        function get whole_update_request_var():Whole_update_request;
        
        /**
         * @private
         */
        function set whole_update_request_var(request:Whole_update_request):void;
                   
    	//Stub functions for the get_object_script_presentation operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @param objid
    	 * @return An AsyncToken
    	 */
    	function get_object_script_presentation(sid:String,skey:String,appid:String,objid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_object_script_presentation_send():AsyncToken;
        
        /**
         * The get_object_script_presentation operation lastResult property
         */
        function get get_object_script_presentation_lastResult():String;
		/**
		 * @private
		 */
        function set get_object_script_presentation_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_object_script_presentation operation successful result event
        * @param The listener function
        */
       function addget_object_script_presentationEventListener(listener:Function):void;
       
       
        /**
         * The get_object_script_presentation operation request wrapper
         */
        function get get_object_script_presentation_request_var():Get_object_script_presentation_request;
        
        /**
         * @private
         */
        function set get_object_script_presentation_request_var(request:Get_object_script_presentation_request):void;
                   
    	//Stub functions for the install_application operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param vhname
    	 * @param appxml
    	 * @return An AsyncToken
    	 */
    	function install_application(sid:String,skey:String,vhname:String,appxml:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function install_application_send():AsyncToken;
        
        /**
         * The install_application operation lastResult property
         */
        function get install_application_lastResult():String;
		/**
		 * @private
		 */
        function set install_application_lastResult(lastResult:String):void;
       /**
        * Add a listener for the install_application operation successful result event
        * @param The listener function
        */
       function addinstall_applicationEventListener(listener:Function):void;
       
       
        /**
         * The install_application operation request wrapper
         */
        function get install_application_request_var():Install_application_request;
        
        /**
         * @private
         */
        function set install_application_request_var(request:Install_application_request):void;
                   
    	//Stub functions for the get_top_objects operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sid
    	 * @param skey
    	 * @param appid
    	 * @return An AsyncToken
    	 */
    	function get_top_objects(sid:String,skey:String,appid:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function get_top_objects_send():AsyncToken;
        
        /**
         * The get_top_objects operation lastResult property
         */
        function get get_top_objects_lastResult():String;
		/**
		 * @private
		 */
        function set get_top_objects_lastResult(lastResult:String):void;
       /**
        * Add a listener for the get_top_objects operation successful result event
        * @param The listener function
        */
       function addget_top_objectsEventListener(listener:Function):void;
       
       
        /**
         * The get_top_objects operation request wrapper
         */
        function get get_top_objects_request_var():Get_top_objects_request;
        
        /**
         * @private
         */
        function set get_top_objects_request_var(request:Get_top_objects_request):void;
                   
        /**
         * Get access to the underlying web service that the stub uses to communicate with the server
         * @return The base service that the facade implements
         */
        function getWebService():BaseVdom;
	}
}