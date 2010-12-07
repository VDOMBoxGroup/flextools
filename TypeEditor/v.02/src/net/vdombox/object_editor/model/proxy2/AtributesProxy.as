/*
	Class AtributesProxy is a wrapper over the Atributes
 */
package net.vdombox.object_editor.model.proxy2
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class AtributesProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "AtributesProxy";

		public function AtributesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}