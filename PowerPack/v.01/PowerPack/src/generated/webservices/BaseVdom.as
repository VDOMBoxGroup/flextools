
/**
 * BaseVdomService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package generated.webservices{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import mx.utils.ObjectUtil;
	import mx.utils.ObjectProxy;
	import mx.messaging.events.MessageFaultEvent;
	import mx.messaging.MessageResponder;
	import mx.messaging.messages.SOAPMessage;
	import mx.messaging.messages.ErrorMessage;
   	import mx.messaging.ChannelSet;
	import mx.messaging.channels.DirectHTTPChannel;
	import mx.rpc.*;
	import mx.rpc.events.*;
	import mx.rpc.soap.*;
	import mx.rpc.wsdl.*;
	import mx.rpc.xml.*;
	import mx.rpc.soap.types.*;
	import mx.collections.ArrayCollection;
	
	/**
	 * Base service implementation, extends the AbstractWebService and adds specific functionality for the selected WSDL
	 * It defines the options and properties for each of the WSDL's operations
	 */ 
	public class BaseVdom extends AbstractWebService
    {
		private var results:Object;
		private var schemaMgr:SchemaManager;
		private var BaseVdomService:WSDLService;
		private var BaseVdomPortType:WSDLPortType;
		private var BaseVdomBinding:WSDLBinding;
		private var BaseVdomPort:WSDLPort;
		private var currentOperation:WSDLOperation;
		private var internal_schema:BaseVdomSchema;
	
		/**
		 * Constructor for the base service, initializes all of the WSDL's properties
		 * @param [Optional] The LCDS destination (if available) to use to contact the server
		 * @param [Optional] The URL to the WSDL end-point
		 */
		public function BaseVdom(destination:String=null, rootURL:String=null)
		{
			super(destination, rootURL);
			if(destination == null)
			{
				//no destination available; must set it to go directly to the target
				this.useProxy = false;
			}
			else
			{
				//specific destination requested; must set proxying to true
				this.useProxy = true;
			}
			
			if(rootURL != null)
			{
				this.endpointURI = rootURL;
			} 
			else 
			{
				this.endpointURI = null;
			}
			internal_schema = new BaseVdomSchema();
			schemaMgr = new SchemaManager();
			for(var i:int;i<internal_schema.schemas.length;i++)
			{
				internal_schema.schemas[i].targetNamespace=internal_schema.targetNamespaces[i];
				schemaMgr.addSchema(internal_schema.schemas[i]);
			}
BaseVdomService = new WSDLService("BaseVdomService");
			BaseVdomPort = new WSDLPort("BaseVdomPort",BaseVdomService);
        	BaseVdomBinding = new WSDLBinding("BaseVdomBinding");
	        BaseVdomPortType = new WSDLPortType("BaseVdomPortType");
       		BaseVdomBinding.portType = BaseVdomPortType;
       		BaseVdomPort.binding = BaseVdomBinding;
       		BaseVdomService.addPort(BaseVdomPort);
       		BaseVdomPort.endpointURI = "http://192.168.0.65:80/SOAP";
       		if(this.endpointURI == null)
       		{
       			this.endpointURI = BaseVdomPort.endpointURI; 
       		} 
       		
			var requestMessage:WSDLMessage;
	        var responseMessage:WSDLMessage;
//define the WSDLOperation: new WSDLOperation(methodName)
            var get_echo:WSDLOperation = new WSDLOperation("get_echo");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_echo");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_echo");
                
                responseMessage = new WSDLMessage("get_echoResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_echo");get_echo.inputMessage = requestMessage;
	        get_echo.outputMessage = responseMessage;
            get_echo.schemaManager = this.schemaMgr;
            get_echo.soapAction = "http://services.vdom.net/VDOMServices/get_echo";
            get_echo.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_echo);//define the WSDLOperation: new WSDLOperation(methodName)
            var create_guid:WSDLOperation = new WSDLOperation("create_guid");
				//input message for the operation
    	        requestMessage = new WSDLMessage("create_guid");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","create_guid");
                
                responseMessage = new WSDLMessage("create_guidResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","create_guid");create_guid.inputMessage = requestMessage;
	        create_guid.outputMessage = responseMessage;
            create_guid.schemaManager = this.schemaMgr;
            create_guid.soapAction = "http://services.vdom.net/VDOMServices/create_guid";
            create_guid.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(create_guid);//define the WSDLOperation: new WSDLOperation(methodName)
            var delete_object:WSDLOperation = new WSDLOperation("delete_object");
				//input message for the operation
    	        requestMessage = new WSDLMessage("delete_object");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","delete_object");
                
                responseMessage = new WSDLMessage("delete_objectResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","delete_object");delete_object.inputMessage = requestMessage;
	        delete_object.outputMessage = responseMessage;
            delete_object.schemaManager = this.schemaMgr;
            delete_object.soapAction = "http://services.vdom.net/VDOMServices/delete_object";
            delete_object.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(delete_object);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_top_objects:WSDLOperation = new WSDLOperation("get_top_objects");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_top_objects");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_top_objects");
                
                responseMessage = new WSDLMessage("get_top_objectsResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_top_objects");get_top_objects.inputMessage = requestMessage;
	        get_top_objects.outputMessage = responseMessage;
            get_top_objects.schemaManager = this.schemaMgr;
            get_top_objects.soapAction = "http://services.vdom.net/VDOMServices/get_top_objects";
            get_top_objects.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_top_objects);//define the WSDLOperation: new WSDLOperation(methodName)
            var whole_delete:WSDLOperation = new WSDLOperation("whole_delete");
				//input message for the operation
    	        requestMessage = new WSDLMessage("whole_delete");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_delete");
                
                responseMessage = new WSDLMessage("whole_deleteResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_delete");whole_delete.inputMessage = requestMessage;
	        whole_delete.outputMessage = responseMessage;
            whole_delete.schemaManager = this.schemaMgr;
            whole_delete.soapAction = "http://services.vdom.net/VDOMServices/whole_delete";
            whole_delete.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(whole_delete);//define the WSDLOperation: new WSDLOperation(methodName)
            var search:WSDLOperation = new WSDLOperation("search");
				//input message for the operation
    	        requestMessage = new WSDLMessage("search");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","pattern"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","search");
                
                responseMessage = new WSDLMessage("searchResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","search");search.inputMessage = requestMessage;
	        search.outputMessage = responseMessage;
            search.schemaManager = this.schemaMgr;
            search.soapAction = "http://services.vdom.net/VDOMServices/search";
            search.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(search);//define the WSDLOperation: new WSDLOperation(methodName)
            var keep_alive:WSDLOperation = new WSDLOperation("keep_alive");
				//input message for the operation
    	        requestMessage = new WSDLMessage("keep_alive");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","keep_alive");
                
                responseMessage = new WSDLMessage("keep_aliveResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","keep_alive");keep_alive.inputMessage = requestMessage;
	        keep_alive.outputMessage = responseMessage;
            keep_alive.schemaManager = this.schemaMgr;
            keep_alive.soapAction = "http://services.vdom.net/VDOMServices/keep_alive";
            keep_alive.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(keep_alive);//define the WSDLOperation: new WSDLOperation(methodName)
            var close_session:WSDLOperation = new WSDLOperation("close_session");
				//input message for the operation
    	        requestMessage = new WSDLMessage("close_session");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","close_session");
                
                responseMessage = new WSDLMessage("close_sessionResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","close_session");close_session.inputMessage = requestMessage;
	        close_session.outputMessage = responseMessage;
            close_session.schemaManager = this.schemaMgr;
            close_session.soapAction = "http://services.vdom.net/VDOMServices/close_session";
            close_session.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(close_session);//define the WSDLOperation: new WSDLOperation(methodName)
            var open_session:WSDLOperation = new WSDLOperation("open_session");
				//input message for the operation
    	        requestMessage = new WSDLMessage("open_session");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","name"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","pwd_md5"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","open_session");
                
                responseMessage = new WSDLMessage("open_sessionResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","open_session");open_session.inputMessage = requestMessage;
	        open_session.outputMessage = responseMessage;
            open_session.schemaManager = this.schemaMgr;
            open_session.soapAction = "http://services.vdom.net/VDOMServices/open_session";
            open_session.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(open_session);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_type:WSDLOperation = new WSDLOperation("get_type");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_type");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","typeid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_type");
                
                responseMessage = new WSDLMessage("get_typeResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_type");get_type.inputMessage = requestMessage;
	        get_type.outputMessage = responseMessage;
            get_type.schemaManager = this.schemaMgr;
            get_type.soapAction = "http://services.vdom.net/VDOMServices/get_type";
            get_type.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_type);//define the WSDLOperation: new WSDLOperation(methodName)
            var send_event:WSDLOperation = new WSDLOperation("send_event");
				//input message for the operation
    	        requestMessage = new WSDLMessage("send_event");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","evdata"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","send_event");
                
                responseMessage = new WSDLMessage("send_eventResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","send_event");send_event.inputMessage = requestMessage;
	        send_event.outputMessage = responseMessage;
            send_event.schemaManager = this.schemaMgr;
            send_event.soapAction = "http://services.vdom.net/VDOMServices/send_event";
            send_event.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(send_event);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_application_info:WSDLOperation = new WSDLOperation("set_application_info");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_application_info");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","attr"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_application_info");
                
                responseMessage = new WSDLMessage("set_application_infoResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_application_info");set_application_info.inputMessage = requestMessage;
	        set_application_info.outputMessage = responseMessage;
            set_application_info.schemaManager = this.schemaMgr;
            set_application_info.soapAction = "http://services.vdom.net/VDOMServices/set_application_info";
            set_application_info.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_application_info);//define the WSDLOperation: new WSDLOperation(methodName)
            var list_applications:WSDLOperation = new WSDLOperation("list_applications");
				//input message for the operation
    	        requestMessage = new WSDLMessage("list_applications");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","list_applications");
                
                responseMessage = new WSDLMessage("list_applicationsResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","list_applications");list_applications.inputMessage = requestMessage;
	        list_applications.outputMessage = responseMessage;
            list_applications.schemaManager = this.schemaMgr;
            list_applications.soapAction = "http://services.vdom.net/VDOMServices/list_applications";
            list_applications.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(list_applications);//define the WSDLOperation: new WSDLOperation(methodName)
            var export_application:WSDLOperation = new WSDLOperation("export_application");
				//input message for the operation
    	        requestMessage = new WSDLMessage("export_application");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","export_application");
                
                responseMessage = new WSDLMessage("export_applicationResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","export_application");export_application.inputMessage = requestMessage;
	        export_application.outputMessage = responseMessage;
            export_application.schemaManager = this.schemaMgr;
            export_application.soapAction = "http://services.vdom.net/VDOMServices/export_application";
            export_application.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(export_application);//define the WSDLOperation: new WSDLOperation(methodName)
            var execute_sql:WSDLOperation = new WSDLOperation("execute_sql");
				//input message for the operation
    	        requestMessage = new WSDLMessage("execute_sql");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","dbid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sql"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","script"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","execute_sql");
                
                responseMessage = new WSDLMessage("execute_sqlResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","execute_sql");execute_sql.inputMessage = requestMessage;
	        execute_sql.outputMessage = responseMessage;
            execute_sql.schemaManager = this.schemaMgr;
            execute_sql.soapAction = "http://services.vdom.net/VDOMServices/execute_sql";
            execute_sql.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(execute_sql);//define the WSDLOperation: new WSDLOperation(methodName)
            var create_application:WSDLOperation = new WSDLOperation("create_application");
				//input message for the operation
    	        requestMessage = new WSDLMessage("create_application");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","attr"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","create_application");
                
                responseMessage = new WSDLMessage("create_applicationResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","create_application");create_application.inputMessage = requestMessage;
	        create_application.outputMessage = responseMessage;
            create_application.schemaManager = this.schemaMgr;
            create_application.soapAction = "http://services.vdom.net/VDOMServices/create_application";
            create_application.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(create_application);//define the WSDLOperation: new WSDLOperation(methodName)
            var submit_object_script_presentation:WSDLOperation = new WSDLOperation("submit_object_script_presentation");
				//input message for the operation
    	        requestMessage = new WSDLMessage("submit_object_script_presentation");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","pres"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","submit_object_script_presentation");
                
                responseMessage = new WSDLMessage("submit_object_script_presentationResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","submit_object_script_presentation");submit_object_script_presentation.inputMessage = requestMessage;
	        submit_object_script_presentation.outputMessage = responseMessage;
            submit_object_script_presentation.schemaManager = this.schemaMgr;
            submit_object_script_presentation.soapAction = "http://services.vdom.net/VDOMServices/submit_object_script_presentation";
            submit_object_script_presentation.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(submit_object_script_presentation);//define the WSDLOperation: new WSDLOperation(methodName)
            var whole_create:WSDLOperation = new WSDLOperation("whole_create");
				//input message for the operation
    	        requestMessage = new WSDLMessage("whole_create");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","parentid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","name"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","data"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_create");
                
                responseMessage = new WSDLMessage("whole_createResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_create");whole_create.inputMessage = requestMessage;
	        whole_create.outputMessage = responseMessage;
            whole_create.schemaManager = this.schemaMgr;
            whole_create.soapAction = "http://services.vdom.net/VDOMServices/whole_create";
            whole_create.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(whole_create);//define the WSDLOperation: new WSDLOperation(methodName)
            var remote_method_call:WSDLOperation = new WSDLOperation("remote_method_call");
				//input message for the operation
    	        requestMessage = new WSDLMessage("remote_method_call");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","func_name"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","xml_param"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","remote_method_call");
                
                responseMessage = new WSDLMessage("remote_method_callResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","remote_method_call");remote_method_call.inputMessage = requestMessage;
	        remote_method_call.outputMessage = responseMessage;
            remote_method_call.schemaManager = this.schemaMgr;
            remote_method_call.soapAction = "http://services.vdom.net/VDOMServices/remote_method_call";
            remote_method_call.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(remote_method_call);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_application_structure:WSDLOperation = new WSDLOperation("get_application_structure");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_application_structure");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_structure");
                
                responseMessage = new WSDLMessage("get_application_structureResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_structure");get_application_structure.inputMessage = requestMessage;
	        get_application_structure.outputMessage = responseMessage;
            get_application_structure.schemaManager = this.schemaMgr;
            get_application_structure.soapAction = "http://services.vdom.net/VDOMServices/get_application_structure";
            get_application_structure.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_application_structure);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_thumbnail:WSDLOperation = new WSDLOperation("get_thumbnail");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_thumbnail");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","resid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","width"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","height"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_thumbnail");
                
                responseMessage = new WSDLMessage("get_thumbnailResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_thumbnail");get_thumbnail.inputMessage = requestMessage;
	        get_thumbnail.outputMessage = responseMessage;
            get_thumbnail.schemaManager = this.schemaMgr;
            get_thumbnail.soapAction = "http://services.vdom.net/VDOMServices/get_thumbnail";
            get_thumbnail.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_thumbnail);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_application_language_data:WSDLOperation = new WSDLOperation("get_application_language_data");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_application_language_data");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_language_data");
                
                responseMessage = new WSDLMessage("get_application_language_dataResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_language_data");get_application_language_data.inputMessage = requestMessage;
	        get_application_language_data.outputMessage = responseMessage;
            get_application_language_data.schemaManager = this.schemaMgr;
            get_application_language_data.soapAction = "http://services.vdom.net/VDOMServices/get_application_language_data";
            get_application_language_data.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_application_language_data);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_application_structure:WSDLOperation = new WSDLOperation("set_application_structure");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_application_structure");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","struct"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_application_structure");
                
                responseMessage = new WSDLMessage("set_application_structureResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_application_structure");set_application_structure.inputMessage = requestMessage;
	        set_application_structure.outputMessage = responseMessage;
            set_application_structure.schemaManager = this.schemaMgr;
            set_application_structure.soapAction = "http://services.vdom.net/VDOMServices/set_application_structure";
            set_application_structure.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_application_structure);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_one_object:WSDLOperation = new WSDLOperation("get_one_object");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_one_object");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_one_object");
                
                responseMessage = new WSDLMessage("get_one_objectResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_one_object");get_one_object.inputMessage = requestMessage;
	        get_one_object.outputMessage = responseMessage;
            get_one_object.schemaManager = this.schemaMgr;
            get_one_object.soapAction = "http://services.vdom.net/VDOMServices/get_one_object";
            get_one_object.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_one_object);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_name:WSDLOperation = new WSDLOperation("set_name");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_name");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","name"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_name");
                
                responseMessage = new WSDLMessage("set_nameResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_name");set_name.inputMessage = requestMessage;
	        set_name.outputMessage = responseMessage;
            set_name.schemaManager = this.schemaMgr;
            set_name.soapAction = "http://services.vdom.net/VDOMServices/set_name";
            set_name.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_name);//define the WSDLOperation: new WSDLOperation(methodName)
            var whole_create_page:WSDLOperation = new WSDLOperation("whole_create_page");
				//input message for the operation
    	        requestMessage = new WSDLMessage("whole_create_page");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sourceid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_create_page");
                
                responseMessage = new WSDLMessage("whole_create_pageResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_create_page");whole_create_page.inputMessage = requestMessage;
	        whole_create_page.outputMessage = responseMessage;
            whole_create_page.schemaManager = this.schemaMgr;
            whole_create_page.soapAction = "http://services.vdom.net/VDOMServices/whole_create_page";
            whole_create_page.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(whole_create_page);//define the WSDLOperation: new WSDLOperation(methodName)
            var list_types:WSDLOperation = new WSDLOperation("list_types");
				//input message for the operation
    	        requestMessage = new WSDLMessage("list_types");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","list_types");
                
                responseMessage = new WSDLMessage("list_typesResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","list_types");list_types.inputMessage = requestMessage;
	        list_types.outputMessage = responseMessage;
            list_types.schemaManager = this.schemaMgr;
            list_types.soapAction = "http://services.vdom.net/VDOMServices/list_types";
            list_types.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(list_types);//define the WSDLOperation: new WSDLOperation(methodName)
            var create_object:WSDLOperation = new WSDLOperation("create_object");
				//input message for the operation
    	        requestMessage = new WSDLMessage("create_object");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","parentid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","typeid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","name"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","attr"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","create_object");
                
                responseMessage = new WSDLMessage("create_objectResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","create_object");create_object.inputMessage = requestMessage;
	        create_object.outputMessage = responseMessage;
            create_object.schemaManager = this.schemaMgr;
            create_object.soapAction = "http://services.vdom.net/VDOMServices/create_object";
            create_object.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(create_object);//define the WSDLOperation: new WSDLOperation(methodName)
            var render_wysiwyg:WSDLOperation = new WSDLOperation("render_wysiwyg");
				//input message for the operation
    	        requestMessage = new WSDLMessage("render_wysiwyg");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","parentid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","dynamic"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","render_wysiwyg");
                
                responseMessage = new WSDLMessage("render_wysiwygResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","render_wysiwyg");render_wysiwyg.inputMessage = requestMessage;
	        render_wysiwyg.outputMessage = responseMessage;
            render_wysiwyg.schemaManager = this.schemaMgr;
            render_wysiwyg.soapAction = "http://services.vdom.net/VDOMServices/render_wysiwyg";
            render_wysiwyg.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(render_wysiwyg);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_attributes:WSDLOperation = new WSDLOperation("set_attributes");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_attributes");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","attr"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_attributes");
                
                responseMessage = new WSDLMessage("set_attributesResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_attributes");set_attributes.inputMessage = requestMessage;
	        set_attributes.outputMessage = responseMessage;
            set_attributes.schemaManager = this.schemaMgr;
            set_attributes.soapAction = "http://services.vdom.net/VDOMServices/set_attributes";
            set_attributes.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_attributes);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_script:WSDLOperation = new WSDLOperation("set_script");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_script");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","script"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","lang"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_script");
                
                responseMessage = new WSDLMessage("set_scriptResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_script");set_script.inputMessage = requestMessage;
	        set_script.outputMessage = responseMessage;
            set_script.schemaManager = this.schemaMgr;
            set_script.soapAction = "http://services.vdom.net/VDOMServices/set_script";
            set_script.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_script);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_application_info:WSDLOperation = new WSDLOperation("get_application_info");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_application_info");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_info");
                
                responseMessage = new WSDLMessage("get_application_infoResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_info");get_application_info.inputMessage = requestMessage;
	        get_application_info.outputMessage = responseMessage;
            get_application_info.schemaManager = this.schemaMgr;
            get_application_info.soapAction = "http://services.vdom.net/VDOMServices/get_application_info";
            get_application_info.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_application_info);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_script:WSDLOperation = new WSDLOperation("get_script");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_script");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","lang"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_script");
                
                responseMessage = new WSDLMessage("get_scriptResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_script");get_script.inputMessage = requestMessage;
	        get_script.outputMessage = responseMessage;
            get_script.schemaManager = this.schemaMgr;
            get_script.soapAction = "http://services.vdom.net/VDOMServices/get_script";
            get_script.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_script);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_child_objects_tree:WSDLOperation = new WSDLOperation("get_child_objects_tree");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_child_objects_tree");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_child_objects_tree");
                
                responseMessage = new WSDLMessage("get_child_objects_treeResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_child_objects_tree");get_child_objects_tree.inputMessage = requestMessage;
	        get_child_objects_tree.outputMessage = responseMessage;
            get_child_objects_tree.schemaManager = this.schemaMgr;
            get_child_objects_tree.soapAction = "http://services.vdom.net/VDOMServices/get_child_objects_tree";
            get_child_objects_tree.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_child_objects_tree);//define the WSDLOperation: new WSDLOperation(methodName)
            var modify_resource:WSDLOperation = new WSDLOperation("modify_resource");
				//input message for the operation
    	        requestMessage = new WSDLMessage("modify_resource");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","resid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","attrname"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","operation"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","attr"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","modify_resource");
                
                responseMessage = new WSDLMessage("modify_resourceResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","modify_resource");modify_resource.inputMessage = requestMessage;
	        modify_resource.outputMessage = responseMessage;
            modify_resource.schemaManager = this.schemaMgr;
            modify_resource.soapAction = "http://services.vdom.net/VDOMServices/modify_resource";
            modify_resource.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(modify_resource);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_child_objects:WSDLOperation = new WSDLOperation("get_child_objects");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_child_objects");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_child_objects");
                
                responseMessage = new WSDLMessage("get_child_objectsResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_child_objects");get_child_objects.inputMessage = requestMessage;
	        get_child_objects.outputMessage = responseMessage;
            get_child_objects.schemaManager = this.schemaMgr;
            get_child_objects.soapAction = "http://services.vdom.net/VDOMServices/get_child_objects";
            get_child_objects.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_child_objects);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_resource:WSDLOperation = new WSDLOperation("get_resource");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_resource");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","ownerid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","resid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_resource");
                
                responseMessage = new WSDLMessage("get_resourceResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_resource");get_resource.inputMessage = requestMessage;
	        get_resource.outputMessage = responseMessage;
            get_resource.schemaManager = this.schemaMgr;
            get_resource.soapAction = "http://services.vdom.net/VDOMServices/get_resource";
            get_resource.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_resource);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_code_interface_data:WSDLOperation = new WSDLOperation("get_code_interface_data");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_code_interface_data");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_code_interface_data");
                
                responseMessage = new WSDLMessage("get_code_interface_dataResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_code_interface_data");get_code_interface_data.inputMessage = requestMessage;
	        get_code_interface_data.outputMessage = responseMessage;
            get_code_interface_data.schemaManager = this.schemaMgr;
            get_code_interface_data.soapAction = "http://services.vdom.net/VDOMServices/get_code_interface_data";
            get_code_interface_data.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_code_interface_data);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_application_events:WSDLOperation = new WSDLOperation("get_application_events");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_application_events");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_events");
                
                responseMessage = new WSDLMessage("get_application_eventsResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_application_events");get_application_events.inputMessage = requestMessage;
	        get_application_events.outputMessage = responseMessage;
            get_application_events.schemaManager = this.schemaMgr;
            get_application_events.soapAction = "http://services.vdom.net/VDOMServices/get_application_events";
            get_application_events.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_application_events);//define the WSDLOperation: new WSDLOperation(methodName)
            var about:WSDLOperation = new WSDLOperation("about");
				//input message for the operation
    	        requestMessage = new WSDLMessage("about");
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","about");
                
                responseMessage = new WSDLMessage("aboutResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","about");about.inputMessage = requestMessage;
	        about.outputMessage = responseMessage;
            about.schemaManager = this.schemaMgr;
            about.soapAction = "http://services.vdom.net/VDOMServices/about";
            about.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(about);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_resource:WSDLOperation = new WSDLOperation("set_resource");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_resource");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","restype"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","resname"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","resdata"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_resource");
                
                responseMessage = new WSDLMessage("set_resourceResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_resource");set_resource.inputMessage = requestMessage;
	        set_resource.outputMessage = responseMessage;
            set_resource.schemaManager = this.schemaMgr;
            set_resource.soapAction = "http://services.vdom.net/VDOMServices/set_resource";
            set_resource.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_resource);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_application_events:WSDLOperation = new WSDLOperation("set_application_events");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_application_events");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","events"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_application_events");
                
                responseMessage = new WSDLMessage("set_application_eventsResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_application_events");set_application_events.inputMessage = requestMessage;
	        set_application_events.outputMessage = responseMessage;
            set_application_events.schemaManager = this.schemaMgr;
            set_application_events.soapAction = "http://services.vdom.net/VDOMServices/set_application_events";
            set_application_events.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_application_events);//define the WSDLOperation: new WSDLOperation(methodName)
            var list_resources:WSDLOperation = new WSDLOperation("list_resources");
				//input message for the operation
    	        requestMessage = new WSDLMessage("list_resources");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","ownerid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","list_resources");
                
                responseMessage = new WSDLMessage("list_resourcesResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","list_resources");list_resources.inputMessage = requestMessage;
	        list_resources.outputMessage = responseMessage;
            list_resources.schemaManager = this.schemaMgr;
            list_resources.soapAction = "http://services.vdom.net/VDOMServices/list_resources";
            list_resources.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(list_resources);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_all_types:WSDLOperation = new WSDLOperation("get_all_types");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_all_types");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_all_types");
                
                responseMessage = new WSDLMessage("get_all_typesResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_all_types");get_all_types.inputMessage = requestMessage;
	        get_all_types.outputMessage = responseMessage;
            get_all_types.schemaManager = this.schemaMgr;
            get_all_types.soapAction = "http://services.vdom.net/VDOMServices/get_all_types";
            get_all_types.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_all_types);//define the WSDLOperation: new WSDLOperation(methodName)
            var set_attribute:WSDLOperation = new WSDLOperation("set_attribute");
				//input message for the operation
    	        requestMessage = new WSDLMessage("set_attribute");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","attr"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","value"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_attribute");
                
                responseMessage = new WSDLMessage("set_attributeResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","set_attribute");set_attribute.inputMessage = requestMessage;
	        set_attribute.outputMessage = responseMessage;
            set_attribute.schemaManager = this.schemaMgr;
            set_attribute.soapAction = "http://services.vdom.net/VDOMServices/set_attribute";
            set_attribute.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(set_attribute);//define the WSDLOperation: new WSDLOperation(methodName)
            var whole_update:WSDLOperation = new WSDLOperation("whole_update");
				//input message for the operation
    	        requestMessage = new WSDLMessage("whole_update");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","data"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_update");
                
                responseMessage = new WSDLMessage("whole_updateResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","whole_update");whole_update.inputMessage = requestMessage;
	        whole_update.outputMessage = responseMessage;
            whole_update.schemaManager = this.schemaMgr;
            whole_update.soapAction = "http://services.vdom.net/VDOMServices/whole_update";
            whole_update.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(whole_update);//define the WSDLOperation: new WSDLOperation(methodName)
            var get_object_script_presentation:WSDLOperation = new WSDLOperation("get_object_script_presentation");
				//input message for the operation
    	        requestMessage = new WSDLMessage("get_object_script_presentation");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","objid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_object_script_presentation");
                
                responseMessage = new WSDLMessage("get_object_script_presentationResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","get_object_script_presentation");get_object_script_presentation.inputMessage = requestMessage;
	        get_object_script_presentation.outputMessage = responseMessage;
            get_object_script_presentation.schemaManager = this.schemaMgr;
            get_object_script_presentation.soapAction = "http://services.vdom.net/VDOMServices/get_object_script_presentation";
            get_object_script_presentation.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(get_object_script_presentation);//define the WSDLOperation: new WSDLOperation(methodName)
            var install_application:WSDLOperation = new WSDLOperation("install_application");
				//input message for the operation
    	        requestMessage = new WSDLMessage("install_application");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","sid"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","skey"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","vhname"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","appxml"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","install_application");
                
                responseMessage = new WSDLMessage("install_applicationResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://services.vdom.net/VDOMServices","Result"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://services.vdom.net/VDOMServices";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://services.vdom.net/VDOMServices","install_application");install_application.inputMessage = requestMessage;
	        install_application.outputMessage = responseMessage;
            install_application.schemaManager = this.schemaMgr;
            install_application.soapAction = "http://services.vdom.net/VDOMServices/install_application";
            install_application.style = "document";
            BaseVdomService.getPort("BaseVdomPort").binding.portType.addOperation(install_application);}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid
		 * @return Asynchronous token
		 */
		public function get_echo(sid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_echo");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey
		 * @return Asynchronous token
		 */
		public function create_guid(sid:String,skey:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("create_guid");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid
		 * @return Asynchronous token
		 */
		public function delete_object(sid:String,skey:String,appid:String,objid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("delete_object");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid
		 * @return Asynchronous token
		 */
		public function get_top_objects(sid:String,skey:String,appid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_top_objects");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid
		 * @return Asynchronous token
		 */
		public function whole_delete(sid:String,skey:String,appid:String,objid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("whole_delete");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param pattern
		 * @return Asynchronous token
		 */
		public function search(sid:String,skey:String,appid:String,pattern:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["pattern"] = pattern;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("search");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey
		 * @return Asynchronous token
		 */
		public function keep_alive(sid:String,skey:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("keep_alive");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid
		 * @return Asynchronous token
		 */
		public function close_session(sid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("close_session");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param name* @param pwd_md5
		 * @return Asynchronous token
		 */
		public function open_session(name:String,pwd_md5:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["name"] = name;
	            out["pwd_md5"] = pwd_md5;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("open_session");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param typeid
		 * @return Asynchronous token
		 */
		public function get_type(sid:String,skey:String,typeid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["typeid"] = typeid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_type");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param evdata
		 * @return Asynchronous token
		 */
		public function send_event(sid:String,skey:String,evdata:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["evdata"] = evdata;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("send_event");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param attr
		 * @return Asynchronous token
		 */
		public function set_application_info(sid:String,skey:String,appid:String,attr:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["attr"] = attr;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_application_info");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey
		 * @return Asynchronous token
		 */
		public function list_applications(sid:String,skey:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("list_applications");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid
		 * @return Asynchronous token
		 */
		public function export_application(sid:String,skey:String,appid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("export_application");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param dbid* @param sql* @param script
		 * @return Asynchronous token
		 */
		public function execute_sql(sid:String,skey:String,appid:String,dbid:String,sql:String,script:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["dbid"] = dbid;
	            out["sql"] = sql;
	            out["script"] = script;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("execute_sql");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param attr
		 * @return Asynchronous token
		 */
		public function create_application(sid:String,skey:String,attr:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["attr"] = attr;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("create_application");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param pres
		 * @return Asynchronous token
		 */
		public function submit_object_script_presentation(sid:String,skey:String,appid:String,objid:String,pres:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["pres"] = pres;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("submit_object_script_presentation");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param parentid* @param name* @param data
		 * @return Asynchronous token
		 */
		public function whole_create(sid:String,skey:String,appid:String,parentid:String,name:String,data:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["parentid"] = parentid;
	            out["name"] = name;
	            out["data"] = data;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("whole_create");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param func_name* @param xml_param
		 * @return Asynchronous token
		 */
		public function remote_method_call(sid:String,skey:String,appid:String,objid:String,func_name:String,xml_param:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["func_name"] = func_name;
	            out["xml_param"] = xml_param;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("remote_method_call");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid
		 * @return Asynchronous token
		 */
		public function get_application_structure(sid:String,skey:String,appid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_application_structure");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param resid* @param width* @param height
		 * @return Asynchronous token
		 */
		public function get_thumbnail(sid:String,skey:String,appid:String,resid:String,width:String,height:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["resid"] = resid;
	            out["width"] = width;
	            out["height"] = height;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_thumbnail");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid
		 * @return Asynchronous token
		 */
		public function get_application_language_data(sid:String,skey:String,appid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_application_language_data");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param struct
		 * @return Asynchronous token
		 */
		public function set_application_structure(sid:String,skey:String,appid:String,struct:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["struct"] = struct;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_application_structure");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid
		 * @return Asynchronous token
		 */
		public function get_one_object(sid:String,skey:String,appid:String,objid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_one_object");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param name
		 * @return Asynchronous token
		 */
		public function set_name(sid:String,skey:String,appid:String,objid:String,name:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["name"] = name;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_name");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param sourceid
		 * @return Asynchronous token
		 */
		public function whole_create_page(sid:String,skey:String,appid:String,sourceid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["sourceid"] = sourceid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("whole_create_page");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey
		 * @return Asynchronous token
		 */
		public function list_types(sid:String,skey:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("list_types");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param parentid* @param typeid* @param name* @param attr
		 * @return Asynchronous token
		 */
		public function create_object(sid:String,skey:String,appid:String,parentid:String,typeid:String,name:String,attr:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["parentid"] = parentid;
	            out["typeid"] = typeid;
	            out["name"] = name;
	            out["attr"] = attr;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("create_object");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param parentid* @param dynamic
		 * @return Asynchronous token
		 */
		public function render_wysiwyg(sid:String,skey:String,appid:String,objid:String,parentid:String,_dynamic:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["parentid"] = parentid;
	            out["dynamic"] = _dynamic;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("render_wysiwyg");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param attr
		 * @return Asynchronous token
		 */
		public function set_attributes(sid:String,skey:String,appid:String,objid:String,attr:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["attr"] = attr;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_attributes");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param script* @param lang
		 * @return Asynchronous token
		 */
		public function set_script(sid:String,skey:String,appid:String,objid:String,script:String,lang:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["script"] = script;
	            out["lang"] = lang;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_script");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid
		 * @return Asynchronous token
		 */
		public function get_application_info(sid:String,skey:String,appid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_application_info");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param lang
		 * @return Asynchronous token
		 */
		public function get_script(sid:String,skey:String,appid:String,objid:String,lang:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["lang"] = lang;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_script");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid
		 * @return Asynchronous token
		 */
		public function get_child_objects_tree(sid:String,skey:String,appid:String,objid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_child_objects_tree");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param resid* @param attrname* @param operation* @param attr
		 * @return Asynchronous token
		 */
		public function modify_resource(sid:String,skey:String,appid:String,objid:String,resid:String,attrname:String,operation:String,attr:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["resid"] = resid;
	            out["attrname"] = attrname;
	            out["operation"] = operation;
	            out["attr"] = attr;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("modify_resource");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid
		 * @return Asynchronous token
		 */
		public function get_child_objects(sid:String,skey:String,appid:String,objid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_child_objects");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param ownerid* @param resid
		 * @return Asynchronous token
		 */
		public function get_resource(sid:String,skey:String,ownerid:String,resid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["ownerid"] = ownerid;
	            out["resid"] = resid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_resource");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid
		 * @return Asynchronous token
		 */
		public function get_code_interface_data(sid:String,skey:String,appid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_code_interface_data");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid
		 * @return Asynchronous token
		 */
		public function get_application_events(sid:String,skey:String,appid:String,objid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_application_events");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 
		 * @return Asynchronous token
		 */
		public function about():AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("about");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param restype* @param resname* @param resdata
		 * @return Asynchronous token
		 */
		public function set_resource(sid:String,skey:String,appid:String,restype:String,resname:String,resdata:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["restype"] = restype;
	            out["resname"] = resname;
	            out["resdata"] = resdata;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_resource");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param events
		 * @return Asynchronous token
		 */
		public function set_application_events(sid:String,skey:String,appid:String,objid:String,events:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["events"] = events;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_application_events");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param ownerid
		 * @return Asynchronous token
		 */
		public function list_resources(sid:String,skey:String,ownerid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["ownerid"] = ownerid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("list_resources");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey
		 * @return Asynchronous token
		 */
		public function get_all_types(sid:String,skey:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_all_types");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param attr* @param value
		 * @return Asynchronous token
		 */
		public function set_attribute(sid:String,skey:String,appid:String,objid:String,attr:String,value:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["attr"] = attr;
	            out["value"] = value;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("set_attribute");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid* @param data
		 * @return Asynchronous token
		 */
		public function whole_update(sid:String,skey:String,appid:String,objid:String,data:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            out["data"] = data;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("whole_update");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param appid* @param objid
		 * @return Asynchronous token
		 */
		public function get_object_script_presentation(sid:String,skey:String,appid:String,objid:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["appid"] = appid;
	            out["objid"] = objid;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("get_object_script_presentation");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param sid* @param skey* @param vhname* @param appxml
		 * @return Asynchronous token
		 */
		public function install_application(sid:String,skey:String,vhname:String,appxml:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["sid"] = sid;
	            out["skey"] = skey;
	            out["vhname"] = vhname;
	            out["appxml"] = appxml;
	            currentOperation = BaseVdomService.getPort("BaseVdomPort").binding.portType.getOperation("install_application");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
        /**
         * Performs the actual call to the remove server
         * It SOAP-encodes the message using the schema and WSDL operation options set above and then calls the server using 
         * an async invoker
         * It also registers internal event handlers for the result / fault cases
         * @private
         */
        private function call(operation:WSDLOperation,args:Object,token:AsyncToken,headers:Array=null):void
        {
	    	var enc:SOAPEncoder = new SOAPEncoder();
	        var soap:Object = new Object;
	        var message:SOAPMessage = new SOAPMessage();
	        enc.wsdlOperation = operation;
	        soap = enc.encodeRequest(args,headers);
	        message.setSOAPAction(operation.soapAction);
	        message.body = soap.toString();
	        message.url=endpointURI;
            var inv:AsyncRequest = new AsyncRequest();
            inv.destination = super.destination;
            //we need this to handle multiple asynchronous calls 
            var wrappedData:Object = new Object();
            wrappedData.operation = currentOperation;
            wrappedData.returnToken = token;
            if(!this.useProxy)
            {
            	var dcs:ChannelSet = new ChannelSet();	
	        	dcs.addChannel(new DirectHTTPChannel("direct_http_channel"));
            	inv.channelSet = dcs;
            }                
            var processRes:AsyncResponder = new AsyncResponder(processResult,faultResult,wrappedData);
            inv.invoke(message,processRes);
		}
        
        /**
         * Internal event handler to process a successful operation call from the server
         * The result is decoded using the schema and operation settings and then the events get passed on to the actual facade that the user employs in the application 
         * @private
         */
		private function processResult(result:Object,wrappedData:Object):void
           {
           		var headers:Object;
           		var token:AsyncToken = wrappedData.returnToken;
                var currentOperation:WSDLOperation = wrappedData.operation;
                var decoder:SOAPDecoder = new SOAPDecoder();
                decoder.resultFormat = "object";
                decoder.headerFormat = "object";
                decoder.multiplePartsFormat = "object";
                decoder.ignoreWhitespace = true;
                decoder.makeObjectsBindable=false;
                decoder.wsdlOperation = currentOperation;
                decoder.schemaManager = currentOperation.schemaManager;
                var body:Object = result.message.body;
                var stringResult:String = String(body);
                if(stringResult == null  || stringResult == "")
                	return;
                var soapResult:SOAPResult = decoder.decodeResponse(result.message.body);
                if(soapResult.isFault)
                {
	                var faults:Array = soapResult.result as Array;
	                for each (var soapFault:Fault in faults)
	                {
		                var soapFaultEvent:FaultEvent = FaultEvent.createEvent(soapFault,token,null);
		                token.dispatchEvent(soapFaultEvent);
	                }
                } else {
	                result = soapResult.result;
	                headers = soapResult.headers;
	                var event:ResultEvent = ResultEvent.createEvent(result,token,null);
	                event.headers = headers;
	                token.dispatchEvent(event);
                }
           }
           	/**
           	 * Handles the cases when there are errors calling the operation on the server
           	 * This is not the case for SOAP faults, which is handled by the SOAP decoder in the result handler
           	 * but more critical errors, like network outage or the impossibility to connect to the server
           	 * The fault is dispatched upwards to the facade so that the user can do something meaningful 
           	 * @private
           	 */
			private function faultResult(error:MessageFaultEvent,token:Object):void
			{
				//when there is a network error the token is actually the wrappedData object from above	
				if(!(token is AsyncToken))
					token = token.returnToken;
				token.dispatchEvent(new FaultEvent(FaultEvent.FAULT,true,true,new Fault(error.faultCode,error.faultString,error.faultDetail)));
			}
		}
	}

	import mx.rpc.AsyncToken;
	import mx.rpc.AsyncResponder;
	import mx.rpc.wsdl.WSDLBinding;
                
    /**
     * Internal class to handle multiple operation call scheduling
     * It allows us to pass data about the operation being encoded / decoded to and from the SOAP encoder / decoder units. 
     * @private
     */
    class PendingCall
    {
		public var args:*;
		public var headers:Array;
		public var token:AsyncToken;
		
		public function PendingCall(args:Object, headers:Array=null)
		{
			this.args = args;
			this.headers = headers;
			this.token = new AsyncToken(null);
		}
	}