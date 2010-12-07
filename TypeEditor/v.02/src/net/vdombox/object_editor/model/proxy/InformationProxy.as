/*
	Class InformationProxy is a wrapper over the Information
 */
package net.vdombox.object_editor.model.proxy
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class InformationProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "InformationProxy";

		public function InformationProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}