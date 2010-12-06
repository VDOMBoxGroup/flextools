/*
	Class ObjectProxy is a wrapper over the ObjectModel
 */
package net.vdombox.object_editor.model.proxy1
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    /**
     * A proxy for the Employee data
     */
    public class ObjectProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "ObjectProxy";

		public function ObjectProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}