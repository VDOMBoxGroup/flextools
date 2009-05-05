package net.vdombox.ide.interfaces
{
	import org.puremvc.as3.multicore.interfaces.IProxy;

	public interface IPageProxy extends IProxy
	{
		function get id() : String;
		function get structure() : XML;
		function get selectedObject() : ObjectVO;
		function get selectedObjectID() : String;
//		function get pagesList() : IPageVO; ???

		function createObject( objectID : String ) : ObjectVO;
		function deleteObject( objectVO : ObjectVO ) : void;
		function deleteObjectAt( objectID : String ) : void;
		function getObjectAt( objectID : String ) : ObjectVO;
		function getObjectProxie( objectVO : ObjectVO );
		function getObjectProxieAt( objectID : String );
	}
}