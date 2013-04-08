package vdom.components.treeEditor
{
	import vdom.connection.soap.Soap;
	import vdom.connection.soap.SoapEvent;
	import mx.controls.Alert;
	
	public class TreeEditorSoap
	{
		private var soap:Soap;
		private var structure:XML;
		private var fun:Function;
		
		public function TreeEditorSoap():void
		{
			soap = Soap.getInstance();	
		}
		
		public function getApplicationStructure(applicationId:String, soapListenner:Function):void
		{
			this.fun = soapListenner;
			
			soap.getApplicationStructure(applicationId);
		
			soap.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_OK, getApplicationStructureOK);
			soap.addEventListener(SoapEvent.GET_APPLICATION_STRUCTURE_ERROR, soapErrorListenner);
		}
		
		private function getApplicationStructureOK(soapEvt:SoapEvent):void
		{
			fun(soapEvt)//  soapEvt.result;
		}
		
		private function soapErrorListenner(soapEvt:SoapEvent):void
		{
			Alert.show(soapEvt.result, 'Title');
		}

	}
}