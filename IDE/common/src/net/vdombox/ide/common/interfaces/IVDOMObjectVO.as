package net.vdombox.ide.common.interfaces
{
	import net.vdombox.ide.common.model._vo.TypeVO;


	public interface IVDOMObjectVO
	{
		function get id() : String;

		function get typeVO() : TypeVO;

		function get name() : String;

		function set name( value : String ) : void;

		function setID( value : String ) : void;

		function setXMLDescription( description : XML ) : void;
	}
}
