/*
	Class SourceCodeProxy is a wrapper over the SourceCode
 */
package net.vdombox.object_editor.model.proxy1
{
	import mx.rpc.IResponder;
	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class SourceCodeProxy extends Proxy implements IProxy, IResponder
    {
		public static const NAME:String = "SourceCodeProxy";

		public function SourceCodeProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}