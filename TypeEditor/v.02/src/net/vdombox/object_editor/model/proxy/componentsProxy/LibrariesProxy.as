/*
	Class LibrariesProxy is a wrapper over the Libraries
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class LibrariesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "LibrariesProxy";

		public function LibrariesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}