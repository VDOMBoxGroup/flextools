/*
Class OETextInputProxy is a wrapper over the OETextInput
*/
package net.vdombox.object_editor.model.Proxy
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class OETextInputProxy extends Proxy implements IProxy, IResponder
	{
		public static const NAME:String = "OETextInputProxy";
		
		public function OETextInputProxy ( data:Object = null ) 
		{
			super ( NAME, data );
		}
	}
}