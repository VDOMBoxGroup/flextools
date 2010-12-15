/*
	Class AtributesProxy is a wrapper over the Atributes
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class AttributesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "AttributesProxy";

		public function AttributesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}