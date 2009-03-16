import mx.rpc.events.FaultEvent;

import vdom.events.SOAPEvent;

private var registeredHandlers:Array = [
	{methodName:"list_applications", handlerName:"soap_listApplicationsHandler"},
	{methodName:"create_application", handlerName:"soap_createApplicationHandler"},
	{methodName:"get_application_info", handlerName:"soap_getApplicationInfoHandler"},
	{methodName:"set_application_info", handlerName:"soap_setApplicationInfoHandler"},
	{methodName:"get_application_structure", handlerName:"soap_getApplicationStructureHandler"},
	{methodName:"set_application_structure", handlerName:"soap_setApplicationStructureHandler"},
	{methodName:"get_application_events", handlerName:"soap_getApplicationEventsHandler"},
	{methodName:"set_application_events", handlerName:"soap_setApplicationEventsHandler"},
	
	{methodName:"get_all_types", handlerName:"soap_getAllTypesHandler"},
	
	{methodName:"get_top_objects", handlerName:"soap_getTopObjectsHandler"},
	{methodName:"get_child_objects_tree", handlerName:"soap_getChildObjectsTreeHandler"},
	{methodName:"create_object", handlerName:"soap_createObjectHandler"},
	{methodName:"delete_object", handlerName:"soap_deleteObjectHandler"},
	{methodName:"set_name", handlerName:"soap_setNameHandler"},
	{methodName:"get_object_script_presentation", handlerName:"soap_getObjectScriptPresentationHandler"},
	{methodName:"submit_object_script_presentation", handlerName:"soap_setObjectScriptPresentationHandler"},
	
	{methodName:"get_script", handlerName:"soap_getScriptHandler"},
	{methodName:"set_script", handlerName:"soap_setScriptHandler"},
	
	{methodName:"get_server_actions", handlerName:"soap_getServerActionsHandler"},
	{methodName:"set_server_actions", handlerName:"soap_setServerActionsHandler"},
	
	{methodName:"search", handlerName:"soap_searchHandler"},
	
	{methodName:"modify_resource", handlerName:"soap_modifyResourceHandler"},
	
	{methodName:"get_libraries", handlerName:"soap_getLibrariesHandler"},
	{methodName:"set_library ", handlerName:"soap_setLibraryHandler"}
]

private function registerEvent(flag:Boolean):void
{
	var method:Object = {};
	
	if(flag)
	{ 
		proxy.addEventListener(
			ProxyEvent.PROXY_SEND, 
			proxy_sendHandler
		);
		
		proxy.addEventListener(
			ProxyEvent.PROXY_COMPLETE, 
			proxy_setAttributesHandler
		);
		
		proxy.addEventListener(
			FaultEvent.FAULT,
			faultHandler
		);
		
		for each(method in registeredHandlers)
		{
			try
			{
				soap[method.methodName].addEventListener(
					SOAPEvent.RESULT,
					this[method.handlerName]
				);
				
				soap[method.methodName].addEventListener(
					FaultEvent.FAULT,
					faultHandler
				);
			}
			catch(error:Error){}
		}
	}
	else
	{
		proxy.removeEventListener(
			ProxyEvent.PROXY_SEND, 
			proxy_sendHandler
		);
		
		proxy.removeEventListener(
			ProxyEvent.PROXY_COMPLETE, 
			proxy_setAttributesHandler
		);
		
		for each(method in registeredHandlers)
		{
			try
			{
				soap[method.methodName].removeEventListener(
					SOAPEvent.RESULT,
					this[method.handlerName]
				);
			}
			catch(error:Error){}
		}
	}
}