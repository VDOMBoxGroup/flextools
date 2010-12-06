/*
	Class LanguageProxy is a wrapper over the Language
 */
package net.vdombox.object_editor.model.proxy1
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class LanguageProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "LanguageProxy";

		public function LanguageProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}