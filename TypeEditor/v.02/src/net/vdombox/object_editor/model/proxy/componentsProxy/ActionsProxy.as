/*
	Class ActionsProxy is a wrapper over the Actions
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class ActionsProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "ActionsProxy";

		public function ActionsProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}