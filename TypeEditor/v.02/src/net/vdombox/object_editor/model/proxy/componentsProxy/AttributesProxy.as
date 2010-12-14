/*
	Class AtributesProxy is a wrapper over the Atributes
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class AttributesProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "AtributesProxy";

		public function AttributesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}