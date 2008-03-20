package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetChildObjectsTree extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetChildObjectsTree(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String):void
		{
			// protect
			ws.get_child_objects_tree.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_child_objects_tree.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.get_child_objects_tree.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.get_child_objects_tree.arguments.objid  	= objid;		//- идентификатор объекта 
			
			//send data & set listener 
			ws.get_child_objects_tree();
			ws.get_child_objects_tree.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = <Result>{XMLList(event.result)}</Result>;
			resultXML = resultXML.Object[0];
			
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_CHILD_OBJECTS_TREE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_CHILD_OBJECTS_TREE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}